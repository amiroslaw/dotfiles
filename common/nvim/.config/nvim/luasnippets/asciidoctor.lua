local ls = require("luasnip")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")
local l = require("luasnip.extras").lambda
local postfix = require("luasnip.extras.postfix").postfix
local matches = require("luasnip.extras.postfix").matches
-- TODO 
-- extract
-- local languages = function () return { t('java'), t('lua'), t('bash'), } end
-- local languages = { t('java'), t('lua'), t('bash'), } 
-- local titleChoices = { sn(1, {t '.', i(1, 'title')}), t(''), } 

local recLs
recLs = function()
	return sn(nil, {
		c(1, { -- important!! Having the sn(...) as the first choice will cause infinite recursion.
			t({""}),
			-- The same dynamicNode as in the snippet (also note: self reference).
			sn(nil, {t({"", "* "}), i(1), d(2, recLs, {})}),
		}),
	});
end
local recLsChecked
recLsChecked = function()
	return sn(nil, {
		c(1, {
			t({""}),
			sn(nil, {t({"", "* [ ] "}), i(1), d(2, recLsChecked, {})}),
		}),
	});
end
local recLsDescription
recLsDescription = function()
	return sn(nil, {
		c(1, {
			t({""}),
			sn(nil, {i(1), t({"", " :: "}), i(2), d(3, recLsDescription, {})}),
		}),
	});
end

-- TODO move to util file
local clip = function(_, parent)
    -- return sn(nil, i(1, parent.snippet.env.CLIPBOARD))
    return sn(nil, i(1, vim.fn.getreg('+', 1, true)))
end

local visual = function(args, parent)
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_DEDENT))
    -- return sn(1, i(1, parent.snippet.env.TM_SELECTED_TEXT))
end

local codeBlock= [[
{}
[source,{}]
----
{}
----
{}]]

local collapsibleBlock= [[
{}
[%collapsible]
====
{}
====
{}]]

local collapsibleCodeBlock= [[
{}
[%collapsible]
====
[source,{}]
----
{}
----
====
{}]]

local codeBlockMd = [[
```{}
{}
```
{}]]

local quoteBlock = [[
{}
____
{}
____
{}]]

return {
	-- s('link',),
    -- s({trig = "(https?://([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))", regTrig = true}, f(function(_, snip) return snip.captures[1].. '[]' end)),
	-- postfix(".fl" , l("[" .. vim.fn.getreg('+', 1, true)[1] .. "]")),
-- formatting
	postfix(".fb" , l("**" .. l.POSTFIX_MATCH .. "**")),
	postfix(".fi" , l("__" .. l.POSTFIX_MATCH .. "__")),
	postfix(".fc" , l("``" .. l.POSTFIX_MATCH .. "``")),
	postfix(".fp" , l("^^" .. l.POSTFIX_MATCH .. "^^")),
	postfix(".ft" , l("~~" .. l.POSTFIX_MATCH .. "~~")),
	postfix(".fd" , l(l.POSTFIX_MATCH .. " :: ")),
	postfix(".ff" , c(1, {
			l("**" .. l.POSTFIX_MATCH .. "**"),
			l("__" .. l.POSTFIX_MATCH .. "__"),
			l("``" .. l.POSTFIX_MATCH .. "``"),
			l("^^" .. l.POSTFIX_MATCH .. "^^"),
			l("~~" .. l.POSTFIX_MATCH .. "~~"),
			l(l.POSTFIX_MATCH .. " :: "),
		})),
	s('ff', fmt('{}{}{} ', { 
		c(1, {t'**', t'__', t'``', t'^^', t'~~'}),
		d(2, visual) , r(1)
	})),
	-- s('bold', fmt('**{}**', { d(1, visual)})), -- bold italic and mono is in snipmate
-- endless list, when is choice node go to next element
	s("ls", {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		t({'', "* "}),
		i(2), d(3, recLs, {}),
		t "",
		i(0)
	}),
	s("ls-checked", {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		t({'', "* [ ] "}),
		i(2), d(3, recLsChecked, {}),
		t "",
		i(0)
	}),
	s("ls-description", {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''),}),
		t({'', ''} ),
		c(2, { sn(1, t('[horizontal]', '')), t'' }),
		t({'', ''} ),
		i(3), c(4, { t' :: ', t' ::: ', t' :::: '}), i(5), 
		-- i(2), d(3, recLsDescription, {}),
		t({'', ''} ), i(0)
	}),
	s("lsd", {
		i(1), c(2, { t' :: ', t' ::: ', t' :::: '}), i(3), 
		t({'', ''} ), i(0)
	}),
	-- s('bb', {t '**', f(visual_selection, 1), i(1), t '**'}),
	s('code', fmt(codeBlock, {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		c(2, { t'java', t'lua', t'bash', t'sql' }),
		d(3, clip),
		i(0)
		})
	),
	s('quote', fmt(quoteBlock, {
		c(1, { sn(1, {t '[quote, ', i(1, 'title'), t']'}), t(''), }),
		d(2, clip),
		i(0)
		})
	),
	s('code-md', fmt(codeBlockMd, {
		c(1, { t('java'), t('lua'), t('bash'), }),
		d(2, clip),
		i(0)
		})
	),

	s('code-collapse', fmt(collapsibleCodeBlock, {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		c(2, { t('java'), t('lua'), t('bash'), }),
		d(3, clip),
		i(0)
		})
	),

	s('collapse', fmt(collapsibleBlock, {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		d(2, clip),
		i(0)
		})
	),

    s({trig = "h(%d)", regTrig = true, snippetType="autosnippet", description = 'header 1-7'}, {
      f(function( _, snip)
        return string.rep("=", snip.captures[1]) .. ' '
      end)
	}), 

	s('adnotation', {
		c(1, { t 'WARNING: ', t 'IMPORTANT: ', t 'NOTE: ', t 'TIP: ', t 'CAUTION: '}),
		d(2, clip),
		i(0)
	}),
	s({trig = 'kbd',  description = 'Keyboard Shortcut'}, {
		t'kdb:[', 
		c(1, { t 'Ctrl + ', t 'Shift + ', t 'Super + ', t 'Tab + ',  t ''}),
		c(2, {i(1, 'key'), t 'Ctrl + ', t 'Shift + ', t 'Super + ', t 'Tab + '}),
		i(3), t '] '
	}),

    s({trig = "table(%d+)x(%d+)", regTrig = true}, {
		c(1, { sn(1, {t '.', i(1, 'title')}), t{''}, }),
		t{'', ''},
        d(2, function(args, snip)
            local nodes = {}
            local i_counter = 0
            table.insert(nodes, t{'[options="header"]', '|===', ''})
            for _ = 1, snip.captures[2] do
                i_counter = i_counter + 1
                table.insert(nodes, t("| "))
                table.insert(nodes, i(i_counter, "Column".. i_counter))
                table.insert(nodes, t(" "))
            end
            table.insert(nodes, t{'', '', ''})
            -- table.insert(nodes, t{hlines, ""})
            for _ = 1, snip.captures[1] do
                for _ = 1, snip.captures[2] do
                    i_counter = i_counter + 1
                    table.insert(nodes, t("| "))
                    table.insert(nodes, i(i_counter))
                    table.insert(nodes, t(" "))
                end
                table.insert(nodes, t{"", ""})
            end
            table.insert(nodes, t{'|===', ""})
            return sn(nil, nodes)
        end
    ), }), 
}
