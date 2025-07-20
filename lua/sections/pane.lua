local M = {}

local open_pane = function()
end

local close_pane = function(win_id)
end

local get_pane_win_id = function()
    -- check if window with code_sections filetype is open
end

M.toggle_pane = function()
    local win_id = get_pane_win_id()

    if win_id ~= nil then
        close_pane(win_id)
    else
        open_pane()
    end
end

return M
