" tools.vim
" Maintainer: rob boll @robertcboll

"
" utilities
"
function s:exec_in_dir(dir, executable)
	let old_workdir = getcwd()
	execute "cd " . a:dir

	let output = system(a:executable)
	
	execute "cd " . old_workdir
	return output
endfunction

function tools#find_tool_root(tool)
	if a:tool ==# "maven"
		let pomfile = findfile("pom.xml", ".;")
		if empty(pomfile)
			return ""	
		else
			return fnamemodify(pomfile, ":p:h")
		endif
	endif
	
	if a:tool ==# "sbt"
		" try *.sbt first
		let sbtfile = findfile("build.sbt", ".;")
		if empty(sbtfile)
			let sbtfile = findfile("sbt", ".;")
		endif

		if empty(sbtfile)
			return ""
		else
			return fnamemodify(sbtfile, ":p:h")
		endif
	endif
endfunction

" 
" maven 
"
function tools#maven_write_classpath(root)
	let mvn_cmd = "mvn dependency:build-classpath "
	let mvn_log = ">> ~/.vim/vimcp.log"

	for scope in keys(g:vimcp_scopes)
		call s:exec_in_dir(a:root, mvn_cmd . "-Dmdep.outputFile=" . g:vimcp_scopes[scope] . ".vimcp -DincludeScope=" . scope . mvn_log)
	endfor
endfunction

"
" sbt
"
function tools#sbt_write_classpath(root)
	for scope in keys(g:vimcp_scopes)
		let cmd = "sbt --error -Dsbt.log.noformat=true 'export " .scope. ":full-classpath'"
		
		let cp_path = g:vimcp_scopes[scope]
		let cp_file = cp_path . ".vimcp"
		
		if !isdirectory(cp_path)
			call mkdir(cp_path, "p")
		endif

		let cmd_output = s:exec_in_dir(a:root, cmd)

		let splitted = split(cmd_output, "\n")
		
		if len(splitted) ==# 1
			let classpath = splitted[0]

			echo "classpath is " . classpath
			echo "writing it to " . cp_file

			call writefile([classpath], a:root . "/" . cp_file)
		else
			let index = 0
	
			while index < len(splitted) 
				let submodule = matchstr(splitted[index], '\c\zs.\{-}\ze/\.*')
				let classpath = splitted[index+1]

				let submodule_dir = finddir(submodule, a:root . "/**")

				if empty(submodule_dir)
					if !empty(matchstr(a:root, '\c.*\(' . submodule .'\)'))
						let submodule_dir = a:root
					endif
				endif
			
				if !empty(submodule_dir)
					let full_dir = fnamemodify(submodule_dir, ":p")  
					call writefile([classpath], full_dir . cp_file)
				endif

				let index = index + 2
			endwhile
		endif

	endfor	
endfunction
