-- vim: ft=lua

local M = {}

function M.num(value)
  return type(value) == 'number' and value or 0
end

function M.watts(value)
  return `{math.floor(M.num(value) + 0.5)} W`
end

function M.percent(value)
  return `{math.floor(M.num(value) + 0.5)}%`
end

function M.charging(v)
  return M.num(v.battery_input_power) > 0
end

function M.isStale(data)
  local s = data.status

  if not s or not s.updated then
    return true
  end

  return os.time() - s.updated > math.max(3 * (data.interval or 60), 180)
end

function M.duration(minutes)
  local m = math.floor(minutes + 0.5)

  if m < 60 then
    return `{m}m`
  end

  local h = m // 60

  if h < 48 then
    local rest = m % 60

    return rest > 0 and `{h}h {rest}m` or `{h}h`
  end

  return `{h // 24}d {h % 24}h`
end

function M.shortDuration(minutes)
  local m = math.floor(minutes + 0.5)

  if m < 60 then
    return `{m}m`
  end

  local h = m // 60

  if h < 10 then
    local rest = m % 60

    return rest > 0 and string.format('%dh%02d', h, rest) or `{h}h`
  elseif h < 48 then
    return `{math.floor(m / 60 + 0.5)}h`
  end

  return `{math.floor(h / 24 + 0.5)}d`
end

function M.etaMinutes(v)
  if M.charging(v) and M.num(v.battery_level) < 100 and M.num(v.remaining_time_charging) > 0 then
    return 'full', v.remaining_time_charging
  end

  if M.num(v.battery_output_power) >= 1 and M.num(v.remaining_time_discharging) > 0 then
    return 'empty', v.remaining_time_discharging
  end

  return nil, nil
end

function M.eta(v)
  local kind, minutes = M.etaMinutes(v)

  return kind and noctalia.tr('eta.' .. kind, { time = M.duration(minutes) }) or nil
end

function M.shortEta(v)
  local _, minutes = M.etaMinutes(v)

  return minutes and M.shortDuration(minutes) or nil
end

function M.batteryGlyph(v)
  return M.charging(v) and 'battery-automotive-filled' or 'battery-automotive'
end

function M.levelColor(v)
  local level = M.num(v.battery_level)

  if level <= 15 then
    return 'error'
  elseif level <= 35 then
    return 'tertiary'
  end

  return 'on_surface'
end

function M.time(ts)
  return os.date('%H:%M', ts)
end

return M
