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
" Create posts automatically
let wiki_1.diary_rel_path = '_posts'
let g:vimwiki_list = [wiki_1]
let g:vimwiki_dir_link = 'index'
let g:vimwiki_use_calendar = 1
```

### 2. Setup GitHub Pages

1. Create a new repo
2. Set "master" as the gh-pages branch: ![xxx](https://pages.github.com/images/source-setting@2x.png)
3. Add the `_config.yml` (see this repo)

## References

* https://pages.github.com/
* http://thedarnedestthing.com/vimwiki%20cheatsheet
* https://rubygems.org/gems/github-pages

## Known issues

### jekyll: no autolink in markdown

It's annoying to wrap links in `<>` and vimwiki opens the URL with the closing
`>`.

This is fixed by switching the markdown rendered in the `_config.yml`:

```yaml
markdown: CommonMarkGhPages
# see https://github.com/gjtorikian/commonmarker#parse-options
commonmark:
  options:
    - FOOTNOTES
    - SMART
  extensions:
    - autolink
    - strikethrough
    - table
```

### jekyll: posts are not listed

Jekyll requires the post to also contain a slug name.

* Works: `_posts/2019-05-06-foo.md`
* Doesn't work: `_posts/2019-05-06.md`

But since this is a journal it doesn't make sense to have a title for every
day. And vimwiki doesn't support it anyways.

### vimwiki: no auto-commit-and-push

It's easy to forget to commit and push the changes

### vimwiki: fix the link converter

By default vimwiki turns `Foo` into `[Foo](Foo)` but GitHub doesn't know how
to follow those links. It would be better if it was `[Foo](Foo.md)` instead.

see https://github.com/vimwiki/vimwiki/pull/529

### vimwiki: links from diary are annoying

To link to wiki entries from the diary, use the `/` prefix.

Eg: `/Foo` will convert to `[Foo](/Foo)`
