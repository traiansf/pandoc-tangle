require "css-selector"

local blocks={}

local function split_classes(str)
    local classes = {}
    for class in string.gmatch(str, "[^ ]+") do
        classes[class] = true
    end
    return classes
end

local function keep_only_lines(str)
    local count = 0
    for _ in string.gmatch(str,'\n') do
        count = count + 1
    end
    return string.rep('\n',count)
end

function Doc(body, metadata, variables)
    local targets = parse(metadata.code or '*')
    local block = 1
    local function replace()
        local classes = {}
        for k,_ in pairs(blocks[block][1]) do
            table.insert(classes,k)
        end
        local code = blocks[block][2]
        block = block + 1
        if eval(targets, classes) then
            return code
        else
            return keep_only_lines(code)
        end
    end
    return string.gsub(body,'#',replace)
end

function Header(lvl,text)
    text = keep_only_lines(text)
    if lvl == 1 then
        return text..'\n\n'
    elseif lvl == 2 then
        return text..'\n\n'
    elseif lvl == 3 then
        return text..'\n'
    else
        return text..'\n'
    end
end

function CodeBlock(s, attr)
    table.insert(blocks,{split_classes(attr.class or ''),s})
    return '\n#\n\n'
end

function Space()
    return ''
end
function SoftBreak()
    return '\n'
end
function LineBreak()
    return '\n'
end
function Str(s)
    return keep_only_lines(s)
end
function Table(s)
    return keep_only_lines(s)
end
function DisplayMath(s)
    return keep_only_lines(s)
end

local function InlineMarkup(s)
    return keep_only_lines(s)
end
Emph = InlineMarkup
Strong = InlineMarkup
Subscript = InlineMarkup
Superscript = InlineMarkup
SmallCaps = InlineMarkup
Strikeout = InlineMarkup
Code = InlineMarkup
InlineMath = InlineMarkup
DiplayMath = InlineMarkup

function Plain(s)
    return s..' '
end

function Image()
    return ''
end
function Note()
    return ''
end

Span = InlineMarkup
DoubleQuoted = InlineMarkup

function Link(text,target,title,attr)
    return keep_only_lines(text)..keep_only_lines(target)
end

function Para(s)
    return s..'\n'
end

function Blocksep()
    return '\n'
end

function BulletList(items)
    if #items == 0 then
        return ''
    else
        if items[#items]:byte(-1) ~= 10 then
            items[#items] = items[#items]..'\n'
        end
        return keep_only_lines(table.concat(items,'\n'))
    end
end

function OrderedList(items)
    return BulletList(items)
end

local function IgnoreBlock(key)
    return function(s,a,b,c)
        return (type(s) == 'string' and keep_only_lines(s)) or ''
    end
end

-- The following code ignores any other items
local meta = {}
meta.__index =
    function(_, key)
        io.stderr:write(string.format("WARNING: Undefined tangle function '%s'\n",key))
        _G[key] = IgnoreBlock(key)
        return _G[key]
    end
setmetatable(_G, meta)
