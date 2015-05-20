" vimcp.vim
" Maintainer: rob boll <http://robertcboll.com>

if !exists("g:vimcp_loaded")
	
	" map of {scope_name : scope_path}
	let g:vimcp_scopes = {"compile" : "", "test" : "src/test/"}

	command! -bang -narg=0 UpdateClasspath call classpaths#update_classpath()
	command! -bang -narg=0 DeleteClasspath call classpaths#delete_classpath()

	command! -bang -narg=0 RefreshClasspath call classpaths#set_vimcp_for_buffer()

	let g:vimcp_loaded = 1
endif

call classpaths#set_vimcp_for_buffer()
