local M = {}

local _sections = {}

local function section_to_text(section, out_lines, indent)
    indent = indent or 0

    local prefix = string.rep(" ", indent)
    table.insert(out_lines, prefix .. section.name)

    for _, sub_section in pairs(section.children) do
        section_to_text(sub_section, out_lines, indent + 2)
    end
end

M.update_sections = function(sections)
    _sections = sections
end

M.format = function()
    local lines = {}

    for _, section in pairs(_sections) do
        section_to_text(section, lines)
    end

    return lines
end

return M
