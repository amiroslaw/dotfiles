vim.g.TodoTxtForceDoneName='done.txt'
vim.g.TodoTxtUseAbbrevInsertMode=1
vim.cmd [[setlocal completeopt-=preview]]
-- vim.bo.completeopt= vim.bo.completeopt - 'preview'
-- " Auto complete projects
vim.bo.omnifunc='todo#Complete'
vim.cmd [[imap <buffer> + +<C-X><C-O>]]
-- " Auto complete contexts
vim.cmd [[imap <buffer> @ @<C-X><C-O>]]

nmap('<localleader>t', 'A @t<esc>') --today
nmap('<localleader>r', '<cmd> .s/ @t//g <cr>') --remove today
nmap('<localleader>n', '<cmd> .s/+x//g <cr>') --remove new
nmap('<LocalLeader>o', '<LocalLeader>scp', {noremap= false}) --order context > project >priority
nmap('<LocalLeader>i', '<LocalLeader>sp', {noremap= false}) --order project > priority
nmap('<LocalLeader>u', '<LocalLeader>sd', {noremap= false}) --order date
