" lein.vim
" Maintainer: rob boll @robertcboll

" 
" lein
"
let s:lein_log = ">>~/.vim/vimcp.log"
let s:mvn_tmpfile = ".vimcp_tmp"

function vimcp#tools#lein#pull_sources(root)
	call vimcp#tools#exec_in_dir(a:root, "lein pom" . s:lein_log)
	call vimcp#tools#exec_in_dir(a:root, "mvn dependency:sources" . s:lein_log)
endfunction

function vimcp#tools#lein#pull_deps(root)
	call vimcp#tools#exec_in_dir(a:root, "lein deps" . s:lein_log)
endfunction

function vimcp#tools#lein#write_sourcepath(root)
	call vimcp#tools#exec_in_dir(a:root, "lein pom" . s:lein_log)
	call vimcp#tools#exec_in_dir(a:root, 
				\"mvn dependency:build-classpath -Dscope=compile -Dclassifier=sources -Dmdep.outputFile=" 
				\. a:root . "/" . s:mvn_tmpfile . s:lein_log)

	if filereadable(a:root . "/" . s:mvn_tmpfile)
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
	else
		echom "couldn't generate sourcepath for lein"
	endif
endfunction

function vimcp#tools#lein#write_classpath(root)
	call vimcp#tools#exec_in_dir(a:root, "lein classpath .vimcp" . s:lein_log)
endfunction
