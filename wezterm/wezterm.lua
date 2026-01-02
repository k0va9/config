local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.automatically_reload_config = true
config.use_ime = true
config.font_size = 16
config.font = wezterm.font('JetBrains Mono', { weight = 'Bold' })
config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = 'kanagawabones'
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

config.leader = { key = 'j', mods = "CTRL", timeout_milliseconds = 2000 }
config.keys = {
  -- create pane
  { key = ';', mods = "LEADER", action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" })},
  { key = ':', mods = "LEADER", action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" })},
  { key = 'x', mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
  -- move pane
  { key = 'h', mods = "ALT", action = wezterm.action.ActivatePaneDirection("Left") },
  { key = 'l', mods = "ALT", action = wezterm.action.ActivatePaneDirection("Right") },
  { key = 'k', mods = "ALT", action = wezterm.action.ActivatePaneDirection("Up") },
  { key = 'j', mods = "ALT", action = wezterm.action.ActivatePaneDirection("Down") },
}

return config
