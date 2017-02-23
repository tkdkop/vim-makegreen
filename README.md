vim-MakeGreen-async
===================

makegreen.vim is a vim (http://www.vim.org) plugin that runs make and shows the
test run status with a red or green bar.

This plugin has been forked from the original makegreen plugin and async support has been 
added. Async support requires VIM 8 or later. Also works with neovim.

Installation
------------

Using [vim-plug](https://github.com/junegunn/vim-plug) add

```vim
Plug 'prabirshrestha/async.vim'
Plug 'tkdkop/vim-makegreen'
```

This plugin uses the 'prabirshrestha/async.vim' to normalize async functionality across 
vim and neovim.

Usage
-----

`:MakeGreen %` will run make for the current file and show its status with a red or green message bar.


My intention with this plugin was to be able to run tests asynchronously. For use with
[vim-test](https://github.com/janko-m/vim-test) the setup looks like this:

```vim
Plug 'janko-m/vim-test'  "make sure vim-test is installed
"Also ensure that your compiler and makeprg are set properly. This works for my django setup
compiler pyunit
set makeprg=python\ manage.py\ test
set efm+=%-G%.%#lib/python%.%#/site-package%.%#,%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
"Create a test strategy using makegreen for vim-test
function! MakeGreenStrategy(cmd) abort
    call MakeGreen(join(split(a:cmd)[3:]))
endfunction
let g:test#custom_strategies = {'makegreen': function('MakeGreenStrategy')}
let g:test#strategy = 'makegreen'
```

See [the full documentation] for more.

[the full documentation]: doc/makegreen.txt
