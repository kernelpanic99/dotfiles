-- vim: ft=lua

local schedule = require('./schedule.luau')

local COLORS = {
  on = 'primary/0.3',
  off = 'error',
  maybe = 'tertiary',
  unknown = 'on_surface/0.1',
}

local CELL_W = 8
local CELL_H = 18
local HOUR_GAP = 2
local DAY_LABEL_W = 44

local data = noctalia.state.get('dtek') or {}
local opened = false

local function muted(text)
  return ui.label({ text = text, fontSize = 12, color = 'on_surface_variant' })
end

local function hourAxis()
  local labels = {}

  for h = 0, 23 do
    local text = h % 3 == 0 and tostring(h) or ''
    table.insert(labels, ui.row({ width = CELL_W * 2, minWidth = CELL_W * 2 }, {
      ui.label({ text = text, fontSize = 10, color = 'on_surface_variant' }),
    }))
  end

  return ui.row({ gap = 8, align = 'end' }, {
    ui.row({ width = DAY_LABEL_W, minWidth = DAY_LABEL_W }, {}),
    ui.row({ gap = HOUR_GAP }, labels),
  })
end

local function dayRow(label, slots, dayTs, now)
  local hours = {}

  for h = 0, 23 do
    local cells = {}

    for k = 1, 2 do
      local i = h * 2 + k
      local t = dayTs + (i - 1) * schedule.SLOT
      local current = now >= t and now < t + schedule.SLOT

      table.insert(cells, ui.box({
        width = CELL_W,
        height = CELL_H,
        radius = 2,
        fill = COLORS[slots[i]] or COLORS.unknown,
        border = current and 'on_surface' or nil,
        borderWidth = current and 2 or 0,
      }))
    end

    table.insert(hours, ui.row({ gap = 0 }, cells))
  end

  return ui.row({ gap = 8, align = 'center' }, {
    ui.row({ width = DAY_LABEL_W, minWidth = DAY_LABEL_W }, {
      ui.label({ text = label, fontSize = 12 }),
    }),
    ui.row({ gap = HOUR_GAP }, hours),
  })
end

local function legend()
  local items = {}

  for _, state in ipairs({ 'on', 'maybe', 'off' }) do
    table.insert(items, ui.row({ gap = 6, align = 'center' }, {
      ui.box({ width = CELL_W * 2, height = CELL_H / 2, radius = 2, fill = COLORS[state] }),
      muted(noctalia.tr('state.' .. state)),
    }))
  end

  return ui.row({ gap = 16, align = 'center' }, items)
end

local function outageBlock(s)
  if not s.outage then
    return { muted(noctalia.tr('outage.none')) }
  end

  local o = s.outage

  local lines = {
    ui.label({ text = o.reason, color = 'error', maxLines = 2 }),
    muted(`{noctalia.tr('outage.start')}: {o.start}`),
    muted(`{noctalia.tr('outage.finish')}: {o.finish}`),
  }

  if o.voluntarily then
    table.insert(lines, muted(noctalia.tr('outage.voluntarily')))
  end

  return lines
end

local function body()
  local s = data.schedule
  local children = {}

  if data.error then
    table.insert(children, ui.label({ text = data.error.message, color = 'error', maxLines = 3 }))

    if data.error.candidates and #data.error.candidates > 0 then
      table.insert(children, muted(`{noctalia.tr('errors.candidates')}: {table.concat(data.error.candidates, ', ')}`))
    end
  end

  if not s then
    if not data.error then
      table.insert(children, muted(noctalia.tr('loading')))
    end

    return children
  end

  local now = os.time()

  table.insert(children, ui.label({ text = `{s.city}, {s.street}, {s.house == '-' and noctalia.tr('whole_street') or s.house}`, fontWeight = 'medium' }))
  table.insert(children, muted(`{noctalia.tr('tooltip.queue')}: {schedule.queueNames(s)}`))

  if #s.queues > 1 then
    table.insert(children, muted(noctalia.tr('multiple_queues')))
  end

  for _, line in ipairs(outageBlock(s)) do
    table.insert(children, line)
  end

  local grid = { hourAxis() }

  for _, queue in ipairs(s.queues) do
    if #s.queues > 1 then
      table.insert(grid, muted(queue.name))
    end

    for _, day in ipairs(s.days) do
      local slots = day.slots[queue.id]

      if slots then
        table.insert(grid, dayRow(schedule.fmtDay(day.ts), slots, day.ts, now))
      end
    end
  end

  if #grid == 1 then
    table.insert(grid, muted(noctalia.tr('no_data')))
  end

  table.insert(children, ui.column({ gap = 4 }, grid))
  table.insert(children, legend())
  table.insert(children, muted(`{noctalia.tr('tooltip.updated')}: {s.factUpdate ~= '' and s.factUpdate or s.updated}`))

  return children
end

local function render()
  if not opened then
    return
  end

  local header = {
    ui.label({ text = noctalia.tr('title'), fontSize = 16, fontWeight = 'bold', flexGrow = 1 }),
    ui.button({
      glyph = data.loading and 'loader-2' or 'refresh',
      enabled = not data.loading,
      tooltip = noctalia.tr('refresh'),
      onClick = function()
        noctalia.state.set('refresh', noctalia.nowMs())
      end,
    }),
  }

  if noctalia.getSetting('shell.show_close_buttons') ~= false then
    table.insert(header, ui.button({
      glyph = 'close',
      onClick = function()
        panel.close()
      end,
    }))
  end

  panel.render(ui.column({ flexGrow = 1, gap = 12 }, {
    ui.row({ align = 'center', justify = 'space_between', gap = 8 }, header),
    ui.scroll({ flexGrow = 1, gap = 8, align = 'start' }, body()),
  }))
end

noctalia.state.watch('dtek', function(value)
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
