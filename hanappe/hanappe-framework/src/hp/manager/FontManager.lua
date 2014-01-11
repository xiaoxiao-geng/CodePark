--------------------------------------------------------------------------------
-- This is a class to manage the Font.
--------------------------------------------------------------------------------

-- import
local ResourceManager           = require "hp/manager/ResourceManager"

-- class
local M                         = {}

-- variables
M.cache                         = {}
M.fontPaths                     = {
    ["VL-PGothic"] = "fonts/VL-PGothic.ttf",
    ["arial-rounded"] = "fonts/arial-rounded.ttf",
}

local function generateUid(fontPath, points, charcodes, dpi, trimSpace)
    if trimSpace ~= nil then
        trimSpace = tostring(trimSpace)
    end
    return (fontPath or "") .. "$" .. (points or "") .. "$" .. (charcodes or "") .. "$" .. (dpi or "")  .. (trimSpace or "")
end

--------------------------------------------------------------------------------
-- Requests the texture.
-- The textures are cached internally.
-- @param fontName fontName or fontPath.
-- @param points Points of the Font.
-- @param charcodes Charcodes of the Font.
-- @param dpi dpi of the Font.
-- @return MOAIFont instance.
-- @param trimSpace trim bitmapfont
--------------------------------------------------------------------------------
function M:request(fontName, points, charcodes, dpi, trimSpace)
    local path = ResourceManager:getFilePath(M.fontPaths[fontName] or fontName)
    local uid = generateUid(path, points, charcodes, dpi, trimSpace)
    
    if self.cache[uid] then
        return M.cache[uid]
    end

    local font = self:newFont(path, points, charcodes, dpi, trimSpace)
    self.cache[font.uid] = font

    return font
end

--------------------------------------------------------------------------------
-- Return you have generated the font.
-- @param fontName fontName or fontPath.
-- @param points Points of the Font.
-- @param charcodes Charcodes of the Font.
-- @param dpi dpi of the Font.
-- @return MOAIFont instance.
--------------------------------------------------------------------------------
function M:newFont(fontName, points, charcodes, dpi, trimSpace)
    local path = ResourceManager:getFilePath(M.fontPaths[fontName] or fontName)

    local font = MOAIFont.new()

    --cdsc add for ".fnt" font
    if string.sub(path, -4) == '.fnt' then
        font:loadFromBMFont(path)
    elseif string.sub(path, -4) == '.png' then
        local bitmapFontReader = MOAIBitmapFontReader.new ()
        bitmapFontReader:loadPage ( path, charcodes, points, nil, trimSpace)
        font:setReader ( bitmapFontReader )
        local glyphCache = MOAIGlyphCache.new ()
        glyphCache:setColorFormat ( MOAIImage.COLOR_FMT_RGBA_8888 )
        font:setCache ( glyphCache )
    else
        font:load(path)
    end
    
    font.path = path
    font.points = points
    font.charcodes = charcodes
    font.dpi = dpi
    font.uid = generateUid(path, points, charcodes, dpi)
    
    if points and charcodes then
        font:preloadGlyphs(charcodes, points, dpi)
    end
    
    return font
end

return M
