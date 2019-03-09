local timer = require "timer"
local font = require "font"

local gui = {}


function gui:initButton(mouse) --初始化按钮

	inButtonMouse = mouse --引用鼠标的操作情况

	if mouse then
		button = {}
	else
		error("button system is not been added mouse.")
	end

end


function gui:initMapTable() --初始化图表

	if mouse then
		mapTable = {}
	else
		error("mapTable system is not been added mouse.")
	end

end


function gui:getButton(name) --获取按钮
	
	if button[name] then
		return button[name]
	else
		error("'"..name.."' this button is not been added.")
	end

end


function gui:addButton(name,imgPath_0,imgPath_1,x,y) --添加按钮,text为可选参数，绘制文本在按钮上

	--设定图片
	button[name] = {}
	button[name].imgDate = {}
	button[name].imgDate.mouseNo = love.graphics.newImage(imgPath_0)
	button[name].imgDate.mouseDown = love.graphics.newImage(imgPath_1)
	--设定触发位置
	button[name].pos = {}
	button[name].pos.x = x
	button[name].pos.y = y
	button[name].pos.w = button[name].imgDate.mouseNo:getWidth()
	button[name].pos.h = button[name].imgDate.mouseNo:getHeight()
	--初始化按钮状态
	button[name].inDown = false
	button[name].use = true

	return {
		setText = function(text,...)
			button[name].text = {}
			button[name].text.content = text
			button[name].text.color = ...
		end,
		setCode = function(code)
			button[name].code = loadstring(code)
		end
	}

end


function gui:setButtonEmploy(name,state) --设置按钮使用状态

	button[name].use = state
	
end


function gui:setMapTableEmploy(name,state) --设置图表使用状态
	
	mapTable[name].open = state

end


function gui:getButtonState(name) --获得按钮状态
	
	local buttonData = button[name]

	if buttonData then
		if gui:button(name) then --弹起状态
			return "jump"
		elseif buttonData.inDown then --按下状态
			return "down"
		else --无使用状态
			return "up"
		end
	end

end


function gui:button(name) --使用按钮，name标识使用哪一个按钮

	function runButtonCode(code) --运行按钮绑定的代码

		if code then
			code()
		end

	end

	local buttonData = button[name]

	if buttonData.use then
		local b_x = buttonData.pos.x
		local b_y = buttonData.pos.y
		local b_w = buttonData.pos.w
		local b_h = buttonData.pos.h

		local x = inButtonMouse.left.x
		local y = inButtonMouse.left.y

		local inDown = buttonData.inDown

		--避免使用不存在的按钮
		if inDown ~= nil then
			if inButtonMouse.left.key and not inDown then 
				if x >= b_x 
					and x <= b_x + b_w
					and y >= b_y
					and y <= b_y + b_h then
					buttonData.inDown = true
				end
			elseif not inButtonMouse.left.key and inDown then
				buttonData.inDown = false
				runButtonCode(buttonData.code)
				return true
			end
		else
			error("used a bad button from '"..name.."'")
		end
	end

	return false

end


function gui:drawButton(name) --绘制按钮

	local buttonData = button[name]

	if buttonData.use then
		local buttonPos = buttonData.pos

		if buttonData.inDown then --绘制按下
			love.graphics.draw(buttonData.imgDate.mouseDown, 
				buttonPos.x, buttonPos.y)
		else --绘制弹起
			love.graphics.draw(buttonData.imgDate.mouseNo, 
				buttonPos.x, buttonPos.y)
		end

		if buttonData.text then --绘制文本
			local size
			local len = string.len(buttonData.text.content)
			len = len/3 --按utf8计算

			if buttonData.pos.h > 32 then --最大字体
				size = 32
			else
				size = buttonData.pos.h
			end
			font:printf(buttonData.text.content,
				buttonPos.x+buttonPos.w/2-size/2*len,buttonPos.y+buttonPos.h/2-size/2-5
				,"t",size,buttonData.text.color)
		end
	end

end


function gui:resButton(name) --重置按钮

	button[name].inDown = false

end


function gui:desButton(name) --破坏按钮

	button[name] = nil

end


function gui:addMapTable(name,backgroundPath,x,y) --添加图表
	
	mapTable[name] = {}
	mapTable[name].button = {}
	mapTable[name].background = {}
	mapTable[name].onButton = ''
	mapTable[name].offButton = ''
	mapTable[name].open = false
	--设定图表背景
	mapTable[name].background.img = love.graphics.newImage(backgroundPath)
	mapTable[name].background.x = x
	mapTable[name].background.y = y
	mapTable[name].background.w = mapTable[name].background.img:getWidth()
	mapTable[name].background.h = mapTable[name].background.img:getHeight()

	return {
		setOnButton = function(objectName)
			mapTable[name].onButton = objectName
		end,
		setOffButton = function(objectName)
			mapTable[name].offButton = objectName
		end,
		addButton = function(objectName)
			mapTable[name].button[objectName] = objectName
		end
	}

end


function gui:mapTable(name) --使用图表

	local mapTableDate = mapTable[name]

	if mapTableDate then
		if not mapTableDate.open then
			--使用开启按钮
			if gui:button(mapTableDate.onButton) then
				mapTableDate.open = true
			end
		else
			--屏蔽
			gui:shieldedCloth(name,"mapTable")
			--使用关闭按钮
			if gui:button(mapTableDate.offButton) then
				mapTableDate.open = false
				--解除屏蔽
				gui:recShieldedCloth(name,"mapTable")
			end

			--使用图表中的按钮
			for key,buttonName in pairs(mapTableDate.button) do
				gui:button(buttonName)
			end
		end
	else
		error("'"..name.."' this mapTable is not been added.")
	end

end


function gui:drawMapTable(name) --绘制图表

	local mapTableDate = mapTable[name]

	if mapTableDate then
		--绘制开启按钮
		if not mapTableDate.open then
			gui:drawButton(mapTableDate.onButton)
		else
			--绘制图表背景
			love.graphics.draw(mapTableDate.background.img, mapTableDate.background.x, mapTableDate.background.y)
			--绘制关闭按钮
			gui:drawButton(mapTableDate.offButton)
			--绘制图表按钮
			for k,buttonName in pairs(mapTableDate.button) do
				gui:drawButton(buttonName)
			end
		end
	else
		error("'"..name.."' this mapTable is not been added.")
	end

end


local function collision(x,y,w,h,tx,ty,tw,th)

	local lenX = x + w
	local lenY = y + h
	local lenTx = tx + tw
	local lenTy = ty + th

	if (lenTx > x and ty > y) --在左上角
		or (tx < lenX and lenTy < y) --在右上角
		or (lenTx > x and ty < lenY) --在左下角
		or (tx < lenX and ty < lenY) then --在右下角
		return true
	end
	return false

end


function gui:shieldedCloth(objectName,objectType,employ) --屏蔽布，用于屏蔽除调用对象外的对象

	--这是内部使用的参数
	local object = 0
	local isEmploy = employ or false

	if objectType == "mapTable" then --是图表
		object = mapTable[objectName]
		local onButton = button[object.onButton]
		local offButton = button[object.offButton]

		if object.open then --开启的图表
			--检索图表的所有按钮
			for k,b in pairs(button) do
				local has = false
				--检索按钮是否是表单中的按钮
				if k == object.offButton then
					has = true
				else
					for buttonName,v in pairs(object.button) do
						if buttonName == k then
							has = true
							break
						end
					end
				end
				--检索需要掩盖的对象
				if not has and collision(object.background.x, object.background.y, object.background.w, object.background.h,
					b.pos.x, b.pos.y, b.pos.w, b.pos.h) then
					b.use = isEmploy
				end
			end
		else --关闭的图表
			for k,b in pairs(button) do
				b.use = isEmploy
			end
		end
	else --是按钮
		object = button[objectName]

		for k,b in pairs(button) do
			if collision(object.pos.x, object.pos.y, object.pos.w, object.pos.h, 
				b.pos.x, b.pos.y, b.pos.w, b.pos.h) then
				b.use = isEmploy
			end
		end
	end

end


function gui:recShieldedCloth(objectName,objectType) --恢复屏蔽对象
	
	gui:shieldedCloth(objectName,objectType,true)

end


return gui