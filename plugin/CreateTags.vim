""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"FileName : createTags.vim                                       "
"Author   : seiya guan                                           "
"Desc     : Create ctags and lookupfile_tag in current path      "
"Version  : 0.9  First Version                                   "
"           0.91 Added param for CreateTags function,If not will "
"                use current path for default                    "
"           0.92 fix bug when give the path to create tags       "
"           0.93 fix g:LookupFile_TagExpr set error              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !has('python')
    echo "Error:Required vim compiled with +python"
    finish
endif

function! CreateTags(...)
    " s:curPath: tags save path and for generate
    let s:curPath = getcwd() 
    if(a:0 > 0)
        let s:curPath = a:1 
    endif

"==========================================================================
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
os.system("ctags -f " + os.path.join(tagsPath,".tags") + " -R " + os.path.join(projPath,"") + "* --fields=+liaS")

vim.command("let g:LookupFile_TagExpr = string(\"" + os.path.join(tagsPath, ".lookupfile_tags").replace("\\","\\\\") + "\")");
vim.command("let &tags=\"./tags,tags," + os.path.join(tagsPath, ".tags").replace("\\","\\\\") + "\"");
EOF
"end of python
"==========================================================================

if exists(":NeoCompleteTagMakeCache")
    :NeoCompleteTagMakeCache
endif
echo "Wow! Creat tags file Success!"

endfunction

command! -nargs=? -complete=file CreateTags call CreateTags(<f-args>)
