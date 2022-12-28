let s:Unless            = { cond -> { fna -> { a -> cond(a) ? a : fna(a) }}}
let s:WriteFile         = { flags -> { path -> { ary -> [ writefile(ary,path,flags), path ][1] } } }
let s:ClearFileContents = { path -> s:WriteFile('')( path )([]) }
let s:_MakeDir          = { flags -> { dirname -> [ mkdir(dirname,flags), dirname ][1] } }
let s:IsDirectory       = { path -> isdirectory(path) }
let s:MakeDir           = s:Unless( s:IsDirectory )( s:_MakeDir('p') )
let s:GetPathHead       = { path -> '/' . join(split(path, '/')[0:-2], '/') }
let s:GetPathTail       = { path -> split(path, '/')[-1] }
let s:WriteFileAndPath  = { flags -> { path -> { ary -> s:WriteFile(flags)( s:MakeDir( s:GetPathHead(path) ).'/'.s:GetPathTail(path) )(ary)  }} }

fu! s:_PrependToFile( path, ary )
  return s:WriteFileAndPath( '' )( a:path )( a:ary + (filereadable(a:path) ? readfile(a:path) : []) )
endfu

let s:PrependToFile = { path -> { ary -> s:_PrependToFile( path, ary ) } }

fu! s:CommentCharacter()
  return split(&commentstring, '%s')[0] . ' '
endfu

fu! s:DateHeader()
  let r = split(system('date'), "\n")[0]
  return [s:CommentCharacter().r, s:CommentCharacter().substitute(r, '.', '-', 'g' ) ]
endfu

fu! s:FileExtension()
  return expand('%')->split('\.')[-1]
endfu

fu! s:ScratchArchive()
  call s:PrependToFile( $PWD."/scratch-archive.".s:FileExtension() )( s:DateHeader() + [getline('.'), ''] )
  exe 'normal! dd'
  silent write
  echo 'Archived'
endfu

fu! s:ScratchArchiveVisual()
  call s:PrependToFile( $PWD."/scratch-archive.".s:FileExtension() )( s:DateHeader() + getline("'<", "'>") + [''] )
  '<,'>d
  silent write
  echo 'Archived'
endfu

nno <Plug>ScratchArchive :call <SID>ScratchArchive()<CR>
vno <Plug>ScratchArchiveVisual :<C-u>call <SID>ScratchArchiveVisual()<CR>

nm gr <Plug>ScratchArchive<CR>
vm gr <Plug>ScratchArchiveVisual<CR>

