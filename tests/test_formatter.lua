describe("should display sections", function()
    local formatter = require("sections.formatter")
    local config = require("sections.config")

    config.init({
        icons = {
            ["function"] = "f",
            header = "#",
        },
    })

    it("should format sequential sections", function()
        local sections = {
            {
                name = "First header",
                type = "header",
                position = { 1, 1 },
                children = {},
            },
            {
                name = "Second header",
                type = "header",
                position = { 5, 1 },
                children = {},
            },
        }

        formatter.update_sections(sections)

        assert.are.same({ "# First header", "# Second header" }, formatter.format())
    end)

    it("should format nested sections", function()
        local sections = {
            {
                name = "Parent header",
                type = "header",
                position = { 1, 1 },
                children = {
                    {
                        name = "Sub header",
                        type = "header",
                        position = { 1, 1 },
                        children = {},
                    },
                },
            },
        }

        formatter.update_sections(sections)

        assert.are.same({ "# Parent header", "  # Sub header" }, formatter.format())
    end)

    it("should format header section", function()
        formatter.update_sections({
            {
                name = "First header",
                type = "header",
                children = {},
            },
        })

        local lines = formatter.format()

        assert.are.same({ "# First header" }, lines)
    end)

    it("should format function section", function()
        formatter.update_sections({
            {
                name = "foo",
                type = "function",
                children = {},
            },
        })

        local lines = formatter.format()

        assert.are.same({ "f foo()" }, lines)
    end)

    it("should format function section with parameters", function()
        formatter.update_sections({
            {
                name = "foo",
                type = "function",
                children = {},
                parameters = { "abc", "bar" },
            },
        })

        local lines = formatter.format()

        assert.are.same({ "f foo(abc, bar)" }, lines)
    end)

    it("should not collapse section when it has no child", function()
        formatter.update_sections({
            {
                name = "foo",
                type = "function",
                children = {},
                parameters = { "abc", "bar" },
            },
        })

        formatter.collapse(1)
        local lines = formatter.format()

        assert.are.same({ "f foo(abc, bar)" }, lines)
    end)

    it("should collapse section", function()
        formatter.update_sections({
            {
                name = "foo",
                type = "function",
                children = {
                    {
                        name = "foo",
                        type = "function",
                        children = {},
                    },
                },
            },
        })

        formatter.collapse(1)
        assert.are.same({ "f foo() ..." }, formatter.format())

        formatter.collapse(1)
        assert.are.same({ "f foo()", "  f foo()" }, formatter.format())
    end)
end)

describe("should get section pos", function()
    local formatter = require("sections.formatter")

    it("should retrieve position of sequential sections", function()
        formatter.update_sections({
            {
                name = "First header",
                type = "header",
                position = { 1, 1 },
                children = {},
            },
            {
                name = "Second header",
                type = "header",
                position = { 5, 1 },
                children = {},
            },
        })

        local section_pos = formatter.get_section_pos(2)

        assert.are.same({ 5, 1 }, section_pos)
    end)
    it("should retrieve position of nested sections", function()
        formatter.update_sections({
            {
                name = "First header",
                type = "header",
                position = { 1, 1 },
                children = {
                    {
                        name = "Sub header",
                        type = "header",
                        position = { 3, 1 },
                        children = {},
                    },
                },
            },
            {
                name = "Second header",
                type = "header",
                position = { 5, 1 },
                children = {},
            },
        })

        local section_pos = formatter.get_section_pos(2)

        assert.are.same({ 3, 1 }, section_pos)
    end)
end)
