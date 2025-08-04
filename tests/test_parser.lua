local function create_buf_with_text(text, lang)
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_option_value("filetype", lang, { buf = buf })
    local lines = vim.split(text, "\n")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    return buf
end

describe("should parse markdown sections", function()
    local parser = require("sections.parser")

    it("parse subsequent headers", function()
        local buf = create_buf_with_text(
            [[
# First header

Foo

# Second header

Bar
        ]],
            "markdown"
        )

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "First header",
                type = "header",
                position = { 1, 0 },
                children = {},
            },
            {
                name = "Second header",
                type = "header",
                position = { 5, 0 },
                children = {},
            },
        }, root_nodes)
    end)

    it("should parse nested headers", function()
        local buf = create_buf_with_text(
            [[
# Parent header
## Sub header
]],
            "markdown"
        )

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "Parent header",
                type = "header",
                position = { 1, 0 },
                children = {
                    {
                        name = "Sub header",
                        type = "header",
                        position = { 2, 0 },
                        children = {},
                    },
                },
            },
        }, root_nodes)
    end)

    it("should associate child section to correct parent", function()
        local buf = create_buf_with_text(
            [[
# Parent header
## Sub header
### Sub sub header
## Sub header 2
]],
            "markdown"
        )

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "Parent header",
                type = "header",
                position = { 1, 0 },
                children = {
                    {
                        name = "Sub header",
                        type = "header",
                        position = { 2, 0 },
                        children = {
                            {
                                name = "Sub sub header",
                                type = "header",
                                position = { 3, 0 },
                                children = {},
                            },
                        },
                    },
                    {
                        name = "Sub header 2",
                        type = "header",
                        position = { 4, 0 },
                        children = {},
                    },
                },
            },
        }, root_nodes)
    end)
end)

describe("parsing lua sections", function()
    local parser = require("sections.parser")

    it("should parse subsequent functions", function()
        local buf = create_buf_with_text(
            [[
function1 = function() end
function function2() end
        ]],
            "lua"
        )

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "function1",
                type = "function",
                position = { 1, 0 },
                children = {},
            },
            {
                name = "function2",
                type = "function",
                position = { 2, 0 },
                children = {},
            },
        }, root_nodes)
    end)

    it("should not parse non-function assignments", function()
        local buf = create_buf_with_text(
            [[
local text = "abcd"
number = 123
        ]],
            "lua"
        )

        local root_nodes = parser.parse_sections(buf)

        assert.are.same(root_nodes, {})
    end)

    it("should parse functions parameters", function()
        local buf = create_buf_with_text(
            [[
function1 = function(p1, p2) end
function function2(p3, p4, p5) end
        ]],
            "lua"
        )

        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = "function1",
                type = "function",
                position = { 1, 0 },
                children = {},
                parameters = { "p1", "p2" },
            },
            {
                name = "function2",
                type = "function",
                position = { 2, 0 },
                children = {},
                parameters = { "p3", "p4", "p5" },
            },
        }, root_nodes)
    end)
end)

describe("parsing python sections", function()
    local parser = require("sections.parser")

    local function create_python_buf(text)
        return create_buf_with_text(text, "python")
    end

    local function assert_has_single_section(buf, type, name, params)
        local root_nodes = parser.parse_sections(buf)

        assert.are.same({
            {
                name = name,
                type = type,
                position = { 1, 0 },
                children = {},
                parameters = params,
            },
        }, root_nodes)
    end

    it("should parse function", function()
        local buf = create_python_buf("def foo():\n  pass")

        assert_has_single_section(buf, "function", "foo")
    end)

    it("should parse functions with parameters", function()
        local buf = create_python_buf([[
def foo(arg1: int, arg2: str, arg3, arg4=None, arg5: int = 1):
    pass
            ]])

        assert_has_single_section(buf, "function", "foo", { "arg1", "arg2", "arg3", "arg4", "arg5" })
    end)

    it("should parse simple class", function()
        local buf = create_python_buf("class SimpleClass:\n  pass")

        assert_has_single_section(buf, "class", "SimpleClass")
    end)

    it("should parse class with parent class", function()
        local buf = create_python_buf("class SimpleClass(Enum):\n  pass")

        assert_has_single_section(buf, "class", "SimpleClass", { "Enum" })
    end)

    it("should parse class with multiple parent classes", function()
        local buf = create_python_buf("class SimpleClass(str, Enum):\n  pass")

        assert_has_single_section(buf, "class", "SimpleClass", { "str", "Enum" })
    end)
end)
