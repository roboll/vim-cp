" classpaths.vim
" Maintainer: rob boll <http://robertcboll.com>

" get the classpath for a given buffer
function classpaths#set_vimcp_for_buffer()
	" check if its set
	if !exists("b:vimcp")
		let cpfile = findfile(".vimcp", ".;")
		if filereadable(cpfile)
			let b:vimcp = join(readfile(cpfile))
		else
			let b:vimcp = ""
		endif
	endif

	return
endfunction
