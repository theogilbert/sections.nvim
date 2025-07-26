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

local function _get_nth_section(sections, n, current_idx)
    current_idx = current_idx or 0

    for _, section in pairs(sections) do
        current_idx = current_idx + 1

        if current_idx == n then
            return section, current_idx
        end

        local matching_sub_section, new_idx = _get_nth_section(section.children, n, current_idx)
        if matching_sub_section ~= nil then
            return matching_sub_section, new_idx
        else
            current_idx = new_idx
        end
    end

    return nil, current_idx
end

M.get_section_pos = function(section_idx)
    local section = _get_nth_section(_sections, section_idx)
    if section ~= nil then
        return section.position
    end
    return nil
end


return M
