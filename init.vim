call plug#begin(stdpath('data') . '/plugged')

    Plug 'Shougo/denite.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'neoclide/coc.nvim', { 'branch': 'release' }
    Plug 'sstallion/vim-wtf'
    Plug 'dart-lang/dart-vim-plugin'

call plug#end()

map <Space> <Leader>

" Filetype
filetype on
filetype plugin on
filetype indent on
syntax on

" Esc to kj
inoremap kj <Esc>

" Escape at terminal mode to kj
tnoremap kj <C-\><C-n>

" Put number line
set number

" Max text width
set textwidth=100

" Search case insensitive
set ignorecase

" Search increment
set incsearch

" Show column and line number
set ruler

" OG backspace
set backspace=indent,eol,start

" Hides buffers instead of closing them
set hidden

" Using system clipboard
set clipboard=unnamedplus

" Insert spaces when TAB is pressed
set expandtab

" Change number of spaces that a <Tab> counts for during editing
set softtabstop=2

" Indentation amount for < and > commands
set shiftwidth=2

" Do not wrap long lines by default
set nowrap

" Only one line for command line
set cmdheight=1

" Don't highlight search result
set nohlsearch


" PLUGIN SETUP

" Wrap in try/catch to avoid errors on initial install before plugin is
" available
try
    " Denite.vim setup

    " By default, ripgrep will respect rules in .gitignore
    "   --files: Print each file that would be searched (but don't search)
    "   --glob: Include or exclude files for searching that match the given
    "           glob (aka ignore .git files)
    call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])

    " Use ripgrep in place of 'grep'
    call denite#custom#var('grep', 'command', ['rg'])

    " Custom options for ripgrep
    "   --vimgrep: Show results with every match on it's own line
    "   --hidden: Search hidden directories and files
    "   --heading: Show the file name above clusters of matches from each file
    "   --S: Search case insensitively if the pattern is all lowercase
    call denite#custom#var('grep', 'defaults_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

    " Recommended defaults for ripgrep via Denite docs
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [''])

    " Remove date from buffer list
    call denite#custom#var('buffer', 'date_format', '')

    " Custom options for Denite
    "   auto_resize: Auto resize the Denite window height automatically
    "   prompt: Customize denite prompt
    "   direction: Specify Denite window direction as directly below current
    "              pane
    "   winminheight: Specify min height for Denite window
    "   hightlight_mode_insert: Specify h1-CursorLine in insert mode
    "   prompt_highlight: Specify color of prompt
    "   highlight_matched_char: Matched characters highlight
    "   highlight_matched_range: Matched range highlight
    let s:denite_options = {'default': {
        \ 'split': 'floating',
        \ 'start_filter': 1,
        \ 'auto_resize': 1,
        \ 'source_names': 'short',
        \ 'prompt': 'L ',
        \ 'highlight_matched_char': 'QuickFixLine',
        \ 'highlight_matched_range': 'Visual',
        \ 'highlight_window_background': 'Visual',
        \ 'highlight_filter_background': 'DiffAdd',
        \ 'winrow': 1,
        \ 'vertical_preview': 1
        \ }}

    " Loop through denite options and enable them
    function! s:profile(opts) abort
        for l:fname in keys(a:opts)
            for l:dopt in keys(a:opts[l:fname])
                call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
            endfor
        endfor
    endfunction

    call s:profile(s:denite_options)

    command! -nargs=0 Prettier :CocCommand prettier.formatFile
catch
    echo 'Denite not installed. Run :PlugInstall first'
endtry

" The UI Setup

" One and only colorscheme
colorscheme wtf

" Enable true color support (disabled for more love of neovim terminal)
"set termguicolors

" Disable line number in terminal mode
autocmd TermOpen * setlocal nonumber norelativenumber

" GIT specific, editing git commit, rebase, config without spawn nested Neovim
if has('nvim')
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

autocmd FileType gitcommit,gitrebase,gitconfig set bufhidden=delete

" Key Mappings / Keybinding

" Denite shortcuts
"   ; - Browser currently open buffers
"   <leader>t - Browse list of files in current directory
"   <leader>g - Search current directory for occurences of given term and
"               close window if no results
"   <leader>j - Search current directory for occurences of word under cursor
nmap ; :Denite buffer<CR>
nmap <leader>t :DeniteProjectDir file/rec<CR>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty<CR>
nnoremap <leader>j :<C-u>DeniteCursorWord grep:.<CR>

" Define mappings while in 'filter' mode
"   <C-o> - Switch to normal mode inside of search results
"   <Esc> - Exit denite window in any mode
"   <CR>  - Open currently selected file in any mode
"   <C-t> - Open currently selected file in a new tab
"   <C-v> - Open currently selected file in a vertical split
"   <C-h> - Open currently selected file in a horizontal split
autocmd FileType denite-filter call s:denite_filter_my_settings()

function! s:denite_filter_my_settings() abort
    imap <silent><buffer> <C-o> <Plug>(denite_filter_quit)
    inoremap <silent><buffer><expr> <Esc> denite#do_map('quit')
    nnoremap <silent><buffer><expr> <Esc> denite#do_map('quit')
    inoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
    inoremap <silent><buffer><expr> <C-t> denite#do_map('do_action', 'tabopen')
    inoremap <silent><buffer><expr> <C-v> denite#do_map('do_action', 'vsplit')
    inoremap <silent><buffer><expr> <C-h> denite#do_map('do_action', 'hsplit')
endfunction

" Window movement fu
" Open always at below-right
set splitbelow
set splitright
nnoremap <Leader>h <C-w>h
nnoremap <Leader>j <C-w>j
nnoremap <Leader>k <C-w>k
nnoremap <Leader>l <C-w>l

