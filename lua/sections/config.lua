local M = {}

local _config = {
    filetypes = {
        markdown = {
            sections = {
                { section = "@section", name = "@section.name" }
            }
        }
    },
    icons = {
        ["function"] = "󰊕",
        header = "󰙅",
    }
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
