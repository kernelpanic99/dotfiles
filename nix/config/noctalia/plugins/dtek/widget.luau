-- vim: ft=lua

local schedule = require('./schedule.luau')

local PANEL = 'kernelpanic99/dtek:panel'

local COLORS = {
  on = 'on_surface',
  off = 'error',
  maybe = 'tertiary',
  unknown = 'on_surface',
}

local data = noctalia.state.get('dtek') or {}

local function tooltip(s, status)
  local rows = {
    { key = noctalia.tr('tooltip.address'), value = `{s.city}, {s.street}, {s.house}` },
    { key = noctalia.tr('tooltip.queue'), value = schedule.queueNames(s) },
  }

  local now = noctalia.tr('state.' .. status.state)

  if status.change then
    now = now .. ' ' .. noctalia.tr('tooltip.until', { time = schedule.fmtTime(status.change) })
  end

  table.insert(rows, { key = noctalia.tr('tooltip.now'), value = now })

  if s.outage then
    table.insert(rows, { key = noctalia.tr('outage.reason'), value = s.outage.reason })
    table.insert(rows, { key = noctalia.tr('outage.finish'), value = s.outage.finish })
  end

  local queue = s.queues[1]

  for _, day in ipairs(s.days) do
    local slots = queue and day.slots[queue.id]

    if slots then
      local ranges = schedule.ranges(slots, day.ts, 'off')
      local value = #ranges > 0 and table.concat(ranges, ', ') or noctalia.tr('tooltip.no_outages')
      table.insert(rows, { key = schedule.fmtDay(day.ts), value = value })
    end
  end

  table.insert(rows, { key = noctalia.tr('tooltip.updated'), value = s.factUpdate ~= '' and s.factUpdate or s.updated })

  if data.error then
    table.insert(rows, { key = noctalia.tr('tooltip.error'), value = data.error.message })
  end

  return rows
end

local function render()
  local s = data.schedule

  if not s then
    barWidget.setGlyph(data.loading and 'loader-2' or 'bolt')
    barWidget.setGlyphColor(data.error and 'error' or 'on_surface')
    barWidget.setText('')
    barWidget.setTooltip(data.error and data.error.message or noctalia.tr('loading'))
    return
  end

  local status = schedule.status(s, os.time())
  local mark = status.change

  if status.state == 'on' then
    mark = status.nextOff
  end

  barWidget.setGlyph(status.state == 'off' and 'bolt-off' or 'bolt')
  barWidget.setGlyphColor(COLORS[status.state] or COLORS.unknown)
  barWidget.setColor(COLORS[status.state] or COLORS.unknown)
  barWidget.setText(mark and schedule.fmtTime(mark) or '')
  barWidget.setTooltip(tooltip(s, status))
end

noctalia.state.watch('dtek', function(value)
  data = value or {}
  render()
end)

noctalia.setUpdateInterval(60 * 1000)

function update()
  render()
end

function onClick()
  noctalia.togglePanel(PANEL)
end

function onRightClick()
  noctalia.state.set('refresh', noctalia.nowMs())
end
