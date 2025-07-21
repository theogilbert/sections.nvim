local M = {}

local PANE_FILETYPE = "sections-pane"

local parser = require("sections.parser")
local formatter = require("sections.formatter")

local function detect_pane_width(lines, min, max)
    min = min or 20
    max = max or 100

    local width = min

    for _, line in pairs(lines) do
        if #line > width then
            width = #line + 2
        end
    end

    if width > max then
        width = max
    end

    return width
end


local function open_pane(src_buf)
    local bufid = vim.api.nvim_create_buf(true, false)
    vim.bo[bufid].filetype = PANE_FILETYPE
    vim.bo[bufid].buftype = "nofile"

    local sections = parser.parse_sections(src_buf)
    formatter.update_sections(sections)
    local lines = formatter.format()
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, lines)

    local width = detect_pane_width(lines)

    vim.api.nvim_open_win(
        bufid, false, { vertical = true, split = "right", width = width, style = "minimal"}
    )
end

local function close_pane(winid)
    local bufid = vim.api.nvim_win_get_buf(winid)
    vim.api.nvim_buf_delete(bufid, {force = true})
end

local function get_pane_win_id()
    for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
        local bufid = vim.api.nvim_win_get_buf(winid)

        if vim.bo[bufid].filetype == PANE_FILETYPE then
            return winid
        end
    end

    return nil
end

M.toggle_pane = function()
    local win_id = get_pane_win_id()
    local src_buf = vim.api.nvim_get_current_buf()

    if win_id ~= nil then
        close_pane(win_id)
    else
        open_pane(src_buf)
    end
end

return M
