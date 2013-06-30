-- Glyph 所有图元的基类

Glyph = class()

function Glyph:draw( window ) end

function Glyph:intersects( point ) end

function Glyph:insert( glyph, i ) end