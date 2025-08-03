describe("should display sections", function()
    local formatter = require("sections.formatter")

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

        assert.are.same({ "First header", "Second header" }, formatter.format())
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

        assert.are.same({ "Parent header", "  Sub header" }, formatter.format())
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
