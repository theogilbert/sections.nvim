local init_config = require("sections.config").init_config
local pane = require("sections.pane")

local M = {}

M.toggle = function()
    pane.toggle_pane()
end

M.setup = function(config)
    init_config(config)
end

return M
