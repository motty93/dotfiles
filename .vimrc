" 一旦ファイルタイプ関連を無効化する
filetype off

" <leader>
let mapleader = ","

" auto reload .vimrc
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

" if dein#load_state("$HOME/.cache/dein")
  call dein#begin("$HOME/.cache/dein")
  call dein#add("$HOME/.cache/dein/repos/github.com/Shougo/dein.vim")
  call dein#add('Shougo/deoplete.nvim')
  if !has('nvim')
    call dein#add('roxma/nvim-yarp')
    call dein#add('roxma/vim-hug-neovim-rpc')
  endif

  call dein#add('Shougo/vimproc.vim', {
        \ 'build': {
        \     'cygwim'  : 'make -f make_cygwin.mak',
        \     'mac'     : 'make -f make_mac.mak',
        \     'linux'   : 'make',
        \     'unix'    : 'gmake',
        \ }, })

  " plantuml
  call dein#add('aklt/plantuml-syntax')
  let g:plantuml_executable_script = "~/file/plantuml.sh"

  " open-broser.vim
  call dein#add('tyru/open-browser.vim')
  let g:netrw_nogx = 1
  nnoremap gx <Plug>(openbrowser-smart-search)
  vnoremap gx <Plug>(openbrowser-smart-search)
  command! OpenBrowserCurrent execute "!xdg-open" expand("%:p")

  " color picker
  call dein#add('KabbAmine/vCoolor.vim')
  let g:vcoolor_map = '<leader>c'

  " json linter
  call dein#add('w0rp/ale')
  let g:ale_lint_on_enter = 0
  let g:ale_linters = {
    \   'json': ['jsonlint'],
    \}
  " ale on off switch nmap
  nnoremap <silent> <leader>json <Plug>(ale_toggle)

  " denite.nvim
  " call dein#add('Shougo/denite.nvim')
  " if !has('nvim')
  "   call dein#add('roxma/nvim-yarp')
  "   call dein#add('roxma/vim-hug-neovim-rpc')
  " endif
  " let g:python3_host_prog = '~/.asdf/shims/python'
  " nnoremap <leader>rec :Denite file_rec<CR>

  " gtags
  call dein#add('lighttiger2505/gtags.vim')
  let g:Gtags_Auto_Map = 0
  let g:Gtags_OpenQuickFixWindow = 1
  " Show definition of function cousor word on quickfix
  nnoremap <silent> K :<C-u>exe("Gtags ".expand('<cword>'))<CR>
  " Show reference of cousor word on quickfix
  nnoremap <silent> R :<C-u>exe("Gtags -f".expand('<cword>'))<CR>

  " gtags async update
  call dein#add('jsfaint/gen_tags.vim')
  let g:gen_tags#gtags_auto_get = 1
  let g:gen_tags#ctags_auto_get = 1

  " unite.vim
  call dein#add('Shougo/unite.vim')
  call dein#add('Shougo/neomru.vim')
  let g:unite_enable_start_insert = 1
  let g:unite_enable_ignore_case = 1
  let g:unite_enable_smart_case = 1
  " let g:unite_source_file_mru_limit = 200
  " let g:unite_source_rec_max_cache_files = 5000
  " file buffer
  nnoremap <C-b> :Unite buffer<CR>
  " files or new file
  noremap <C-N> :Unite file -buffer-name=file file/new<CR>
  " recursive file search
  " nnoremap <leader>rec :Unite file_rec<CR>
  nnoremap <leader>rec :<C-u>Unite -start-insert file_rec/async:! -buffer-name=file file/new<CR>
  " current files
  noremap <C-Z> :Unite file_mru -buffer-name=file<CR>
  " file dir change on this directory
  noremap :uff :<C-u>UniteWithBufferDir file file/new -buffer-name=file<CR>
  " file new
  noremap :file_new :Unite -buffer-name=file file/new
  " window split level
  au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
  au FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
  " window split vertical
  au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
  au FileType unite inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
  " push Esc to end
  au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
  au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
  " grep
  nnoremap <silent> <leader>g :<C-u>Unite grep: -buffer-name=search-buffer<CR>
  " cursor word grep
  nnoremap <silent> <leader>cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
  " call result of grep
  nnoremap <silent> <leader>ur :<C-u>UniteResume search-buffer<CR>

  " file search
  call dein#add('ctrlpvim/ctrlp.vim')
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'

  " Ag - the silver search -
  call dein#add('rking/ag.vim')
  " use Ag for unite grep and ctrlpvim
  if executable('ag')
    let g:ctrlp_use_caching = 0
    let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup -g ""'
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
  endif

  " file devicons
  call dein#add('ryanoasis/vim-devicons')
  let g:WebDeviconsUnicodeDecorateFolderNodes = 1
  let g:webdevicons_conceal_nerdtree_brackets = 1
  let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '
  " NERDTree
  call dein#add('scrooloose/nerdtree')
  call dein#add('tiagofumo/vim-nerdtree-syntax-highlight')
  nnoremap <silent><C-e> :NERDTree<CR>
  let s:rspec_red = 'FE405F'
  let s:git_orange = 'F54D27'
  let g:NERDTreeExactMatchHighlightColor = {} " this line is needed to avoid error
  let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange " sets the color for .gitignore files
  let g:NERDTreePatternMatchHighlightColor = {} " this line is needed to avoid error
  let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red " sets the color for files ending with _spec.rb
  let g:NERDTreeLimitedSyntax = 1

  " endwise
  call dein#add('tpope/vim-endwise')
  " comment
  call dein#add('tomtom/tcomment_vim')
  " surround vim
  call dein#add('tpope/vim-surround')
  " indent color
  call dein#add('nathanaelkane/vim-indent-guides')
  " logs color
  call dein#add('vim-scripts/AnsiEsc.vim')
  " end of line space color
  call dein#add('bronson/vim-trailing-whitespace')
  " markdown
  call dein#add('iamcco/markdown-preview.nvim', { 'on_ft': ['markdown', 'pandoc.markdown', 'rmd'], 'build': 'cd app & yarn install' })
  " auto save
  " call dein#add('907th/vim-auto-save')
  " let g:auto_save = 1
  " switch vim
  call dein#add('AndrewRadev/switch.vim')
  let g:switch_mapping = "-"

  " elixir syntax highlight
  call dein#add('elixir-editors/vim-elixir')
  " mix command :Mix
  call dein#add('mattreduce/vim-mix')
  " elixir test
  call dein#add('BjRo/vim-extest')
  " elixir alchemist.vim
  call dein#add('slashmili/alchemist.vim')

  " vim-go
  call dein#add('fatih/vim-go')
  let g:go_version_warning = 0

  " rails complement
  call dein#add('tpope/vim-rails')
  " ruby methods complement
  call dein#add('Shougo/neocomplcache.vim')
  call dein#add('Shougo/neocomplete.vim')
  let g:neocomplete#enable_at_startup = 1
  " call dein#add('NigoroJr/rsense')
  call dein#add('Shougo/neocomplcache-rsense.vim')
  " let g:neocomplcache_force_overwrite_completefunc = 1
  " let g:rsenseHome = '/usr/local/lib/rsense'
  " let g:rsenseUseOmniFunc = 1
  let g:neocomplcache#enable_at_startup = 1
  let g:neocomplcache#enable_smart_case = 1
  " Set minimum syntax keyword length.
  let g:neocomplcache_min_syntax_length = 3
  let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
  let g:neocomplcache_enable_camel_case_completion = 1
  let g:neocomplcache_enable_underbar_completion = 1
  " rubocop
  " call dein#add('ngmy/vim-rubocop')
  " call dein#add('scrooloose/syntastic')
  " let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby'] }
  " let g:syntastic_ruby_checkers = ['rubocop', 'mri']

  " react native plugins
  call dein#add('pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] })
  call dein#add('othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] })
  call dein#add('othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] })
  call dein#add('othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] })
  " react native complement
  call dein#add('ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'], 'do': 'npm install' })
  " vim-prettier
  call dein#add('prettier/vim-prettier', { 'do': 'yarn install', 'branch': 'release/1.x' , 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] })
  " autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.vue,*.css,*.scss,*.json PrettierAsync
  let g:prettier#autoformat = 0
  let g:prettier#quickfix_enabled = 0
  let g:prettier#config#semi = 'false'
  let g:prettier#config#single_quote = 'true'
  let g:prettier#config#bracket_spacing = 'true'
  let g:prettier#config#parser = 'babylon'
  " js indent
  call dein#add('jason0x43/vim-js-indent')
  " TypeSctipt
  call dein#add('leafgarland/typescript-vim')
  call dein#add('Quramy/tsuquyomi')
  let g:syntastic_typescript_tsc_args = "--experimentalDecorators --target ES5"
  let g:tsuquyomi_use_vimproc = 0
  let g:tsuquyomi_definition_split = 3
  autocmd InsertLeave,TextChanged,BufWritePost *.ts,*.tsx call tsuquyomi#asyncGeterr()
  nnoremap <leader>tsu :TsuAsyncGeterr

  " html5 code syntax
  call dein#add('hail2u/vim-css3-syntax')
  " HTML5 plugins
  call dein#add('othree/html5.vim')
  " emmet
  call dein#add('mattn/emmet-vim')

  call dein#end()
  call dein#save_state()
" endif

" Required:
filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

""""""""""""""""""""""""""""""

" Cica font linux
set encoding=utf8
set guifont=Cica:h16
set ambiwidth=double
" Mac Cica font
" set guifont=Cica:h16
" set printfont=Cica:h12
" set ambiwidth=double
" Win Cica font
" set guifont=Cica:h11
" set printfont=Cica:h8
" set renderingoptions=type:directx,renmode:5
" set ambiwidth=double
set tags=~/.tags " set .tags files
set noswapfile " no use swap file
if has("mouse") " enable mouse
  set mouse=a
endif
set showmode " display current mode
set noundofile " not make undo files
set ruler " カーソルが何行目の何列目に置かれているかを表示する
set cmdheight=2 " コマンドラインに使われる画面上の行数
set laststatus=2 " エディタウィンドウの末尾から2行目にステータスラインを常時表示させる
set nobackup " バックアップを作成しない
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P " ステータス行に表示させる情報の指定
set title " ウインドウのタイトルバーにファイルのパス情報等を表示する
set wildmenu " コマンドラインモードで<Tab>キーによるファイル名補完を有効にする
set showcmd " 入力中のコマンドを表示する
set browsedir=buffer " バッファで開いているファイルのディレクトリでエクスクローラを開始する
set smartcase " 小文字のみで検索したときに大文字小文字を無視する
set hlsearch " 検索結果をハイライト表示する
set background=dark " 暗い背景色に合わせた配色にする
set expandtab " タブ入力を複数の空白入力に置き換える
set incsearch " 検索ワードの最初の文字を入力した時点で検索を開始する
set hidden " 保存されていないファイルがあるときでも別のファイルを開けるようにする
set list " 不可視文字を表示する
set listchars=eol:\ ,trail:- " タブと行の続きを可視化する
set number " 行番号を表示する
set showmatch " 対応する括弧やブレースを表示する
set tabstop=2 " タブ文字の表示幅
set shiftwidth=2 " Vimが挿入するインデントの幅
set smarttab
set clipboard& " カーソルを行頭、行末で止まらないようにする
set clipboard^=unnamedplus " ``
set whichwrap=b,s,h,l,<,>,[,] " カーソルを行頭、行末で止まらないようにする
set backspace=indent,eol,start " バックスペースを使えるようにする
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set formatoptions=q " textwidthでフォーマットさせたくない
set synmaxcol=200 " クラッシュ防止
" set textwidth=0 " 勝手に改行するのを防ぐ
" 構文毎に文字色を変化させる
syntax on
" カラースキーマの指定
colorscheme desert
" 行番号の色
highlight LineNr ctermfg=darkyellow
" vimでalias読み込み
let $BASH_ENV = "~/.bash_alias"

" HTML5 tags
syn keyword htmlTagName contained article aside audio bb canvas command
syn keyword htmlTagName contained datalist details dialog embed figure
syn keyword htmlTagName contained header hgroup keygen mark meter nav output
syn keyword htmlTagName contained progress time ruby rt rp section time
syn keyword htmlTagName contained source figcaption
syn keyword htmlArg contained autofocus autocomplete placeholder min max
syn keyword htmlArg contained contenteditable contextmenu draggable hidden
syn keyword htmlArg contained itemprop list sandbox subject spellcheck
syn keyword htmlArg contained novalidate seamless pattern formtarget
syn keyword htmlArg contained formaction formenctype formmethod
syn keyword htmlArg contained sizes scoped async reversed sandbox srcdoc
syn keyword htmlArg contained hidden role
syn match   htmlArg "\<\(aria-[\-a-zA-Z0-9_]\+\)=" contained
syn match   htmlArg contained "\s*data-[-a-zA-Z0-9_]\+"

" HTML template
autocmd BufNewFile *.html 0r $HOME/.cache/dein/template/html.txt
""""""""""""""""""""""""""""""
" js filetype
autocmd BufNewFile,BufRead *.ts       set filetype=typescript
autocmd BufNewFile,BufRead *.tsx      set filetype=typescript

" vimを立ち上げたときに、自動的にvim-indent-guidesをオンにする
let g:indent_guides_enable_on_vim_startup = 1
" grep検索の実行後にQuickFix Listを表示する
autocmd QuickFixCmdPost *grep* cwindow

""""""""""""""""""""""""""""""
" javascript
""""""""""""""""""""""""""""""
function! EnableJavascript()
  " Setup used libraries
  let g:used_javascript_libs = 'jquery,underscore,react,flux,jasmine,d3'
  let b:javascript_lib_use_jquery = 1
  let b:javascript_lib_use_underscore = 1
  let b:javascript_lib_use_react = 1
  let b:javascript_lib_use_flux = 1
  let b:javascript_lib_use_jasmine = 1
  let b:javascript_lib_use_d3 = 1
endfunction

if has('syntax')
  augroup Javascript
    autocmd! FileType javascript,javascript.jsx call EnableJavascript()
  augroup END
endif

""""""""""""""""""""""""""""""
" display zenkaku space
""""""""""""""""""""""""""""""
function! ZenkakuSpace()
  highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray
endfunction

if has('syntax')
  augroup ZenkakuSpace
    autocmd!
    autocmd ColorScheme * call ZenkakuSpace()
    autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
  augroup END
  call ZenkakuSpace()
endif
""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""
" 挿入モード時、ステータスラインの色を変更
""""""""""""""""""""""""""""""""""""""""""""
let g:hi_insert = 'highlight StatusLine guifg=darkblue guibg=darkyellow gui=none ctermfg=blue ctermbg=yellow cterm=none'

if has('syntax')
  augroup InsertHook
      autocmd!
      autocmd InsertEnter * call s:StatusLine('Enter')
      autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif

let s:slhlcmd = ''
function! s:StatusLine(mode)
  if a:mode == 'Enter'
    silent! let s:slhlcmd = 'highlight ' . s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction

function! s:GetHighlight(hi)
  redir => hl
  exec 'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction
""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
" 最後のカーソル位置を復元する
""""""""""""""""""""""""""""""
if has("autocmd")
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
endif
""""""""""""""""""""""""""""""

" mapping
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
inoremap ` ``<LEFT>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
" tabnew mapping
nnoremap <silent> <leader>tab :<C-u>tabnew<CR>
" browser open current file
nnoremap <leader>chrome :exe ':silent !google-chrome % &'<CR>
" Edit vimrc
nnoremap <leader>v :edit $MYVIMRC<CR>

" filetype detection
filetype on
