# Personal wiki + automatic GitHub pages publication

vimwiki <3 github pages.

## How to create your own wiki

### 1. Setup vim

1. Install the [VimWiki](https://github.com/vimwiki/vimwiki) plugin
2. Optionally install the [Calendar](https://github.com/mattn/calendar-vim)
   plugin
3. Add the following in your `~/.vimrc`:

```vim
let g:vimwiki_list = [{'path': '~/vimwiki', 'ext': '.md', 'syntax': 'markdown', 'auto_toc': 1, 'diary_index': 'index'}]
let g:vimwiki_dir_link = 'index'
let g:vimwiki_use_calendar = 1
```
### 2. Setup GitHub Pages

1. Create a new repo
2. Set "master" as the gh-pages branch: ![xxx](https://pages.github.com/images/source-setting@2x.png)


## References

* https://pages.github.com/

## TODO

find a way to auto-commit-and-push

### sync valid HTML tags with GFM

Here is the default list:
```vim
let g:vimwiki_valid_html_tags='b,i,s,u,sub,sup,kbd,br,hr'
```
