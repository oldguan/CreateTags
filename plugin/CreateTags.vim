""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"FileName : createTags.vim                                       "
"Author   : seiya guan                                           "
"Desc     : Create ctags and lookupfile_tag in current path      "
"Version  : 0.9                                                  "
"           0.91 Added param for CreateTags function,If not will "
"                use current path for default                    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !has('python')
    echo "Error:Required vim compiled with +python"
    finish
endif

function! CreateTags(...)
    " curPath: must create tags path and tags file path
    let s:curPath = getcwd() 
    if(a:0 > 0)
        let s:curPath = a:1 
    endif

"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
python << EOF
import sys
import os
import vim

projPath = vim.eval("s:curPath")
tagsPath = projPath

# create LookupFile tag file
strWriteFile = "!_TAG_FILE_SORTED\t2\t/2=foldcase/\n"
for root, dirs, files in os.walk(projPath, False):
    if ".svn" in root or ".git" in root:
        continue
    for f in files:
        strWriteFile += f + "\t" + os.path.join(root,f) + "\t1\n"
    for d in dirs:
        strWriteFile += d + "\t" + os.path.join(root,d) + "\t1\n"
fw = open(os.path.join(tagsPath,".lookupfile_tags"), "w")
fw.writelines(strWriteFile)
fw.close()

# create ctags file
os.system("ctags -f " + os.path.join(tagsPath,".tags") + " -R " + os.path.join(projPath,"") + "* --fields=+lS")

EOF
"end of python
"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

if filereadable(s:curPath . '/.lookupfile_tags')
    let g:LookupFile_TagExpr = string (s:curPath .'/.lookupfile_tags')
endif

"set tags file path
let &tags="./tags,tags," . s:curPath . "/.tags"

unlet s:curPath
echo "Wow! Creat tags file Success!"

endfunction

command! -nargs=? -complete=file CreateTags call CreateTags(<f-args>)
