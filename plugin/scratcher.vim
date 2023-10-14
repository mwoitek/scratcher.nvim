if exists("g:loaded_scratcher")
  finish
endif
let g:loaded_scratcher=1

command! -nargs=0 ScratcherNew lua require("scratcher")._new_scratch()
command! -nargs=0 ScratcherNewAbove lua require("scratcher")._new_scratch("top")
command! -nargs=0 ScratcherNewBelow lua require("scratcher")._new_scratch("bottom")
command! -nargs=0 ScratcherNewLeft lua require("scratcher")._new_scratch("left")
command! -nargs=0 ScratcherNewRight lua require("scratcher")._new_scratch("right")
