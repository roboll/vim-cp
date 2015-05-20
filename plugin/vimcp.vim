" vimcp.vim
" Maintainer: rob boll <http://robertcboll.com>

" map of {scope_name : scope_path}
let g:vimcp_scopes = {"compile" : "", "test" : "src/test/"}

call classpaths#set_vimcp_for_buffer()

" update classpath closest to this buffer
function UpdateClasspath() 
	let rootdir = ""
	let toolname = ""

	for tool in ["maven", "sbt"]
		let rootdir = tools#find_tool_root("" . tool) 
		
		" found a project root
		if rootdir !=# ""
			break
		endif
	endfor

	echo "updating classpaths (may take a minute)"	
	execute "call tools#" . tool . "_write_classpath(\"" . rootdir . "\")"
	echo "classpaths updated!"
endfunction

" delete classpath closest to this buffer
function DeleteClasspath()
	delete(findfile(".vimcp", ".;"))
endfunction
