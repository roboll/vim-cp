" tools.vim
" Maintainer: rob boll @robertcboll

"
" utilities
"
function s:exec_in_dir(dir, executable)
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

" 
" maven 
"
let s:mvn_log = ">>~/.vim/vimcp.log"
let s:mvn_tmpfile = ".vimcp_tmp"

function vimcp#tools#maven_pull_sources(root)
	call s:exec_in_dir(a:root, "mvn dependency:sources" . s:mvn_log)
endfunction

function vimcp#tools#maven_pull_deps(root)
	call s:exec_in_dir(a:root, "mvn dependency:build-classpath" . s:mvn_log)
endfunction

function vimcp#tools#maven_write_sourcepath(root)
	call s:exec_in_dir(a:root, 
				\"mvn dependency:build-classpath -Dscope=compile -Dclassifier=sources -Dmdep.outputFile=" 
				\. a:root . "/" . s:mvn_tmpfile . s:mvn_log)

	let src_jars = split(join(readfile(a:root . "/" . s:mvn_tmpfile)), ":")
	call delete(a:root . "/" . s:mvn_tmpfile)

	if len(src_jars) > 0
		let src_paths = []
		for src_jar in src_jars
			let src_jar_dir = fnamemodify(src_jar, ":p:h")
			let src_jar_name = fnamemodify(src_jar, ":t")

			if filereadable(src_jar_dir . src_jar_name)
				call s:exec_in_dir(src_jar_dir, "unzip " . src_jar_name . " -d source")
				call add(src_paths, src_jar_dir . "/source")
			endif
		endfor
		call writefile([join(src_paths, ":")], a:root . "/.vimsp")
	endif
endfunction

function vimcp#tools#maven_write_classpath(root)
	let mvn_cmd = "mvn dependency:build-classpath "

	for scope in keys(g:vimcp_scope_files)
		call s:exec_in_dir(a:root, mvn_cmd . "-Dmdep.outputFile=" . 
					\g:vimcp_scope_files[scope] . " -DincludeScope=" . scope . s:mvn_log)
	endfor
endfunction

"
" sbt
"
function vimcp#tools#sbt_pull_sources(root)
	call s:exec_in_dir(a:root, "sbt --error update-classifiers")
endfunction

function vimcp#tools#sbt_pull_deps(root)
	call s:exec_in_dir(a:root, "sbt --error full-classpath")
endfunction

function vimcp#tools#sbt_write_sourcepath(root)
	let cmd = "sbt --error -Dsbt.log.noformat=true 'export compile:dependency-classpath'"
		
	let cp_file = ".vimsp"

	let cmd_output = s:exec_in_dir(a:root, cmd)
	let splitted = split(cmd_output, "\n")
		
	if len(splitted) ==# 1
		" single module
		let classpath = splitted[0]
		let sourcepath = []

		for jar in split(classpath, ":")
			if !empty(matchstr(jar, '.*\(bundles\|jars\).*\/\(.*\)\.jar'))
				let src_jar_name = substitute(jar, "bundles", "srcs", "")
				let src_jar_name = substitute(src_jar_name, "jars", "srcs", "")
				let src_jar_name = substitute(src_jar_name, "\\.jar", "-sources.jar", "")

				if filereadable(src_jar_name)
					let src_jar_dir = fnamemodify(src_jar_name, ":p:h")
					call s:exec_in_dir(src_jar_dir, "unzip " . src_jar_name . " -d source")
					call add(sourcepath, src_jar_dir . "/source")
				endif
			endif
		endfor

		call writefile([join(sourcepath, ":")], a:root . "/" . cp_file)
	else
			" multi module
		let index = 0
	
		while index < len(splitted) 
			let submodule = matchstr(splitted[index], '\c\zs.\{-}\ze/\.*')
			let classpath = splitted[index+1]
			let sourcepath = []

			let submodule_dir = finddir(submodule, a:root . "/**")

			if empty(submodule_dir)
				if !empty(matchstr(a:root, '\c.*\(' . submodule .'\)'))
					let submodule_dir = a:root
				endif
			endif
			
			if !empty(submodule_dir)
				let full_dir = fnamemodify(submodule_dir, ":p")
				for jar in split(classpath, ":")
					if !empty(matchstr(jar, '.*\(bundles\|jars\).*\/\(.*\)\.jar'))
						let src_jar_name = substitute(jar, "bundles", "srcs", "")
						let src_jar_name = substitute(src_jar_name, "jars", "srcs", "")
						let src_jar_name = substitute(src_jar_name, "\\.jar", "-sources.jar", "")

						if filereadable(src_jar_name)
							let src_jar_dir = fnamemodify(src_jar_name, ":p:h")
							call s:exec_in_dir(src_jar_dir, "unzip " . src_jar_name . " -d source")
							call add(sourcepath, src_jar_dir . "/source")
						endif
					endif
				endfor

				call writefile([join(sourcepath, ":")], full_dir . cp_file)
			endif

			let index = index + 2
		endwhile
	endif
endfunction

function vimcp#tools#sbt_write_classpath(root)
	for scope in keys(g:vimcp_scope_files)
		let cmd = "sbt --error -Dsbt.log.noformat=true 'export " .scope. ":full-classpath'"
		
		let cp_file = g:vimcp_scope_files[scope]
	
		let cp_path = fnamemodify(cp_file, ":h")
		if !isdirectory(cp_path)
			call mkdir(cp_path, "p")
		endif

		let cmd_output = s:exec_in_dir(a:root, cmd)
		let splitted = split(cmd_output, "\n")
		
		if len(splitted) ==# 1
			" single module
			let classpath = splitted[0]
			call writefile([classpath], a:root . "/" . cp_file)
		else
			" multi module
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
