
--[[

     Dremora Awesome WM config 2.0
     github.com/copycat-killer

--]]

-- {{{ Required libraries
local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local lain          = require("lain")
local shape         = require("gears.shape")
--local menubar       = require("menubar")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local volume_widget = require("volume-widget")

local volume = volume_widget:new({
  backend="pulseaudio",
})

-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Autostart applications
local function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
     findme = cmd:sub(0, firstspace-1)
  end
  awful.spawn.with_shell(string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd))
end

run_once("urxvtd")
run_once("unclutter -root")
-- }}}

-- {{{ Variable definitions
-- beautiful init
beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/dremora/theme.lua")

-- common
local modkey     = "Mod4"
local altkey     = "Mod1"
local terminal   = "lxterminal"
local editor     = os.getenv("EDITOR") or "nano" or "vi"

-- user defined
local browser    = "firefox"
local gui_editor = "emacs"
local graphics   = "gimp"
local filemanager = "thunar"
-- local tagnames   = { "ƀ", "Ƅ", "Ɗ", "ƈ", "ƙ" }
local tagnames   = { "1", "2", "3", "4", "5" }

-- table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- lain
lain.layout.termfair.nmaster        = 3
lain.layout.termfair.ncol           = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol    = 1
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end
-- }}}

-- {{{ Menu
local myawesomemenu = {
    { "hotkeys", function() return false, hotkeys_popup.show_help end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", string.format("%s -e %s %s", terminal, editor, awesome.conffile) },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end }
}
local mymainmenu = freedesktop.menu.build({
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
        -- other triads can be put here
    },
    after = {
        { "Open terminal", terminal },
        -- other triads can be put here
    }
})
--menubar.utils.terminal = terminal -- Set the Menubar terminal for applications that require it
-- }}}

-- {{{ Wibox
local markup     = lain.util.markup
local separators = lain.util.separators
local white      = beautiful.fg_focus
local gray       = "#858585"

-- Textclock
local mytextclock = wibox.widget.textclock(markup(gray, " %a")
.. markup(white, " %d ") .. markup(gray, "%b ") ..  markup(white, "%H:%M "))

-- Calendar
lain.widgets.calendar.attach(mytextclock, { fg = white })

--[[ Mail IMAP check
-- commented because it needs to be set before use
local mailwidget = lain.widgets.imap({
    timeout  = 180,
    server   = "server",
    mail     = "mail",
    password = "keyring get mail",
    settings = function()
        mail_notification_preset.fg = white
        mail  = ""
        count = ""

        if mailcount > 0 then
            mail = "Mail "
            count = mailcount .. " "
        end

        widget:set_markup(markup(gray, mail) .. markup(white, count))
    end
})
]]

-- MPD
local mpdwidget = lain.widgets.mpd({
    settings = function()
        mpd_notification_preset.fg = white
        artist = mpd_now.artist .. " "
        title  = mpd_now.title  .. " "

        if mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        elseif mpd_now.state == "stop" then
            artist = ""
            title  = ""
        end

        widget:set_markup(markup(gray, artist) .. markup(white, title))
    end
})

-- /home fs
local fshome = lain.widgets.fs({
    partition = "/home",
    options = "--exclude-type=tmpfs",
    notification_preset = { fg = white },
    settings  = function()
        fs_header = ""
        fs_p      = ""

        if fs_now.used >= 90 then
            fs_header = " Hdd "
            fs_p      = fs_now.used
        end

        widget:set_markup(markup(gray, fs_header) .. markup(white, fs_p))
    end
})

-- Battery
local batwidget = lain.widgets.bat({
    settings = function()
        bat_header = " Bat "
        bat_p      = bat_now.perc .. " "
        widget:set_markup(markup(gray, bat_header) .. markup(white, bat_p))
    end
})

-- ALSA volume
-- local volicon = wibox.widget.imagebox(beautiful.vol)
-- local alsabar = lain.widgets.alsabar({
--     width = 59, border_width = 0, ticks = true, ticks_size = 6, step = "2%",
--     --togglechannel = "IEC958,3",
--     settings = function()
--         if volume_now.status == "off" then
--             volicon:set_image(beautiful.vol_mute)
--         elseif volume_now.level == 0 then
--             volicon:set_image(beautiful.vol_no)
--         elseif volume_now.level <= 50 then
--             volicon:set_image(beautiful.vol_low)
--         else
--             volicon:set_image(beautiful.vol)
--         end
--     end,
--     colors = {
--         background   = beautiful.bg_normal,
--         mute         = red,
--         unmute       = beautiful.fg_normal
--     }
-- })

local volicon = wibox.widget.imagebox(beautiful.vol)
local volume_bar = wibox.widget {
    forced_height    = 1,
    forced_width     = 60,
    color            = "#A4CE8A",
    background_color = beautiful.bg_normal,
    margins          = 1,
    paddings         = 1,
    ticks            = false,
    ticks_size       = 7,
    widget           = wibox.widget.progressbar,
    layout           = vertical and wibox.container.rotate
}

local extra_volume_bar = wibox.widget {
    forced_height    = 1,
    forced_width     = 31,
    color            = "#ffCE8A",
    background_color = beautiful.bg_normal,
    margins          = 1,
    paddings         = 1,
    ticks            = false,
    ticks_size       = 7,
    widget           = wibox.widget.progressbar,
    layout           = vertical and wibox.container.rotate
}

volume_bar:buttons(awful.util.table.join (
      awful.button({}, 1, function()
        awful.util.spawn_with_shell("pavucontrol")
      end),
      awful.button({}, 2, function()

      end),
      awful.button({}, 3, function()
      end),
      awful.button({}, 4, function()
        volume:up()
        update_volume_widgets()
      end),
      awful.button({}, 5, function()
        volume:down()
        update_volume_widgets()
      end)
))

extra_volume_bar:buttons(awful.util.table.join (
      awful.button({}, 1, function()
        awful.util.spawn_with_shell("pavucontrol")
      end),
      awful.button({}, 2, function()

      end),
      awful.button({}, 3, function()
      end),
      awful.button({}, 4, function()
        volume:up()
        update_volume_widgets()
      end),
      awful.button({}, 5, function()
        volume:down()
        update_volume_widgets()
      end)
))

local volume_bg = wibox.container.background(volume_bar, "#474747", shape.rectangle)
local volume_widget = wibox.container.margin(volume_bg, 2, 7, 4, 4)

local extra_volume_bg = wibox.container.background(extra_volume_bar, "#474747", shape.rectangle)
local extra_volume_widget = wibox.container.margin(extra_volume_bg, 2, 7, 4, 4)

function update_volume_widgets()
  local volume_value = tonumber(volume:getVolume())
  volume_bar:set_value(volume_value/100)

  if volume_value <= 0 then
      volicon:set_image(beautiful.vol_no)
  elseif volume_value == 0 then
      volicon:set_image(beautiful.vol_no)
  elseif volume_value <= 50 then
      volicon:set_image(beautiful.vol_low)
  else
      volicon:set_image(beautiful.vol)
  end

  extra_volume_bar:set_value((volume_value - 100)/50)
end

update_volume_widgets()

volume_timer = timer({ timeout = 5 })
volume_timer:connect_signal("timeout", function()
  update_volume_widgets()
end)

volume_timer:start()

-- Weather
local myweather = lain.widgets.weather({
    city_id = 123456, -- placeholder
    notification_preset = { fg = white }
})

-- Separators
local first     = wibox.widget.textbox('<span font="Tamsyn 4"> </span>')
local arrl_pre  = separators.arrow_right("alpha", "#1A1A1A")
local arrl_post = separators.arrow_right("#1A1A1A", "alpha")

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
   if beautiful.wallpaper then
      for s = 1, screen.count() do
         gears.wallpaper.maximized(beautiful.wallpaper, s, true)
         if s < 2 then
            gears.wallpaper.maximized(beautiful.wallpaper1, s, true)
         else
            gears.wallpaper.maximized(beautiful.wallpaper2, s, true)
         end
      end
        -- local wallpaper = beautiful.wallpaper
        -- -- If wallpaper is a function, call it with the screen
        -- if type(wallpaper) == "function" then
        --     wallpaper = wallpaper(s)
        -- end
        -- gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Quake application
    s.quake = lain.util.quake({ app = terminal })

    -- Wallpaper
    set_wallpaper(s)

    -- Tags
    awful.tag(tagnames, s, awful.layout.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 18 })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            first,
            s.mytaglist,
            arrl_pre,
            s.mylayoutbox,
            arrl_post,
            s.mypromptbox,
            first,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            first,
            -- mpdwidget,
            --mailwidget,
            fshome,
            -- batwidget,
            volicon,
            volume_widget,
            extra_volume_widget,
            -- volume.widget,
            mytextclock,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- Take a screenshot
    -- https://github.com/copycat-killer/dots/blob/master/bin/screenshot
    awful.key({ altkey }, "p", function() os.execute("screenshot") end),

    -- Hotkeys
    -- awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              -- {description="show help", group="awesome"}),
    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    -- Non-empty tag browsing
    -- awful.key({ altkey }, "Left", function () lain.util.tag_view_nonempty(-1) end,
    --           {description = "view  previous nonempty", group = "tag"}),
    -- awful.key({ altkey }, "Right", function () lain.util.tag_view_nonempty(1) end,
    --           {description = "view  previous nonempty", group = "tag"}),

    -- Default client focus
    awful.key({ altkey, modkey     }, "s",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ altkey, modkey     }, "d",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- By direction client focus
    awful.key({ modkey }, "s",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "d",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "a",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey }, "f",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "]", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "s", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "d", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "s", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "d", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Show/Hide Wibox
    awful.key({ modkey }, "b", function ()
        for s in screen do
            s.mywibox.visible = not s.mywibox.visible
        end
    end),

    -- On the fly useless gaps change
    awful.key({ altkey, "Control" }, "+", function () lain.util.useless_gaps_resize(1) end),
    awful.key({ altkey, "Control" }, "-", function () lain.util.useless_gaps_resize(-1) end),

    -- Dynamic tagging
    awful.key({ modkey, "Shift" }, "n", function () lain.util.add_tag() end),
    awful.key({ modkey, "Shift" }, "r", function () lain.util.rename_tag() end),
    awful.key({ modkey, "Shift" }, "Left", function () lain.util.move_tag(1) end),   -- move to next tag
    awful.key({ modkey, "Shift" }, "Right", function () lain.util.move_tag(-1) end), -- move to previous tag
    -- awful.key({ modkey, "Shift" }, "d", function () lain.util.delete_tag() end),

    -- Standard program
    awful.key({ modkey,           }, "t", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "Escape", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ altkey, "Shift"   }, "f",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ altkey, "Shift"   }, "a",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "a",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "f",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "a",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "f",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ modkey,           }, "BackSpace", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                      client.focus = c
                      c:raise()
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Dropdown application
    awful.key({ modkey, }, "z", function () awful.screen.focused().quake:toggle() end),

    -- Widgets popups
    -- awful.key({ altkey, }, "c", function () lain.widgets.calendar.show(7) end),
    -- awful.key({ altkey, }, "a", function () fshome.show(7) end),
    -- awful.key({ altkey, }, "w", function () myweather.show(7) end),

    -- Calculator
    awful.key({ modkey }, "k", function()
          awful.util.spawn_with_shell("speedcrunch")
    end),

    awful.key({}, "Print", function()
          awful.util.spawn_with_shell("gnome-screenshot")
          -- os.execute("gnome-screenshot -a -i")
    end),

    awful.key({ "Shift" }, "Print", function()
          awful.util.spawn_with_shell("gnome-screenshot -a")
          -- os.execute("gnome-screenshot -a -i")
    end),

    awful.key({ "Control" }, "Print", function()
          awful.util.spawn_with_shell("gnome-screenshot -w")
          -- os.execute("gnome-screenshot -a -i")
    end),

    -- ALSA volume control
    awful.key({}, "XF86AudioRaiseVolume", function()
      volume:up()
      update_volume_widgets()
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
      volume:down()
      update_volume_widgets()
    end),
    awful.key({}, "XF86AudioMute",
        function ()
            os.execute(string.format("amixer set %s toggle", volume.togglechannel or volume.channel))
            volume.update()
        end),

    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
        function ()
            awful.spawn.with_shell("mpc toggle || ncmpc toggle || pms toggle")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Down",
        function ()
            awful.spawn.with_shell("mpc stop || ncmpc stop || pms stop")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Left",
        function ()
            awful.spawn.with_shell("mpc prev || ncmpc prev || pms prev")
            mpdwidget.update()
        end),
    awful.key({ altkey, "Control" }, "Right",
        function ()
            awful.spawn.with_shell("mpc next || ncmpc next || pms next")
            mpdwidget.update()
        end),
    --]]

    -- Copy primary to clipboard
    awful.key({ modkey }, "c", function () os.execute("xsel | xsel -b") end),

    -- User programs
    awful.key({ modkey }, "q", function () awful.spawn(browser) end),
    awful.key({ modkey }, "e", function () awful.spawn(gui_editor) end),
    awful.key({ modkey }, "g", function () awful.spawn(graphics) end),
    awful.key({ modkey }, "c", function () awful.spawn(filemanager) end),

    -- Default
    -- Prompt
    -- awful.key({ modkey }, "r", function () awful.screen.focused().mypromptbox:run() end,
              -- {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "r", function () awful.util.spawn("rofi -show drun -modi drun") end),
    awful.key({ modkey }, "w", function () awful.util.spawn("rofi -show window") end),
    -- awful.key({ modkey }, "s",function () awful.util.spawn("rofi -show ssh") end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
    --]]

    --[[ dmenu
    awful.key({ modkey }, "x", function ()
        awful.spawn(string.format("dmenu_run -i -fn 'Tamsyn' -nb '%s' -nf '%s' -sb '%s' -sf '%s'",
        beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
		end)
    --]]
)

clientkeys = awful.util.table.join(
    awful.key({ altkey, "Shift"   }, "m",      lain.util.magnify_client                         ),
    awful.key({ modkey,           }, "l",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     size_hints_honor = false
     }
    },

    -- Titlebars
    { rule_any = { type = { "dialog", "normal" } },
      properties = { titlebars_enabled = true } },

    -- Set Firefox to always map on the first tag on screen 1.
    { rule = { class = "Firefox" },
      properties = { screen = 1, tag = awful.screen.focused().tags[1] } },

    { rule = { class = "Gimp", role = "gimp-image-window" },
          properties = { maximized_horizontal = true,
                         maximized_vertical = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
-- client.connect_signal("request::titlebars", function(c)
--     -- buttons for the titlebar
--     local buttons = awful.util.table.join(
--         awful.button({ }, 1, function()
--             client.focus = c
--             c:raise()
--             awful.mouse.client.move(c)
--         end),
--         awful.button({ }, 3, function()
--             client.focus = c
--             c:raise()
--             awful.mouse.client.resize(c)
--         end)
--     )

--     awful.titlebar(c, {size = 16}) : setup {
--         { -- Left
--             awful.titlebar.widget.iconwidget(c),
--             buttons = buttons,
--             layout  = wibox.layout.fixed.horizontal
--         },
--         { -- Middle
--             { -- Title
--                 align  = "center",
--                 widget = awful.titlebar.widget.titlewidget(c)
--             },
--             buttons = buttons,
--             layout  = wibox.layout.flex.horizontal
--         },
--         { -- Right
--             awful.titlebar.widget.floatingbutton (c),
--             awful.titlebar.widget.maximizedbutton(c),
--             awful.titlebar.widget.stickybutton   (c),
--             awful.titlebar.widget.ontopbutton    (c),
--             awful.titlebar.widget.closebutton    (c),
--             layout = wibox.layout.fixed.horizontal()
--         },
--         layout = wibox.layout.align.horizontal
--     }
-- end)

-- Enable sloppy focus, so that focus follows mouse.
--[[
client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)
]]

-- No border for maximized clients
client.connect_signal("focus",
    function(c)
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = 0
        -- no borders if only 1 client visible
        elseif #awful.client.visible(mouse.screen) > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

awful.util.spawn("redshift -l 55.0084:82.9357");
awful.spawn.with_shell("~/.config/awesome/autorun.sh");
