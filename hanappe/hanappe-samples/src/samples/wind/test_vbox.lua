module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }

	panel = Panel {
		parent = view,
		pos = { 100, 100 },
		size = { 400, 400 }
	}

	panel:setClip( 12, 8, 12, 16 )

	scroller = Scroller { 
		parent = panel,
		pos = { 0, 0 }, 
		size = { 0, 0 }, 

		layout = VBoxLayout {
            align = {"left", "top"},
            padding = {16, 16, 16, 16},
            gap = {0, 0},
		},
	}

	addText( scroller, "技能名称：巴拿马大叔" )

	local Component = require "hp/gui/Component"
	local component = Component { 
		parent = scroller, 
		size = { 1368, 20 },
		layout = HBoxLayout {
			align = { "left", "top" },
			padding = {0,0,0,0},
			gap = {0,0},
		},
	}



	addText( component, "等级：5级", 120 )
	addText( component, "范围：100", 120 )	
	addText( component, "冷却：30秒", 120 )	
	Button { parent = scroller, text = "hello" }
	addText( scroller, "[ 技能描述 ]" )
	addText( scroller, "召唤4个巴拿马大叔帮你攻击敌人，持续30秒，巴拿马大叔召唤出的瞬间照成200%的伤害。" )
	addText( scroller, "[ 技能描述 ]" )
	addText( scroller, "召唤4个巴拿马大叔帮你攻击敌人，持续30秒，巴拿马大叔召唤出的瞬间照成200%的伤害。" )
	addText( scroller, "[ 技能描述 ]" )
	addText( scroller, "召唤4个巴拿马大叔帮你攻击敌人，持续30秒，巴拿马大叔召唤出的瞬间照成200%的伤害。" )

	scroller:updateLayout()
	local w, h = scroller:getSize()
	scroller:setHScrollEnabled( w > 400 )
	scroller:setVScrollEnabled( h > 400 )
	print( "scroller.pos:", scroller:getPos() )
	print( "scroller.size:", scroller:getSize() )
end

function addText( parent, text, w )
	w = w or 368

    local textbox1 = TextLabel {
        text = text,
        parent = parent,
        size = { w, 18 },
        wordBreak = MOAITextBox.WORD_BREAK_CHAR,
    }
    textbox1:fitHeight()
	return textbox1
end