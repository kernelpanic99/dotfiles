-- vim: ft=lua

local fmt = require('./format.luau')

local TOGGLES = { 'ac_ports', 'usb_ports', 'dc_12v_port' }

local data = noctalia.state.get('ecoflow') or {}
local opened = false

local function muted(text)
  return ui.label({ text = text, fontSize = 12, color = 'on_surface_variant' })
end

local function line(label, value, strong)
  return ui.row({ align = 'center', gap = 8 }, {
    ui.label({ text = label, flexGrow = 1, fontWeight = strong and 'medium' or 'normal' }),
    ui.label({ text = value, fontWeight = strong and 'medium' or 'normal' }),
  })
end

local function section(title, children)
  local items = { muted(title) }

  for _, child in ipairs(children) do
    table.insert(items, child)
  end

  return ui.column({ gap = 6 }, items)
end

local function batteryBlock(v)
  local state = noctalia.tr('battery.idle')

  if fmt.charging(v) then
    state = noctalia.tr('battery.charging', { watts = fmt.watts(v.battery_input_power) })
  elseif fmt.num(v.battery_output_power) >= 1 then
    state = noctalia.tr('battery.discharging', { watts = fmt.watts(v.battery_output_power) })
  end

  local eta = fmt.eta(v)

  if eta then
    state = `{state}, {eta}`
  end

  return ui.column({ gap = 6 }, {
    ui.row({ align = 'center', gap = 8 }, {
      ui.glyph({ name = fmt.batteryGlyph(v), size = 22 }),
      ui.label({ text = fmt.percent(v.battery_level), fontSize = 22, fontWeight = 'bold' }),
      ui.label({ text = state, flexGrow = 1, color = 'on_surface_variant', maxLines = 2 }),
    }),
    ui.progress({ progress = fmt.num(v.battery_level) / 100, fill = fmt.levelColor(v) == 'on_surface' and 'primary' or fmt.levelColor(v) }),
  })
end

local function inputs(v)
  return section(noctalia.tr('power.input'), {
    line(noctalia.tr('power.total'), fmt.watts(v.input_power), true),
    line(noctalia.tr('power.ac'), v.plugged_in_ac and fmt.watts(v.ac_input_power) or noctalia.tr('unplugged')),
    line(noctalia.tr('power.solar'), fmt.watts(fmt.num(v.solar_input_power) + fmt.num(v.solar_input_power_2))),
  })
end

local function outputs(v)
  return section(noctalia.tr('power.output'), {
    line(noctalia.tr('power.total'), fmt.watts(v.output_power), true),
    line(noctalia.tr('power.ac'), fmt.watts(v.ac_output_power)),
    line(noctalia.tr('power.usbc'), fmt.watts(fmt.num(v.usbc_output_power) + fmt.num(v.usbc2_output_power))),
    line(noctalia.tr('power.usba'), fmt.watts(fmt.num(v.usba_output_power) + fmt.num(v.usba2_output_power))),
    line(noctalia.tr('power.dc12v'), fmt.watts(v.dc12v_output_power)),
  })
end

local function toggles(s)
  local available = {}

  for _, key in ipairs(s.toggles or {}) do
    available[key] = true
  end

  local rows = {}

  for _, key in ipairs(TOGGLES) do
    if available[key] then
      table.insert(
        rows,
        ui.row({ align = 'center', gap = 12 }, {
          ui.label({ text = noctalia.tr('toggles.' .. key), flexGrow = 1 }),
          ui.toggle({
            checked = s.values[key] == true,
            enabled = not data.busy,
            onChange = function(value)
              noctalia.state.set('command', { key = key, on = value == 'true', at = noctalia.nowMs() })
            end,
          }),
        })
      )
    end
  end

  return section(noctalia.tr('toggles.title'), rows)
end

local function body()
  local s = data.status
  local children = {}

  if data.error then
    table.insert(children, ui.label({ text = data.error.message, color = 'error', maxLines = 3 }))
  end

  if not s then
    if not data.error then
      table.insert(children, muted(noctalia.tr('loading')))
    end

    return children
  end

  local v = s.values

  table.insert(children, batteryBlock(v))
  table.insert(children, inputs(v))
  table.insert(children, outputs(v))

  table.insert(children, toggles(s))

  local footer = `{noctalia.tr('updated')}: {fmt.time(s.updated)}`

  if fmt.isStale(data) then
    footer = `{footer} ({noctalia.tr('stale')})`
  end

  if v.cell_temperature then
    footer = `{footer}  ·  {v.cell_temperature} °C`
  end

  table.insert(children, muted(footer))

  return children
end

local function render()
  if not opened then
    return
  end

  local s = data.status

  local header = {
    ui.label({ text = s and s.model or noctalia.tr('title'), fontSize = 16, fontWeight = 'bold', flexGrow = 1 }),
    ui.button({
      glyph = data.busy and 'loader-2' or 'refresh',
      enabled = not data.busy,
      tooltip = noctalia.tr('refresh'),
      onClick = function()
        noctalia.state.set('refresh', noctalia.nowMs())
      end,
    }),
  }

  if noctalia.getSetting('shell.show_close_buttons') ~= false then
    table.insert(
      header,
      ui.button({
        glyph = 'close',
        onClick = function()
          panel.close()
        end,
      })
    )
  end

  panel.render(ui.column({ flexGrow = 1, gap = 12 }, {
    ui.row({ align = 'center', justify = 'space_between', gap = 8 }, header),
    ui.scroll({ flexGrow = 1, gap = 14 }, body()),
  }))
end

noctalia.state.watch('ecoflow', function(value)
  data = value or {}
  render()
end)

function onOpen(_context)
  opened = true
  render()
end

function onClose()
  opened = false
end
