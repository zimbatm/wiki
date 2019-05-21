# Dark Mode


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
| Nomadlist     | [x]      |                                             |
| Notion        | [~]      | manual toggle                               |
| Reddit        | [x]      | manual toggle                               |
| StackOverflow | [ ]      |                                             |
| Twitter       | [~]      | manual toggle                               |

### Browser extension

For all the sites that are not supported: https://darkreader.org/

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

### References
 
* https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-color-scheme
* https://blog.iconfactory.com/2018/10/dark-mode-and-css/
