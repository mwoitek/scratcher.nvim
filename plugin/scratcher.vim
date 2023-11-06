if exists("g:loaded_scratcher")
  finish
endif
let g:loaded_scratcher=1

command! Scratch lua require("scratcher").scratch()
command! ScratchClear lua require("scratcher").scratch(true)
command! ScratchToggle lua require("scratcher").scratch_toggle()
command! ScratchPaste lua require("scratcher").scratch_paste()
command! ScratchMove lua require("scratcher").scratch_paste(true)
