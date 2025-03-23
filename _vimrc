" vim:foldmethod=marker:foldlevelstart=0

" custom function {{{

function! Grep() abort
  let s:pattern = input({'prompt':'search: '})
  redraw

  execute printf ("silent grep %s", s:pattern)
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

  "lsp
  call minpac#add('prabirshrestha/vim-lsp')
  call minpac#add('mattn/vim-lsp-settings')
  call minpac#add('prabirshrestha/asyncomplete.vim')
  call minpac#add('prabirshrestha/asyncomplete-lsp.vim')
endfunction

"disable Please do... message
let g:lsp_settings_enable_suggestions=0
let g:caw_no_default_keymappings=1

"}}}

"commands {{{
command! PackUpdate call PackInit() | call minpac#update()
command! PackClean call PackInit() | call minpac#clean()
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

if finddir('.git') !=# ''
  set grepprg=git\ grep\ -n
endif

au QuickFixCmdPost *grep* cwindow

set shiftwidth=2
set expandtab
set ambiwidth=double
set foldmethod=syntax
set mouse=
set noswapfile
set tabline=%!TabLine()
set showtabline=2
set hidden
"}}}

"mapping {{{
let g:mapleader=","
nmap <Space> [Space]
nnoremap [Space] <Nop>
nnoremap [Space]t <Cmd>belowright new<CR><Cmd>resize 15<CR><Cmd>terminal<CR>
nnoremap <Tab> <Cmd>wincmd w<CR>

call Key('t' , '<C-[>', '<C-\><C-n>')
call Key('n' , 'gh'   , '<Cmd>LspHover<CR>')
call Key('n' , 'gr'   , '<Cmd>LspReferences<CR>')
call Key('n' , 'gd'   , '<Cmd>LspDefinition<CR>')
call Key('n' , ';g'   , '<Cmd>call Grep()<CR>')
call Key('n' , ',f'   , '<Cmd>edit .<CR>')
call Key('n' , ',q'   , '<Cmd>confirm quit<CR>')
call Key('c' , '<C-x>', '<C-r>=expand("%:p")<CR>')
call Key('c' , '<C-a>', '<Home>')
call Key('c' , '<C-e>', '<End>')
call Key('nx', 'gf'   , '<Cmd>LspDocumentFormatSync<CR>')
call Key('nx', 'ccm'  , '<Plug>(caw:hatpos:toggle)')
call Key('nx', 'ccz'  , '<Plug>(caw:zeropos:comment)')
call Key('nx', 'ccuz' , '<Plug>(caw:zeropos:uncomment)')
call Key('nx', 'cca'  , '<Plug>(caw:dollarpos:comment)')
call Key('nx', 'ccua' , '<Plug>(caw:dollarpos:uncomment)')

autocmd FileType molder 
      \ call Key('n', 'h', '<Plug>(molder-up)',v:true)   | 
      \ call Key('n', 'l', '<Plug>(molder-open)',v:true)


if filereadable(expand('~/.vimrc_local'))
  source ~/.vimrc_local
endif

