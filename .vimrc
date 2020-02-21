" 一旦ファイルタイプ関連を無効化する
filetype off

" <leader>キー
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

  " html補完 emmet
  call dein#add('mattn/emmet-vim')

  " open-broser.vim
  call dein#add('tyru/open-browser.vim')
  " call dein#add('open-browser.vim')
  let g:netrw_nogx = 1
  nnoremap gx <Plug>(openbrowser-smart-search)
  vnoremap gx <Plug>(openbrowser-smart-search)
  command! OpenBrowserCurrent execute "!xdg-open" expand("%:p")

  " html5のコードをシンタックス表示する
  call dein#add('hail2u/vim-css3-syntax')

  " color picker
  call dein#add('KabbAmine/vCoolor.vim')
  let g:vcoolor_map = '<leader>c'

  " Ag - the silver search -
  call dein#add('rking/ag.vim')
  " use Ag for unite grep and ctrlpvim
  if executable('ag')
    let g:ctrlp_use_caching=0
    let g:ctrlp_user_command='ag %s -i --nocolor --nogroup -g ""'
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --nocolor --column'
    let g:unite_source_grep_recursive_opt = ''
  endif

  " unite.vim
  call dein#add('Shougo/unite.vim')
  let g:unite_enable_start_insert = 1
  let g:unite_enable_ignore_case = 1
  let g:unite_enable_smart_case = 1
  " バッファ一覧
  nnoremap <C-b> :Unite buffer<CR>
  " ファイル一覧 なければ新規ファイル
  noremap <C-N> :Unite file -buffer-name=file file/new<CR>
  " 再帰的にファイル検索
  nnoremap <leader>rec :Unite file_rec<CR>
  " 最近使ったファイルの一覧
  noremap <C-Z> :Unite file_mru<CR>
  " sourcesを「今開いているファイルのディレクトリ」とする
  noremap :uff :<C-u>UniteWithBufferDir file file/new -buffer-name=file<CR>
  " 新規ファイル作成
  noremap :file_new :Unite -buffer-name=file file/new
  " ウィンドウを分割して開く
  au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
  au FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
  " ウィンドウを縦に分割して開く
  au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
  au FileType unite inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
  " ESCキーを2回押すと終了する
  au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
  au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
  " grep検索 起点を変更してgrep
  nnoremap <silent> <leader>g :<C-u>Unite grep: -buffer-name=search-buffer<CR>
  " カーソル位置の単語をgrep検索
  nnoremap <silent> <leader>cg :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>
  " grep検索結果の再呼び出し
  nnoremap <silent> <leader>ur :<C-u>UniteResume search-buffer<CR>

  " Unite.vimで最近使ったファイルを表示できるようにする
  call dein#add('Shougo/neomru.vim')

  " denite.nvim
  " call dein#add('Shougo/denite.nvim')
  " if !has('nvim')
  "   call dein#add('roxma/nvim-yarp')
  "   call dein#add('roxma/vim-hug-neovim-rpc')
  " endif
  " let g:python3_host_prog = '~/.asdf/shims/python'
  " nnoremap <leader>rec :Denite file_rec<CR>

  " vin-devicons
  call dein#add('ryanoasis/vim-devicons')
  let g:WebDeviconsUnicodeDecorateFolderNodes = 1
  let g:webdevicons_conceal_nerdtree_brackets = 1
  let g:WebDevIconsNerdTreeAfterGlyphPadding = ' '

  " ファイルをtree表示してくれる
  call dein#add('scrooloose/nerdtree')
  nnoremap <silent><C-e> :NERDTree<CR>

  " vim-elixir シンタックスハイライト
  call dein#add('elixir-editors/vim-elixir')
  " vim-mix :Mix でコマンド実行可能
  call dein#add('mattreduce/vim-mix')
  " vim-extest テスト実行プラグイン
  call dein#add('BjRo/vim-extest')
  " elixir alchemist.vim
  call dein#add('slashmili/alchemist.vim')

  " NerdTreeのカラーリング
  call dein#add('tiagofumo/vim-nerdtree-syntax-highlight')
  let s:rspec_red = 'FE405F'
  let s:git_orange = 'F54D27'
  let g:NERDTreeExactMatchHighlightColor = {} " this line is needed to avoid error
  let g:NERDTreeExactMatchHighlightColor['.gitignore'] = s:git_orange " sets the color for .gitignore files
  let g:NERDTreePatternMatchHighlightColor = {} " this line is needed to avoid error
  let g:NERDTreePatternMatchHighlightColor['.*_spec\.rb$'] = s:rspec_red " sets the color for files ending with _spec.rb
  let g:NERDTreeLimitedSyntax = 1

  " Rails向けのコマンドを提供する
  " call dein#add('tpope/vim-rails')
  " Ruby向けにendを自動挿入してくれる
  call dein#add('tpope/vim-endwise')

  " コメントON/OFFを手軽に実行
  call dein#add('tomtom/tcomment_vim')

  " シングルクオートとダブルクオートの入れ替え等
  call dein#add('tpope/vim-surround')

  " vim-go
  call dein#add('fatih/vim-go')
  let g:go_version_warning = 0

  " インデントに色を付けて見やすくする
  call dein#add('nathanaelkane/vim-indent-guides')
  " ログファイルを色づけしてくれる
  call dein#add('vim-scripts/AnsiEsc.vim')
  " 行末の半角スペースを可視化
  call dein#add('bronson/vim-trailing-whitespace')
  " less用のsyntaxハイライト
  " call dein#add('KohPoll/vim-less')

  " markdown設定
  call dein#add('tpope/vim-markdown')
  call dein#add('kannokanno/previm')
  call dein#add('skanehira/preview-markdown.vim')
  let g:preview_markdown_vertical = 1
  let g:previm_open_cmd = 'google-chrome'
  augroup PrevimSetting
    autocmd!
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
  augroup END
  " 'Need: kannokanno/previm'
  " 自動で折りたたまないようにする
  let g:vim_markdown_folding_disabled=1
  let g:previm_enable_realtime=1
  " nnoremap <silent> <C-p> :PrevimOpen<CR>

  " RubyMineのように自動保存する
  call dein#add('907th/vim-auto-save')
  let g:auto_save = 1

  " Rubyメソッド自動補完
  call dein#add('Shougo/neocomplcache.vim')
  " call dein#add('NigoroJr/rsense')
  call dein#add('Shougo/neocomplcache-rsense.vim')
  " let g:neocomplcache_force_overwrite_completefunc=1
  " let g:rsenseHome = expand("~/.asdf/shims/rsense")
  " let g:rsenseUseOmniFunc = 1

  let g:acp_enableAtStartup = 0
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
  " let g:syntastic_ruby_checkers=['rubocop', 'mri']

  " switch vim
  call dein#add('AndrewRadev/switch.vim')
  let g:switch_mapping = "-"

  " react native plugins
  call dein#add('pangloss/vim-javascript', { 'for': ['javascript', 'javascript.jsx'] })
  call dein#add('othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] })
  call dein#add('othree/es.next.syntax.vim', { 'for': ['javascript', 'javascript.jsx'] })
  call dein#add('othree/javascript-libraries-syntax.vim', { 'for': ['javascript', 'javascript.jsx'] })
  " react native用コード補完
  call dein#add('ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'], 'do': 'npm install' })

  " HTML5のプラグイン
  call dein#add('othree/html5.vim')

  " vimでtwitter
  let twitvim_enable_python = 1
  let twitvim_browser_cmd = 'google-chrome'
  let twitvim_force_ssl = 1
  let twitvim_count = 100

  " CtrlP ファイルをさくっと開けるやつ
  call dein#add('ctrlpvim/ctrlp.vim')
  let g:ctrlp_map = '<c-p>'
  let g:ctrlp_cmd = 'CtrlP'

  " vim-prettier
  call dein#add('prettier/vim-prettier', { 'do': 'yarn install', 'branch': 'release/1.x' , 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'yaml', 'html'] })
  let g:prettier#autoformat = 0
  let g:prettier#quickfix_enabled = 0
  let g:prettier#config#semi = 'false'
  let g:prettier#config#single_quote = 'true'
  let g:prettier#config#bracket_spacing = 'true'
  let g:prettier#config#parser = 'babylon'
  " autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.vue,*.css,*.scss,*.json PrettierAsync

  " JS indent
  call dein#add('jason0x43/vim-js-indent')

  " TypeSctipt
  call dein#add('leafgarland/typescript-vim')
  call dein#add('Quramy/tsuquyomi')
  let g:syntastic_typescript_tsc_args = "--experimentalDecorators --target ES5"

  " mattn/sl
  " call dein#add('mattn/vim-sl')


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

""""""""""""""""""""""""""""""
" 各種オプションの設定
""""""""""""""""""""""""""""""
" Cicaフォント設定linux
set encoding=utf8
set guifont=Cica:h16
set ambiwidth=double
" Mac Cicaフォント
" set guifont=Cica:h16
" set printfont=Cica:h12
" set ambiwidth=double
" Win Cicaフォント
" set guifont=Cica:h11
" set printfont=Cica:h8
" set renderingoptions=type:directx,renmode:5
" set ambiwidth=double

set tags=~/.tags
" スワップファイルは使わない(ときどき面倒な警告が出るだけで役に立ったことがない)
set noswapfile
" モード表示
set showmode
" undoファイルは作成しない
set noundofile
" カーソルが何行目の何列目に置かれているかを表示する
set ruler
" コマンドラインに使われる画面上の行数
set cmdheight=2
" エディタウィンドウの末尾から2行目にステータスラインを常時表示させる
set laststatus=2
" バックアップを作成しない
set nobackup
" ステータス行に表示させる情報の指定(どこからかコピペしたので細かい意味はわかっていない)
set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
" ウインドウのタイトルバーにファイルのパス情報等を表示する
set title
" コマンドラインモードで<Tab>キーによるファイル名補完を有効にする
set wildmenu
" 入力中のコマンドを表示する
set showcmd
" バッファで開いているファイルのディレクトリでエクスクローラを開始する(でもエクスプローラって使ってない)
set browsedir=buffer
" 小文字のみで検索したときに大文字小文字を無視する
set smartcase
" 検索結果をハイライト表示する
set hlsearch
" 暗い背景色に合わせた配色にする
set background=dark
" タブ入力を複数の空白入力に置き換える
set expandtab
" 検索ワードの最初の文字を入力した時点で検索を開始する
set incsearch
" 保存されていないファイルがあるときでも別のファイルを開けるようにする
set hidden
" 不可視文字を表示する
set list
" タブと行の続きを可視化する
set listchars=eol:\ ,trail:-
" 行番号を表示する
set number
" 対応する括弧やブレースを表示する
set showmatch
" タブ文字の表示幅
set tabstop=2
" Vimが挿入するインデントの幅
set shiftwidth=2
set smarttab
" ヤンク時クリップボードにもコピー
set clipboard&
set clipboard^=unnamedplus
" カーソルを行頭、行末で止まらないようにする
set whichwrap=b,s,h,l,<,>,[,]
" バックスペースを使えるようにする
set backspace=indent,eol,start
" 構文毎に文字色を変化させる
syntax on
" カラースキーマの指定
colorscheme desert
" 行番号の色
highlight LineNr ctermfg=darkyellow
" 勝手に改行するのを防ぐ
" set textwidth=0
" textwidthでフォーマットさせたくない
set formatoptions=q
" クラッシュ防止（http://superuser.com/questions/810622/vim-crashes-freezes-on-specific-files-mac-osx-mavericks）
set synmaxcol=200

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
autocmd BufNewFile *.html 0r $HOME/.vim/dein/template/html.txt
""""""""""""""""""""""""""""""


" vimを立ち上げたときに、自動的にvim-indent-guidesをオンにする
let g:indent_guides_enable_on_vim_startup = 1

" grep検索の実行後にQuickFix Listを表示する
autocmd QuickFixCmdPost *grep* cwindow


""""""""""""""""""""""""""""""
" javascriptの設定
""""""""""""""""""""""""""""""
" function! EnableJavascript()
"   " Setup used libraries
"   let g:used_javascript_libs = 'jquery,underscore,react,flux,jasmine,d3'
"   let b:javascript_lib_use_jquery = 1
"   let b:javascript_lib_use_underscore = 1
"   let b:javascript_lib_use_react = 1
"   let b:javascript_lib_use_flux = 1
"   let b:javascript_lib_use_jasmine = 1
"   let b:javascript_lib_use_d3 = 1
" endfunction
"
" if has('syntax')
"   augroup Javascript
"     autocmd! FileType javascript,javascript.jsx call EnableJavascript()
"   augroup END
" endif
"
" 改行時に前の行のインデントを継続する
set autoindent
" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent

" http://inari.hatenablog.com/entry/2014/05/05/231307
""""""""""""""""""""""""""""""
" 全角スペースの表示
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

" https://sites.google.com/site/fudist/Home/vim-nihongo-ban/-vimrc-sample
""""""""""""""""""""""""""""""
" 挿入モード時、ステータスラインの色を変更
""""""""""""""""""""""""""""""
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
""""""""""""""""""""""""""""""

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

""""""""""""""""""""""""""""""
" 自動的に閉じ括弧を入力
""""""""""""""""""""""""""""""
inoremap { {}<LEFT>
inoremap [ []<LEFT>
inoremap ( ()<LEFT>
inoremap ' ''<LEFT>
inoremap " ""<LEFT>
inoremap ` ``<LEFT>
""""""""""""""""""""""""""""""
" インサートモード中のキーマップ変更
""""""""""""""""""""""""""""""
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
""""""""""""""""""""""""""""""
" tabnew mapping
nnoremap <silent> <leader>t :<C-u>tabnew<CR>
" 現在のファイルをブラウザで開く
nnoremap <leader>chrome :exe ':silent !google-chrome % &'<CR>
" Edit vimrc
nnoremap <leader>v :edit $MYVIMRC<CR>

" filetypeの自動検出(最後の方に書いた方がいいらしい)
filetype on
