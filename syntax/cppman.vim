syntax case ignore
syntax match  manReference       "[a-z_:+-\*][a-z_:+-~!\*<>()]\+ ([1-9][a-z]\=)"
syntax match  manTitle           "^\w.\+([0-9]\+[a-z]\=).*"
syntax match  manSectionHeading  "^[a-z][a-z_ \-:]*[a-z]$"
syntax match  manSubHeading      "^\s\{3\}[a-z][a-z ]*[a-z]$"
syntax match  manOptionDesc      "^\s*[+-][a-z0-9]\S*"
syntax match  manLongOptionDesc  "^\s*--[a-z0-9-]\S*"

syntax include @cppCode runtime! syntax/cpp.vim
syntax match manCFuncDefinition  display "\<\h\w*\>\s*("me=e-1 contained

syntax region manSynopsis start="^SYNOPSIS"hs=s+8 end="^\u\+\s*$"me=e-12 keepend contains=manSectionHeading,@cppCode,manCFuncDefinition
syntax region manSynopsis start="^EXAMPLE"hs=s+7 end="^       [^ ]"he=s-1 keepend contains=manSectionHeading,@cppCode,manCFuncDefinition

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
echo version
if version >= 508 || !exists("did_man_syn_inits")
  if version < 508
    let did_man_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink manTitle	    Title
  HiLink manSectionHeading  Statement
  HiLink manOptionDesc	    Constant
  HiLink manLongOptionDesc  Constant
  HiLink manReference	    PreProc
  HiLink manSubHeading      Function
  HiLink manCFuncDefinition Function

  delcommand HiLink
endif
