local config = require("sections.config")

local M = {}

local _sections = {}

local function get_section_icon(section_type)
    local cfg = config.get_config()
    return cfg.icons[section_type] or " "
end

local function get_section_text(section)
    local suffix = ""
    if section.type == "function" then
        if section.parameters == nil then
            suffix = "()"
        else
            suffix = "(" .. table.concat(section.parameters, ", ") .. ")"
        end
    elseif section.type == "attribute" and section.type_annotation ~= nil then
        suffix = ": " .. section.type_annotation
    end

    return section.name .. suffix
end

local function get_section_line(section, cfg, depth)
    local prefix = string.rep(" ", depth * cfg.indent)
    local icon = get_section_icon(section.type)
    local text = get_section_text(section)
    local suffix = ""

    if section.collapsed and #section.children > 0 then
        suffix = " ..."
    end

    return prefix .. icon .. " " .. text .. suffix
end

local function write_sections(section, out_lines, cfg, depth)
    depth = depth or 0

    table.insert(out_lines, get_section_line(section, cfg, depth))

    if not section.collapsed then
        for _, sub_section in pairs(section.children) do
            write_sections(sub_section, out_lines, cfg, depth + 1)
        end
    end
end

M.update_sections = function(sections)
    _sections = sections
end

M.format = function()
    local cfg = config.get_config()
    local lines = {}

    for _, section in pairs(_sections) do
        write_sections(section, lines, cfg)
    end

    return lines
end

local function get_nth_section(sections, n, current_idx)
    current_idx = current_idx or 0

    for _, section in pairs(sections) do
        current_idx = current_idx + 1

        if current_idx == n then
            return section, current_idx
        end

        local matching_sub_section, new_idx = get_nth_section(section.children, n, current_idx)
        if matching_sub_section ~= nil then
            return matching_sub_section, new_idx
        else
            current_idx = new_idx
        end
    end

    return nil, current_idx
end

M.get_section_pos = function(section_idx)
    local section = get_nth_section(_sections, section_idx)
    if section ~= nil then
        return section.position
    end
    return nil
end

M.collapse = function(line)
    local section = get_nth_section(_sections, line)

    if section == nil then
        return
    end

    section.collapsed = not section.collapsed
end

return M
