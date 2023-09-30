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
local types = require("luasnip.util.types")
local conds = require("luasnip.extras.expand_conditions")

local clip = function(_, parent)
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

-- TODO 
-- convert asciidoc to md
-- table is ok

local rec_ls
rec_ls = function()
	return sn(nil, {
		c(1, { -- important!! Having the sn(...) as the first choice will cause infinite recursion.
			t({""}),
			-- The same dynamicNode as in the snippet (also note: self reference).
			sn(nil, {t({"", "* [ ] "}), i(1), d(2, rec_ls, {})}),
		}),
	});
end

return {
	-- s('link',),
    -- s({trig = "(https?://([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w%w%w?%w?)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))", regTrig = true}, f(function(_, snip) return snip.captures[1].. '[]' end)),
-- formatting 
	s('ff', fmt('{}{}{}', { 
		c(1, {t'**', t'__', t'``', t'^^', t'~~'}),
		d(2, visual) , r(1)
	})),
	s('bold', fmt('**{}**', { d(1, visual)})),
	s('italic', fmt('**{}**', { d(1, visual)})),
	s(
		{ trig = "a%d", regTrig = true },
		f(function(_, snip)
			return "Triggered with " .. snip.trigger .. "."
		end, {})
	),
-- endless list, when is choice node go to next element
	s("ls", {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		t({'', "* [ ] "}),
		i(2), d(3, rec_ls, {}),
		t "",
		i(0)
	}),
	-- s('bb', {t '**', f(visual_selection, 1), i(1), t '**'}),
	s('code', fmt(codeBlock, {
		c(1, { sn(1, {t '.', i(1, 'title')}), t(''), }),
		c(2, { t('java'), t('lua'), t('bash'), }),
		d(3, clip),
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

    s({trig = "table(%d+)x(%d+)", regTrig = true}, {
        d(1, function(args, snip)
            local nodes = {}
            local i_counter = 0
            local hlines = ""
            for _ = 1, snip.captures[2] do
                i_counter = i_counter + 1
                table.insert(nodes, t("| "))
                table.insert(nodes, i(i_counter, "Column".. i_counter))
                table.insert(nodes, t(" "))
                hlines = hlines .. "|---"
            end
            table.insert(nodes, t{"|", ""})
            hlines = hlines .. "|"
            table.insert(nodes, t{hlines, ""})
            for _ = 1, snip.captures[1] do
                for _ = 1, snip.captures[2] do
                    i_counter = i_counter + 1
                    table.insert(nodes, t("| "))
                    table.insert(nodes, i(i_counter))
                    print(i_counter)
                    table.insert(nodes, t(" "))
                end
                table.insert(nodes, t{"|", ""})
            end
            return sn(nil, nodes)
        end
    ), }), 
}
