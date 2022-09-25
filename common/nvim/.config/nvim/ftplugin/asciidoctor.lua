nmap('<localleader>n', 'A +next<esc>')
nmap('<localleader>r', '<cmd> .s/ +next//g <cr>') --remove next
nmap('<localleader><', '<cmd> s/^.//g <cr> <cmd>nohlsearch<cr>') -- decrease list
vmap('<localleader><', '<cmd> s/^.//g <cr> <cmd>nohlsearch<cr>') 
nmap('<localleader>>', [[<cmd> s/\(^.\)/\1\1/g <cr> <cmd>nohlsearch<cr>]]) -- increase list
vmap('<localleader>>', [[<cmd> s/\(^.\)/\1\1/g <cr> <cmd>nohlsearch<cr>]]) -- increase list

-- move to lua
local function change(str)
	return str:gsub('%[%s]', '[x]')		
end
nmap('<localleader>n', '<cmd> lua vim.fn.setline(vim.fn.line("."), change(vim.fn.getline(vim.fn.line("."))))<cr>')
-- nmap('<localleader>n', [[<cmd> lua vim.fn.setline(vim.fn.line("."), vim.fn.substitute( vim.fn.getline(vim.fn.line(".")), "\[ \]", "[x]" , "g")) <cr>]])
-- vim.fn.setline(l, vim.fn.substitute(vim.fn.getline(l), 'last change: \\zs.*', time , 'gc'))
