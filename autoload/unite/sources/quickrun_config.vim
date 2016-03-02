scriptencoding utf-8


let g:unite_quickrun_config_selected_prefix =
\	get(g:, "unite_quickrun_config_selected_prefix", "> ")


function! unite#sources#quickrun_config#quickrun_config_all()
	return copy(extend(copy(get(g:, "quickrun#default_config", {})), get(g:, "quickrun_config", {})))
endfunction

function! s:quickrun_config_type_filetype(filetype)
	return get(get(unite#sources#quickrun_config#quickrun_config_all(), a:filetype, {}), "type", a:filetype)
endfunction

function! s:quickrun_config_type_bufnr(bufnr)
	let filetype = getbufvar(a:bufnr, "&filetype")
	let quickrun_config = getbufvar(a:bufnr, "quickrun_config")
	return empty(quickrun_config)
\		? s:quickrun_config_type_filetype(filetype)
\		: get(quickrun_config, "type", s:quickrun_config_type_filetype(filetype))
endfunction


function! unite#sources#quickrun_config#config_type(...)
	let bufnr = a:0 && type(a:1) == type(0) ? a:1 : bufnr("%")
	return a:0 && type(a:1) == type("")
\		? s:quickrun_config_type_filetype(a:1)
\		: s:quickrun_config_type_bufnr(bufnr)
endfunction


function! s:main_gather_candidates(args, context)
	let bufnr = get(get(b:, "unite", {}), "prev_bufnr", bufnr("%"))
	let filetype   = getbufvar(bufnr, "&filetype")
	let cmds = filter(unite#sources#quickrun_config#quickrun_config_all(), "v:key =~# ('^'.filetype).'/'")

	let prefix = g:unite_quickrun_config_selected_prefix
	let prefix_space = repeat(" ", strdisplaywidth(prefix))
	let now_type = unite#sources#quickrun_config#config_type()
	return sort(values(map(cmds, '{
\		"abbr"           : v:key == now_type ? (prefix . v:key) : (prefix_space . v:key),
\		"word"           : v:key,
\		"kind" : "command",
\		"action__config" : v:key,
\		"action__filetype" : filetype,
\		"action__command" : ":QuickRun " . v:key,
\	}')))
endfunction


function! unite#sources#quickrun_config#define()
	return s:source
endfunction


let s:source = {
\	"name" : "quickrun_config",
\	'description' : 'quickrun select filetype config',
\	"default_action" : "set_local_quickrun_config",
\	"action_table" : {
\		"set_global_quickrun_config" : {
\			"description" : "let g:quickrun_config.{filetype}.type =",
\			"is_selectable" : 0,
\		},
\		"set_local_quickrun_config" : {
\			"description" : "let b:quickrun_config.type =",
\			"is_selectable" : 0,
\		},
\	},
\}

function! s:source.action_table.set_global_quickrun_config.func(candidates)
	let filetype = a:candidates.action__filetype

	if !exists("g:quickrun_config")
		let g:quickrun_config = {}
	endif
	if !exists("g:quickrun_config.".&filetype)
		let g:quickrun_config[filetype] = {}
	endif

	let g:quickrun_config[filetype].type = a:candidates.action__config
endfunction

function! s:source.action_table.set_local_quickrun_config.func(candidates)
	let bufnr = get(get(b:, "unite", {}), "prev_bufnr", bufnr("%"))
	if empty(getbufvar(bufnr, "quickrun_config"))
		call setbufvar(bufnr, "quickrun_config", {})
	endif
	let config = getbufvar(bufnr, "quickrun_config")
	let config.type = a:candidates.action__config
endfunction


function! s:source.gather_candidates(args, context)
	return s:main_gather_candidates(a:args, a:context)
endfunction


