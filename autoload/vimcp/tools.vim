" tools.vim
" Maintainer: rob boll @robertcboll

"
" utilities
"
function vimcp#tools#exec_in_dir(dir, executable)
	let old_workdir = getcwd()
	exe "cd " . a:dir

	let output = system(a:executable)
	
	exe "cd " . old_workdir
	return output
endfunction

function s:find_root(filename)
		let index = 1
		let found = findfile(a:filename, ".;", index)
		
		while !empty(found)
			let index = index + 1
			let next_found = findfile(a:filename, ".;", index)
			if !empty(next_found)
				let found = next_found
			else
				break
			endif
		endwhile

		return found
endfunction

function vimcp#tools#find_tool_root(tool)
	if a:tool ==# "maven"
		let found = s:find_root("pom.xml")
		if empty(found)
			return ""
		else
			return fnamemodify(found, ":p:h")
		endif
	endif
	
	if a:tool ==# "sbt"
		let found = ""
		for marker in g:vimcp_sbt_marker_files
			if empty(found)
				let found = s:find_root(marker)
			endif
		endfor

		if empty(found)
			return ""
		else
			return fnamemodify(found, ":p:h")
		endif
	endif
endfunction
