Config = {}

-- Framework: 'esx' or 'qbcore'
Config.Framework = 'esx' -- Change to 'qbcore' if using QBCore

-- Shop locations with NPCs and blips
Config.Shops = {
    {
        name = "24/7 Store",
        coords = vector3(25.7, -1347.3, 29.49),
        heading = 180.0,
        blip = {
            sprite = 52,
            color = 2,
            scale = 0.8
        },
        npc = {
            model = "mp_m_shopkeep_01",
            heading = 180.0
        },
        items = {
            {
                name = "bread",
                label = "Bread",
                price = 5,
                image = "trash_bread.png",
                description = "Fresh baked bread for your daily needs"
            },
            {
                name = "water",
                label = "Water Bottle",
                price = 3,
                image = "water.png",
                description = "Clean drinking water to stay hydrated"
            },
            {
                name = "burger",
                label = "Cheese Burger",
                price = 12,
                image = "burger.png",
                description = "Delicious ham and cheese burger"
            },
            {
                name = "phone",
                label = "Mobile Phone",
                price = 200,
                image = "phone.png",
                description = "Latest smartphone with all features"
            }
        }
    },
    {
        name = "Ammunation",
        coords = vector3(1693.44, 3759.50, 34.70),
        heading = 90.0,
        blip = {
            sprite = 110,
            color = 1,
            scale = 0.8
        },
        npc = {
            model = "s_m_y_ammucity_01",
            heading = 90.0
        },
        items = {
            {
                name = "pistol",
                label = "Pistol",
                price = 1500,
                image = "pistol.png",
                description = "Standard issue pistol for protection"
            },
            {
                name = "pistol_ammo",
                label = "Pistol Ammo",
                price = 25,
                image = "pistol_ammo.png",
                description = "9mm ammunition for pistols"
            }
        }
    },
    {
        name = "Clothing Store",
        coords = vector3(72.3, -1399.1, 29.4),
        heading = 270.0,
        blip = {
            sprite = 73,
            color = 3,
            scale = 0.8
        },
        npc = {
            model = "s_f_y_shop_low",
            heading = 270.0
        },
        items = {
            {
                name = "tshirt",
                label = "T-Shirt",
                price = 45,
                image = "tshirt.png",
                description = "Comfortable cotton t-shirt"
            },
            {
                name = "jeans",
                label = "Jeans",
                price = 85,
                image = "jeans.png",
                description = "Classic blue denim jeans"
            },
            {
                name = "sneakers",
                label = "Sneakers",
                price = 120,
                image = "sneakers.png",
                description = "Comfortable running sneakers"
            }
        }
    }
}

-- Settings
Config.MaxDistance = 3.0  -- Distance to interact with NPC
Config.DrawText = true    -- Show interaction text
Config.UseTarget = false  -- Set to true if using ox_target or qb-target