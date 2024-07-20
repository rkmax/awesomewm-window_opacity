local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

-- Define the file path to store window opacity settings
local opacity_file = gears.filesystem.get_cache_dir() .. "window_opacity"

-- Load saved opacities from the file
local function load_opacity()
    local opacities = {}
    local file = io.open(opacity_file, "r")
    if file then
        for line in file:lines() do
            local class, opacity = line:match("^(.-)=(.+)$")
            if class and opacity then
                opacities[class] = tonumber(opacity)
            end
        end
        file:close()
    end
    return opacities
end

-- Save opacities to the file
local function save_opacity(opacities)
    local file = io.open(opacity_file, "w")
    if not file then
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Opacity Error",
                         text = "Failed to open opacity file for writing." })
        return
    end
    for class, opacity in pairs(opacities) do
        local success, result = pcall(function()
            -- Ensure opacity is saved as an integer
            return string.format("%s=%d\n", class, math.floor(opacity))
        end)
        if success then
            file:write(result)
        else
            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Opacity Error",
                             text = "Failed to format opacity for class: " .. class .. "\nError: " .. result })
        end
    end
    file:close()
end

-- Set the opacity of a client window
local function set_opacity(c, opacity)
    local success, result = pcall(function()
        c.opacity = math.floor(opacity) / 100
    end)
    if not success then
        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Opacity Error",
                         text = "Failed to set opacity: " .. result })
    end
end

-- Adjust the opacity of a client window by a given adjustment
local function adjust_opacity(c, adjustment)
    local current_opacity = c.opacity * 100
    local new_opacity = math.max(0, math.min(100, current_opacity + adjustment))
    set_opacity(c, new_opacity)
    return new_opacity
end

-- Handle opacity changes for a client window
local function handle_opacity_change(c, adjustment)
    local opacities = load_opacity()
    local class = c.class

    if adjustment then
        local new_opacity = adjust_opacity(c, adjustment)
        opacities[class] = new_opacity
    else
        local opacity = tonumber(adjustment)
        if opacity then
            set_opacity(c, opacity)
            opacities[class] = opacity
        else
            naughty.notify({ preset = naughty.config.presets.critical,
                             title = "Opacity Error",
                             text = "Invalid opacity value: " .. tostring(adjustment) })
        end
    end

    save_opacity(opacities)
end

-- Restore the saved opacity for a client window
local function restore_opacity(c)
    local opacities = load_opacity()
    local class = c.class
    if opacities[class] then
        set_opacity(c, opacities[class])
    end
end

-- Return the functions to be used externally
return {
    handle_opacity_change = handle_opacity_change,
    restore_opacity = restore_opacity
}
