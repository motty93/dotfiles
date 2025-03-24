" 一旦ファイルタイプ関連を無効化する
filetype off

" <leader>
let mapleader = ","

" disabled modify other keys
let &t_TI = ""
let &t_TE = ""

" shell
let $SHELL = '/bin/bash'
let $PATH = system('bash -c "echo -n $PATH"')

" clear cache
" call map(dein#check_clean(), 'delete(v:val, 'rf')')

" auto reload .vimrc
augroup source-vimrc
  autocmd!
  autocmd BufWritePost *vimrc source $MYVIMRC | set foldmethod=marker
  autocmd BufWritePost *gvimrc if has('gui_running') source $MYGVIMRC
augroup END

set runtimepath+=$HOME/.cache/dein/repos/github.com/Shougo/dein.vim

call dein#begin("$HOME/.cache/dein")
call dein#add("$HOME/.cache/dein/repos/github.com/Shougo/dein.vim")
let g:python3_host_prog = '~/.asdf/shims/python3'
let g:python_host_prog = '~/.asdf/shims/python'
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
call dein#add('mattn/vim-lsp-icons')
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = 'vim-lsp.log'
" let g:lsp_log_level = 'debug'
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
  nnoremap <silent> K :LspHover<CR>
  nnoremap <silent> gr :LspReferences<CR>
  nnoremap <silent> gS :LspDocumentSymbolSearch<CR>
  nnoremap <silent> gs :LspWorkspaceSymbolSearch<CR>
  nnoremap <silent> gi :LspImplementation<CR>
  " nnoremap <silent> gt :LspTypeDefinition<CR>
  nnoremap <silent> <leader>rn :LspRename<CR>
  nnoremap <silent> [g :LspPreviousDiagnostic<CR>
  nnoremap <silent> ]g :LspNextDiagnostic<CR>
  nnoremap <silent> ]e :LspNextError<CR>
  nnoremap <silent> [e :LspPreviousError<CR>
  inoremap <silent> <expr><c-f> lsp#scroll(+4)
  inoremap <silent> <expr><c-d> lsp#scroll(-4)

  let g:lsp_format_sync_timeout = 1000
  autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction
augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END
" NOTE: vim-lspに統合されたのでコメントアウト
" call dein#add('prabirshrestha/async.vim')
call dein#add('prabirshrestha/asyncomplete.vim')
let g:asyncomplete_auto_completeopt = 0
let g:lsp_diagnostics_enabled = 1
let g:lsp_diagnostics_echo_cursor = 1
let g:asyncomplete_popup_delay = 200
let g:lsp_text_edit_enabled = 1
let g:lsp_preview_float = 1
let g:lsp_diagnostics_fload_cursor = 1
" let g:lsp_settings_filetype_ruby = ['ruby-lsp', 'steep', 'typeprof']
" let g:lsp_settings_filetype_ruby = ['solargraph', 'steep']
call dein#add('thomasfaingnaert/vim-lsp-snippets')
" call dein#add('thomasfaingnaert/vim-lsp-ultisnips')

call dein#add('tyru/capture.vim')

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
if executable('solargraph')
    " gem install solargraph
    au User lsp_setup call lsp#register_server({
        \ 'name': 'solargraph',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
        \ 'whitelist': ['ruby'],
        \ })
endif
" lsp typescript(vim-lsp-settingsだとtsxに対応してないっぽい)
let g:lsp_settings_filetype_javascript = ['typescript-language-server']
let g:lsp_settings_filetype_javascriptreact = ['typescript-language-server']
let g:lsp_settings_filetype_typescript = ['typescript-language-server']
let g:lsp_settings_filetype_typescriptreact = ['typescript-language-server']
if executable('typescript-language-server')
  augroup lsp_typescriptreact
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
                \ 'name': 'typescript-language-server',
                \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
                \ 'whitelist': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
                \ })
    autocmd FileType typescript setlocal omnifunc=lsp#complete
  augroup END :echomsg 'vim-lsp with `typescript-language-server` enabled'
else
  :echomsg 'vim-lsp for typescript unavailable'
endif
" lsp deno
" if executable("deno")
"   augroup LspTypeScript
"     autocmd!
"     autocmd User lsp_setup call lsp#register_server({
"     \ "name": "deno lsp",
"     \ "cmd": {server_info -> ["deno", "lsp"]},
"     \ "root_uri": {server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), "tsconfig.json"))},
"     \ "whitelist": ["typescript", "typescript.tsx"],
"     \ })
"   augroup END
" endif
" lsp terraform
if executable("terraform-ls")
  au User lsp_setup call lsp#register_server({
    \ 'name': 'terraform-ls',
    \ 'cmd': {server_info -> ['terraform-ls', 'serve']},
    \ 'whitelist': ['terraform'],
    \ })
  autocmd BufWritePre *.tf LspDocumentFormatSync
endif
" lsp Vue
call dein#add('posva/vim-vue')
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
"         \           echo -n $PATH}
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
" lsp go template
if executable('vscode-html-languageserver')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'html-languageserver',
    \ 'cmd': {server_info->['vscode-html-languageserver', '--stdio']},
    \ 'whitelist': ['html', 'gohtmltmpl'],
    \ })
endif
" elixir-ls
" let g:lsp_settings = { 'elixir-ls': { 'cmd': $HOME . '/.elixir-ls/release/' } }
if executable('elixir-ls')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'elixir-ls',
    \ 'cmd': {server_info->['elixir-ls']},
    \ 'whitelist': ['elixir'],
    \ })
  autocmd BufWritePre *.exs,*.ex,*.eex,*.heex,*.leex,*.sface LspDocumentFormatSync
endif
" pylsp-all
" pip install python-lsp-server[pylint] pylint
if executable('pylsp')
  let g:lsp_settings = {
  \  'pylsp-all': {
  \    'workspace_config': {
  \      'pylsp': {
  \        'configurationSources': ['flake8'],
  \        'plugins': {
  \          'flake8': {
  \            'enabled': 1
  \          },
  \          'mccabe': {
  \            'enabled': 0
  \          },
  \          'pycodestyle': {
  \            'enabled': 0
  \          },
  \          'pyflakes': {
  \            'enabled': 0
  \          },
  \          'pylsp_mypy': {
  \            'enabled': 1
  \          },
  \          'pylint': {
  \            'enabled': 1,
  \            'executable': '~/.asdf/shims/pylint'
  \          },
  \        }
  \      }
  \    }
  \  }
  \}
endif

" ruby lsp
" Rubyのメジャーバージョンを取得して返す関数
function! GetRubyVersion()
  let l:version = system("ruby -e 'print RUBY_VERSION.split(\".\")[0]'")
  return str2nr(substitute(l:version, '\n', '', ''))
endfunction
" 親ディレクトリを取得してURIを返す関数
function! GetRubyRootURI()
  " 親ディレクトリを取得
  let l:dir = lsp#utils#find_nearest_parent_directory(
        \ lsp#utils#get_buffer_path(), ['Gemfile', '.git']
        \ )

  " デバッグ用の出力
  echom "Value: " . string(l:dir)
  echom "Type: " . string(type(l:dir))

  " 数値型または無効な型の場合のフォールバック処理
  if type(l:dir) != type('') || l:dir == 1
    echom "Warning: Invalid directory, using fallback."
    let l:dir = fnamemodify(lsp#utils#get_buffer_path(), ':h')
  endif

  " URI形式に変換して返す
  return lsp#utils#path_to_uri(l:dir)
endfunction

" RubyのバージョンによってLSPを切り替える
if GetRubyVersion() >= 3 && executable('ruby-lsp')
  " Ruby 3以上の場合: ruby-lspを使用
  augroup RubyLsp
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'ruby-lsp',
          \ 'cmd': ['ruby-lsp'],
          \ 'whitelist': ['ruby'],
          "\ 'root_uri': {server_info -> GetRubyRootURI()},
          \ })
  augroup END
  let g:lsp_settings_filetype_ruby = ['ruby-lsp']
elseif executable('solargraph')
  " Ruby 2.x以下の場合: solargraphを使用
  augroup Solargraph
    autocmd!
    autocmd User lsp_setup call lsp#register_server({
          \ 'name': 'solargraph',
          \ 'cmd': ['solargraph', 'stdio'],
          \ 'whitelist': ['ruby'],
          "\ 'root_uri': {server_info -> GetRubyRootURI()},
          \ })
  augroup END
  let g:lsp_settings_filetype_ruby = ['solargraph']
endif

" 保存時の自動フォーマット
autocmd BufWritePre *.rb LspDocumentFormatSync


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
let g:previm_open_cmd = '/mnt/c/Program\ Files/Google/Chrome/Application/chrome.exe'
let g:previm_wsl_mode = 1

" editorconfig
call dein#add('editorconfig/editorconfig-vim')

" git diff
call dein#add('airblade/vim-gitgutter')
let g:gitgutter_hightlight_lines = 1

" git commit prefix autocomplete
" :AICommitMessageのおかげで不要になった
" call dein#add('gotchane/vim-git-commit-prefix')
" let g:git_commit_prefix_lang = 'ja'

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
" lspを無効化
" let g:ale_disable_lsp = 1
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

let g:ale_lint_on_enter = 1 " ファイルオープン時のチェック
let g:ale_lint_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_linters = {
\   'ruby': ['rubocop'],
\   'json': ['jsonlint'],
\   'javascript': ['biome'],
\   'typescript': ['biome'],
\   'elixir': ['credo'],
\   'markdown': ['remark-lint'],
\   'python': ['flake8', 'mypy'],
\}
" npm i -g @biomejs/biome
" npm i -g js-beautify
" pip install flake8 flake8-import-order black isort autopep8
" npm i -g prettier
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'html': ['html-beautify'],
\   'css': ['prettier'],
\   'javascript': ['biome'],
\   'javascriptreact': ['biome'],
\   'typescript': ['biome'],
\   'typescriptreact': ['biome'],
\   'ruby': ['prettier'],
\   'elixir': ['mix_format'],
\   'markdown': ['remark-lint'],
\   'yaml': ['prettier'],
\   'dart': ['dart-format'],
\   'python': ['black', 'isort'],
\   'sql': [
\     { buffer -> {
\       'command': 'sql-formatter -l mysql'
\     }},
\   ],
\}
let g:ale_html_beautify_options = '--indent-with-tabs --indent-size 1'
" let g:ale_ruby_rubocop_executable = 'rubocop-daemon-wrapper'
let g:ale_ruby_rubocop_options = ''
let g:ale_javascript_prettier_options = '--single-quote --trailing-comma all'
let g:ale_javascript_prettier_use_local_config = 1
" let g:ale_elixir_elixir_ls_release = expand("~/.elixir-ls/release")
let g:ale_elixir_elixir_ls_release = expand("~/.local/share/vim-lsp-settings/servers/elixir-ls")
let g:ale_elixir_elixir_ls_config = {
\   'elixirLS': {
\     'dialyzerEnabled': v:false,
\   },
\}
let g:ale_completion_enabled = 1

" npm i -g prisma
function! PrismaFormat()
  " prisma formatを実行
  call system('prisma format --schema ' . shellescape(expand('%')))
  " バッファを再読み込みしてファイルに反映
  edit!
endfunction
" prisma format
nnoremap <silent> <leader>pf :call PrismaFormat()<CR>

" ale on off switch nnoremap
nnoremap <silent> <leader>json <Plug>(ale_toggle)
" エラー間の移動
nnoremap <silent> <C-k> <Plug>(ale_previous_wrap)
nnoremap <silent> <C-j> <Plug>(aple_next_wrap)
" ALEFixの実行
nnoremap <silent> <leader>af :ALEFix<CR>
" ALELintの実行
nnoremap <silent> <leader>al :ALELint<CR>

" denops.vim
call dein#add('vim-denops/denops.vim')
" deno fmt
nnoremap <silent> <leader>df :!deno fmt<CR>

" ddu.vim
" call dein#add('Shougo/ddu.vim')
" call dein#add('Shougo/ddu-ui-ff')
" call ddu#custom#patch_global(#{
"       \   ui: 'ff',
"       \ })

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
  let g:unite_source_grep_command = '/usr/bin/ag'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor --ignore .git --ignore .svn --ignore .hg --ignore .DS_Store --ignore node_modules'
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
call dein#add('prabirshrestha/asyncomplete-ultisnips.vim')
let g:UltiSnipsExpandTrigger = "<tab>"
let g:UltiSnipsJumpForwardTrigger = "<c-f>"
let g:UltiSnipsJumpBackwardTrigger = "<c-z>"
" if you want :UltiSnipsEdit to split your window
let g:UltiSnipsEditSplit = 'vertical'
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips',$HOME.'/.cache/dein/repos/github.com/honza/vim-snippets/UltiSnips']
nnoremap <leader>ul :UltiSnipsEdit<CR>
let g:UltiSnipsExpandTrigger="<c-e>"
call asyncomplete#register_source(asyncomplete#sources#ultisnips#get_source_options({
    \ 'name': 'ultisnips',
    \ 'allowlist': ['*'],
    \ 'completor': function('asyncomplete#sources#ultisnips#completor'),
    \ }))

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
" call dein#add('iamcco/markdown-preview.nvim', { 'on_ft': ['markdown', 'pandoc.markdown', 'rmd'], 'build': 'cd app & yarn install' })
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
au BufRead,BufNewFile *.ex,*.exs set filetype=elixir
au BufRead,BufNewFile *.eex,*.heex,*.leex,*.sface,*.lexs set filetype=eelixir
au BufRead,BufNewFile mix.lock set filetype=elixir
" mix command :Mix
call dein#add('mattreduce/vim-mix')
" elixir test
call dein#add('BjRo/vim-extest')
" elixir alchemist.vim
call dein#add('slashmili/alchemist.vim')
" elixir formatter
call dein#add('mhinz/vim-mix-format')
nnoremap <leader>mf :MixFormat<CR>
nnoremap <leader>mfd :MixFormatDiff<CR>

" vim-crystal
call dein#add('vim-crystal/vim-crystal')

" vim-solidity
call dein#add('tomlion/vim-solidity')

" vim-delve
call dein#add('sebdah/vim-delve')
nnoremap <silent> <leader>dlv :DlvDebug<CR>
nnoremap <silent> <leader>dlb :DlvToggleBreakpoint<CR>

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

" vim ruby
call dein#add('vim-ruby/vim-ruby')
call dein#add('vim-scripts/ruby-matchit')
" ruby move block mapping
" function! GoToMatchingPair()
"   let l:cur_pos = getpos('.')
"   let l:matchpairs = 'do:end,' . &matchpairs
"   let old_matchpairs = &matchpairs
"   let &matchpairs = l:matchpairs
"   exe "normal! %"
"   let &matchpairs = old_matchpairs
" endfunction  nnoremap [r :call GoToMatchingPair()<CR>

" rails complement
call dein#add('tpope/vim-rails')
call dein#add('slim-template/vim-slim')
autocmd BufRead,BufNewFile *.slim setfiletype slim

" tailwindcss
" call dein#add('iamcco/coc-tailwindcss',  {
" \  'do': 'yarn install --frozen-lockfile && yarn run build'
" \})
call dein#add('mrdotb/vim-tailwindcss')
set completefunc=tailwind#complete
nnoremap <leader>tl :set completefunc=tailwind#complete<cr>
autocmd CompleteDone * pclose

" javascript
" call dein#add('yuezk/vim-js')
call dein#add('pangloss/vim-javascript')
call dein#add('maxmellon/vim-jsx-pretty')
let g:vim_jsx_pretty_colorful_config = 1
call dein#add('othree/yajs.vim', { 'for': ['javascript', 'javascript.jsx'] })
" set filetypes as typescriptreact
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescriptreact
autocmd BufNewFile,BufRead *.ts,*.tsx set filetype=typescript
autocmd BufEnter *.tsx set filetype=typescriptreact

" prisma
call dein#add('prisma/vim-prisma')
autocmd BufRead,BufNewFile *.prisma set filetype=prisma
" sql formatter
call dein#add('mattn/vim-sqlfmt')

" TypeScript
call dein#add('leafgarland/typescript-vim')
call dein#add('peitalin/vim-jsx-typescript')
call dein#add('styled-components/vim-styled-components', { 'branch': 'main' })

" Svelte
call dein#add('evanleck/vim-svelte')
let g:svelte_preprocessors = ['typescript']

" html5 code syntax
call dein#add('hail2u/vim-css3-syntax')
" HTML5 plugins
call dein#add('othree/html5.vim')
" emmet
call dein#add('mattn/emmet-vim')

" terraform
call dein#add('hashivim/vim-terraform')
let g:terraform_fmt_on_save=1

" copilot
call dein#add('github/copilot.vim')

" vimmemo
call dein#add('glidenote/memolist.vim')
let g:memolist_prompt_tags = 1
let g:memolist_prompt_categories = 1
let g:memolist_path = "~/github.com/motty93/memotty/memo"
let g:memolist_memo_suffix = "md"
" let g:memolist_template_dir_path = "~/.vim/template/memolist"
let g:memolist_unite = 1
map <leader>mn :MemoNew<CR>
map <leader>ml :MemoList<CR>
map <leader>mg :MemoGrep<CR>
" augroup MemoNew
"   autocmd!
"   autocmd BufNewFile ~/github.com/motty-memo/memo/*.md call InsertTemplate()
" augroup END
" function! InsertTemplate()
"   " 既存の第一行が'titile:'を含む場合、先頭行を削除
"   if getline(1) =~ 'title:'
"     execute '1delete'
"   endif
"
"   let template_file = expand('~/.vim/template/memolist/memo_template.txt')
"   if filereadable(template_file)
"     execute '0r ' . template_file
"     " {{DATE}}を今日の日付に置換
"     let l:today = strftime('%Y-%m-%d')
"     execute '%s/##DATE##/' . l:today . '/e'
"     " {{CURSOR}をカーソル位置に設定}
"     call search('##CURSOR##')
"     execute 'normal!' "_diw"
"   endif
" endfunction

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
set incsearch " 検索ワードの最初の文字を入力した時点で検索を開始する
set hidden " 保存されていないファイルがあるときでも別のファイルを開けるようにする
set list " 不可視文字を表示する
set listchars=eol:\ ,trail:-,tab:>>- " タブと行の続きを可視化する
set number " 行番号を表示する
set showmatch " 対応する括弧やブレースを表示する
set tabstop=2 " タブ文字の表示幅
set expandtab " タブ入力を複数の空白入力に置き換える
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
set shell=/bin/bash
set regexpengine=1
set noignorecase
set nosmartcase
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

" .templ, .tmpl ファイルをhtml ファイルタイプとして認識
autocmd BufNewFile,BufRead *.html,*.templ,*.tmpl set filetype=html


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

" command
command! -nargs=0 AICommitMessage call AICommitMessage()
function! AICommitMessage()
  " コマンドの出力を取得
  let l:message = system("~/.config/generate_commit_message 2> /dev/null")

  " messageが空であれば何もしない
  if l:message == ''
    return
  endif

  " 出力のエラーハンドリング
  if v:shell_error != 0
    echohl ErrorMsg
    echo "Error running generate_commit_message"
    echohl None
    return
  endif

  " 出力結果の改行をtrim
  let l:message = substitute(l:message, '\n\+$', '', '')

  " カーソル位置に挿入（改行しない）
  call setline('.', getline('.') . l:message)
endfunction

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
" vim cache clear
nnoremap <leader>cc :call dein#recache_runtimepath()<CR>
" ai commit message
nnoremap <silent> <leader>cm :silent! AICommitMessage<CR>
" remove hightlight
nnoremap <silent> <leader>n :nohlsearch<CR>
"  github copilot C-j
imap <silent><script><expr> <C-j> copilot#Accept("\<CR>")
" filetype detection
filetype on

source $VIMRUNTIME/macros/matchit.vim
