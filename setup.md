# Personal wiki + automatic GitHub pages publication

vimwiki <3 github pages.

## How to create your own wiki

### 1. Setup vim

1. Install the [VimWiki](https://github.com/vimwiki/vimwiki) plugin
2. Optionally install the [Calendar](https://github.com/mattn/calendar-vim)
   plugin
3. Add the following in your `~/.vimrc`:

```vim
let wiki_1 = {}
let wiki_1.path = '~/vimwiki'
let wiki_1.ext = '.md'
let wiki_1.syntax = 'markdown'
let wiki_1.auto_toc = 1
" Move the diary to the top-level to avoid linking issues
let wiki_1.diary_rel_path = ''
let g:vimwiki_list = [wiki_1]
let g:vimwiki_dir_link = 'index'
let g:vimwiki_use_calendar = 1
```
### 2. Setup GitHub Pages

1. Create a new repo
2. Set "master" as the gh-pages branch: ![xxx](https://pages.github.com/images/source-setting@2x.png)


## References

* https://pages.github.com/
* http://thedarnedestthing.com/vimwiki%20cheatsheet
* https://rubygems.org/gems/github-pages

## Known issues

### no auto-commit-and-push

It's easy to forget to commit and push the changes

### no diary index auto-generation

To regenerate the Diary on has to type `<Leader>wi` to open the diary index,
then `<Leader>w<Leader>i` to regenerate the TOC. It would be better if it was
automatically updated.

see https://github.com/vimwiki/vimwiki/pull/530

### Fix the link converter

By default vimwiki turns `Foo` into `[Foo](Foo)` but GitHub doesn't know how
to follow those links. It would be better if it was `[Foo](Foo.md)` instead.

see https://github.com/vimwiki/vimwiki/pull/529

### Diary needs to be at the top-level

Because new pages linked from the diary are created under the diary/ folder
otherwise. See https://github.com/vimwiki/vimwiki/issues/527
