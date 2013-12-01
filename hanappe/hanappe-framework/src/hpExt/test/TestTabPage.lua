local super			= TabControl
local M				= class( super )

function M:getTabPageClasses()
	return {
		TestPageB,
		TestPageA,
		TestPageC,
	}
end

function M:getRadioButtonGroupConfig()
	return { 
		buttonTheme = "ButtonMainTab",
		boardLayoutDirection = "right",
		-- horizonAlign = "center",
		verticalAlign = "center",
		buttonSize = HP_BUTTON_MAIN_TAB_SIZE,
		}
end

function M:isUseTextTitle()
	return false
end


function M:creatPageEnterAnim( page, contentWidth, isForward )
	local duration = 0.3

	page:setCenterPiv()

	if isForward then
		return Animation():parallel(
			Animation( page ):setScl( 0.5, 0.5, 1 ):seekScl( 1, 1, 1, duration, Ease.ein ),
			Animation( page ):fadeIn( duration, Ease.ein )
			)
	else
		return Animation():parallel(
			Animation( page ):setScl( 2, 2, 1 ):seekScl( 1, 1, 1, duration, Ease.ein ),
			Animation( page ):fadeIn( duration, Ease.ein )
			)
	end
end


function M:creatPageLeaveAnim( page, contentWidth, isForward )
	local duration = 0.3

	page:setCenterPiv()

	if isForward then
		return Animation():parallel(
			Animation( page ):seekScl( 2, 2, 1, duration, Ease.ein ),
			Animation( page ):fadeOut( duration, Ease.ein )
			)
	else
		return Animation():parallel(
			Animation( page ):seekScl( 0.5, 0.5, 1, duration, Ease.ein ),
			Animation( page ):fadeOut( duration, Ease.ein )
			)
	end
end

return M