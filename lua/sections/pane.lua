local M = {}

local PANE_FILETYPE = "sections-pane"
local _source_win = nil

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

local function notify_error(msg)
    vim.notify(msg, vim.log.levels.ERROR)
end

local function select_section()
    if _source_win == nil or not vim.api.nvim_win_is_valid(_source_win) then
        notify_error("Source window not found")
        return
    end

    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local pos = formatter.get_section_pos(cur_line)

    vim.api.nvim_win_set_cursor(_source_win, pos)
end


local function open_pane(src_buf)
    _source_win = vim.api.nvim_get_current_win()

    local bufid = vim.api.nvim_create_buf(true, false)
    vim.bo[bufid].filetype = PANE_FILETYPE
    vim.bo[bufid].buftype = "nofile"

    local sections, err = parser.parse_sections(src_buf)
    if sections == nil and err ~= nil then
        notify_error(err)
        return
    end
    formatter.update_sections(sections)
    local lines = formatter.format()
    vim.api.nvim_buf_set_lines(bufid, 0, -1, false, lines)

    local width = detect_pane_width(lines)

    local winid = vim.api.nvim_open_win(
        bufid, false, { vertical = true, split = "left", width = width, style = "minimal"}
    )
    vim.api.nvim_set_option_value("cursorline", true, { win = winid })
    vim.keymap.set("n", "<cr>", select_section, { buffer = bufid })

    vim.bo[bufid].modifiable = false
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
