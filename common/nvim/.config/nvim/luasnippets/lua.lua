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

return {
	-- s("for", {
	-- t"for ", c(1, {
	-- sn(nil, {i(1, "k"), t", ", i(2, "v"), t" in ", c(3, {t"pairs", t"ipairs"}), t"(", i(4), t")"}),
	-- sn(nil, {i(1, "i"), t" = ", i(2), t", ", i(3), })
	-- }), t{" do", "\t"}, i(0), t{"", "end"}
	-- })
	postfix({ trig = ".sout", matches.line }, l("print(" .. l.POSTFIX_MATCH .. ")")),
}
