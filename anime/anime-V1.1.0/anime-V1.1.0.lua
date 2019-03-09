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
function anime:addAnime(name,path,num,type) --添加动画（path参数填写为动画文件夹目录，示例img/anime/,num为动画张数，type为图片格式）
	
	animeList[name] = {}
	local data = {}
	local list = animeList[name]
	local w,h

	--加载动画资源
	for i=1,num do
		data[i]	= love.graphics.newImage(path..i.."."..type)
	end
	w = data[1]:getWidth()
	h = data[1]:getHeight()

	list.order = 1 --播放顺序
	list.state = 0 --播放状态
	list.num = num --动画图片数
	list.data = data --动画数据
	list.nowPos = 1 --当前播放位置
	list.staPos = 1 --开始播放位置
	list.endPos = num --结束播放位置
	timer:addTimer(name.."_anime",1/15) --动画速度时钟
	list.axis = { x=0,y=0,arc=0,w=w,h=h } --动画绘制坐标

	return {
		setAxis = function(x,y,arc)
			list.axis.x = x
			list.axis.y = y
			list.axis.arc = arc or list.axis.arc
		end
	}

end


function anime:drawAnime(name) --绘制动画（若不播放，将绘制当前帧）
	
	local list = animeList[name]
	local aw = list.axis.w/2
	local ah = list.axis.h/2

	if list then
		love.graphics.draw(list.data[list.nowPos], list.axis.x+aw, list.axis.y+ah, list.axis.arc, 1, 1, aw, ah)

		if list.state == 1 and timer:timer(name.."_anime") then --播放
			if list.order == 1 then
				list.nowPos = list.nowPos + 1
			else
				list.nowPos = list.nowPos - 1
			end
		end
		if list.nowPos < list.staPos then
			list.nowPos = list.endPos
		end
		if list.nowPos > list.endPos then
			list.nowPos = list.staPos
		end
	else
		error("'"..name.."' this is anime is not been added.")
	end

end


function anime:staAnime(name) --开始动画（暂停状态使用会恢复，结束状态使用会重启动画）
	
	local list = animeList[name]

	if list then
		if list.state == 0 then
			list.nowPos = 1
		end
		list.state = 1

		timer:staTimer(name.."_anime")
	else
		error("'"..name.."' this is anime is not been added.")
	end

end


function anime:stopAnime(name) --暂停动画
	
	local list = animeList[name]

	if list then
		list.state = -1

		timer:endTimer(name.."_anime")
	else
		error("'"..name.."' this is anime is not been added.")
	end

end


function anime:endAnime(name) --结束动画
	
	local list = animeList[name]

	if list then
		list.state = 0

		timer:endTimer(name.."_anime")
	else
		error("'"..name.."' this is anime is not been added.")
	end

end


function anime:desAnime(name) --破坏动画
	
	animeList[name] = nil
	timer:desTimer(name.."_anime")

end


function anime:setAnimeData(name) --设置动画数据
	
	local list = animeList[name]

	if list then
		return {
			addAnime = function(pos,...) --添加动画
				table.insert(list.data, pos, ...)
			end,
			desAnime = function(pos) --移除动画帧
				if pos >= 1 and pos < list.num and list.num > 0 then
					list.num = list.num - 1
					table.remove(list.data, pos)
				else
					error("this is anime of pos is not find.")
				end
			end,
			altAnime = function(pos,tiggerPos) --替换两个动画的位置
				local buffer = list.data[pos]

				list.data[pos] = list.data[tiggerPos]
				list.data[tiggerPos] = buffer
			end,
			moveAnime = function(pos,tiggerPos) --移动动画的位置
				local buffer = list.data[pos]

				table.remove(list.data, pos)
				table.insert(list.data, tiggerPos - 1, buffer)
			end
		}	
	else
		error("'"..name.."' this is anime is not been added.")
	end

end


function anime:setAnimeSpeed(name,speed) --设置动画速度

	timer:setTickTime(name.."_anime",speed)

end


function anime:setAnimeOrder(name,order) --设置播放顺序
	
	animeList[name].order = order

end


function anime:setAnimeAxis(name,...) --设置动画位置
	
	local axis = ...

	animeList[name].axis.x = axis[1]
	animeList[name].axis.y = axis[2]
	if axis[3] then
		animeList[name].axis.arc = axis[3]
	end

end


function anime:getAnime(name) --获得动画对象
	
	local list = animeList[name]

	return {
		getW = function()
			return list.data[1]:getWidth()
		end,
		getH = function()
			return list.data[1]:getHeight()
		end,
		getPos = function()
			return list.nowPos
		end,

		setAxis = function(...)
			local axis = ...

			list.axis.x = axis[1]
			list.axis.y = axis[2]
			list.axis.arc = axis[3] or list.axis.arc
		end,

		setNowPos = function(nowPos) --设置播放位置
			list.nowPos = nowPos
		end,
		setStaPos = function(staPos) --设置开始播放位置
			list.staPos = staPos
		end,
		setEndPos = function(endPos) --设置结束播放位置
			list.endPos = endPos
		end,

		staAnime = function()
			if list.state == 0 then
				list.nowPos = 1
			end
			list.state = 1
			timer:staTimer(name.."_anime")
		end,
		stopAnime = function()
			list.state = -1

			timer:endTimer(name.."_anime")
		end,
		endAnime = function()
			list.state = 0

			timer:endTimer(name.."_anime")
		end
	}

end


function anime:getAnimePos(name)
	
	return animeList[name].nowPos

end


function anime:setAnimeLayer(name,lay) --设置动画层
	


end


return anime