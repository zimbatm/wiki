# Personal wiki + automatic GitHub pages publication

vimwiki <3 github pages.

## How to create your own vim

1. Install the vim plugin: [VimWiki](https://github.com/vimwiki/vimwiki)
2. Add the following in your `~/.vimrc`:

```vim
let g:vimwiki_list = [{ 'path': '~/vimwiki', 'ext': '.md', 'syntax': 'markdown']]
```

