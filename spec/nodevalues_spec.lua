describe("nodevalues", function()
    local nodevalues
    local constants

    setup(function()
        nodevalues = require("nodevalues")
        constants = require("constants")
    end)

    teardown(function()
        nodevalues = nil
        package.loaded["nodevalues"] = nil
        constants = nil
        package.loaded["constants"] = nil
    end)

    describe("node", function()

        for k, v in pairs(nodevalues) do
            local category_id, exp = unpack(v)

            it(k .. " should have a proper category", function()
                local category_name = constants.SKILLS[category_id]
                assert.is.truthy(category_name)
            end)

            it(k .. " should have an experience value greater than 0", function()
                assert.is_true(exp > 0)
            end)
        end
    end)
end)
