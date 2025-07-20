local config = require("sections.config")
local ts = vim.treesitter

local M = {}



local function build_section(match, metadata, query_info, buf_id)
    local current_section = { children = {} }

    for id, nodes in pairs(match) do
        for _, node in ipairs(nodes) do
            local capture_name = query_info.captures[id]

            if capture_name == "section" then
                local sr, sc, _, _ = ts.get_node_range(node)
                current_section.position = { sr + 1, sc + 1 }
                current_section.type = metadata.type
            elseif capture_name == "section.name" then
                current_section.name = ts.get_node_text(node, buf_id)
            end
        end
    end

    return current_section
end


-- Parses TSNode objects matching queries present in queries/<filetype>/sections.scm
-- @param buf_id The ID of the buffer from which to parse the sections
-- @return A table containing sections parsed from the buffer if sections are successfully parsed.
--         Otherwise, returns nil and the error message.
M.parse_sections = function(buf_id)
    local lang = vim.api.nvim_get_option_value('filetype', { buf = buf_id })

    local parser = ts.get_parser(buf_id, lang)
    if parser == nil then
        return nil, "No treesitter parser found for " .. lang .. " files"
    end

    local tree = parser:parse()[1]
    local root = tree:root()

    local queries = ts.query.get(lang, "sections")
    if queries == nil then
        return nil, "No sections.scm file found for " .. lang .. " files"
    end

    local sections = {}
    for match_id, match, meta in queries:iter_matches(root, buf_id, 0, -1) do
        local section = build_section(match, meta, queries.info, buf_id)
        table.insert(sections, section)
    end

    return sections, nil
end

return M
