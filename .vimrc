" 一旦ファイルタイプ関連を無効化する
filetype off

" <leader>
let mapleader = ","

" disabled modify other keys
let &t_TI = ""
let &t_TE = ""

" clear cache
" call map(dein#check_clean(), 'delete(v:val, 'rf')')

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
  let g:python3_host_prog = '~/.asdf/shims/python'
  call dein#add('Shougo/vimproc.vim', {
        \ 'build': {
        \     'cygwim'  : 'make -f make_cygwin.mak',
        \     'mac'     : 'make -f make_mac.mak',
        \     'linux'   : 'make',
        \     'unix'    : 'gmake',
        \ }, })

  " vim lsp
  call dein#add('prabirshrestha/vim-lsp')
  call dein#add('mattn/vim-lsp-settings')
  " let g:lsp_log_verbose = 1
  " let g:lsp_log_file = 'vim-lsp.log'
   " 保存時source.organizaImports実行
  autocmd BufWritePre <buffer>
                \ call execute('LspCodeActionSync source.organizeImports')
  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nnoremap <silent> gd :LspDefinition<CR>
    nnoremap <silent> gp :LspPeekDefinition<CR>
    nnoremap <silent> gh :LspHover<CR>
    nnoremap <silent> gr :LspReferences<CR>
    nnoremap <silent> gs :LspDocumentSymbolSearch<CR>
    nnoremap <silent> gS :LspWorkspaceSymbolSearch<CR>
    nnoremap <silent> gi :LspImplementation<CR>
    " nnoremap <silent> gt :LspTypeDefinition<CR>
    nnoremap <silent> <leader>rn :LspRename<CR>
    nnoremap <silent> [g :LspPreviousDiagnostic<CR>
    nnoremap <silent> ]g :LspNextDiagnostic<CR>
    nnoremap <silent> K :LspHover<CR>
    inoremap <silent> <expr><c-f> lsp#scroll(+4)
    inoremap <silent> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
  endfunction
  augroup lsp_install
      au!
      autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  augroup END
  call dein#add('prabirshrestha/async.vim')
  call dein#add('prabirshrestha/asyncomplete.vim')
  let g:asyncomplete_auto_completeopt = 0
  let g:lsp_diagnostics_enabled = 1
  let g:lsp_diagnostics_echo_cursor = 1
  let g:asyncomplete_popup_delay = 200
  let g:lsp_text_edit_enabled = 1
  let g:lsp_preview_float = 1
  let g:lsp_diagnostics_fload_cursor = 1
  call dein#add('thomasfaingnaert/vim-lsp-snippets')
  call dein#add('thomasfaingnaert/vim-lsp-ultisnips')

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  inoremap <silent><expr> <TAB>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<TAB>" :
    \ asyncomplete#force_refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  call dein#add('prabirshrestha/asyncomplete-lsp.vim')
  " lsp ruby
  " if executable('solargraph')
  "     " gem install solargraph
  "     au User lsp_setup call lsp#register_server({
  "         \ 'name': 'solargraph',
  "         \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
  "         \ 'whitelist': ['ruby'],
  "         \ })
  " endif
  " lsp typescript(vim-lsp-settingsだとtsxに対応してないっぽい)
  if executable('typescript-language-server')
    augroup LspTypeScript
      au!
      autocmd User lsp_setup call lsp#register_server({
                  \ 'name': 'typescript-language-server',
                  \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
                  \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'tsconfig.json'))},
                  \ 'whitelist': ['typescript', 'typescriptreact'],
                  \ })
      autocmd FileType typescript setlocal omnifunc=lsp#complete
    augroup END :echomsg 'vim-lsp with `typescript-language-server` enabled'
  else
    :echomsg 'vim-lsp for typescript unavailable'
  endif
  " lsp Vue
  " call dein#add('posva/vim-vue')
  " if executable('vls')
  "   augroup LspVls
  "     au!
  "     au User lsp_setup call lsp#register_server({
  "         \ 'name': 'vue-language-server',
  "         \ 'cmd': {server_info->['vls']},
  "         \ 'whitelist': ['vue'],
  "         \ 'initialization_options': {
  "         \       'config': {
  "         \           'html': {},
  "         \           'vetur': {
  "         \               'validation': {}
  "         \           }
  "         \       }
  "         \   }
  "         \ })
  "     au FileType vue setlocal omnifunc=lsp#complete
  "   augroup end
  " endif
  " lsp golang
  if executable('gopls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'gopls',
        \ 'cmd': {server_info->['gopls']},
        \ 'whitelist': ['go'],
        \ })
    autocmd BufWritePre *.go LspDocumentFormatSync
  endif
  let g:lsp_settings_filetype_go = ['gopls', 'golangci-lint-langserver']
  let g:lsp_settings = {}
  let g:lsp_settings['gopls'] = {
  \  'workspace_config': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \  'initialization_options': {
  \    'usePlaceholders': v:true,
  \    'analyses': {
  \      'fillstruct': v:true,
  \    },
  \  },
  \}
  " elixir-ls
  " if executable('elixir-ls')
  "   au User lsp_setup call lsp#register_server({
  "     \ 'name': 'elixir-ls',
  "     \ 'cmd': {server_info->['elixir-ls']},
  "     \ 'whitelist': ['elixir'],
  "     \ })
  "   autocmd BufWritePre *.exs,*.ex,*.eex,*.heex,*.leex,*.sface LspDocumentFormatSync
  " endif
  " let g:lsp_settings = { \ 'elixir-ls': {'cmd': $HOME . '/.elixir-ls/release/'}}
  " vim notification
  call dein#add('mattn/vim-notification')
  " go auto imports
  call dein#add('mattn/vim-goimports')

  " debug vimspector
  call dein#add('puremourning/vimspector')
  let g:vimspector_enable_mappings = 'HUMAN'
  nmap bp <Plug>VimspectorToggleBreakpoint

  " graphql vim
  call dein#add('jparise/vim-graphql')

  " preview
  call dein#add('previm/previm')
  let g:previm_plantuml_imageprefix = 'http://localhost:8888/png/'

  " editorconfig
  call dein#add('editorconfig/editorconfig-vim')

  " git diff
  call dein#add('airblade/vim-gitgutter')
  let g:gitgutter_hightlight_lines = 1

  " git commit prefix autocomplete
  call dein#add('gotchane/vim-git-commit-prefix')
  let g:git_commit_prefix_lang = 'ja'

  " protobuf
  call dein#add('uarun/vim-protobuf')

  " plantuml
  call dein#add('aklt/plantuml-syntax')
  let g:plantuml_executable_script = "~/file/plantuml.sh"

  " REST client
  call dein#add('sharat87/roast.vim')

  " traces vim
  call dein#add('markonm/traces.vim')

  " google translate
  call dein#add('skanehira/translate.vim')

  " open-broser.vim
  call dein#add('tyru/open-browser.vim')
  let g:netrw_nogx = 1
  nnoremap gx <Plug>(openbrowser-smart-search)
  vnoremap gx <Plug>(openbrowser-smart-search)
  command! OpenBrowserCurrent execute "!xdg-open" expand("%:p")

  " color picker
  call dein#add('KabbAmine/vCoolor.vim')
  let g:vcoolor_map = '<leader>c'

  " airline
  call dein#add('vim-airline/vim-airline')
  call dein#add('vim-airline/vim-airline-themes')
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'
  let g:airline#extensions#ale#enabled = 1

  " linter
  call dein#add('dense-analysis/ale')
  " エラーシンボル変更・シンボルカラムを常に表示
  let g:ale_sign_error = 'E'
  let g:ale_sign_warning = 'W'
  let g:ale_sign_column_always = 1

  " ステータスラインの変更
  let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']

  " メッセージのフォーマット変更
  let g:ale_echo_msg_error_str = 'E'
  let g:ale_echo_msg_warning_str = 'W'
  let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

  let g:ale_lint_on_enter = 0 " ファイルオープン時のチェックなし
  let g:ale_lint_on_save = 0
  let g:ale_linters_explicit = 1
  let g:ale_linters = {
  \   'ruby': ['rubocop'],
  \   'json': ['jsonlint'],
  \   'javascript': ['prettier', 'eslint'],
  \   'typescript': ['prettier', 'eslint'],
  \   'elixir': ['elixir-ls'],
  \}
  let g:ale_fixers = {
  \   '*': ['remove_trailing_lines', 'trim_whitespace'],
  \   'ruby': ['prettier'],
  \   'javascript': ['prettier', 'eslint'],
  \   'typescript': ['prettier', 'eslint'],
  \   'typescriptreact': ['prettier', 'eslint'],
  \}
  let g:ale_ruby_rubocop_executable = 'rubocop-daemon-wrapper'
  let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all'
  let g:ale_javascript_prettier_use_local_config = 1
  " let g:ale_elixir_elixir_ls_release = expand("$HOME/.elixir-ls/release")
  " let g:ale_elixir_elixir_ls_release = expand("$HOME/.local/share/vim-lsp-settings/servers/elixir-ls")
  " let g:ale_elixir_elixir_ls_config = {'elixirLS': {'dialyzerEnabled': v:false}}
  " let g:ale_completion_enabled = 1
  " ale on off switch nnoremap
  nnoremap <silent> <leader>json <Plug>(ale_toggle)
  " エラー間の移動
  " nnoremap <silent> <C-k> <Plug>(ale_previous_wrap)
  " nnoremap <silent> <C-j> <Plug>(aple_next_wrap)
  " ALEFixの実行
  nnoremap <silent> <leader>af :ALEFix<CR>
  " ALELintの実行
  nnoremap <silent> <leader>al :ALELint<CR>

  " denite.nvim
  " call dein#add('Shougo/denite.nvim')
  " let g:python3_host_prog = '~/.asdf/shims/python'
  " nnoremap <leader>rec :Denite file_rec<CR>

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
  call dein#add('mattn/ctrlp-matchfuzzy')
  let g:ctrlp_match_func = {'match': 'ctrlp_matchfuzzy#matcher'}

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
  let g:WebDevIconsConcealNerdTreeBrackets = 1
  let g:WebDevIconsNerdTreeBeforeGlyphPadding = ''
  let g:WebDevIconsNerdTreeAfterGlyphPadding = ''
  let g:WebDevIconsUnicodeDecorateFolderNodes = v:true

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

  " ultisnips
  call dein#add('SirVer/ultisnips')
  call dein#add('honza/vim-snippets')
  let g:UltiSnipsExpandTrigger = "<tab>"
  let g:UltiSnipsJumpForwardTrigger = "<c-f>"
  let g:UltiSnipsJumpBackwardTrigger = "<c-z>"
  " if you want :UltiSnipsEdit to split your window
  let g:UltiSnipsEditSplit = 'vertical'
  let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips',$HOME.'/.cache/dein/repos/github.com/honza/vim-snippets/UltiSnips']
  nnoremap <leader>ul :UltiSnipsEdit<CR>

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
  call dein#add('godlygeek/tabular')
  call dein#add('plasticboy/vim-markdown')
  let g:vim_markdown_folding_disabled = 1
  let g:vim_markdown_frontmatter = 1
  let g:vim_markdown_toml_frontmatter = 1
  let g:vim_markdown_json_frontmatter = 1
  let g:vim_markdown_autowrite = 1
  nnoremap <leader>m :MarkdownPreview<CR>

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

  " vim-crystal
  call dein#add('vim-crystal/vim-crystal')

  " vim-solidity
  call dein#add('tomlion/vim-solidity')

  " vim-go
  " call dein#add('fatih/vim-go', { 'do': ':GoInstallBinaries' })
  " let g:go_version_warning = 0
  " let g:go_fmt_command = 'goimports'
  " let g:go_addtags_transform = 'camelcase'
  " let g:go_term_mode = 'split'
  " let g:go_highlight_types = 1
  " let g:go_highlight_fields = 1
  " let g:go_highlight_functions = 1
  " let g:go_highlight_function_calls = 1
  " let g:go_highlight_operators = 1
  " let g:go_highlight_build_constraints = 1
  " vim-delve
  call dein#add('sebdah/vim-delve')

  " colorscheme tokyonight(それ以外はコメントアウト)
  call dein#add('ghifarit53/tokyonight-vim')
  set termguicolors
  let g:tokyonight_style = 'night' " available: night, storm
  " call dein#add('tomasr/molokai')
  " let g:molokai_original = 1
  " let g:rehash256 = 1
  " call dein#add('sjl/badwolf')
  " let g:badwolf_darkgutter = 1
  " let g:badwolf_tabline = 2
  " let g:badwolf_css_props_highlight = 1

  " rails complement
  call dein#add('tpope/vim-rails')
  call dein#add('slim-template/vim-slim')
  autocmd BufRead,BufNewFile *.slim setfiletype slim

  " rubocop
  call dein#add('ngmy/vim-rubocop')
  call dein#add('scrooloose/syntastic')
  let g:syntastic_mode_map = { 'mode': 'passive', 'active_filetypes': ['ruby'] }
  let g:syntastic_ruby_checkers = ['rubocop', 'mri']
  let g:syntastic_ruby_rubocop_exe = 'bundle exec rubocop'

  " CoffeeScript
  call dein#add('kchmck/vim-coffee-script')

  " tailwindcss
  " call dein#add('iamcco/coc-tailwindcss',  {
  " \  'do': 'yarn install --frozen-lockfile && yarn run build'
  " \})
  call dein#add('mrdotb/vim-tailwindcss')
  set completefunc=tailwind#complete
  nnoremap <leader>tl :set completefunc=tailwind#complete<cr>
  autocmd CompleteDone * pclose

  " vim-prettier
  call dein#add('prettier/vim-prettier', {
       \ 'do': 'yarn install',
       \ 'branch': 'release/1.x',
       \ 'for': [
       \ 'javascript',
       \ 'typescript',
       \ 'typescriptreact',
       \ 'css',
       \ 'less',
       \ 'scss',
       \ 'json',
       \ 'graphql',
       \ 'ruby',
       \ 'python',
       \ 'vue',
       \ 'yaml',
       \ 'html',
       \ 'solidity',
       \]})
  let g:prettier#autoformat = 0
  let g:prettier#quickfix_enabled = 0
  let g:prettier#config#semi = 'false'
  let g:prettier#config#single_quote = 'true'
  let g:prettier#config#bracket_spacing = 'true'
  let g:prettier#config#parser = ''
  let g:prettier#exec_cmd_path = '/home/motty/.asdf/shims/prettier'
  " autocmd BufWritePre *.js,*.jsx,*.ts,*.tsx,*.vue,*.css,*.scss,*.json PrettierAsync

  " javascript
  " call dein#add('yuezk/vim-js')
  call dein#add('pangloss/vim-javascript')
  call dein#add('maxmellon/vim-jsx-pretty')
  let g:vim_jsx_pretty_colorful_config = 1
  call dein#add('othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] })
  " set filetypes as typescriptreact
  autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
  autocmd BufNewFile,BufRead *.ts,*.tsx set filetype=typescript

  " prisma
  call dein#add('pantharshit00/vim-prisma')
  " sql formatter
  call dein#add('mattn/vim-sqlfmt')

  " TypeScript
  call dein#add('leafgarland/typescript-vim')
  call dein#add('peitalin/vim-jsx-typescript')
  call dein#add('styled-components/vim-styled-components', { 'branch': 'main' })

  " html5 code syntax
  call dein#add('hail2u/vim-css3-syntax')
  " HTML5 plugins
  call dein#add('othree/html5.vim')
  " emmet
  call dein#add('mattn/emmet-vim')

  " vim polyglot
  " syntax highlightやデフォルトフォーマットに対応してないものを適応する)
  call dein#add('sheerun/vim-polyglot')

  call dein#end()
  call dein#save_state()

" Required:
filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

""""""""""""""""""""""""""""""

" Cica font linux
set encoding=utf-8
set fileencodings=utf-8,iso-2022-jp,euc-jp,sjis
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
set wildmode=full
set showcmd " 入力中のコマンドを表示する
set browsedir=buffer " バッファで開いているファイルのディレクトリでエクスクローラを開始する
set smartcase " 小文字のみで検索したときに大文字小文字を無視する
set hlsearch " 検索結果をハイライト表示する
set background=dark " 暗い背景色に合わせた配色にする
set expandtab " タブ入力を複数の空白入力に置き換える
set incsearch " 検索ワードの最初の文字を入力した時点で検索を開始する
set hidden " 保存されていないファイルがあるときでも別のファイルを開けるようにする
set list " 不可視文字を表示する
set listchars=eol:\ ,trail:-,tab:>>- " タブと行の続きを可視化する
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
set completeopt^=popup,menuone,noinsert,noselect,preview
" set noequalalways " 自動的にウィンドウサイズを同じにする
" set winfixheight " ウィンドウの高さを保つ
" set textwidth=0 " 勝手に改行するのを防ぐ
" 構文毎に文字色を変化させる
syntax on
" カラースキーマの指定
" colorscheme desert
" colorscheme molokai
" colorscheme badwolf
colorscheme tokyonight
" 行番号の色
highlight LineNr ctermfg=darkyellow
" vimでalias読み込み
let $BASH_ENV = "~/.bash_aliases"

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

" vimを立ち上げたときに、自動的にvim-indent-guidesをオンにする
let g:indent_guides_enable_on_vim_startup = 1
" grep検索の実行後にQuickFix Listを表示する
autocmd QuickFixCmdPost *grep* cwindow

""""""""""""""""""""""""""""""
" javascript
""""""""""""""""""""""""""""""
function! EnableJavascript()
  " Setup used libraries
  let g:used_javascript_libs = 'jquery,underscore,react,typescript,vue,flux'
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
" go to end sentence
inoremap <C-a> <C-o>^
" go to start sentence
imap <C-s> <C-o>$

" filetype detection
filetype on
