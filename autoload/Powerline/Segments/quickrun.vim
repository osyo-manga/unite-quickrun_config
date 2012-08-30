
function! Powerline#Segments#quickrun#config_type()
	let type = unite#sources#quickrun_config#config_type()
	return empty(type) ? "not found" : type
endfunction

let g:Powerline#Segments#quickrun#segments = Pl#Segment#Init(["quickrun",
\	Pl#Segment#Create('quickrun_compile_config', '%{Powerline#Segments#quickrun#config_type()}', Pl#Segment#Modes('!N'))
\])

