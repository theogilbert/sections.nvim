local config = require("sections.config")

local M = {}

local DEFAULT_HIGHLIGHTS = {
    SectionsFunction = { fg = "#61AFEF", bold = true },
    SectionsClass = { fg = "#E06C75", bold = true },
    SectionsHeader = { fg = "#98C379", bold = true },
}

local SECTIONS_HIGHLIGHTS = {
    ["function"] = "SectionsFunction",
    class = "SectionsClass",
    header = "SectionsHeader",
}

local function setup_highlights()
    for group, opts in pairs(DEFAULT_HIGHLIGHTS) do
        if vim.fn.hlexists(group) == 0 then
            vim.api.nvim_set_hl(0, group, opts)
        end
    end
end

local function define_syntax_match_rules(buf)
    local cfg = config.get_config()

    vim.api.nvim_buf_call(buf, function()
        vim.cmd("syntax enable")
        for type, icon in pairs(cfg.icons) do
            local hl_group = SECTIONS_HIGHLIGHTS[type]
            local cmd = string.format([[syntax match %s /%s/]], hl_group, icon)
            vim.cmd(cmd)
        end
    end)
end

M.setup = function()
    setup_highlights()

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "sections-pane",
        callback = function(args)
            define_syntax_match_rules(args.buf)
        end,
    })
end

return M
