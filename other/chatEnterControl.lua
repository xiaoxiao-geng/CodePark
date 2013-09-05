module("pChatEnter", package.seeall)

-- 渠道选择界面关闭
function mfButtonChannelCloseListener( event, data )
	if data then
		data:hide()
	end
end
-- 渠道选择按钮侦听
function mfButtonChannelListener(event, data)
		
	if data then
		if data:getVisible() then
			data:hide()
			gItemCompare.mfItemCompareClose()
		else
			data:show()
			data:moveToFront()
			local priList = pChat.windowPriList
			if priList and priList:getVisible() then
				priList:hide()
			end
		end
	end

end

function mfButtonFastListener(event, data)
	if fastPanel then
		if fastPanel:getVisible() then
			fastPanel:hide()
		else
			fastPanel:show()
			fastPanel:moveToFront()
		end
	end
end


function mfGetFastContent(event, data)
	if event.currValue then
		local text = data:getText()
		mWindowContent = data
	end
end

function mfFastSendListener(event, data)
	if mWindowContent == nil then
		return
	end
	local text = mWindowContent:getText()
	if text == "" then
		return
	end
	mfSendContent(text)
end

function mfFastSettingListener(event, data)
	local function _onGetText(text)
		local widget = mWindowContent
		local id = widget.id
		mFastContentTable[id][2] = text
		gRecordSvr.fWrite( text, "fast"..id )
		widget:setText(text)
	end
	T.mfShowKeyboard(_onGetText, mWindowContent)
end

-- 改变发言频道侦听
function mfChangeChannelListener(event, data)
	if event.currValue then
		local name = data.NAME
		local id = data.ID
		local heroLv = pcMgr.mMyHero.ui[X_LEVEL]
		if heroLv <= 10 and id == pMessage.mCHANNEL_WORLD then
			pDialog.mfAddTipMsg("10级以后才可以在世界频道发言。")
		else
			if id == pMessage.mCHANNEL_GUILD then
				if not pcMgr.mMyHero.guild then
					pDialog.mfAddTipMsg("您还没有公会，不能再公会频道发言。")
					return 
				end
			elseif id == pMessage.mCHANNEL_TEAM then
				if pTeam.mMateNum <= 0 then
					pDialog.mfAddTipMsg("您还没有队伍，不能在队伍频道发言。")
					return 
				end
			end
			buttonSayChanel:setText(name)
			buttonSayChanel:setUserData(id)
			windowChannelChats:hide()
		end
	end
end

function mfChangeChannel( channelId )
	-- 根据ID查找名称
	local channelName = ""
	for k, v in pairs( mCHANNEL_LIST ) do
		local name, id = v[ 1 ], v[ 2 ]
		if id == channelId then
			channelName = name
			break
		end
	end


	-- 根据名字查找按钮
	local buttonChannel = windowChannelChats:getChildByName( channelName )
	if not buttonChannel then return end

	-- 设置为选中
	if not buttonChannel:getSelected() then

		buttonChannel:setSelected( true )
	end
end

function mfClearMesEditbox()
	if editBoxChats then
		editBoxChats:setText("")
	end

end

-- 发送消息
function  mfSendBtnListener(event, data)
	local editC = data:getText()
	-- 将输入框清空
	data:setText("")
	data:removePropGroup(pMessage.mFACE_OBJ_INDEX)
	if editC == nil or editC == "" or editC == editC:match("^%s+") then
		return
	end
	
	if editC == "Debug#" then
		DEBUG_FPS = not DEBUG_FPS
		if DEBUG_FPS then
			STATE_INPLAY:LoadDebug()
		else
			STATE_INPLAY:HideDebug()
		end
		return true
	end
	mfSendContent(editC)
end

function mfSendContent(editC)
	if editC == "AutoCommand#" then
		mAutoCommand = not mAutoCommand
		return true
	end

	-- 2013-7-19 gxx 针对欧元符号进行特殊处理
	-- DELME TODO FIXME 下个版本后可以删掉了
	local result = ""
	string.u8foreach( editC, function( ch, starti, endi )
		if ch ~= "€" then result = result .. ch end
		end )
	editC = result
	
	if mAutoCommand then
		if mfAutoCommand(editC) then
			return
		end
	end

	if string.find( editC, "#" ) then
		editC = "呵呵"
	end

	local Content = ""
	local channelId = buttonSayChanel:getUserData()
	channelId = channelId or pMessage.mCHANNEL_LOCAL
	local string_format = string.format
	local string_match = string.match
	local string_gsub = string.gsub

	if mMessageTimer == nil then
		mMessageTimer = MOAITimer.new()
		mMessageTimer:setMode(MOAITimer.NORMAL)
		mMessageTimer:setSpan(6)
	end

	if mMessageWorldTimer == nil then
		mMessageWorldTimer = MOAITimer.new()
		mMessageWorldTimer:setMode(MOAITimer.NORMAL)
		mMessageWorldTimer:setSpan(16)
	end

	if pcMgr.gmLv < 10 and mMessageTimer:isBusy() then
		pDialog.mfAddTipMsg("你说的太快了，歇歇吧！")
		
		-- 恢复输入的文本
		if editBoxChats and editBoxChats._rootProp then
			editBoxChats:setText( editC )
		end
		return
	elseif channelId == pMessage.mCHANNEL_WORLD then
		--如果发送的是世界消息，则特殊处理
		if pcMgr.gmLv < 10 and mMessageWorldTimer:isBusy() then
			pDialog.mfAddTipMsg("你说的太快了，歇歇吧！")

			-- 恢复输入的文本
			if editBoxChats and editBoxChats._rootProp then
				editBoxChats:setText( editC )
			end
			return
		end
	end
	


	-------vip 专用区域----------------
	local vipLv = gVipM.mVipLevel
	local isShowVipInChat = gVipM.mChatVisible
	local vipStr = ""

	if vipLv > 0 and isShowVipInChat then	
		-- GM输入GM命令，则不添加VIP标识符
		if not ( pcMgr.gmLv > 10 and string.sub( editC, 1, 1 ) == "@" ) then
			vipStr = string.format("<vip>000%s</>", vipLv)
		end
	end
	------------------------------------

	--print(channelId)

	if channelId == pMessage.mCHANNEL_PRIVATE then

		if string_match(editC,"^%s+") then -- 如果以空白字符开头则转换为本地聊天
			
			channelId = pMessage.mCHANNEL_LOCAL
			
			local win = windowChannelChats:getChildByName("本地")
 			win:setSelected(true)

			Content = mfU2a(string_format("%s : %s%s", pcMgr.mMyHero.name, vipStr, editC))
			
			if pcMgr.gmLv < 10 and mLastContentTable[channelId] == Content then
				pDialog.mfAddTipMsg("本次发送内容不能和上次相同",false, 2)
			else
				mSendChatContentTables[channelId](Content)
				pChat.mfChangeChannel(channelId)
				mfSaveHistory( channelId, editC )
				-- 保存最后一次发送的内容
				mfSaveLastContent(channelId, Content)
			end
		

		elseif string_match(editC,"([^%s+])(%s)(%s*[^%s]+)") then

			mPrivateName = mfU2a(string_gsub(editC,"([^%s]+)(%s)(.*)","%1"))

			if mPrivateName == pcMgr.mMyHero.name then
				
				--pMessage.mfAddText("",pMessage.mCHAT_COLOR[pMessage.mCHAT_TYPE_SYSTEM])

			else

				Content = string_gsub(mfU2a(editC),"([^%s]+%s)(.*)","%2") 
				
				if Content == "" or Content == Content:match("^%s+") then
					pDialog.mfAddTipMsg("发送了空白内容！",false, 2)
				else
					if pcMgr.gmLv < 10 and mLastContentTable[channelId] == Content then
						pDialog.mfAddTipMsg("本次发送内容不能和上次相同",false, 2)
					else
						pPrivateChat.mCurTarget = mfA2u(mPrivateName)
						
						pPrivateChat.mfRecieveMsg(mfU2a(pcMgr.mMyHero.name), Content)
						
						mSendChatContentTables[channelId](mfTrim(mPrivateName), Content)
						pChat.mfChangeChannel(channelId)
						mfSaveHistory( channelId, editC )
						-- 保存最后一次发送的内容
						mfSaveLastContent(channelId, Content)
						-- 如果当前是在私聊界面的话 就把私聊名称再次设置到输入框中
						if pChat.mFilterIndex == pChat.FILTER_PRI then
							editBoxChats:setText(mfA2u(mPrivateName) .. " ")
						end
					end
				end
			end

		else
			channelId = pMessage.mCHANNEL_LOCAL
			
			local win = windowChannelChats:getChildByName("本地")
 			win:setSelected(true)

			Content = mfU2a(string_format("%s : %s%s", pcMgr.mMyHero.name,vipStr,editC))
			if pcMgr.gmLv < 10 and mLastContentTable[channelId] == Content then
				pDialog.mfAddTipMsg("本次发送内容不能和上次相同",false, 2)
			else
				mSendChatContentTables[channelId](Content)
				pChat.mfChangeChannel(channelId)
				mfSaveHistory( channelId, editC )
				mfSaveLastContent(channelId, Content)
			end
		end
	else

		-- if not mfDoXCommand( editC ) then
			Content = mfU2a(string_format("%s : %s%s", pcMgr.mMyHero.name,vipStr,editC))
			if pcMgr.gmLv < 10 and mLastContentTable[channelId] == Content then
				pDialog.mfAddTipMsg("本次发送内容不能和上次相同",false, 2)
			else
				mSendChatContentTables[channelId](Content)
				pChat.mfChangeChannel(channelId)
				mfSaveLastContent(channelId, Content)
				mfSaveHistory( channelId, editC )
			end
		-- end


		
	end

	if facePanel:getVisible() then
		facePanel:hide()
	end

	if fastPanel:getVisible() then
		fastPanel:hide()
	end

	if windowChannelChats and windowChannelChats:getVisible() then
		windowChannelChats:hide()
	end 
	if pChat.windowPriList and pChat.windowPriList:getVisible() then
		pChat.windowPriList:hide()
	end


	uiManage.mfRemoveViewToManager(pMcItem.mUIManagerItem)  


	-- 关闭键盘 
	-- 发送的时候有两种情况，如果键盘还在，则重新show一次，这样可以清空键盘的缓存
	-- 如果键盘不在，则不用考虑这种情况
	local keyboard = MOAIKeyboardAndroid or MOAIKeyboardIOS or MOAIKeyboardWindows 
	if T.mfIsKeyBoardShowing() and keyboard and keyboard ~= MOAIKeyboardWindows then 
		keyboard:showKeyboard("")
	end

end

function mfSaveLastContent(channelId, Content)
	mMessageTimer:start()
	if channelId == pMessage.mCHANNEL_WORLD then
		mMessageWorldTimer:start()
	end
	
	mLastContentTable[channelId] = Content
	local timer = MOAITimer.new()
	timer:setMode(MOAITimer.NORMAL)
	timer:setSpan( 30 )
	timer.channelId = channelId
	timer.Content = Content
	timer:setListener(MOAITimer.EVENT_TIMER_END_SPAN, function( this )
		local channelID = this.channelId
		if mLastContentTable and channelID ~= nil then
			mLastContentTable[channelID] = nil
		end
		if this ~= nil then
			this.channelId = nil
			this.Content = nil
			this:stop()
			this = nil
		end
		
	end)
	timer:start()
	if mLastContentTimerTable[channelId] then
		mLastContentTimerTable[channelId]:stop()
		mLastContentTimerTable[channelId] = nil
	end
	mLastContentTimerTable[channelId] = timer
end

function mfAutoCommand(editC)
	if string.sub(editC,1, 2) == "z+" then
		local str, count = string.gsub(editC,"+","")
		STATE_INPLAY:cameraZoomOut(count)
		return true
	elseif string.sub(editC,1, 2) == "z-" then
		local str, count = string.gsub(editC,"-","")
		STATE_INPLAY:cameraZoomIn(count)
		return true
	end

	if editC == "AutoAttack#" then
		pcMgr.mAutoAttack = not pcMgr.mAutoAttack
		return true
	end

	if string.sub(editC,1, 7) == "Effect#" then
		editC = string.gsub(editC,"Effect#","")
		if editC ~= "" then
			if tonumber(editC) > EFFECT_ALL then
				editC = EFFECT_ALL
			elseif tonumber(editC) < EFFECT_NONE then
				editC = EFFECT_NONE
			end
			pcMgr.mEffectLevel = tonumber(editC)
		end
		return true
	end 
	
	if string.sub(editC,1, 9) == "AutoHeal#" then
		editC = string.gsub(editC,"AutoHeal#","")
		if editC ~= "" then
			if tonumber(editC) > 0 and tonumber(editC) < 1 then
				pcMgr.mAutoHealMinHp = tonumber(editC)
			end
		end
		pcMgr.mAutoHeal = not pcMgr.mAutoHeal
		return true
	end

	if string.sub(editC,1, 9) == "AutoCast#" then
		editC = string.gsub(editC,"AutoCast#","")
		if editC ~= "" then
			for i=1,#editC do
				local id = tonumber(string.sub(editC,i,i))
				if id == 0 then
					pShortcuts.mfSetAutoCast(i, 0)
				else
					pShortcuts.mfSetAutoCast(id, id)
				end
			end
		end
		return true
	end

	if string.sub(editC,1, 10) == "SellEquip#" then
		editC = string.gsub(editC,"SellEquip#","")
		if editC == "" then
			pMcItem.mfSellListener(nil, 10)
		else
			pMcItem.mfSellListener(tonumber(editC), 10)
		end
		return true
	end

	if string.sub(editC,1, 14) == "AutoSellEquip#" then
		pcMgr.mAutoSellEquip = not pcMgr.mAutoSellEquip
		return true
	end

	if string.sub(editC,1, 14) == "SoulEquip#" then
		protoRequestSoulUpFastMsg()
		return true
	end

	if string.sub(editC,1, 8) == "SetDrug#" then
		local name = string.gsub(editC,"SetDrug#","")
		pMcItem.mfSetAutoHeal(mfU2a(name))
		return true
	end

 	
end

-- -- 2013-5-31 gxx
-- -- 内部测试用扩展GM命令
-- -- xmonster begin_id end_id   					刷出指定范围内所有怪物 阵营0 数量1
-- -- xitem item1 item2 ... itemN amount quality 	刷出指定物品
-- function mfDoXCommand( editC )
-- 	-- 查找xmonster
-- 	local p1, p2 = string.find( editC, "xmonster" )
-- 	if p1 and p2 then
-- 		local arr = mfLua_string_split( editC, " " )
-- 		local min, max = arr[2], arr[3]
-- 		if min and max then
-- 			mfXMonster( tonumber(min), tonumber(max) )
-- 		end
-- 		return true
-- 	end

-- 	-- 查找xitem
-- 	p1, p2 = string.find( editC, "xitem" )
-- 	if p1 and p2 then
-- 		local arr = mfLua_string_split( editC, " " )
-- 		if #arr >= 4 then
-- 			local ids = {}
-- 			for i = 2, #arr - 2 do
-- 				table.insert( ids, arr[i] )
-- 			end
-- 			mfXItem( ids, tonumber( arr[ #arr - 1 ] ), tonumber( arr[ #arr ] ) )
-- 		end
-- 		return true
-- 	end

-- 	return false
-- end

-- function mfXMonster( min, max )
-- 	local timer = MOAITimer:new()
-- 	timer:setMode(MOAITimer.LOOP)
-- 	timer:setSpan( 0.1 )
-- 	timer.id = min
-- 	timer:setListener(MOAITimer.EVENT_TIMER_LOOP, function( action )
-- 		local cmd = "@monster " .. action.id .. " 1 0"
-- 		local content = mfU2a(string.format("%s : %s", pcMgr.mMyHero.name, cmd))
-- 		mSendChatContentTables[pMessage.mCHANNEL_LOCAL](content)
-- 		action.id = action.id + 1
-- 		if action.id > max then action:stop() end
-- 	end)
-- 	timer:start()
-- end

-- function mfXItem( ids, amount, quality )
-- 	local equips = ids

-- 	local timer = MOAITimer:new()
-- 	timer:setMode(MOAITimer.LOOP)
-- 	timer:setSpan( 0.1 )
-- 	timer.count = 0
-- 	timer.equips = equips
-- 	timer:setListener(MOAITimer.EVENT_TIMER_LOOP, function( action )		
-- 		action.count = action.count + 1
-- 		if action.count > #action.equips then action:stop() return end

-- 		local equips = action.equips
-- 		local itemID = equips[ action.count ]

-- 		local cmd = "@item " .. itemID .. " " .. amount .. " " .. quality
-- 		local content = mfU2a(string.format("%s : %s", pcMgr.mMyHero.name, cmd))
-- 		mSendChatContentTables[pMessage.mCHANNEL_LOCAL](content)
-- 	end)
-- 	timer:start()
-- end

function mfTrim (s) 
	return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end 


-- 私聊打开界面
function mfShowPrivateChatEnterPanel(name)
	-- gLog.debug("showPrivateChat EnterPanel", name)

 	local win = windowChannelChats:getChildByName("私聊")
 	
 	win:setSelected(true)

	mPrivateName = mfU2a(name)

	editBoxChats:setText(name .. " ")

	channelId = pMessage.mCHANNEL_PRIVATE
end

function mfShowChatEnterPanel()	
	chatEnterPanel.window:show()
	mfButtonChannelCloseListener()
	channelId = channelIdTemp
end

function mfHideChatEnterPanel()
	chatEnterPanel.window:hide()
	mfButtonChannelCloseListener()
end

local chatEditNowText = ""
function mfOnChatEditFocus(event, data)
	chatEditNowText =  event.widget and event.widget:getText() or ""
	local function _onGetText(text)
		local widget = event.widget
		local t = chatEditNowText .. text
		widget:setText( t )
        if widget._addCursor then
            widget._cursorPos = string.len( t )+1
            widget:_addCursor()
        end
	end
	T.mfShowKeyboard(_onGetText, event.widget)
end

function mfButtonBackspaceListener(event, data)
	local text = editBoxChats:getText()
	text = pMessage.mfOnBackspace(text)
	editBoxChats:setText(text)
	pMessage.mfParseFaces(editBoxChats, text, true)
	chatEditNowText = text
end

function mfButtonPhizListener(event, data)
	if facePanel:getVisible() then
		facePanel:hide()
	else
		facePanel:show()
		facePanel:moveToFront()
		mfUpdateFacePanel()
	end
end

function mfClickFaceListener(event, data)
	if data <= mMAX_FACE then
		local n = data
		local h = math.modf(n / 100)
		n = n%100
		local d = math.modf(n / 10)
		n = n%10
		local name = string.format("%s%s%s",h,d,n)

		local text = editBoxChats:getText()

		local t, num = string.gsub(text, "<face>[^/]+</>", "")
		--一条消息里面最多只能有5个表情
		if num < mMESSAGE_FACE_MAX then
			text = string.format("%s<face>%s</>",text, name)
		end
		editBoxChats:setText(text)
		pMessage.mfParseFaces(editBoxChats, text, true)

	end
	
end

function mfButtonPakageListener(event, data)
	pMcItem.mfEnterInit()
end

-- 历史记录按钮回调
-- 将上一条记录显示到输入框中
function mfButtonHistoryListener()
	local channelId, text = mfGetHistory()
	if not channelId then 
		pDialog.mfAddTipMsg( "暂时没有聊天记录" )
		return
	end

	-- 按照channel改变UI
	mfChangeChannel( channelId )

	-- 填充文本框
	editBoxChats:setText( text )	
	pMessage.mfParseFaces(editBoxChats, text, true)
end


function mfItemPlaced(item)

	if not item then
        return true
    end
    
    mfInsertItemLink(item)
   
    return true
end

function mfCursorCallback(event, data)
    
    local item = data:getUserData()
    if not item then
        return true
    end
    
    if event.currValue then
		local itemBtns = mMcPanelTable[item:getItemType()]
    	gItemCompare.fLoadAndShow( item, true, itemBtns, ALIGN_LEFT)
    end
    -- if event.prevValue and event.currValue then
    --     mfHandleItem(data)
    -- end
    return true
end

function mfInsertItemLink(item)
    local itemName = mfA2u(item.name)

	local ci1, ci2 = string.find(itemName, ">[^<]+<", 1)
	local a = string.sub(itemName, 1, ci1)
	local b = string.sub(itemName, ci1+1, ci2-1)
	local c = string.sub(itemName, ci2)

	itemName = string.format("%s[%s]%s",a,b,c)

	local name = string.format("<item:%s:%s:%s:%s>%s<c></>",mTYPE_ITEM,item.index,pcMgr.mHeroId,item.name_id,itemName)

	local text = editBoxChats:getText()
	local t, num = string.gsub(text, "<item:[^>]+>[^/]+</>", "")
	--一条消息里面最多只能有3个装备
	if num < mMESSAGE_ITEM_MAX then
		text = string.format("%s%s",text, name)
	end

	editBoxChats:setText(text)

	gItemCompare.mfItemCompareClose()
end














-- 历史记录相关
function mfSaveHistory( channelId, text )
	-- 删除相同的历史记录
	mfRemoveHistory( channelId, text )

	if #mHistory >= mMAX_HISTORY then
		table.remove( mHistory, #mHistory )
	end
	table.insert( mHistory, 1, { channelId, text } )

	currHistoryIndex = 1

	mfSaveHistoryRecord()
end

function mfRemoveHistory( channelId, text )
	for k, v in pairs( mHistory ) do
		if v and v[ 1 ] == channelId and v[ 2 ] == text then
			table.remove( mHistory, k )
		end
	end
end

function mfGetHistory()
	if #mHistory <= 0 then return nil, nil end

	if currHistoryIndex > #mHistory then currHistoryIndex = 1 end

	local history = mHistory[ currHistoryIndex ]
	currHistoryIndex = currHistoryIndex + 1

	return history[ 1 ], history[ 2 ]
end

-- 调试用，打印聊天历史
-- function mfPrintHistory()
-- 	print("history:")
-- 	for k, v in pairs( mHistory ) do
-- 		print( "  ", k, mfU2a( v[ 1 ] ), mfU2a( v[ 2 ] ) )
-- 	end
-- end

function mfLoadHistoryRecord()
	currHistoryIndex = 1
	mHistory = gRecordSvr.fReadCharData( "chatHistory" ) or {}
end

function mfSaveHistoryRecord()
	if not mHistory then return end
	gRecordSvr.fWriteCharData( mHistory, "chatHistory" )
end