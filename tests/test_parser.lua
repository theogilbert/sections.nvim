function expectNodeCount(root_nodes, count)
    assert.equals(count, #root_nodes, "Invalid number of parsed nodes")
end

function expectNodeName(node, name)
    assert.equals(name, node.name, "Invalid node name")
end

function expectNodeType(node, name)
    assert.equals(name, node.type, "Header")
end

function expectNodePosition(node, pos)
    assert.equals(pos[1], node.position[1], "Invalid node column position")
    assert.equals(pos[2], node.position[2], "Invalid node row position")
end

function create_buf_with_text(text, lang)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "filetype", lang)
    local lines = vim.split(text, '\n')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end

describe("parsing markdown sections", function()
    local parser = require("sections.parser")

    it("parse subsequent headers", function()
        local buf = create_buf_with_text([[
# First header

Foo

# Second header

Bar
        ]], "markdown")

        local root_nodes = parser.parse_sections(buf)

        expectNodeCount(root_nodes, 2)

        expectNodeName(root_nodes[1], "First header")
        expectNodeName(root_nodes[2], "Second header")

        expectNodeType(root_nodes[1], "header")
        expectNodeType(root_nodes[2], "header")

        expectNodePosition(root_nodes[1], {1, 1})
        expectNodePosition(root_nodes[2], {5, 1})

        expectNodeCount(root_nodes[1].children, 0)
        expectNodeCount(root_nodes[2].children, 0)
    end)
end)

