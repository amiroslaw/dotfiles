function AdocPasteFileLink()
	local absolutePath = vim.fn.getreg '+'
	local notePath = os.getenv 'NOTE'
	local _, endStr = absolutePath:find(notePath)
	if endStr then
		local relativePath = absolutePath:sub(endStr + 1, #absolutePath)
		local fileName = ''
		for token in relativePath:gmatch '[^/]+' do
			fileName = token
		end
		local adocLink = 'link:.' .. relativePath .. '[' .. fileName .. ']'
		vim.fn.append(vim.fn.line '.', adocLink)
	end
end

nmap('<localleader>l', ':lua AdocPasteFileLink()<esc>')
vmap('<localleader>t', '<cmd>Tab /|<CR>') -- format table by `|`
nmap('<F7>', ':!preview-ascii.sh % <CR>')

-- todolist
nmap('<localleader><', '<cmd> s/^.//g <cr> <cmd>nohlsearch<cr>') -- decrease list
vmap('<localleader><', '<cmd> s/^.//g <cr> <cmd>nohlsearch<cr>')
nmap('<localleader>>', [[<cmd> s/\(^.\)/\1\1/g <cr> <cmd>nohlsearch<cr>]]) -- increase list
vmap('<localleader>>', [[<cmd> s/\(^.\)/\1\1/g <cr> <cmd>nohlsearch<cr>]])
nmap('<localleader>n', 'A +next<esc>')
nmap('<localleader>r', '<cmd> .s/ +next//g <cr>') --remove next
nmap('<localleader>w', 'A wa:some<esc>')
nmap('<localleader>W', '<cmd> .s/ wa:some//g <cr>')
-- append, prepend
nmap('<localleader>al', 'I* <ESC>$')
nmap('<localleader>az', 'I* [ ] <ESC>$')
nmap('<localleader>at', 'I.<ESC>$')
nmap('<localleader>ao', 'I* <ESC>$')
nmap('<localleader>ad', 'A :: <ESC>')
