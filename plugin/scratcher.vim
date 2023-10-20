if exists("g:loaded_scratcher")
  finish
endif
let g:loaded_scratcher=1

command! -nargs=0 Scratch lua require("scratcher").scratch()
