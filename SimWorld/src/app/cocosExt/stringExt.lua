function string.u8foreach(str, callback)
    if not str or not callback then return end

    local i = 1
    local multiLen = #str

    local string_sub = string.sub
    local string_byte = string.byte

    local b, skip, i2
    while i <= multiLen do
        b = string_byte( str, i, i )
        skip = 0

        if b >= 0xf0 and b <= 0xf7 then     skip = 3
        elseif b >= 0xe0 then               skip = 2
        elseif b >= 0xc0 then               skip = 1
        end

        i2 = i + skip
        if callback( string_sub( str, i, i2 ), i, i2 ) then
            break
        end
        i = i2 + 1
    end
end

function string.u8len(str)
    local len = 0
    string.u8foreach(str, function() len = len + 1 end)
    return len
end

function string.u8sub(str, idx1, idx2)
    if not str or not idx1 then
        return nil
    end
    idx2 = idx2 or 0xffffffff
    if idx1 > idx2 then
        return nil
    end
    local loc = 1
    local st, ed = 1,1
    local function _each(ch, starti, endi )
        if loc == idx1 then
            st = starti
        end
        if loc <= idx2 then
            ed = endi
        else
          return true
        end
        loc = loc + 1
    end
    string.u8foreach(str, _each)
    return string.sub(str, st, ed)
end