local init_config = require("sections.config").init
local pane = require("sections.pane")
local hl = require("sections.hl")
local header = require("sections.header")
local parser = require("sections.parser")
local formatter = require("sections.formatter")

local M = {}

local tab_infos = {}
-- Keeps various information related to the tab, such as:
-- * Which window is currently being watched
-- * Which buffer is currently being watched
-- * Parsed sections to display
-- * Whether or not to display private sections
--
-- The key is the tab number. If the tab number is not present, it means
-- that the section pane is not open.

local function init_tab_info(watched_win, watched_buf)
    local cur_tab = vim.api.nvim_get_current_tabpage()

    tab_infos[cur_tab] = {
        watched_win = watched_win,
        watched_buf = watched_buf,
        sections = {},
        show_private = true,
    }
end

local function get_tab_info()
    local cur_tab = vim.api.nvim_get_current_tabpage()
    return tab_infos[cur_tab]
end

local function clear_tab_info()
    local cur_tab = vim.api.nvim_get_current_tabpage()
    tab_infos[cur_tab] = nil
end

local function render_header(tab_info)
    local header_lines = header.get_lines(tab_info.show_private)
    pane.write_header(header_lines)
    pane.apply_highlight(header.get_hl_rules(tab_info.show_private))
end

local function refresh_pane(win, buf)
    local info = get_tab_info()
    if info == nil or win == nil or buf == nil then
        return
    end

    local win_cfg = vim.api.nvim_win_get_config(win)
    if win_cfg.relative ~= "" then
        return -- Window is floating
    end

    local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
    if ft == pane.PANE_FILETYPE then
        return -- We do not want to read sections from the sections pane
    end

    render_header(info)

    local sections, err = parser.parse_sections(buf)
    if err ~= nil then
        pane.write_error({ err })
        return
    end

    local sections_lines = formatter.format(sections, info.show_private)
    pane.write_sections(sections_lines)

    info.watched_win = win
    info.watched_buf = buf
    info.sections = sections
end

local function select_section()
    local info = get_tab_info()
    if info == nil then
        return
    end

    local section_number, err = pane.get_selected_section()
    if err ~= nil then
        vim.notify("Failed to select section: " .. err, vim.log.levels.ERROR)
        return
    end

    if section_number == nil then
        return
    end

    local section_pos = formatter.get_section_pos(info.sections, section_number)
    if section_pos == nil then
        vim.notify("Failed to select section: could not retrieve section position", vim.log.levels.ERROR)
        return
    end

    vim.api.nvim_win_set_cursor(info.watched_win, section_pos)
    vim.api.nvim_set_current_win(info.watched_win)
end

local function toggle_section()
    local info = get_tab_info()
    if info == nil then
        return
    end

    local section_line, err = pane.get_selected_section()
    if err ~= nil then
        vim.notify("Cannot select section: " .. err, vim.log.level.ERROR)
        return
    end

    formatter.toggle_collapse(info.sections, section_line)
    local sections_lines = formatter.format(info.sections, info.show_private)
    pane.write_sections(sections_lines)
end

local function toggle_private()
    local info = get_tab_info()
    if info == nil then
        return
    end

    info.show_private = not info.show_private

    render_header(info)

    local sections_lines = formatter.format(info.sections, info.show_private)
    pane.write_sections(sections_lines)
end

local function setup_autocommands()
    local group = vim.api.nvim_create_augroup("SectionsAutoRefresh", { clear = true })

    -- When saving a file, refresh the pane if the file is currently watched
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = function(args)
            local info = get_tab_info()
            if info == nil then
                return
            end

            if args.buf == info.watched_buf then
                local win = vim.api.nvim_get_current_win()
                refresh_pane(win, args.buf)
            end
        end,
    })

    -- When focusing a different win, refresh the pane
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
        group = group,
        callback = function(args)
            local win = vim.api.nvim_get_current_win()
            refresh_pane(win, args.buf)
        end,
    })
end

M.toggle = function()
    local info = get_tab_info()

    if info == nil then
        local watched_buf = vim.api.nvim_get_current_buf()
        local watched_win = vim.api.nvim_get_current_win()
        init_tab_info(watched_win, watched_buf)
        pane.open({
            keymaps = {
                ["<C-]>"] = select_section,
                ["<cr>"] = toggle_section,
                p = toggle_private,
            },
            on_close = clear_tab_info,
        })
        refresh_pane(watched_win, watched_buf)
    else
        pane.close()
        clear_tab_info()
    end
end

M.setup = function(config)
    init_config(config)
    setup_autocommands()
    pane.setup()
    hl.setup()
end

return M
