describe("should display sections", function()
    local formatter = require("sections.formatter")

    it("should format sequential sections", function()
        local sections = {
            {
                name = "First header", type = "header", position = {1, 1},
                children = {},
            },
            {
                name = "Second header", type = "header", position = {5, 1},
                children = {},
            }
        }

        formatter.update_sections(sections)

        assert.are.same(
            { "First header", "Second header" },
            formatter.format()
        )
    end)

    it("should format nested sections", function()
        local sections = {
            {
                name = "Parent header", type = "header", position = {1, 1},
                children = {
                    {
                        name = "Sub header", type = "header", position = {1, 1},
                        children = {}
                    }
                },
            },
        }

        formatter.update_sections(sections)

        assert.are.same(
            { "Parent header", "  Sub header" },
            formatter.format()
        )
    end)

end)
