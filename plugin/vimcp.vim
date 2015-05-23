" vimcp.vim
" Maintainer: rob boll @robertcboll

if !exists("g:vimcp_loaded")
	
	" map of {scope_name : scope_path}
	let g:vimcp_scope_files = {	
				\"compile" : ".vimcp", 
				\"test" : "src/test/.vimcp"}

	let g:vimcp_sbt_marker_files = ["build.sbt"]

	command! -bang -narg=0 CPInit call vimcp#paths#download_all() | 
				\ call vimcp#paths#write_and_set_paths()

	command! -bang -narg=0 CPDownloadAll call vimcp#paths#download_all()
	command! -bang -narg=0 CPDownloadDeps call vimcp#paths#download_deps()
	command! -bang -narg=0 CPDownloadSources call vimcp#paths#download_sources()

	command! -bang -narg=0 CPBuildPaths call vimcp#paths#write_and_set_paths()
	command! -bang -narg=0 CPBuildSourcePath call vimcp#paths#write_source_path()
	command! -bang -narg=0 CPBuildClassPath call vimcp#paths#write_class_path()
	
	command! -bang -narg=0 CPDeletePaths call vimcp#paths#delete_paths()

	command! -bang -narg=0 CPReload call vimcp#paths#set_paths_for_buffer(1)

	let g:vimcp_loaded = 1
endif

call vimcp#paths#set_paths_for_buffer(0)
