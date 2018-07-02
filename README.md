# Personal wiki + automatic GitHub pages publication

vimwiki <3 github pages.

## How to create your own wiki

### 1. Setup vim

1. Install the [VimWiki](https://github.com/vimwiki/vimwiki) plugin
2. Add the following in your `~/.vimrc`:
  ```vim
  let g:vimwiki_list = [{ 'path': '~/vimwiki', 'ext': '.md', 'syntax': 'markdown']]
  ```

TODO: find a way to auto-commit-and-push

### 2. Setup GitHub Pages

1. Create a new repo
2. Set "master" as the gh-pages branch: ![xxx](https://pages.github.com/images/source-setting@2x.png)


## References

* https://pages.github.com/

