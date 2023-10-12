local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local l = require("luasnip.extras").lambda
local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local matches = require("luasnip.extras.postfix").matches

local function box(opts)
    local function box_width()
        return opts.box_width or vim.opt.textwidth:get()
    end

    local function padding(cs, input_text)
        local spaces = box_width() - (2 * #cs)
        spaces = spaces - #input_text
        return spaces / 2
    end

    local comment_string = function()
        return require("luasnip.util.util").buffer_comment_chars()[1]
    end

    return {
        f(function()
            local cs = comment_string()
            return string.rep(string.sub(cs, 1, 1), box_width())
        end, { 1 }),
        t({ "", "" }),
        f(function(args)
            local cs = comment_string()
            return cs .. string.rep(" ", math.floor(padding(cs, args[1][1])))
        end, { 1 }),
        i(1, "placeholder"),
        f(function(args)
            local cs = comment_string()
            return string.rep(" ", math.ceil(padding(cs, args[1][1]))) .. cs
        end, { 1 }),
        t({ "", "" }),
        f(function()
            local cs = comment_string()
            return string.rep(string.sub(cs, 1, 1), box_width())
        end, { 1 }),
    }
end

local visual = function(args, parent)
	return sn(nil, i(1, parent.snippet.env.LS_SELECT_DEDENT))
end
local snippets = {
    s({ trig = "comment" }, box({ box_width = 50 })),
    s({ trig = "comment-line" }, box({})),
-- idk if .( trigger won't be better
		postfix(".br" , l("(" .. l.POSTFIX_MATCH .. ")")),
		postfix(".bs" , l("[" .. l.POSTFIX_MATCH .. "]")),
		postfix(".bc" , l("{" .. l.POSTFIX_MATCH .. "}")),
		postfix(".ba" , l("<" .. l.POSTFIX_MATCH .. ">")),
		postfix(".bb" , c(1, {
				l("(" .. l.POSTFIX_MATCH .. ")"),
				l("{" .. l.POSTFIX_MATCH .. "}"),
				l("[" .. l.POSTFIX_MATCH .. "]"),
				l("<" .. l.POSTFIX_MATCH .. ">"),
			})),
		postfix(".qd" , l('"' .. l.POSTFIX_MATCH .. '"')),
		postfix(".qs" , l("'" .. l.POSTFIX_MATCH .. "'")),
		postfix(".qg" , l("`" .. l.POSTFIX_MATCH .. "`")),
		postfix(".qq" , c(1, {
				l('"' .. l.POSTFIX_MATCH .. '"'),
				l("'" .. l.POSTFIX_MATCH .. "'"),
				l("`" .. l.POSTFIX_MATCH .. "`"),
			})),
		s('qq', fmt('{}{}{} ', { 
			c(1, {t'"', t"'", t'`'}),
			d(2, visual) , r(1)
		})),
}

-- TODO 
-- doesn't show in cmp when have autosnippet
-- https://hub.espanso.org/contractions-en
-- https://www.google.com/search?q=enlish abberivation[english abbreviation - Google Search]
local abbreviations = {
agm = "Good morning.",
agw = 'Have a good week.',
agwe = 'Have a nice weekend.',
aty = 'Thank you.',
ayw = "You're welcome.",
atf = 'Thanks for the feedback.',
awl = "I'd like to", 
aih = "I have to",
ayh = "You have to", 
aidk = "I don't know,", 
awdm = "What do you mean?",
ait = "I think,",
aidt = "I don't think,",
}

for i,v in pairs(abbreviations) do
	table.insert(snippets, s( { trig = i, snippetType = 'autosnippet' }, t(v .. ' ')))
end

return snippets
