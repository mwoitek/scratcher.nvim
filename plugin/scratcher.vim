if exists("g:loaded_scratcher")
  finish
endif
let g:loaded_scratcher=1

command! -nargs=0 Scratch lua require("scratcher").scratch()
command! -nargs=0 ScratchClear lua require("scratcher").scratch(true)
command! -nargs=0 ScratchToggle lua require("scratcher").scratch_toggle()
