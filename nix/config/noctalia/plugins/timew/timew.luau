-- vim: ft=lua

local update_interval = barWidget.getConfig('update_interval')

noctalia.setUpdateInterval(update_interval * 1000)

local function parseISO8601(s)
  local Y, M, D, h, m, sec = s:match('(%d%d%d%d)(%d%d)(%d%d)T(%d%d)(%d%d)(%d%d)Z')

  return os.time({ year = Y + 0, month = M + 0, day = D + 0, hour = h + 0, min = m + 0, sec = sec + 0 })
end

local function fmtDur(seconds, with_secs)
  local h = math.floor(seconds / 3600)
  local m = math.floor((seconds % 3600) / 60)

  if with_secs then
    return string.format('%d:%02d:%02d', h, m, math.floor(seconds % 60))
  end

  return string.format('%d:%02d', h, m)
end

local Timew = {}
Timew.__index = Timew

function Timew.new(records)
  local self = setmetatable({}, Timew)
  self.records = records
  return self
end

function Timew:render()
  local active = self:get_active()

  if not active then
    return '--/--'
  end

  local filtered = self:filter_by_tags(active.tags)
  local total = self:total()
  local total_active = self:total(filtered)

  return self:format(active.tags[#active.tags], total_active, total)
end

function Timew:format(tag, total_active, total)
  return tag .. ' ' .. fmtDur(total_active, true) .. '/' .. fmtDur(total, false)
end

function Timew:total(records)
  records = records or self.records
  local total = 0

  for _, record in ipairs(records) do
    local start = parseISO8601(record.start)

    local done = os.time()

    if record['end'] ~= nil then
      done = parseISO8601(record['end'])
    end

    total = total + (done - start)
  end

  return total
end

function Timew:filter_by_tags(tags)
  local result = {}

  for _, record in ipairs(self.records) do
    if #record.tags == #tags then
      local match = true

      -- Timew sorts tags
      for i, tag in ipairs(record.tags) do
        if tag ~= tags[i] then
          match = false
          break
        end
      end

      if match then
        table.insert(result, record)
      end
    end
  end

  return result
end

function Timew:get_active()
  for _, val in pairs(self.records) do
    if val['end'] == nil then
      return val
    end
  end

  return self.records[#self.records]
end

function update()
  noctalia.runAsync('timew export :today', function(res)
    if res.stderr ~= '' then
      error('Timew command failed:' .. res.stderr)
    end

    local res, err = noctalia.json.decode(res.stdout)

    if err then
      error('Failed to decode timew json output: ' .. err)
    end

    local timew = Timew.new(res)

    barWidget.setText(timew:render())
  end)
end

function onClick()
  noctalia.runAsync('timew continue', function(res)
    if res.exitCode == 255 then -- Tracking is already running attempt to stop
      noctalia.runAsync('timew stop', function(res)
        if res.exitCode == 0 then
          noctalia.notify(noctalia.tr('notifications.tracking.stopped'))
        else
          noctalia.notifyError(noctalia.tr('notifications.tracking.stop_failed'))
          error('Failed to stop timew tracking: ' .. res.stderr)
        end
      end)
    elseif res.exitCode == 0 then
      noctalia.notify(noctalia.tr('notifications.tracking.resumed'))
    else
      noctalia.notifyError(noctalia.tr('notifications.tracking.resume_failed'))
      error('Failed to resume timew tracking: ' .. res.stderr)
    end
  end)
end
