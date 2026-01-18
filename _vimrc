" vim:foldmethod=marker:foldlevelstart=0

" custom function {{{

function! Grep() abort
  let s:pattern = input({'prompt':'search: '})
  redraw

  execute printf ("silent grep %s", s:pattern)
endfunction

function! Terminal() abort
  call Cd(expand('%:p:h'))
  belowright new
  resize 15
  terminal
endfunction

function! Cd(path=getcwd()) abort
    execute printf('lcd %s', a:path)
endfunction

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
" }}}

"plugins {{{
function! PackInit() abort
  let url = 'https://github.com/k-takata/minpac.git'
  let dir = '~/.config/nvim/pack/minpac/opt/minpac'

  if !isdirectory(expand(l:dir))
    silent execute printf("!git clone %s %s", url, dir)
  endif

  packadd minpac

  call minpac#init()
  call minpac#add('k-takata/minpac', { 'type': 'opt' })
  call minpac#add('vim-denops/denops.vim')
  call minpac#add('previm/previm')
  call minpac#add('tyru/open-browser.vim')
  call minpac#add('prettier/vim-prettier')
  call minpac#add('cocopon/iceberg.vim')
  call minpac#add('tyru/caw.vim')
  call minpac#add('mattn/vim-molder')
  call minpac#add('ctrlpvim/ctrlp.vim')
  call minpac#add('mattn/ctrlp-matchfuzzy')
  call minpac#add('mattn/ctrlp-gitchanges')
  call minpac#add('mattn/ctrlp-lsp')
  call minpac#add('machakann/vim-sandwich')

  call minpac#add('hrsh7th/vim-vsnip')
  call minpac#add('hrsh7th/vim-vsnip-integ')
  call minpac#add('mattn/vim-maketable')

  "lsp
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('mattn/vim-lsp-settings')
  call minpac#add('prabirshrestha/asyncomplete.vim')
  call minpac#add('prabirshrestha/asyncomplete-lsp.vim')

endfunction

"disable Please do... message
let g:lsp_settings_enable_suggestions=0
let g:caw_no_default_keymappings=1
let g:ctrlp_show_hidden = 1
let g:ctrlp_max_files=10000
let g:ctrlp_custom_ignore = 'node_modules\|vendor\|DS_Store\|git'
let g:ctrlp_match_func = #{ match: 'ctrlp_matchfuzzy#matcher'}

let g:sandwich#recipes = deepcopy(g:sandwich#default_recipes)
let g:sandwich#recipes += [
      \ {
      \    "buns": ["```","```"],
      \    'nesting': 0,
      \    'input': ["cb"],
      \    'filetype': ['markdown'],
      \    'linewise': 1
      \ },
      \ ]
"}}}

"commands {{{
command! PackUpdate call PackInit() | call minpac#update()
command! PackClean call PackInit() | call minpac#clean()
command! PackStatus call PackInit() | call minpac#status()
"}}}

"opts {{{

let loaded_netrwPlugin = 1

let g:lsp_settings_filetype_typescript = [
      \ 'typescript-language-server',
      \ 'deno'
      \ ]

let g:vsnip_snippet_dir = expand('~/config/snippet')
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.typescript = ['javascript']

try
  colorscheme iceberg
catch
  colorscheme habamax
  "for lsp preview
  highlight clear FloatBorder
endtry

if finddir('.git') !=# ''
  set grepprg=git\ grep\ -n
endif

au QuickFixCmdPost *grep* cwindow
au TabNewEntered * call Cd(expand('%:p:h'))

set shiftwidth=2
set expandtab
set ambiwidth=double
set mouse=
set noswapfile
set tabline=%!TabLine()
set showtabline=1
set hidden
"}}}

"mapping {{{
let g:mapleader=","

"keymap prefix
nnoremap [Space] <Nop>
nmap <Space> [Space]

nnoremap [LSP] <Nop>
nmap e [LSP]

nnoremap <Tab> <Cmd>wincmd w<CR>
nnoremap K <Nop>

call Key('t' , '<C-[>', '<C-\><C-n>')
call Key('n' , '[LSP]h'   , '<Cmd>LspHover<CR>')
call Key('n' , '[LSP]r'   , '<Cmd>LspReferences<CR>')
call Key('n' , '[LSP]d'   , '<Cmd>LspDefinition<CR>')
call Key('nx', '[LSP]f'   , '<Cmd>LspDocumentFormatSync<CR>')

call Key('n' , ';g'   , '<Cmd>call Grep()<CR>')
call Key('n' , ',f'   , '<Cmd>edit .<CR>')
call Key('n' , ',w'   , '<Cmd>update<CR>')
call Key('n' , ',q'   , '<Cmd>confirm quit<CR>')
call Key('n', '[Space]f', '<Cmd>CtrlP<CR>')
call Key('n', '[Space]t', '<Cmd>call Terminal()<CR>')
call Key('n', ';b', '<Cmd>CtrlPBuffer<CR>')
call Key('c' , '<C-x>', '<C-r>=expand("%:p")<CR>')
call Key('c' , '<C-a>', '<Home>')
call Key('c' , '<C-e>', '<End>')
call Key('nx', 'ccm'  , '<Plug>(caw:hatpos:toggle)')
call Key('nx', 'ccz'  , '<Plug>(caw:zeropos:comment)')
call Key('nx', 'ccuz' , '<Plug>(caw:zeropos:uncomment)')
call Key('nx', 'cca'  , '<Plug>(caw:dollarpos:comment)')
call Key('nx', 'ccua' , '<Plug>(caw:dollarpos:uncomment)')

imap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'
smap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'
imap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

inoremap <expr> /
      \ complete_info(['mode']).mode == 'files' && complete_info(['selected']).selected >= 0
      \ ? '<C-x><C-f>'
      \ : '/'

autocmd FileType molder 
      \ call Key('n', 'h', '<Plug>(molder-up)',v:true)   | 
      \ call Key('n', 'l', '<Plug>(molder-open)',v:true)


if filereadable(expand('~/.vimrc_local'))
  source ~/.vimrc_local
endif

