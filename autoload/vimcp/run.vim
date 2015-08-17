" run.vim
" Maintainer: rob boll @robertcboll

function g:vimcp#run#java_cmd()
    return (exists('$JAVA_CMD') ? $JAVA_CMD : 'java') . ' -cp '.b:vimcp.':'.expand('%:p:h')
endfunction

function g:vimcp#run#javac_cmd()
    return (exists('$JAVAC_CMD') ? $JAVAC_CMD : 'javac') . ' -cp '.b:vimcp
endfunction

function g:vimcp#run#java_run()
    execute g:vimcp#run#javac_cmd().' '.expand('%:p')
    execute g:vimcp#run#java_cmd().' '.expand('%:t:r')
endfunction
