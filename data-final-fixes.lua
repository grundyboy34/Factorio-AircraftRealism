-- Collision while on the ground is done by having a separate copy of each plane, teleporting the player into the grounded version once below landing speed
-- and out into the flyable one surpassing landing speed

require("prototypes.airbornePlanes") -- Make airborne plane clones first

------------------------------
-- Landed versions of planes
------------------------------

-- (Compared to the default aircraft from Aircraft)
-- Disallows planes to turn on the spot
-- Increases the turn radius
-- Lowers braking power for longer landing stoping distance
-- Less health on ground for more severe impact damage (divided by 2)
-- More weight for slower acceleration (~5x)

-- WARNING
-- max_health must be the max_health of the original plane DIVIDED BY 2
function ExtendGroundedAircraft(name, rotation_speed, braking_power, max_health, weight, collision_box)
    data.raw.car[name].collision_mask = {"player-layer", "train-layer"}

    if settings.startup["aircraft-realism-turn-radius"].value then
        data.raw.car[name].tank_driving = false
        data.raw.car[name].rotation_speed = rotation_speed
    end

    if settings.startup["aircraft-realism-acceleration"].value then
        data.raw.car[name].weight = weight
        data.raw.car[name].friction = 0.0001 -- Lower the friction so the plane can still reach its max speed
    end

    if settings.startup["aircraft-realism-braking-speed"].value then
        data.raw.car[name].braking_power = braking_power
    end

    if settings.startup["aircraft-realism-takeoff-health"].value then
        data.raw.car[name].max_health = max_health
        data.raw.car[name].repair_speed_modifier = 0.5; -- Account for less health by reducing the repair speed by 2x
    end

    -- Fuel consumption multiplier
    -- Substring off kW, convert to number, multiply, convert back to string and append kW
    data.raw.car[name].consumption = tostring(
        tonumber(
            string.sub(data.raw.car[name].consumption, 1, string.len(data.raw.car[name].consumption) - 2)
        ) * settings.startup["aircraft-realism-fuel-usage-multiplier-grounded"].value / 10 --It seems to get it a decimal place off
    ) .. string.sub(data.raw.car[name].consumption, string.len(data.raw.car[name].consumption) - 2)

    -- Lower the fuel effectivity so the plane handles the same
    data.raw.car[name].effectivity = data.raw.car[name].effectivity / settings.startup["aircraft-realism-fuel-usage-multiplier-grounded"].value


    -- Collisions and selection
    data.raw.car[name].collision_box = collision_box
    data.raw.car[name].selection_box = collision_box
end

-- Gunship
ExtendGroundedAircraft("gunship", 0.008, "380kW", 250, 3750, {{-2, -2}, {2, 2}})
-- Cargo plane
ExtendGroundedAircraft("cargo-plane", 0.006, "610kW", 250, 20500, {{-1.5, -1.5}, {1.5, 1.5}})
-- Jet
ExtendGroundedAircraft("jet", 0.005, "540kW", 125, 1500, {{-2, -2}, {2, 2}})
-- Flying fortress
ExtendGroundedAircraft("flying-fortress", 0.01, "2620kW", 1000, 15000, {{-2, -2}, {2, 2}})


------------------------------------------------------
-- OTHER MODS
------------------------------------------------------

-- Better cargo planes
if mods["betterCargoPlanes"] then
    ExtendGroundedAircraft("better-cargo-plane", 0.0065, "1080kW", 200, 31500, {{-1.3, -1.3}, {1.3, 1.3}}) --Gets more breaking power, turn radius since it is better, heavier too since it has more inventory
    ExtendGroundedAircraft("even-better-cargo-plane", 0.007, "1680kW", 400, 37500, {{-1.3, -1.3}, {1.3, 1.3}})
end