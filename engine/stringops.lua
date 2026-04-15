StringOps = {}

---Split string into table by specified delimiter.
---@param input string Input string to process.
---@param sep? string String delimiter. Defaults to "%s"
---@return table words Table of split strings.
function StringOps.split(input, sep)
    sep = sep or "%s"

    local words = {}

    for str in string.gmatch(input, "([^"..sep.."]+)") do
        table.insert(words, str)
    end

    return words
end

return StringOps