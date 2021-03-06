Shows disk space usage for a set partition.

Displays a notification when the partition is full or has low space.

```lua
mypartition = lain.widgets.fs()
```

### Input table

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds -| int | 600
`partition` | Partition to monitor | string | "/"
`options` | Additional options to pass to [`dfs`](https://github.com/copycat-killer/lain/blob/master/scripts/dfs) | string, in the form `--type='fstype' | --exclude-type='fstype'` | nil
`notification_preset` | Notification preset | table | `{ fg = beautiful.fg_normal }`
`followtag` | Display the notification on currently focused screen | boolean | false
`notify` | Display notifications | string | "on"
`showpopup` | Display df popups with mouse hovering | string, possible values: "on", "off" | "on"
`settings` | User settings | function | empty function

`settings` can use the following `partition` related float values:

* `fs_now.available`
* `fs_now.size_mb`
* `fs_now.size_gb`
* `fs_now.used`
* `fs_now.used_mb`
* `fs_now.used_gb`

Within `settings`, you can obtain other partition values from internal `fs_info` table. For each partition, the following indexes are available:

*  `fs_info[other_partition .. " avail_p"]`
*  `fs_info[other_partition .. " size_mb"]`
*  `fs_info[other_partition .. " size_gb"]`
*  `fs_info[other_partition .. " used_p"]`
*  `fs_info[other_partition .. " used_mb"]`
*  `fs_info[other_partition .. " used_gb"]`

just like the variables of `fs_now`. Example:

```lua
-- shows root and home partitions percentage used
fsroothome = lain.widgets.fs({
    settings  = function()
        local home_used = tonumber(fs_info["/home used_p"]) or 0
        widget:set_text("/ " .. fs_now.used .. "% | /home " .. home_used .. "% ")
    end
})
```

Also, `settings` can modify `notification_preset` table. This table will be the preset for the naughty notifications. Check [here](https://awesomewm.org/doc/api/libraries/naughty.html#notify) for the list of variables it can contain. Default definition:

```lua
notification_preset = { fg = beautiful.fg_normal }
```

In multiple screen setups, the default behaviour is to show a visual notification pop-up window on the first screen. By setting `followtag` to `true` it will be shown on the currently focused tag screen.

### Output table

Variable | Meaning | Type
--- | --- | ---
`widget` | The widget | `wibox.widget.textbox`
`show` | The notification | function

You can display the notification with a key binding like this:

```lua
awful.key({ altkey }, "h", function () mypartition.show(seconds, scr) end),
```

where ``altkey = "Mod1"`` and ``show`` arguments, all optionals, are:

* `seconds`, notification time in seconds
* `scr`, screen in which display the notification

**Note that** naughty notifications requires `beautiful.font` or `notification_preset.font` to be monospaced, in order to correctly display the output.
