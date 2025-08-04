local M = {}

local _config = {
    indent = 2,
    icons = {
        ["function"] = "󰊕",
        class = "",
        attribute = "󰠲",
        header = "",
    },
}

M.init = function(config)
    if config then
        _config = vim.tbl_deep_extend("force", _config, config)
    end
end

M.get_config = function()
    return _config
end

return M
