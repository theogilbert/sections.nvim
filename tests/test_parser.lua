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

        assert.are.same(root_nodes, {
            {
                name = "First header", type = "header", position = {1, 1},
                children = {},
            },
            {
                name = "Second header", type = "header", position = {5, 1},
                children = {},
            }
        })
    end)

it("parse nested headers", function()
        local buf = create_buf_with_text([[
# Parent header
## Sub header
]], "markdown")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same(root_nodes, {
            {
                name = "Parent header", type = "header", position = {1, 1},
                children = {
                    {
                        name = "Sub header", type = "header", position = {2, 1},
                        children = {},
                    }
                },
            },
        })
    end)

it("associate child section to correct parent", function()
        local buf = create_buf_with_text([[
# Parent header
## Sub header
### Sub sub header
## Sub header 2
]], "markdown")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same(root_nodes, {
            {
                name = "Parent header", type = "header", position = {1, 1},
                children = {
                    {
                        name = "Sub header", type = "header", position = {2, 1},
                        children = {
                            {
                                name = "Sub sub header", type = "header", position = {3, 1},
                                children = {},
                            }
                        },
                    },
                    {
                        name = "Sub header 2", type = "header", position = {4, 1},
                        children = {},
                    }
                },
            },
        })
    end)
end)

