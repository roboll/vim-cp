" tools.vim
" Maintainer: rob boll <http://robertcboll.com>

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

	call s:exec_in_dir(a:root, mvn_cmd . "-Dmdep.outputFile=.vimcp -DincludeScope=compile" . mvn_log)
	call s:exec_in_dir(a:root, mvn_cmd . "-Dmdep.outputFile=src/test/.vimcp -DincludeScope=test" . mvn_log)
	return
endfunction

"
" sbt
"
function tools#sbt_write_classpath(root)
	for cmd in ["sbt --error -Dsbt.log.noformat=true 'export compile:full-classpath'", "sbt --error -Dsbt.log.noformat=true 'export test:full-classpath'"]
	
		let is_test = !empty(matchstr(cmd, '\c.*\(test\)'))
		let cmd_output = s:exec_in_dir(a:root, cmd)

		let splitted = split(cmd_output, "\n")
		let index = 0
	
		while index < len(splitted) 
			let submodule = matchstr(splitted[index], '\c\zs.\{-}\ze/\.*')
			let classpath = splitted[index+1]

			" TODO document this best effort to find the directory
			let submodule_dir = fnamemodify(finddir(submodule, "./**"), ":p")

			if empty(submodule_dir) 
				if ! empty(matchstr(a:root, '\c.*\(' . submodule .'\)'))
					let submodule_dir = a:root
				endif
			else
				let filename = ".vimcp"
				if is_test
					let filename = "/src/test/.vimcp"
				endif
				call writefile([classpath], submodule_dir . filename)
			endif

			let index = index+2
		endwhile

	endfor
	return
endfunction
