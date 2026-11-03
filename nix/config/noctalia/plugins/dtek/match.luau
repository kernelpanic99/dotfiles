-- vim: ft=lua

local M = {}

local HOMOGLYPHS = {
  a = 'а',
  b = 'в',
  c = 'с',
  e = 'е',
  h = 'н',
  i = 'і',
  k = 'к',
  m = 'м',
  o = 'о',
  p = 'р',
  t = 'т',
  x = 'х',
  y = 'у',
}

local SKIP = { [0x09] = true, [0x0A] = true, [0x0D] = true, [0x20] = true, [0x2E] = true, [0xA0] = true }
local DASHES = { [0x2D] = true, [0x2013] = true, [0x2014] = true }

local function lower(cp)
  if (cp >= 0x41 and cp <= 0x5A) or (cp >= 0x410 and cp <= 0x42F) then
    return cp + 32
  end

  if cp >= 0x400 and cp <= 0x40F then
    return cp + 80
  end

  if cp == 0x490 then
    return 0x491
  end

  return cp
end

function M.normalize(value)
  local out = {}

  for _, cp in utf8.codes(tostring(value)) do
    cp = lower(cp)

    if DASHES[cp] then
      table.insert(out, '/')
    elseif not SKIP[cp] then
      local ch = utf8.char(cp)
      table.insert(out, HOMOGLYPHS[ch] or ch)
    end
  end

  return (table.concat(out):gsub('/+', '/'))
end

function M.loosen(value)
  return (M.normalize(value):gsub('/', ''))
end

local function filter(list, pred)
  local result = {}

  for _, item in ipairs(list) do
    if pred(item) then
      table.insert(result, item)
    end
  end

  return result
end

local function take(list, limit)
  local result = {}

  for i = 1, math.min(#list, limit) do
    result[i] = list[i]
  end

  return result
end

local function contains(haystack, needle)
  return haystack:find(needle, 1, true) ~= nil
end

-- Returns the matched item, or nil plus a list of candidates
function M.resolve(list, query)
  if table.find(list, query) then
    return query
  end

  local target = M.normalize(query)

  local folded = filter(list, function(item)
    return M.normalize(item) == target
  end)

  if #folded == 1 then
    return folded[1]
  end

  local partial = folded

  if #partial == 0 then
    partial = filter(list, function(item)
      return contains(M.normalize(item), target)
    end)
  end

  if #partial == 1 then
    return partial[1]
  end

  return nil, take(partial, 20)
end

local function sortedKeys(map)
  local keys = {}

  for key in pairs(map) do
    table.insert(keys, key)
  end

  table.sort(keys, function(a, b)
    local na, nb = tonumber(a:match('^%d+')), tonumber(b:match('^%d+'))

    if na and nb and na ~= nb then
      return na < nb
    end

    return a < b
  end)

  return keys
end

-- Returns the house key, or nil plus a list of candidates
function M.pickHouse(data, wanted)
  local keys = sortedKeys(data)

  if #keys == 1 and keys[1] == '-' then
    return '-'
  end

  if wanted == '' then
    return nil, take(keys, 40)
  end

  if data[wanted] then
    return wanted
  end

  for _, fold in ipairs({ M.normalize, M.loosen }) do
    local target = fold(wanted)

    for _, key in ipairs(keys) do
      if fold(key) == target then
        return key
      end
    end
  end

  local target = M.normalize(wanted)

  local partial = filter(keys, function(key)
    return contains(M.normalize(key), target)
  end)

  if #partial == 0 then
    partial = keys
  end

  return nil, take(partial, 40)
end

return M
