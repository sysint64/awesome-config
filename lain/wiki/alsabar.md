Shows and controls ALSA volume with a progressbar; provides tooltips, notifications, and color changes at mute/unmute switch.

```lua
volume = lain.widgets.alsabar()
```

* Left click: launch `alsamixer` in your `terminal`.
* Right click: mute/unmute.
* Scroll wheel: increase/decrase volume.
* Middle click: set volume to 100%.

### Input table

The table and all of its variables are optional.

Variable | Meaning | Type | Default
--- | --- | --- | ---
`timeout` | Refresh timeout seconds | int | 5
`settings` | User settings | function | empty function
`width` | Bar width | int | 63
`height` | Bar height | int | 1
`ticks` | Set bar ticks on | boolean | false
`ticks_size` | Ticks size | int | 7
`vertical` | Set the bar vertical | boolean | false
`cmd` | ALSA mixer command | string | "amixer"
`channel` | Mixer channel | string | "Master"
`togglechannel` | Toggle channel | string | `nil`
`step` | Step at which volume is increased/decreased | string | "1%"
`colors` | Bar colors | table | see **colors**
`notifications` | Notifications settings | table | see **notifications**
`followtag` | Display the notification on currently focused screen | boolean | false

`cmd` is useful if you need to pass additional arguments to  `amixer`. For instance, users with multiple sound cards may define `command = "amixer -c X"` in order to set amixer with card `X`.

In case you are using an HDMI output, and mute toggling can't be mapped to `Master`, define `togglechannel` argument as your S/PDIF device. Read [alsa widget](https://github.com/copycat-killer/lain/wiki/alsa) page to know how.

### Colors

Variable | Meaning | Type | Default
--- | --- | --- | ---
`background` | Bar backgrund color | string | `beautiful.bg_normal`
`mute` | Bar mute color | string | "#EB8F8F"
`unmute` | Bar unmute color | string | "#A4CE8A"

### Notifications

Variable | Meaning | Type | Default
--- | --- | --- | ---
`font` | Notifications font | string | The one defined in `beautiful.font`
`font_size` | Notifications font size | string | "11"
`color` | Notifications color | string | `beautiful.fg_normal`

`settings` can use the following variables:

Variable | Meaning | Type | Values
--- | --- | --- | ---
`volume_now.level` | Self explained | int | 0-100
`volume_now.status` | Device status | string | "on", "off"

### Output table

Variable | Meaning | Type
--- | --- | ---
`bar` | The widget | `wibox.widget.progressbar`
`channel` | Alsa channel | string
`card` | Alsa card | string
`step` | Increase/decrease step | string
`notify` | The notification | function
`update` | Update state | function

In multiple screen setups, the default behaviour is to show a visual notification pop-up window on the first screen. By setting `followtag` to `true` it will be shown on the currently focused tag screen.

You can control the widget with key bindings like these:

```lua
-- ALSA volume control
awful.key({ altkey }, "Up",
	function ()
		os.execute(string.format("amixer set %s %s+", volume.channel, volume.step))
		volume.update()
	end),
awful.key({ altkey }, "Down",
	function ()
		os.execute(string.format("amixer set %s %s-", volume.channel, volume.step))
		volume.update()
	end),
awful.key({ altkey }, "m",
	function ()
		os.execute(string.format("amixer set %s toggle", volume.togglechannel or volume.channel))
		volume.update()
	end),
awful.key({ altkey, "Control" }, "m",
	function ()
		os.execute(string.format("amixer set %s 100%%", volume.channel))
		volume.update()
	end),
awful.key({ altkey, "Control" }, "0",
	function ()
		os.execute(string.format("amixer set %s 0%%", volume.channel))
		volume.update()
	end),
```

where `altkey = "Mod1"`.
