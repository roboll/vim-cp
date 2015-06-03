" sbt.vim
" Maintainer: rob boll @robertcboll

"
" sbt
"
function vimcp#tools#sbt#pull_sources(root)
	call vimcp#tools#exec_in_dir(a:root, "sbt --error update-classifiers")
endfunction

function vimcp#tools#sbt#pull_deps(root)
	call vimcp#tools#exec_in_dir(a:root, "sbt --error full-classpath")
endfunction

function vimcp#tools#sbt#write_sourcepath(root)
	let cmd = "sbt --error -Dsbt.log.noformat=true 'export compile:dependency-classpath'"
		
	let cp_file = ".vimsp"

	let cmd_output = vimcp#tools#exec_in_dir(a:root, cmd)
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
					call vimcp#tools#exec_in_dir(src_jar_dir, "unzip " . src_jar_name . " -d source")
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
							call vimcp#tools#exec_in_dir(src_jar_dir, "unzip " . src_jar_name . " -d source")
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

function vimcp#tools#sbt#write_classpath(root)
	for scope in keys(g:vimcp_scope_files)
		let cmd = "sbt --error -Dsbt.log.noformat=true 'export " .scope. ":full-classpath'"
		
		let cp_file = g:vimcp_scope_files[scope]
	
		let cp_path = fnamemodify(cp_file, ":h")
		if !isdirectory(cp_path)
			call mkdir(cp_path, "p")
		endif

		let cmd_output = vimcp#tools#exec_in_dir(a:root, cmd)
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
