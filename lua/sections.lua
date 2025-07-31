local init_config = require("sections.config").init
local pane = require("sections.pane")

local M = {}

local function setup_autocommands()
    local group = vim.api.nvim_create_augroup("SectionsAutoRefresh", { clear = true })

    -- When saving a file, refresh pane if the file is currently watched
    vim.api.nvim_create_autocmd("BufWritePost", {
        group = group,
        callback = function(args)
            if args.buf == pane.get_watched_buf() then
                pane.refresh_pane(args.buf)
            end
        end,
    })
    -- When entering a window, if it's not
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
        group = group,
        callback = function(args)
            if args.buf ~= pane.get_pane_buf() then
                local win = vim.api.nvim_get_current_win()
                pane.refresh_pane(args.buf, win)
            end
        end,
    })
    vim.api.nvim_create_autocmd("BufWinEnter", {
        group = group,
        callback = function(args)
            local win = vim.api.nvim_get_current_win()
            if win == pane.get_pane_win() then
                pane.toggle_pane()
            end
        end,
    })
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = function(args)
            if args.buf == pane.get_pane_buf() then
                pane.cleanup_pane()
            end
        end,
    })
end

M.toggle = function()
    pane.toggle_pane()
end

M.setup = function(config)
    init_config(config)
    setup_autocommands()
end

return M
