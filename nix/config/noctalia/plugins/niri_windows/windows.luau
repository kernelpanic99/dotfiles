-- vim: ft=lua

local icons = {
  foot = '',
  ['brave-browser'] = '',
  ['io.wavebox.Wavebox'] = '',
}

local title_rules = {
  ['^t *'] = '',
  ['^Yazi: *'] = '',
  ['^Rmpc$'] = '',
  ['^Grayjay$'] = '',
  ['^nt *'] = '',
  ['^Notes$'] = '',
}

local fallback_icon = ''

function update()
  noctalia.runAsync('niri msg --json windows', function(res)
    local windows = noctalia.json.decode(res.stdout)
    local focused

    for _, win in ipairs(windows) do
      if win.is_focused then
        focused = win
      end
    end

    if not focused then
      barWidget.render(ui.label({ text = '' }))
      return
    end

    local visible = {}

    for _, win in ipairs(windows) do
      if win.workspace_id == focused.workspace_id then
        table.insert(visible, win)
      end
    end

    table.sort(visible, function(a, b)
      -- floating windows have no scrolling position; sort them last
      local pa = a.layout.pos_in_scrolling_layout or { math.huge, math.huge }
      local pb = b.layout.pos_in_scrolling_layout or { math.huge, math.huge }

      if pa[1] ~= pb[1] then
        return pa[1] < pb[1]
      end

      return pa[2] < pb[2]
    end)

    local labels = {}

    for _, win in ipairs(visible) do
      local color = win.is_focused and 'tertiary' or 'on_surface'

      local icon

      for pat, ic in pairs(title_rules) do
        if win.title and win.title:match(pat) then
          icon = ic
          break
        end
      end

      if not icon then
        icon = icons[win.app_id]
      end

      table.insert(labels, ui.label({ text = icon or fallback_icon, color = color }))
    end

    barWidget.render(ui.row({ gap = 8 }, labels))
  end)
end
