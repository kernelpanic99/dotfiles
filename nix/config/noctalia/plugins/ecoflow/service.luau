-- vim: ft=lua

local TIMEOUT_MS = 50000
local MIN_REFRESH_GAP_S = 10

local cacheFile = noctalia.pluginDataDir() .. '/state.json'

local busy = false
local pending
local lastRun = 0
local lastError
local lastGood

local cached = noctalia.readFile(cacheFile)

if cached then
  lastGood = noctalia.json.decode(cached)
end

local function interval()
  return noctalia.getConfig('update_interval') or 60
end

local function publish()
  noctalia.state.set('ecoflow', { status = lastGood, error = lastError, busy = busy, interval = interval() })
end

local function lastLine(text)
  local line = ''

  for l in text:gmatch('[^\n]+') do
    line = l
  end

  return noctalia.string.trim(line)
end

local run

local function onResult(res)
  busy = false

  if res.timedOut then
    lastError = { message = noctalia.tr('errors.timeout') }
  elseif res.exitCode ~= 0 then
    local detail = lastLine(res.stderr)
    lastError = { code = res.exitCode, message = detail ~= '' and detail or noctalia.tr('errors.exit', { code = res.exitCode }) }
  else
    local status, err = noctalia.json.decode(res.stdout)

    if type(status) == 'table' then
      lastGood = status
      lastError = nil
      noctalia.writeFile(cacheFile, res.stdout)
    else
      lastError = { message = noctalia.tr('errors.json', { detail = err or '' }) }
    end
  end

  publish()

  if pending then
    local argv = pending
    pending = nil
    run(argv)
  end
end

run = function(argv)
  if busy then
    if argv[2] == 'set' then
      pending = argv
    end

    return
  end

  busy = true
  lastRun = os.time()
  publish()

  if not noctalia.runAsync(argv, onResult, TIMEOUT_MS) then
    busy = false
    lastError = { message = noctalia.tr('errors.spawn') }
    publish()
  end
end

local function poll()
  run({ 'ecoflow', 'status' })
end

noctalia.setUpdateInterval(interval() * 1000)
publish()
poll()

noctalia.state.watch('refresh', function()
  if os.time() - lastRun >= MIN_REFRESH_GAP_S then
    poll()
  end
end)

noctalia.state.watch('command', function(cmd)
  if type(cmd) == 'table' and cmd.key then
    run({ 'ecoflow', 'set', cmd.key, cmd.on and 'on' or 'off' })
  end
end)

function update()
  poll()
end

function onConfigChanged()
  noctalia.setUpdateInterval(interval() * 1000)
  publish()
end
