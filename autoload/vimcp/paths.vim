" classpaths.vim
" Maintainer: rob boll @robertcboll

" set script-wide s:tool and s:rootdir variables
function s:set_rootdir_and_tool()
	let s:rootdir = ""

	for tool in ["lein", "maven", "sbt"]
		let s:rootdir = vimcp#tools#find_tool_root(tool)
		let s:tool = tool

		" found a project root
		if s:rootdir !=# ""
			break
		endif
	endfor
endfunction

function s:write_paths(funcs)
	echon "updating paths..."
		for writer in a:funcs
			exe writer
		endfor
	echon "complete!  "

	call vimcp#paths#set_paths_for_buffer(1)
endfunction

" get the classpath for a given buffer
function vimcp#paths#set_paths_for_buffer(force)
	" check if its set
	for path in ["vimcp", "vimsp"]
		let it = "b:" . path
		if !exists("b:" . path) || a:force ==# 1
			let pathfile = findfile("." . path, ".;")
			if filereadable(pathfile)
				exe "let b:" . path . " = \"" . join(readfile(pathfile)) . "\""
			else
				exe "let b:" . path . " = \"\""
			endif
		endif
	endfor

	if exists("g:loaded_javacompleteplugin")
		if exists("b:vimcp")
			if !empty(b:vimcp)
				call javacomplete#SetClassPath(b:vimcp)
			endif
		endif
		if exists("b:vimsp")
			if !empty(b:vimsp)
				call javacomplete#SetSourcePath(b:vimsp)
				call javacomplete#AddSourcePath(getcwd())
			endif
		endif
	endif

	if exists("g:loaded_syntastic_plugin")
		if exists("b:vimcp")
			let g:syntastic_java_javac_classpath = b:vimcp
			let g:syntastic_scala_scalac_classpath = b:vimcp
		endif
	endif
endfunction

function vimcp#paths#download_deps()
	call s:set_rootdir_and_tool()
	echon "downloading deps from " . s:tool . "..."
	exe "call vimcp#tools#" . s:tool . "#pull_deps(\"" . s:rootdir . "\")"
	echon "complete!  "
endfunction

function vimcp#paths#download_sources()
	call s:set_rootdir_and_tool()
	echon "downloading sources from " . s:tool . "..."
	exe "call vimcp#tools#" . s:tool . "#pull_sources(\"" . s:rootdir ."\")"
	echon "complete!  "
endfunction

function vimcp#paths#download_all()
	call s:set_rootdir_and_tool()
	echon "downloading deps and sources from " . s:tool . "..."
	exe "call vimcp#tools#" . s:tool . "#pull_deps(\"" . s:rootdir . "\")"
	exe "call vimcp#tools#" . s:tool . "#pull_sources(\"" . s:rootdir ."\")"
	echon "complete!  "
endfunction

" update classpath closest to this buffer
function vimcp#paths#write_and_set_paths()
	call s:set_rootdir_and_tool()
	let sp = "call vimcp#tools#" . s:tool . "#write_sourcepath(\"" . s:rootdir . "\")"
	let cp = "call vimcp#tools#" . s:tool . "#write_classpath(\"" . s:rootdir . "\")"
	call s:write_paths([sp, cp])
endfunction

function vimcp#paths#write_class_path()
	call s:set_rootdir_and_tool()
	let cp = "call vimcp#tools#" . s:tool . "#write_classpath(\"" . s:rootdir . "\")"
	call s:write_paths([cp])
endfunction

function vimcp#paths#write_source_path()
	call s:set_rootdir_and_tool()
	let sp = "call vimcp#tools#" . s:tool . "#write_sourcepath(\"" . s:rootdir . "\")"
	call s:write_paths([sp])
endfunction

" delete classpath closest to this buffer
function vimcp#paths#delete_paths()
	call s:set_rootdir_and_tool()

	for name in [".vimcp", ".vimsp"]
		for found in findfile(name, s:rootdir . "/**", -1)
			call delete(found)
		endfor
	endfor
endfunction
