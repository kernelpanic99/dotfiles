-- vim: ft=lua

local M = {}

M.SLOT = 1800

local function parseStamp(s)
  if type(s) ~= 'string' then
    return nil
  end

  local h, m, D, M_, Y = s:match('(%d%d):(%d%d) (%d%d)%.(%d%d)%.(%d%d%d%d)')

  if not h then
    return nil
  end

  -- Luau's os.time reads the table as UTC, shift it back by the local offset
  local t = os.time({ year = Y + 0, month = M_ + 0, day = D + 0, hour = h + 0, min = m + 0, sec = 0 })

  return t - (os.time(os.date('*t', t)) - t)
end

function M.fmtTime(t)
  return os.date('%H:%M', t)
end

function M.fmtDay(t)
  return os.date('%d.%m', t)
end

function M.queueNames(schedule)
  local names = {}

  for _, queue in ipairs(schedule.queues) do
    table.insert(names, queue.name)
  end

  return table.concat(names, ', ')
end

local function timeline(schedule, queue)
  local points = {}

  for _, day in ipairs(schedule.days) do
    local slots = day.slots[queue]

    if slots then
      for i, state in ipairs(slots) do
        table.insert(points, { t = day.ts + (i - 1) * M.SLOT, state = state })
      end
    end
  end

  return points
end

-- Current state of the first queue: { state, change?, nextOff? }
function M.status(schedule, now)
  local queue = schedule.queues[1]

  if not queue then
    return { state = 'unknown' }
  end

  local outage = schedule.outage

  if outage then
    local start, finish = parseStamp(outage.start), parseStamp(outage.finish)

    if start and finish and now >= start and now < finish then
      return { state = 'off', change = finish }
    end
  end

  local points = timeline(schedule, queue.id)

  for i, point in ipairs(points) do
    if now >= point.t and now < point.t + M.SLOT then
      local result = { state = point.state }

      for j = i + 1, #points do
        local next = points[j]

        if not result.change and next.state ~= point.state then
          result.change = next.t
        end

        if not result.nextOff and point.state ~= 'off' and next.state == 'off' then
          result.nextOff = next.t
        end

        if result.change and (result.nextOff or point.state == 'off') then
          break
        end
      end

      return result
    end
  end

  return { state = 'unknown' }
end

-- Runs of `wanted` within one day, formatted as "HH:MM-HH:MM"
function M.ranges(slots, dayTs, wanted)
  local ranges = {}
  local from

  for i = 1, #slots + 1 do
    local hit = slots[i] == wanted

    if hit and not from then
      from = i
    elseif not hit and from then
      local a = dayTs + (from - 1) * M.SLOT
      local b = dayTs + (i - 1) * M.SLOT
      table.insert(ranges, M.fmtTime(a) .. '-' .. M.fmtTime(b))
      from = nil
    end
  end

  return ranges
end

return M
