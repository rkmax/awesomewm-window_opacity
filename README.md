# AwesomeWM Window Opacity Manager

## What's This?

This project is a script for AwesomeWM that lets you manage window opacity based on their class. It automatically saves and restores window opacity using a cache file.

## What You Need

- AwesomeWM
- Lua
- AwesomeWM libraries: `awful`, `gears`, `naughty`
- A compositor like [picom](https://github.com/yshui/picom) for transparency to work

## How to Install

1. Clone this repository into your AwesomeWM configuration directory:

    ```sh
    git clone https://github.com/rkmax/awesomewm-window_opacity.git ~/.config/awesome/window_opacity
    ```

2. Include the script in your AwesomeWM configuration (`rc.lua`):

    ```lua
    local window_opacity = require("window_opacity")

    -- Connect the 'manage' signal to restore opacity when managing a new window
    client.connect_signal("manage", function(c)
        window_opacity.restore_opacity(c)
    end)
    ```

3. Add keybindings to adjust the opacity of windows in your AwesomeWM configuration (`rc.lua`):

    ```lua
    local window_opacity = require("window_opacity")

    -- Increase opacity (we use = because when Shift is pressed, + is returned)
    awful.key({ modkey, "Shift" }, "=", function()
        if client.focus then
            window_opacity.handle_opacity_change(client.focus, 5)
        end
    end, {description = "increase window opacity", group = "client"}),

    -- Decrease opacity
    awful.key({ modkey, "Shift" }, "-", function()
        if client.focus then
            window_opacity.handle_opacity_change(client.focus, -5)
        end
    end, {description = "decrease window opacity", group = "client"}),

    -- Set opacity to specific value
    awful.key({ modkey, "Shift" }, "0", function()
        if client.focus then
            window_opacity.handle_opacity_change(client.focus, 100)
        end
    end, {description = "set window opacity to 100%", group = "client"}),
    ```

4. Make sure the `awful`, `gears`, and `naughty` libraries are available in your AwesomeWM configuration.

5. Add a global function to adjust opacity from the command line in your AwesomeWM configuration (`rc.lua`):

    ```lua
    -- Define a global function to adjust opacity from the command line
    _G.adjust_opacity = function(adjustment)
        if client.focus then
            window_opacity.handle_opacity_change(client.focus, adjustment)
        end
    end
    ```

## How to Use

The script will automatically manage the opacity of windows based on their class. You can tweak the opacity of a window in real-time using the `handle_opacity_change` function or the keybindings you've set up.

### Example Usage

To change the opacity of the active window using keybindings:

- Increase the opacity of the active window: `Mod + Shift + =` (increases by 5%)
- Decrease the opacity of the active window: `Mod + Shift + -` (decreases by 5%)
- Set the opacity of the active window to 100%: `Mod + Shift + 0`

To change the opacity of the active window programmatically:

```lua
-- Increase the opacity of the active window by 5 units
window_opacity.handle_opacity_change(client.focus, 5)

-- Decrease the opacity of the active window by 5 units
window_opacity.handle_opacity_change(client.focus, -5)

-- Set the opacity of the active window to 100%
window_opacity.handle_opacity_change(client.focus, 100)
```

To change the opacity of the active window from the command line:

```sh
awesome-client 'adjust_opacity(5)'