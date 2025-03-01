" custom function {{{
function! TabLine() abort
  let format = ''
  for i in range(1, tabpagenr('$'))
    let bufnrlist = tabpagebuflist(i)
    let winnr     = tabpagewinnr(i)
    let bufname   = fnamemodify(bufname(bufnrlist[winnr - 1]), ':t')
    let hi_name   = '%#'.(i == tabpagenr() ? 'TabLineSel' : 'TabLine'). '#'
    let format  ..= hi_name.'|%M '.i.':'.bufname.' |'
  endfor
  let format ..= '%#TabLineFill'
  return format
endfunction

function! Key(modes, key, action, buf = v:false, silent = v:false) abort
  let base = ['%snoremap']

  if a:buf    | call add(base,'<buffer>') | endif
  if a:silent | call add(base,'<silent>') | endif

  for mode in split(a:modes, '\zs')
    execute printf(join(base,' ').' %s %s', mode, a:key, a:action)
  endfor
endfunction

function! s:editsnippet() abort
  let l:filetype = getbufvar(bufnr(), '&ft')
  let l:extension = 'toml'
  let l:path = g:snippet_dir . l:filetype . '.' . l:extension

  execute printf('edit %s',l:path)
endfunction
" }}}

"plugins {{{
function! PackInit() abort
  let url = 'https://github.com/k-takata/minpac.git'
  let dir = '~/.config/nvim/pack/minpac/opt/minpac'

  if !isdirectory(expand(l:dir))
    silent execute printf("git clone %s %s", url, dir)
  endif

  packadd minpac

  call minpac#init()
  call minpac#add('k-takata/minpac', { 'type': 'opt' })
  call minpac#add('vim-denops/denops.vim')
  call minpac#add('prettier/vim-prettier')
  call minpac#add('cocopon/iceberg.vim')
  call minpac#add('tyru/caw.vim')
  call minpac#add('mattn/vim-molder')
  call minpac#add('uga-rosa/denippet.vim')

  "ddu
  call minpac#add('Shougo/ddu.vim')
  call minpac#add('Shougo/ddu-ui-ff')
  call minpac#add('Shougo/ddu-source-file_rec')
  call minpac#add('Shougo/ddu-kind-file')
  call minpac#add('Shougo/ddu-source-action')
  call minpac#add('Shougo/ddu-filter-matcher_substring')
  call minpac#add('Shougo/ddu-commands.vim')
  call minpac#add('kyoh86/ddu-source-git_log')

  "lsp
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('mattn/vim-lsp-settings')
  call minpac#add('prabirshrestha/asyncomplete.vim')
  call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
endfunction

" ddu {{{
call ddu#custom#action('ui', 'ff', 'tabedit',
  \ { args -> ddu#ui#do_action('itemAction', #{params: #{command: 'tabedit'}})
  \ })


call ddu#custom#patch_global(#{
  \ sourceOptions: #{
  \   _: #{
  \       matchers: ['matcher_substring'],
  \       ignoreCase: v:true
  \     },
  \ },
  \ sourceParams: #{
  \  file_rec: #{
  \     ignoredDirectories: ['.git','node_modules','vendor','.vscode']
  \  },
  \ },
  \ kindOptions: #{
  \   action: #{
  \     defaultAction: 'do',
  \   },
  \   file_rec: #{
  \     defaultAction: 'open',
  \   },
  \   file: #{
  \     defaultAction: 'open',
  \   },
  \ },
  \ uiParams: #{
  \   _:  #{
  \    split: 'floating',
  \    floatingBorder: 'rounded',
  \    floatingTitlePos: 'center'
  \   },
  \   ff: #{
  \     prompt: ">> ",
  \   }
  \ },
  \ })

autocmd FileType ddu-ff,ddu-filer call s:my_ddu_keymaps()

function! s:my_ddu_keymaps() abort
  call Key('n', 'q'    , "<Cmd>call ddu#ui#do_action('quit')<CR>"        , v:true, v:true)
  call Key('n', 'a'    , "<Cmd>call ddu#ui#do_action('chooseAction')<CR>", v:true, v:true)
  call Key('n', 't'    , "<Cmd>call ddu#ui#do_action('tabedit')<CR>"     , v:true, v:true)
  call Key('n', '<ESC>', "<Cmd>call ddu#ui#do_action('quit')<CR>"        , v:true, v:true)
  call Key('n', '<ESC>', "<Cmd>call ddu#ui#do_action('quit')<CR>"        , v:true, v:true)
  call Key('n', '<CR>' , "<Cmd>call ddu#ui#do_action('itemAction')<CR>"  , v:true, v:true)

  let uiName =  ddu#custom#get_current()->get('ui')

  if uiName == 'ff'
    call Key('n', 'i', "<Cmd>call ddu#ui#do_action('openFilterWindow')<CR>", v:true, v:true)
  endif
endfunction
" }}}

let g:snippet_dir = stdpath('config').'/snippet/'

for file in glob(g:snippet_dir.'*.*',1,1)
  call denippet#load(file)
endfor

"disable Please do... message
let g:lsp_settings_enable_suggestions=0
let g:caw_no_default_keymappings=1

"}}}

"commands {{{
command! PackUpdate call PackInit() | call minpac#update()
command! PackClean call PackInit() | call minpac#clean()
command! EditSnippet call s:editsnippet()
"}}}

"opts {{{

let loaded_netrwPlugin = 1

try
  colorscheme iceberg
catch
  colorscheme habamax
  "for lsp preview
  highlight clear FloatBorder
endtry


set shiftwidth=2
set expandtab
set ambiwidth=double
set foldmethod=syntax
set mouse=
set noswapfile
set tabline=%!TabLine()
set showtabline=2
"}}}

"mapping {{{
let g:mapleader="\<Space>"

call Key('t' , '<C-[>', '<C-\><C-n>')
call Key('n' , 'gh'   , '<Cmd>LspHover<CR>')
call Key('n' , 'gr'   , '<Cmd>LspReferences<CR>')
call Key('n' , 'gd'   , '<Cmd>LspDefinition<CR>')
call Key('n' , ',f'   , '<Cmd>edit .<CR>')
call Key('n' , ',q'   , '<Cmd>confirm quit<CR>')
call Key('c' , '<C-x>', '<C-r>=expand("%:p")<CR>')
call Key('nx', 'gf'   , '<Cmd>LspDocumentFormatSync<CR>')
call Key('nx', 'ccm'  , '<Plug>(caw:hatpos:toggle)')
call Key('nx', 'ccz'  , '<Plug>(caw:zeropos:comment)')
call Key('nx', 'ccuz' , '<Plug>(caw:zeropos:uncomment)')
call Key('nx', 'cca'  , '<Plug>(caw:dollarpos:comment)')
call Key('nx', 'ccua' , '<Plug>(caw:dollarpos:uncomment)')
inoremap <expr> <Tab>   denippet#jumpable()   ? '<Plug>(denippet-jump-next)' : '<Tab>'
snoremap <expr> <Tab>   denippet#jumpable()   ? '<Plug>(denippet-jump-next)' : '<Tab>'
inoremap <expr> <S-Tab> denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<S-Tab>'
snoremap <expr> <S-Tab> denippet#jumpable(-1) ? '<Plug>(denippet-jump-prev)' : '<S-Tab>'
inoremap <C-l> <Plug>(denippet-expand)

autocmd FileType molder 
      \ call Key('n', 'h', '<Plug>(molder-up)',v:true)   | 
      \ call Key('n', 'l', '<Plug>(molder-open)',v:true)

nnoremap g<Space> <Cmd>Ddu git_log
      \ -ui=ff
      \ -ui-param-ff-floatingTitle=gitlog
      \ -ui-param-ff-winWidth=&columns
      \ -source-param-git_log-showGraph=v:true
      \ <CR>
nnoremap <Space>f <Cmd>Ddu file_rec
      \ -ui=ff
      \ -ui-param-ff-floatingTitle=fuzzyfinnd
      \ -ui-param-ff-startAutoAction=v:true
      \ <CR>
"}}}


if filereadable(expand('~/.vimrc_local'))
  source ~/.vimrc_local
endif

" vim:foldmethod=marker:foldlevelstart=0
