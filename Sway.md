# Sway is a Wayland Desktop Environment

It needs a bit of work to make it confortable

https://wiki.archlinux.org/index.php/Sway

https://github.com/swaywm/sway/wiki/i3-Migration-Guide#common-xorg-apps-used-on-i3-with-wayland-alternatives


## X1 Yoga report

Login manager: broken

Camera: working

Sound: working

Network: working

RedShift: ???

Wacom: not configurable?

Copy-paste seems to be working fine

## Rofi

Doesn't seem to be well supported: https://github.com/DaveDavenport/rofi/wiki/Wayland

sway also wants to control the launch of new applications but rofi executes
them directly instead of printing to stdout like dmenu does

## Termite

Really cool term for keyboard-centric workflows

* ctrl+shift+u for URL opening. requires xdg_utils to work.
* ctrl+shift+space for VIM selection mode

https://wiki.archlinux.org/index.php/Termite

## TODO

notify-osd for wayland?
No OSD display for things like volume and brightness changes

Disable HiDPI: https://wiki.archlinux.org/index.php/HiDPI#GUI_toolkits

https://github.com/greshake/i3status-rust/blob/07e5ffeb50aa37bc634158555704879d7a1e1cee/blocks.md

fix brightnessctl

Notification center (mako)

Keyring / Keychain

Remember all the key shortcuts

kanshi GUI

RedShift replacement

i3 menu entries

Color schemes
Configure .Xresources


Wacom + Wayland needs xorg 1.20, nixpkgs-unstable ships with 1.19

https://www.phoronix.com/scan.php?page=news_item&px=XWayland-Tablet-Pads

## kanshi 

Supposed to be a GUI for display configuration, still very young

https://github.com/emersion/kanshi

## Known issues

XWayland doesn't support scaling[1].

Google Chrome seems to be using XWayland but was supposed to have Wayland
support in Chrome 50

  https://askubuntu.com/questions/946763/chrome-wayland-scaling-issue
  
Slack doesn't like my wacom input

Hangouts screen sharing can only share X11 apps (makes sense)
  
[1]: https://bugs.freedesktop.org/show_bug.cgi?id=101193
[2]: https://bugs.freedesktop.org/show_bug.cgi?id=108632

