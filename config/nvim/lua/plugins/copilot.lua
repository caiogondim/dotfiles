-- ~/.config/nvim/lua/plugins/copilot.lua
-- copilot configuration
return {
  "zbirenbaum/copilot.lua",
  opts = {
    -- These are disabled in the default configuration.
    suggestion = { enabled = true },
    panel = { enabled = true },
  },
}
-- For additional configurations for the copilot panel, suggestions, filetypes supported, etc
-- see https://github.com/zbirenbaum/copilot.lua
