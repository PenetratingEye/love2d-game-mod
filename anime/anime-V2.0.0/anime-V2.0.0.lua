local timer = require "timer"

local anime = {}


function anime:initAnime() --初始化动画系统
	
	animeList = {}

end


--[[
播放顺序表
1——正向播放
-1——反向播放

播放状态表
0——未开始播放
1——正在播放中
-1——暂停播放
]]


function anime:addAnimeContainer(name) --添加动画容器
	
	animeList[name] = {}
	animeList[name].container = {}

end


function anime:getAnimeContainer(name) --获得动画容器
	
	local container = animeList[name].container

	if container then
		return {
			--添加动画（path参数填写为动画文件夹目录，示例img/anime/,num为动画张数，type为图片格式，layer为当前动画层数）
			addAnime = function(names,path,num,type,layer)
				local obj
				local data = {}
				local w,h
				container[names] = {}
				obj = container[names]

				--加载动画资源
				for i=1,num do
					data[i]	= love.graphics.newImage(path..i.."."..type)
				end
				w = data[1]:getWidth()
				h = data[1]:getHeight()

				obj.name = names --动画名称
				obj.layer = layer --动画层数
				obj.show = true --显示状态
				obj.order = 1 --播放顺序
				obj.state = 0 --播放状态
				obj.num = num --动画图片数
				obj.data = data --动画数据
				obj.nowPos = 1 --当前播放位置
				obj.staPos = 1 --开始播放位置
				obj.endPos = num --结束播放位置
				obj.axis = { x=0,y=0,arc=0,w=w,h=h } --动画绘制坐标
				timer:addTimer(name..tostring(layer).."_anime",1/15) --动画速度时钟

				return {
					setAxis = function(x,y,arc) --设置动画坐标
						obj.axis.x = x
						obj.axis.y = y
						if arc then
							obj.axis.arc = arc
						end
					end
				}
			end
		}
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:getAnimePos(name,subName) --获得动画当前帧位置
	
	local val = { name, subName }

	if #val == 2 then
		return animeList[name].container[subName].nowPos
	else
		local container = animeList[name].container
		local posList = {}

		for k,v in pairs(container) do
			posList[k] = v.nowPos
		end

		return posList
	end

end


local function sort(obj) --将容器排序

	local function sortFunc(a,b)
		return a.layer < b.layer
	end

	local sortList = {}
	local i = 1

	--将数据导入顺序队列
	for _,v in pairs(obj) do
		sortList[i] = v
		i = i + 1
	end
	table.sort(sortList,sortFunc) --排序

	return sortList

end


local function toContainer(obj) --顺序表转换成容器表
	
	local container = {}

	for _,v in pairs(obj) do
		container[v.name] = v
	end

	return container

end


function anime:drawAnime(name,subName) --绘制动画（若不播放，将绘制当前帧）
	
	local function draw(obj,fName)
		if obj then
			local axis = obj.axis
			local aw = axis.w/2
			local ah = axis.h/2

			if obj.show then --显示
				love.graphics.draw(obj.data[obj.nowPos], axis.x+aw, axis.y+ah, axis.arc, 1, 1, aw, ah)
			end

			if obj.state == 1 and timer:timer(fName..tostring(obj.layer).."_anime") then --播放
				if obj.order == 1 then
					obj.nowPos = obj.nowPos + 1
				else
					obj.nowPos = obj.nowPos - 1
				end
			end
			if obj.nowPos < obj.staPos then
				obj.nowPos = obj.endPos
			end
			if obj.nowPos > obj.endPos then
				obj.nowPos = obj.staPos
			end
		else
			error("'"..obj.name.."' this is anime object is not find.")
		end
	end

	local val = { name, subName }
	local container = animeList[name].container

	if container then --容器存在
		if #val == 2 then
			draw(container[subName],name)
		else
			local drawList = sort(container)

			for _,v in pairs(drawList) do
				draw(v,name)
			end
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:staAnime(name,subName) --开始动画（暂停状态使用会恢复，结束状态使用会重启动画）

	local function start(obj,fName)
		if obj then
			if obj.state == 0 then
				obj.nowPos = 1
			end
			obj.state = 1

			timer:staTimer(fName..tostring(obj.layer).."_anime")
		else
			error("'"..obj.name.."' this is anime object is not find.")
		end
	end

	local val = { name, subName }
	local container = animeList[name].container

	if container then --容器存在
		if #val == 2 then
			start(container[subName],name)
		else
			for _,v in pairs(container) do
				start(v,name)
			end
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:stopAnime(name,subName) --暂停动画
	
	local function stop(obj,fName)
		if obj then
			obj.state = -1

			timer:endTimer(fName..tostring(obj.layer).."_anime")
		else
			error("'"..obj.name.."' this is anime object is not find.")
		end
	end

	local val = { name, subName }
	local container = animeList[name].container

	if container then --容器存在
		if #val == 2 then
			stop(container[subName],name)
		else
			for _,v in pairs(container) do
				stop(v,name)
			end
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:endAnime(name,subName) --结束动画
		
	local function ends(obj,fName,layer)
		if list then
			list.state = 0

			timer:endTimer(fName..tostring(layer).."_anime")
		else
			error("'"..obj.name.."' this is anime object is not find.")
		end
	end

	local val = { name, subName }
	local container = animeList[name].container

	if container then --容器存在
		if #val == 2 then
			ends(container[subName],name)
		else
			for _,v in pairs(container) do
				ends(v,name)
			end
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:desAnime(name,subName) --破坏动画

	local val = { name, subName }
	local container = animeList[name].container

	if container then --容器存在
		if #val == 2 then
			container[subName] = nil
		else
			local num = #container

			animeList[name] = nil
			for i=1,num do
				timer:desTimer(name..tostring(i).."_anime")
			end
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:setAnimeData(name) --设置动画数据
	
	local container = animeList[name].container

	if container then
		return {
			addAnime = function(names,pos,...) --添加动画帧
				container[names].num = container[names].num + 1
				table.insert(container[names].data, pos, ...)
			end,
			remAnime = function(names,pos) --移除动画帧
				local obj = container[names]

				if pos >= 1 and pos < obj.num and obj.num > 0 then
					obj.num = obj.num - 1
					table.remove(obj.data, pos)
				else
					error("'"..names.."' this is anime object of pos is not find.")
				end
			end,
			altAnime = function(names,pos,tiggerPos) --替换两个动画帧的位置
				local obj = container[names]

				obj.data[pos] = obj.data[tiggerPos]
				obj.data[tiggerPos] = buffer
			end,
			moveAnime = function(names,pos,tiggerPos) --移动动画帧的位置
				local obj = container[names]

				table.remove(obj.data, pos)
				table.insert(obj.data, tiggerPos - 1, buffer)
			end
		}
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:setAnimeShow(name,subName,show) --设置动画显示状态

	local val = { name, subName, show }
	local container = animeList[name].container

	if container then
		if #val == 3 then --设置指定动画对象
			container[subName].show = show
		elseif #val == 2 then --设置整个容器
			for _,v in pairs(container) do
				v.show = show
			end
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:setAnimeSpeed(name,subName,speed) --设置动画速度

	local container = animeList[name].container

	if container then
		timer:setTickTime(name..tostring(container[subName].layer).."_anime",speed)
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:setAnimeOrder(name,subName,order) --设置播放顺序
	
	local container = animeList[name].container

	if container then
		container[subName].order = order
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:setAnimeAxis(name,subName,...) --设置动画位置
	
	local axis = ...
	local container = animeList[name].container

	if container then
		local obj = container[subName]

		obj.axis.x = axis.x
		obj.axis.y = axis.y
		if axis.arc then
			obj.axis.arc = axis.arc
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:setAnimeLayer(name,subName) --设置动画层位置

	local container = animeList[name].container

	if container then
		local sortList
		local obj = container[subName]

		return {
			setToTop = function()
				sortList = sort(container) --设置到最顶层

				table.remove(sortList,obj.layer)
				obj.layer = #sortList + 1
				sortList[#sortList + 1] = obj

				container = toContainer(sortList)
			end,
			setToBottom = function() --设置到最底层
				sortList = sort(container)

				obj.layer = 1
				table.insert(sortList,1,obj)

				container = toContainer(sortList)
			end,
			setLayer = function(layer) --设置层数
				sortList = sort(container)

				obj.layer = layer
				table.insert(sortList,layer,obj)

				container = toContainer(sortList)
			end
		}
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:getAnime(name,subName) --获得动画对象
	
	local val = { name, subName }
	if #val < 2 then
		error("you need set two value to this is function.")
	end

	local container = animeList[name].container

	if container then
		local obj = container[subName]
		local timerName = name..tostring(obj.layer).."_anime" --计时器名称

		if obj then
			return {
				getW = function()
					return obj.data[1]:getWidth()
				end,
				getH = function()
					return obj.data[1]:getHeight()
				end,
				getAxis = function()
					return obj.axis
				end,
				getPos = function()
					return obj.nowPos
				end,
				getNum = function()
					return obj.num
				end,

				setAxis = function(...)
					local axis = ...

					obj.axis.x = axis[1]
					obj.axis.y = axis[2]
					if axis[3] then
						obj.axis.arc = axis[3]
					end
				end,
				setSpeed = function(speed) --设置播放速度
					timer:setTickTime(name..tostring(obj.layer).."_anime",speed)
				end,

				setNowPos = function(nowPos) --设置播放位置
					obj.nowPos = nowPos
				end,
				setStaPos = function(staPos) --设置开始播放位置
					obj.staPos = staPos
				end,
				setEndPos = function(endPos) --设置结束播放位置
					obj.endPos = endPos
				end,
				setAnimeData = function() --设置动画数据
					return anime:setAnimeData(name)
				end,

				staAnime = function()
					if obj.state == 0 then
						obj.nowPos = 1
					end
					obj.state = 1
					timer:staTimer(timerName)
				end,
				stopAnime = function()
					obj.state = -1

					timer:endTimer(timerName)
				end,
				endAnime = function()
					obj.state = 0

					timer:endTimer(timerName)
				end
			}
		else
			error("'"..name.."' this is anime container is not find your need object.")
		end
	else
		error("'"..name.."' this is anime container is not find.")
	end

end


function anime:copyAnime(name,subName,tiggerName,tiggerSubName) --复制动画对象（从一个对象复制到另一个对象，以名称表示）（待修正）

	local val = { name, subName, tiggerName, tiggerSubName }
	local container = animeList[tiggerName].container
	local copyContainer = animeList[name].container

	if container and copyContainer then
		if #val == 4 then --复制动画对象
			local copyObj = copyContainer[subName]
			local obj = container[tiggerSubName]

			for k,v in pairs(copyObj) do
				obj[k] = v
			end
			timer:addTimer(tiggerName..tostring(copyObj.layer).."_anime",1/15)
		elseif #val == 2 then --复制容器对象
			local i = 1

			for k,v in pairs(copyContainer) do
				container[k] = v
				timer:addTimer(tiggerName..tostring(v.layer).."_anime",1/15)
			end
		else
			error()
		end
	else
		error("'"..name.."' or '"..tiggerName.."' this is anime container is not find.")
	end

end


return anime