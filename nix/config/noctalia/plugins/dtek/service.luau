-- vim: ft=lua

local match = require('./match.luau')

local BASE = 'https://www.dtek-oem.com.ua'
local PAGE = BASE .. '/ua/shutdowns'
local AJAX = BASE .. '/ua/ajax'
local UA = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'

-- Prints the csrf token on the first line, then one city per line
local EXTRACT_PAGE = [[
grep -o 'name="csrf-token" content="[^"]*"' "$1" | head -n 1 | sed 's/.*content="//; s/"$//'
grep -m 1 'DisconSchedule.streets = ' "$1" | grep -o '"[^"]*":\[' | sed 's/^"//; s/":\[$//'
]]

-- Writes the JSON array of streets for city $2 into $3
local EXTRACT_STREETS = [[
grep -m 1 'DisconSchedule.streets = ' "$1" | K="\"$2\":[" awk '{
  i = index($0, ENVIRON["K"])
  if (i) { s = substr($0, i + length(ENVIRON["K"])); print "[" substr(s, 1, index(s, "]")) }
}' > "$3"
]]

local STALE_UPDATE = '01.01.2020 00:00'
local TIMEOUT_MS = 30000
local MIN_REFRESH_GAP_S = 20

local HALVES = {
  yes = { 'on', 'on' },
  no = { 'off', 'off' },
  maybe = { 'maybe', 'maybe' },
  first = { 'off', 'on' },
  second = { 'on', 'off' },
  mfirst = { 'maybe', 'on' },
  msecond = { 'on', 'maybe' },
}

local dataDir = noctalia.pluginDataDir()
local jarFile = dataDir .. '/cookies.txt'
local pageFile = dataDir .. '/page.html'
local streetsFile = dataDir .. '/streets.json'
local answerFile = dataDir .. '/answer.json'
local cacheFile = dataDir .. '/schedule.json'

local busy = false
local lastFetch = 0
local lastGood

local cached = noctalia.readFile(cacheFile)

if cached then
  lastGood = noctalia.json.decode(cached)
end

local function str(value)
  return type(value) == 'string' and value or ''
end

local function truthy(value)
  return value == true or (type(value) == 'number' and value ~= 0) or (type(value) == 'string' and value ~= '')
end

local function publish(err)
  noctalia.state.set('dtek', { schedule = lastGood, error = err, loading = busy })
end

local function fail(message, candidates)
  busy = false
  publish({ message = message, candidates = candidates })
end

local function curl(args, cb)
  local argv = { 'curl', '-sS', '--fail', '--compressed', '--max-time', '25', '-A', UA }

  for _, arg in ipairs(args) do
    table.insert(argv, arg)
  end

  local started = noctalia.runAsync(argv, function(res)
    if res.exitCode ~= 0 then
      fail(noctalia.tr('errors.network', { detail = noctalia.string.trim(res.stderr) }))
      return
    end

    cb()
  end, TIMEOUT_MS)

  if not started then
    fail(noctalia.tr('errors.network', { detail = 'curl' }))
  end
end

local function sh(script, args, cb)
  local argv = { 'sh', '-c', script, 'sh' }

  for _, arg in ipairs(args) do
    table.insert(argv, arg)
  end

  local started = noctalia.runAsync(argv, function(res)
    if res.exitCode ~= 0 then
      fail(noctalia.tr('errors.layout'))
      return
    end

    cb(res.stdout)
  end, TIMEOUT_MS)

  if not started then
    fail(noctalia.tr('errors.layout'))
  end
end

local function halves(hours)
  local slots = {}

  for h = 1, 24 do
    local pair = HALVES[hours[tostring(h)]] or { 'unknown', 'unknown' }
    table.insert(slots, pair[1])
    table.insert(slots, pair[2])
  end

  return slots
end

local function buildSchedule(answer, city, street, houseKey)
  local entry = answer.data[houseKey]
  local preset = type(answer.preset) == 'table' and answer.preset or {}
  local names = type(preset.sch_names) == 'table' and preset.sch_names or {}
  local fact = type(answer.fact) == 'table' and answer.fact or nil
  local queueIds = type(entry.sub_type_reason) == 'table' and entry.sub_type_reason or {}

  local schedule = {
    city = city,
    street = street,
    house = houseKey,
    queues = {},
    days = {},
    updated = str(answer.updateTimestamp),
    factUpdate = fact and str(fact.update) or '',
  }

  for _, id in ipairs(queueIds) do
    table.insert(schedule.queues, { id = id, name = names[id] or id })
  end

  if truthy(answer.showCurOutageParam) and (str(entry.sub_type) ~= '' or str(entry.start_date) ~= '' or str(entry.end_date) ~= '') then
    schedule.outage = {
      reason = str(entry.type) == '1' and noctalia.tr('outage.planned') or str(entry.sub_type),
      start = str(entry.start_date),
      finish = str(entry.end_date),
      voluntarily = truthy(entry.voluntarily),
    }
  end

  if truthy(answer.showTableFact) and fact and type(fact.data) == 'table' then
    local dayKeys = {}

    for key in pairs(fact.data) do
      table.insert(dayKeys, key)
    end

    table.sort(dayKeys, function(a, b)
      return tonumber(a) < tonumber(b)
    end)

    for _, key in ipairs(dayKeys) do
      local day = { ts = tonumber(key), slots = {} }

      for _, id in ipairs(queueIds) do
        if type(fact.data[key][id]) == 'table' then
          day.slots[id] = halves(fact.data[key][id])
        end
      end

      table.insert(schedule.days, day)
    end
  end

  return schedule
end

local function onAnswer(city, street)
  noctalia.readFileAsync(answerFile, function(text, err)
    if not text then
      fail(noctalia.tr('errors.read', { detail = err or '' }))
      return
    end

    if noctalia.string.trim(text):sub(1, 1) == '<' then
      fail(noctalia.tr('errors.waf'))
      return
    end

    local answer, decodeErr = noctalia.json.decode(text)

    if not answer then
      fail(noctalia.tr('errors.json', { detail = decodeErr or '' }))
      return
    end

    if not truthy(answer.result) then
      fail(noctalia.tr('errors.rejected', { detail = str(answer.text) }))
      return
    end

    local houseKey, candidates = match.pickHouse(answer.data, noctalia.string.trim(noctalia.getConfig('house') or ''))

    if not houseKey then
      fail(noctalia.tr('errors.house'), candidates)
      return
    end

    lastGood = buildSchedule(answer, city, street, houseKey)
    lastGood.fetchedAt = os.time()
    busy = false

    noctalia.writeFile(cacheFile, noctalia.json.encode(lastGood))
    publish(nil)
  end)
end

local function requestAnswer(token, city, street)
  curl({
    '-b',
    jarFile,
    '-c',
    jarFile,
    '-e',
    PAGE,
    '-H',
    'X-CSRF-Token: ' .. token,
    '-H',
    'X-Requested-With: XMLHttpRequest',
    '--data-urlencode',
    'method=getHomeNum',
    '--data-urlencode',
    'data[0][name]=city',
    '--data-urlencode',
    'data[0][value]=' .. city,
    '--data-urlencode',
    'data[1][name]=street',
    '--data-urlencode',
    'data[1][value]=' .. street,
    '--data-urlencode',
    'data[2][name]=updateFact',
    '--data-urlencode',
    'data[2][value]=' .. STALE_UPDATE,
    '-o',
    answerFile,
    AJAX,
  }, function()
    onAnswer(city, street)
  end)
end

local function onStreets(token, city)
  noctalia.readFileAsync(streetsFile, function(text, err)
    if not text then
      fail(noctalia.tr('errors.read', { detail = err or '' }))
      return
    end

    local streets = noctalia.json.decode(text)

    if type(streets) ~= 'table' then
      fail(noctalia.tr('errors.layout'))
      return
    end

    local streetList = {}

    for _, name in ipairs(streets) do
      if name ~= '' then
        table.insert(streetList, name)
      end
    end

    if #streetList == 0 then
      requestAnswer(token, city, '')
      return
    end

    local street, candidates = match.resolve(streetList, noctalia.string.trim(noctalia.getConfig('street') or ''))

    if not street then
      fail(noctalia.tr('errors.street'), candidates)
      return
    end

    requestAnswer(token, city, street)
  end)
end

local function onPage(stdout)
  local lines = {}

  for line in stdout:gmatch('[^\n]+') do
    table.insert(lines, line)
  end

  local token = table.remove(lines, 1)

  if not token or #lines == 0 then
    fail(noctalia.tr('errors.layout'))
    return
  end

  local city, candidates = match.resolve(lines, noctalia.string.trim(noctalia.getConfig('city') or ''))

  if not city then
    fail(noctalia.tr('errors.city'), candidates)
    return
  end

  sh(EXTRACT_STREETS, { pageFile, city, streetsFile }, function()
    onStreets(token, city)
  end)
end

local function fetch()
  if busy then
    return
  end

  if noctalia.string.trim(noctalia.getConfig('city') or '') == '' then
    publish({ message = noctalia.tr('errors.not_configured') })
    return
  end

  busy = true
  lastFetch = os.time()
  publish(nil)

  noctalia.removeFile(jarFile)
  curl({ '-c', jarFile, '-o', pageFile, PAGE }, function()
    sh(EXTRACT_PAGE, { pageFile }, onPage)
  end)
end

local function applyInterval()
  noctalia.setUpdateInterval((noctalia.getConfig('update_interval') or 15) * 60 * 1000)
end

applyInterval()
fetch()

noctalia.state.watch('refresh', function()
  if os.time() - lastFetch >= MIN_REFRESH_GAP_S then
    fetch()
  end
end)

function update()
  fetch()
end

function onConfigChanged()
  applyInterval()
  fetch()
end
