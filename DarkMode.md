# Dark Mode

Dark Mode is an idea promulgated by Apple; invert the theme to use a dark
background and light text instead.

## Websites

Websites that provide a dark theme.

Ideally they would respect [`prefers-color-scheme: dark`](https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme).

| Site          | Supports | Notes                                       |
| ---           | ---      | ---                                         |
| DuckDuckGo    | [x]      | theme selection                             |
| GitHub        | [ ]      |                                             |
| Google        | [ ]      |                                             |
| Hacker News   | [ ]      |                                             |
| Gmail         | [x]      | theme selection                             |
| JSFiddle      | [~]      | became dark after disabling the ad-blocker? |
| Lobste.rs     | [ ]      |                                             |
| Nomadlist     | [x]      | respects `prefers-color-scheme`             |
| Notion        | [x]      | manual toggle                               |
| Reddit        | [x]      | manual toggle                               |
| StackOverflow | [ ]      |                                             |
| Twitter       | [x]      | manual toggle                               |

### Browser extension

For all the sites that are not supported: https://darkreader.org/

I noticed that this extension can take quite a bit of CPU. I assume it is
needed to calculate the inverted colors.

## Browser Support

### Safari

Out of the box

### Firefox

Ships since Firefox 67.

The feature is disabled if the `privacy.resistFingerprinting` option is set to
`true`.

To force a value, create a new entry in `about:config`.

* name: `ui.systemUsesDarkTheme`
* type: `int`
* values: `0` (light) `1` (dark)

If you would like to have a quick method to toggle that setting as an add-on, you can also install [this Firefox add-on](https://addons.mozilla.org/firefox/addon/dark-mode-website-switcher/?src=external-zimbatm).

### References
 
* https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme
* https://blog.iconfactory.com/2018/10/dark-mode-and-css/
