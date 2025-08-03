local function create_buf_with_text(text, lang)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", lang, { buf = buf })
    local lines = vim.split(text, '\n')
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end

describe("should parse markdown sections", function()
    local parser = require("sections.parser")

    it("parse subsequent headers", function()
        local buf = create_buf_with_text([[
# First header

Foo

# Second header

Bar
        ]], "markdown")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "First header", type = "header", position = {1, 0},
                children = {},
            },
            {
                name = "Second header", type = "header", position = {5, 0},
                children = {},
            }
        }, root_nodes)
    end)

it("should parse nested headers", function()
        local buf = create_buf_with_text([[
# Parent header
## Sub header
]], "markdown")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "Parent header", type = "header", position = {1, 0},
                children = {
                    {
                        name = "Sub header", type = "header", position = {2, 0},
                        children = {},
                    }
                },
            },
        }, root_nodes)
    end)

it("should associate child section to correct parent", function()
        local buf = create_buf_with_text([[
# Parent header
## Sub header
### Sub sub header
## Sub header 2
]], "markdown")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "Parent header", type = "header", position = {1, 0},
                children = {
                    {
                        name = "Sub header", type = "header", position = {2, 0},
                        children = {
                            {
                                name = "Sub sub header", type = "header", position = {3, 0},
                                children = {},
                            }
                        },
                    },
                    {
                        name = "Sub header 2", type = "header", position = {4, 0},
                        children = {},
                    }
                },
            },
        }, root_nodes)
    end)
end)

describe("parsing lua sections", function()
    local parser = require("sections.parser")

    it("should parse subsequent functions", function()
        local buf = create_buf_with_text([[
function1 = function() end
function function2() end
        ]], "lua")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "function1", type = "function", position = {1, 0},
                children = {}
            },
            {
                name = "function2", type = "function", position = {2, 0},
                children = {}
            }
        }, root_nodes)
    end)

    it("should not parse non-function assignments", function()
        local buf = create_buf_with_text([[
local text = "abcd"
number = 123
        ]], "lua")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same(root_nodes, {})
    end)

    it("should parse functions parameters", function()
        local buf = create_buf_with_text([[
function1 = function(p1, p2) end
function function2(p3, p4, p5) end
        ]], "lua")

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "function1", type = "function", position = {1, 0},
                children = {}, parameters={"p1", "p2"}
            },
            {
                name = "function2", type = "function", position = {2, 0},
                children = {}, parameters={"p3", "p4", "p5"}
            }
        }, root_nodes)
    end)
end)
