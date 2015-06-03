" maven.vim
" Maintainer: rob boll @robertcboll

" 
" maven 
"
let s:mvn_log = ">>~/.vim/vimcp.log"
let s:mvn_tmpfile = ".vimcp_tmp"

function vimcp#tools#maven#pull_sources(root)
	call vimcp#tools#exec_in_dir(a:root, "mvn dependency:sources" . s:mvn_log)
endfunction

function vimcp#tools#maven#pull_deps(root)
	call vimcp#tools#exec_in_dir(a:root, "mvn dependency:build-classpath" . s:mvn_log)
endfunction

function vimcp#tools#maven#write_sourcepath(root)
	call vimcp#tools#exec_in_dir(a:root, 
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
				call vimcp#tools#exec_in_dir(src_jar_dir, "unzip " . src_jar_name . " -d source")
				call add(src_paths, src_jar_dir . "/source")
			endif
		endfor
		call writefile([join(src_paths, ":")], a:root . "/.vimsp")
	endif
endfunction

function vimcp#tools#maven#write_classpath(root)
	let mvn_cmd = "mvn dependency:build-classpath "

	for scope in keys(g:vimcp_scope_files)
		call vimcp#tools#exec_in_dir(a:root, mvn_cmd . "-Dmdep.outputFile=" . 
					\g:vimcp_scope_files[scope] . " -DincludeScope=" . scope . s:mvn_log)
	endfor
endfunction
