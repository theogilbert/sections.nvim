local M = {}

local _config = {
    filetypes = {
        markdown = {
            sections = {
                { section = "@section", name = "@section.name" }
            }
        }
    }
}

M.init = function(config)
end

M.get_config = function()
    return _config
end

return M
