

# Wacom Intuos BT M

```
$ nix run nixpkgs.libinput
$ libinput list-devices
```

The wacom tables has two decides: one for the pen and one for the buttons on
the pad.

# Device 2

```
version: 1
ndevices: 1
libinput:
  version: "1.11.3"
  git: "unknown"
system:
  kernel: "4.14.78"
  dmi: "dmi:bvnLENOVO:bvrN1FET64W(1.38):bd07/25/2018:svnLENOVO:pn20FQ0040UK:pvrThinkPadX1Carbon4th:rvnLENOVO:rn20FQ0040UK:rvrSDK0J40697WIN:cvnLENOVO:ct31:cvrNone:"
devices:
- node: /dev/input/event19
  evdev:
    # Name: Wacom Intuos BT M Pad
    # ID: bus 0x3 vendor 0x56a product 0x378 version 0x110
    # Size in mm: unknown, missing resolution
    # Supported Events:
    # Event type 0 (EV_SYN)
    # Event type 1 (EV_KEY)
    #   Event code 256 (BTN_0)
    #   Event code 257 (BTN_1)
    #   Event code 258 (BTN_2)
    #   Event code 259 (BTN_3)
    #   Event code 331 (BTN_STYLUS)
    # Event type 3 (EV_ABS)
    #   Event code 0 (ABS_X)
    #       Value           0
    #       Min             0
    #       Max             1
    #       Fuzz            0
    #       Flat            0
    #       Resolution      0
    #   Event code 1 (ABS_Y)
    #       Value           0
    #       Min             0
    #       Max             1
    #       Fuzz            0
    #       Flat            0
    #       Resolution      0
    #   Event code 40 (ABS_MISC)
    #       Value           0
    #       Min             0
    #       Max             0
    #       Fuzz            0
    #       Flat            0
    #       Resolution      0
    # Properties:
    name: "Wacom Intuos BT M Pad"
    id: [3, 1386, 888, 272]
    codes:
      0: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] # EV_SYN
      1: [256, 257, 258, 259, 331] # EV_KEY
      3: [0, 1, 40] # EV_ABS
    absinfo:
      0: [0, 1, 0, 0, 0]
      1: [0, 1, 0, 0, 0]
      40: [0, 0, 0, 0, 0]
    properties: []
  udev:
    properties:
    - ID_INPUT=1
    - ID_INPUT_TABLET=1
    - LIBINPUT_DEVICE_GROUP=3/56a/378:usb-0000:00:14.0-6
  events:
  - evdev:
    - [  0,      0,   1, 256,     1] # EV_KEY / BTN_0                   1
    - [  0,      0,   3,  40,    15] # EV_ABS / ABS_MISC               15
    - [  0,      0,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +0ms
  - evdev:
    - [  0,  93993,   1, 256,     0] # EV_KEY / BTN_0                   0
    - [  0,  93993,   3,  40,     0] # EV_ABS / ABS_MISC                0
    - [  0,  93993,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +0ms
  - evdev:
    - [  0, 740042,   1, 257,     1] # EV_KEY / BTN_1                   1
    - [  0, 740042,   3,  40,    15] # EV_ABS / ABS_MISC               15
    - [  0, 740042,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +647ms
  - evdev:
    - [  0, 823470,   1, 257,     0] # EV_KEY / BTN_1                   0
    - [  0, 823470,   3,  40,     0] # EV_ABS / ABS_MISC                0
    - [  0, 823470,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +83ms
  - evdev:
    - [  2, 370018,   1, 258,     1] # EV_KEY / BTN_2                   1
    - [  2, 370018,   3,  40,    15] # EV_ABS / ABS_MISC               15
    - [  2, 370018,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +1547ms
  - evdev:
    - [  2, 480015,   1, 258,     0] # EV_KEY / BTN_2                   0
    - [  2, 480015,   3,  40,     0] # EV_ABS / ABS_MISC                0
    - [  2, 480015,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +110ms
  - evdev:
    - [  3,  14083,   1, 259,     1] # EV_KEY / BTN_3                   1
    - [  3,  14083,   3,  40,    15] # EV_ABS / ABS_MISC               15
    - [  3,  14083,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +534ms
  - evdev:
    - [  3, 170023,   1, 259,     0] # EV_KEY / BTN_3                   0
    - [  3, 170023,   3,  40,     0] # EV_ABS / ABS_MISC                0
    - [  3, 170023,   0,   0,     0] # ------------ SYN_REPORT (0) ---------- +156ms
```
