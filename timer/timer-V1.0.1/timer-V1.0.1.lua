local timer = {}

--[[
暂时无法确保精度
计时器在运行状态下存在误差
]]

--cpu杀手代码
local timerThreadCode=[[

local name,staTime,tickTime = ...
local endTime = staTime

local inChannel = love.thread.getChannel("in"..name)
local outChannel = love.thread.getChannel("out"..name)

while true do
	endTime = inChannel:pop()

	if endTime then
		if endTime - staTime >= tickTime then
			staTime = endTime
			outChannel:push(true)
		else
			outChannel:push(false)
		end
	end
end

]]

--实验中的计时器系统隔离运行的代码
local timerSysThreadCode=[[

local endTime
local newTimer,staTimer,endTimer
local setCount,getCountFlag
local setTickTime,getTickTimeFlag
local runTimer = {}

local isError = { error=false, name=" " } --错误

local timeChannel = love.thread.getChannel("getTime") --时间通道

local addChannel = love.thread.getChannel("addTimer") --添加通道
local desChannel = love.thread.getChannel("desTimer") --破坏通道
local staChannel = love.thread.getChannel("staTimer") --开始通道
local endChannel = love.thread.getChannel("endTimer") --结束通道

local setCountDataChannel = love.thread.getChannel("setCountData") --设定计时器运行计数通道
local getCountChannelFlag = love.thread.getChannel("getCountFlag") --获取计时器运行计数标记
local getCountDataChannel = love.thread.getChannel("getCountData") --获取计时器运行计数通道
local setTickTimeChannel = love.thread.getChannel("setTickTimeData") --设定计时器滴答时间通道
local getTickTimeChannelFlag = love.thread.getChannel("getTickTimeFlag") --获取计时器滴答时间标记
local getTickTimeDataChannel = love.thread.getChannel("getTickTimeData") --获取计时器滴答时间通道

while true do
	endTime = timeChannel:pop() --获取时间
	
	setCount = setCountDataChannel:pop() --设定计时器计数
	if setCount then
		if runTimer[setCount.name] then
			runTimer[setCount.name].runCount = setCount.newCount
		else
			isError.error = true
			isError.name = setCount.name
		end
	end

	getCountFlag = getCountChannelFlag:pop() --获取计时器计数
	if getCountFlag then
		if runTimer[getCountFlag] then
			getCountDataChannel:push(runTimer[getCountFlag].runCount)
		else
			isError.error = true
			isError.name = getCountFlag
		end
	end

	setTickTime = setTickTimeChannel:pop() --设定计时器滴答时间
	if setTickTime then
		if runTimer[setTickTime.name] then
			runTimer[setTickTime.name].tickTime = setTickTime.tickTime
		else
			isError.error = true
			isError.name = setTickTime.name
		end
	end

	getTickTimeFlag = getTickTimeChannelFlag:pop() --获取计时器滴答时间
	if getTickTimeFlag then
		if runTimer[getTickTimeFlag] then
			getTickTimeDataChannel:push(runTimer[getTickTimeFlag].tickTime)
		else
			isError.error = true
			isError.name = getTickTimeFlag
		end
	end

	newTimer = addChannel:pop() --添加计时器
	if newTimer then
		runTimer[newTimer.name] = {}	
		runTimer[newTimer.name].name = newTimer.name --名字
		runTimer[newTimer.name].tickTime = newTimer.tickTime --滴答时间
		runTimer[newTimer.name].staTime = 0 --开始时间
		runTimer[newTimer.name].runCount = 0 --运行计数
		runTimer[newTimer.name].Channel = love.thread.getChannel(newTimer.name) --通道
		runTimer[newTimer.name].runState = false --运行状态
	end

	desTimer = desChannel:pop() --破坏计时器
	if desTimer then
		if runTimer[desTimer] then
			runTimer[desTimer] = nil
		else
			isError.error = true
			isError.name = desTimer
		end
	end
	
	if endTime then
		staTimer = staChannel:pop() --开始计时器
		if staTimer then
			if runTimer[staTimer] then
				if not runTimer[staTimer].runState then
					runTimer[staTimer].staTime = endTime
					runTimer[staTimer].runState = true
				end
			else
				isError.error = true
				isError.name = getCount
			end
		end

		for timerName,timer in pairs(runTimer) do --计时器滴答
			if timer.runState then
				if endTime - timer.staTime >= timer.tickTime then
					timer.staTime = endTime
					timer.runCount = timer.runCount + 1
					timer.Channel:push(true)
				else
					timer.Channel:push(false)
				end
			end
		end
	end

	endTimer = endChannel:pop() --结束计时器
	if endTimer then
		if runTimer[endTimer] then
			runTimer[endTimer].runState = false
		else
			isError.error = true
			isError.name = endTimer
		end
	end

	if isError.error then --出错
		error("'"..isError.name.."'this timer is not been added.")
	end
end

]]


function timer:initTimer() --初始化计时器

	runTimerThread = love.thread.newThread(timerSysThreadCode)
	runTimerThread:start()

end


function timer:addTimer(name,tickTime) --添加一个计时器（暂时不能保证精度）

	if runTimerThread then
		local addTimer = {}
		addTimer.name = name
		addTimer.tickTime = tickTime
		love.thread.getChannel("addTimer"):push(addTimer)
	else
		error("timer system is not been init.")
	end

end


function timer:staTimer(name) --开始某个计时器

	love.thread.getChannel("staTimer"):push(name)

end


function timer:resTimer(name) --重启某个计时器
	
	timer:staTimer(name)
	timer:endTimer(name)

end


function timer:runTimer() --运行计时器（必要函数，放置在每次更新中以获取当前时间）

	love.thread.getChannel("getTime"):push(love.timer.getTime())
	local error = runTimerThread:getError()
	assert(not error, error)

end


function timer:timer(name) --每次达到设定时间时返回一个真值，否则返回假


	return love.thread.getChannel(name):pop()

end


function timer:endTimer(name) --结束某个计时器

	love.thread.getChannel("endTimer"):push(name)

end


function timer:desTimer(name) --破坏某个计时器

	love.thread.getChannel("desTimer"):push(name)

end


function timer:resRunCount(name) --重置计时器运行计数

	timer:setRunCount(name,0)

end


function timer:setRunCount(name,num) --设置计时器运行计数

	local data = { name=name, newCount=num }
	love.thread.getChannel("setCountData"):push(data)

end


function timer:getRunCount(name) --获取计时器运行计数

	love.thread.getChannel("getCountFlag"):push(name)
	return love.thread.getChannel("getCountData"):demand()

end


function timer:setTickTime(name,tickTime) --设置计时器滴答时间
	
	local data = { name=name, tickTime=tickTime }
	love.thread.getChannel("setTickTimeData"):push(data)

end


function timer:getTickTime(name) --获取计时器滴答时间

	love.thread.getChannel("getTickTimeFlag"):push(name)
	return love.thread.getChannel("getTickTimeData"):demand()

end


function timer:isHaveTimer(name) --检查计时器是否存在（debug）
	
	love.thread.getChannel("getCountFlag"):push(name)
	return love.thread.getChannel("getCountData"):demand()

end


return timer