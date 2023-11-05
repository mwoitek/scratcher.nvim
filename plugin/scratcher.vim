if exists("g:loaded_scratcher")
  finish
endif
let g:loaded_scratcher=1

command! Scratch lua require("scratcher").scratch()
command! ScratchClear lua require("scratcher").scratch(true)
command! ScratchToggle lua require("scratcher").scratch_toggle()
