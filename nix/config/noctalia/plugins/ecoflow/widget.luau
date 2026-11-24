-- vim: ft=lua

local fmt = require('./format.luau')

local PANEL = 'kernelpanic99/ecoflow:panel'

local data = noctalia.state.get('ecoflow') or {}

local function tooltip(s, stale)
  local v = s.values

  local eta = fmt.eta(v)

  local rows = {
    { key = s.model, value = fmt.percent(v.battery_level) },
    { key = noctalia.tr('power.input'), value = fmt.watts(v.input_power) },
    { key = noctalia.tr('power.output'), value = fmt.watts(v.output_power) },
  }

  if eta then
    table.insert(rows, { key = noctalia.tr('eta.title'), value = eta })
  end

  table.insert(rows, { key = noctalia.tr('updated'), value = fmt.time(s.updated) .. (stale and ` ({noctalia.tr('stale')})` or '') })

  if data.error then
    table.insert(rows, { key = noctalia.tr('error'), value = data.error.message })
  end

  return rows
end

local function render()
  local s = data.status

  if not s then
    barWidget.setGlyph(data.busy and 'loader-2' or 'battery-automotive')
    barWidget.setGlyphColor(data.error and 'error' or 'on_surface')
    barWidget.setText('')
    barWidget.setTooltip(data.error and data.error.message or noctalia.tr('loading'))
    return
  end

  local v = s.values
  local stale = fmt.isStale(data)
  local color = stale and 'on_surface_variant' or fmt.levelColor(v)
  local text = fmt.num(v.battery_level) > 0 and fmt.percent(v.battery_level) or '--'

  local eta = fmt.shortEta(v)

  if fmt.num(v.output_power) >= 1 then
    text = `{text} {fmt.watts(v.output_power)}`
  end

  if eta then
    text = `{text} ~{eta}`
  end

  barWidget.setGlyph(fmt.batteryGlyph(v))
  barWidget.setGlyphColor(color)
  barWidget.setColor(color)
  barWidget.setText(text)
  barWidget.setTooltip(tooltip(s, stale))
end

noctalia.state.watch('ecoflow', function(value)
  data = value or {}
  render()
end)

noctalia.setUpdateInterval(30 * 1000)

function update()
  render()
end

function onClick()
  noctalia.togglePanel(PANEL)
end

function onRightClick()
  noctalia.state.set('refresh', noctalia.nowMs())
end
