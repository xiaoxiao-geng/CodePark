module(..., package.seeall)

local downSprite = nil
local downOffsetX, downOffsetY = 0, 0
local sprites = {}

function onCreate(params)
    layer = Layer {scene = scene, touchEnabled = true }

    layer3d = Layer { scene = scene }

	local camera = MOAICamera.new ()
	camera:setLoc ( 0, 0, camera:getFocalLength ( 1000 ))
	layer3d:setCamera ( camera )

	print("camera:getFocalLength ( 1000 )", camera:getFocalLength ( 1000 ))

    for i = 1, 6 do
    	local x, y = ( i - 1 ) % 3, math.floor( ( i - 1 ) / 3 )


    	local la = layer
    	-- if y > 0 then la = layer3d end

    	local sprite = Sprite { 
    		texture = "bird" .. i .. ".png", 
    		layer = la, 
    		}

    	local w, h = sprite:getSize()

    	sprite:setPos( ( x + 1 ) * w, ( y + 1 ) * h )
    	sprite:setScl( 2, 2 )

		sprite:addEventListener( "touchDown",     fOnTouchDown )
		sprite:addEventListener( "touchUp",       fOnTouchUp )
		sprite:addEventListener( "touchMove",     fOnTouchMove )
		sprite:addEventListener( "touchCancel",   fOnTouchCancel )

		sprite.id = i

		table.insert( sprites, sprite )
    end

    buttonFlip1 = Button { 
    	layer = layer, 
    	name = "buttonFlip1",
        text = "to 180",
        pos = { 400, 300 },
        onClick = function( e ) 
        	for k, v in pairs( sprites ) do
        		v:seekRot( 0, 180, 0, 1 )
        		v.id = ( v.id + 1 - 1 ) % 6 + 1
        		v:setTexture( string.format( "bird%d.png", v.id ) )

        		-- v:setWidth( 50 + v.id * 20 )
        		-- v:setHeight( 50 + v.id * 20 )
        		v:setSize( 50 + v.id * 20, 50 + v.id * 20 )
        	end
        end
        }

    buttonFlip2 = Button { 
    	layer = layer, 
    	name = "buttonFlip2",
        text = "to 0",
        pos = { 400, 400 },
        onClick = function( e ) 
        	for k, v in pairs( sprites ) do
        		v:seekRot( 0, 0, 0, 1 )
        		v.id = ( v.id - 1 - 1 ) % 6 + 1 
        		v:setTexture( string.format( "bird%d.png", v.id ) )
        	end
        end,
        }

    local sp = Sprite { texture = "bird1.png", layer = layer }
    sp:setLoc( 100, 100 )
    print("1 pos -> ", sp:getPos() )
    print("1 loc -> ", sp:getLoc() )
    print("1 board -> ", sp:getLeft(), sp:getRight(), sp:getTop(), sp:getBottom() )
    sp:setSize( 300, 300 )
    print("2 pos -> ", sp:getPos() )
    print("2 loc -> ", sp:getLoc() )
    print("2 board -> ", sp:getLeft(), sp:getRight(), sp:getTop(), sp:getBottom() )
end

function fOnTouchDown( e )
	local sprite = e.touchingProp
	if not sprite then return end
	print("fOnTouchDown")

	local px, py = sprite:getPos()

	print("loc", sprite:getLoc())
	print("pos", sprite:getPos())
	print("left, right, top, bottom", sprite:getLeft(), sprite:getRight(), sprite:getTop(), sprite:getBottom() )

	downOffsetX = px - e.x
	downOffsetY = py - e.y

	downSprite = sprite

	fOnDown( sprite )
end

function fOnTouchMove( e )
	local sprite = e.touchingProp
	if not sprite or sprite ~= downSprite then return end

	print("fOnTouchMove")

	sprite:setPos( e.x + downOffsetX, e.y + downOffsetY )
end

function fOnTouchUp( e )
	local sprite = e.touchingProp
	if not sprite or sprite ~= downSprite then 
		downSprite = nil
		return 
	end

	sprite:setPos( e.x + downOffsetX, e.y + downOffsetY )
	downSprite = nil

	fOnUp( sprite )
end

function fOnTouchCancel( e )
	local sprite = e.touchingProp
	if not sprite or sprite ~= downSprite then 
		downSprite = nil
		return 
	end

	sprite:setPos( e.x + downOffsetX, e.y + downOffsetY )
	downSprite = nil

	fOnUp( sprite )
end

function fOnDown( sprite )
	-- if sprite.sclAction then sprite.sclAction:stop() end
	if sprite.colorAction then sprite.colorAction:stop() end
	if sprite.rotAction then sprite.rotAction:stop() end

	print("down", sprite)

	local easeType = MOAIEaseType.EASE_IN
	-- sprite.sclAction = sprite:seekScl( 1.2, 1.2, 1, 0.1, easeType )
	sprite.colorAction = sprite:seekColor( 1, 0.5, 0.5, 1, 0.1, easeType )
	sprite.rotAction = sprite:seekRot( 0, 0, 90, 0.1, easeType )
end

function fOnUp( sprite )
	-- if sprite.sclAction then sprite.sclAction:stop() end
	if sprite.colorAction then sprite.colorAction:stop() end
	if sprite.rotAction then sprite.rotAction:stop() end

	print("up", sprite)

	local easeType = MOAIEaseType.EASE_OUT
	-- sprite.sclAction = sprite:seekScl( 1, 1, 1, 0.1, easeType )
	sprite.colorAction = sprite:seekColor( 1, 1, 1, 1, 0.1, easeType )
	sprite.rotAction = sprite:seekRot( 0, 0, 0, 0.1, easeType )
end