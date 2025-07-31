-- TODO add colored prefix icon depending on capture type
-- TODO parse public/private functions
local parser = require("sections.parser")
local formatter = require("sections.formatter")

local M = {}

local PANE_FILETYPE = "sections-pane"
local _pane_infos = {}

local function get_pane_info()
    local cur_tab = vim.api.nvim_get_current_tabpage()
    return _pane_infos[cur_tab]
end

local function on_section_selected()
    local info = get_pane_info()

    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
    local pos = formatter.get_section_pos(cur_line)

    if pos ~= nil then
        vim.api.nvim_win_set_cursor(info.watched_win, pos)
    end
end


local function open_pane()
    local bufid = vim.api.nvim_create_buf(true, false)
    vim.bo[bufid].filetype = PANE_FILETYPE
    vim.bo[bufid].buftype = "nofile"
    vim.bo[bufid].modifiable = false

    local winid = vim.api.nvim_open_win(
        bufid, false, { vertical = true, split = "left", width = 50, style = "minimal"}
    )
    vim.api.nvim_set_option_value("cursorline", true, { win = winid })
    vim.keymap.set("n", "<cr>", on_section_selected, { buffer = bufid })

    local tab = vim.api.nvim_get_current_tabpage()
    local watched_buf = vim.api.nvim_get_current_buf()
    local watched_win = vim.api.nvim_get_current_win()
    _pane_infos[tab] = {
        pane_buf = bufid,
        pane_win = winid,
        watched_buf = watched_buf,
        watched_win = watched_win,
    }

    M.refresh_pane(watched_buf)
end

local function close_pane(winid)
    local bufid = vim.api.nvim_win_get_buf(winid)
    vim.api.nvim_buf_delete(bufid, {force = true})
end


M.cleanup_pane = function()
    local cur_tab = vim.api.nvim_get_current_tabpage()
    _pane_infos[cur_tab] = nil
end

M.get_watched_buf = function()
    local info = get_pane_info()
    if info == nil then
        return nil
    end

    return info.watched_buf
end

M.get_pane_buf = function()
    local info = get_pane_info()
    if info == nil then
        return nil
    end

    return info.pane_buf
end

M.toggle_pane = function()
    local pane_info = get_pane_info()

    if pane_info ~= nil then
        close_pane(pane_info.pane_win)
    else
        open_pane()
    end
end

M.refresh_pane = function(updated_buf, buf_win)
    if updated_buf == nil then
        return
    end

    local pane_info = get_pane_info()
    if pane_info == nil then
        return
    end

    if buf_win ~= nil then
        local win_cfg = vim.api.nvim_win_get_config(buf_win)
        if win_cfg.relative ~= "" then
            return  -- Window is floating
        end
    end

    local sections, err = parser.parse_sections(updated_buf)
    local lines = {}
    if sections ~= nil then
        formatter.update_sections(sections)
        lines = formatter.format()
    elseif err ~= nil then
        lines = { err }
    end

    local pane_buf = pane_info.pane_buf
    vim.bo[pane_buf].modifiable = true
    vim.api.nvim_buf_set_lines(pane_buf, 0, -1, false, lines)
    vim.bo[pane_buf].modifiable = false

    pane_info.watched_buf = updated_buf
    if buf_win ~= nil then
        pane_info.watched_win = buf_win
    end
end


return M
