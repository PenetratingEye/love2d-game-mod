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

--计时器系统主线程代码
local timerSysMainThreadCode=[[

	local timer,addTimer
	local addTime
	local endTime = 0
	local timerList = {}

	local addCount,desCount,staCount,endCount,setTickCount --计数

	local isError = { error=false, name=nil } --错误

	local getTimeChannel = love.thread.getChannel("getTime") --获取时间通道

	local addChannel = love.thread.getChannel("addTimer") --添加通道
	local desChannel = love.thread.getChannel("desTimer") --破坏通道
	local staChannel = love.thread.getChannel("staTimer") --开始通道
	local endChannel = love.thread.getChannel("endTimer") --结束通道

	local mainThreadChannel = love.thread.getChannel("subThread") --时间系统子线程通道
	local subThreadChannel = love.thread.getChannel("mainThread") --时间系统主线程通道

	while true do
		addTime = getTimeChannel:pop() --获取时间

		addCount = addChannel:getCount()
		desCount = desChannel:getCount()
		
		if addTime then
			endTime = endTime + addTime
			--优先级机制
			staCount = staChannel:getCount()
			endCount = endChannel:getCount()
			setTickCount = subThreadChannel:getCount()

			--第一优先级：修改滴答计时并滴答
			for i=1,setTickCount do
				timer = subThreadChannel:pop()
				timerList[timer.name].tickTime = timer.tickTime
			end
			for name,timer in pairs(timerList) do --计时器滴答
				if timer.runState then
					if endTime - timer.staTime >= timer.tickTime then
						timer.Channel:push(true)
						mainThreadChannel:push(name) --压入计数到子线程
						timer.staTime = endTime
					end
				end
			end

			--第二优先级：开始计时器和结束计时器
			for i=1,staCount do
				timer = timerList[staChannel:pop()]
				if timer then
					if not timer.runState then
						timer.staTime = endTime
						timer.runState = true
					end
				else
					isError.error = "start timer not seccess."
					isError.name = getCount
				end
			end
			for i=1,endCount do
				timer = timerList[endChannel:pop()]
				if timer then
					timer.runState = false
				else
					isError.error = "end timer not seccess."
					isError.name = endTimer
				end
			end
		end
		--第三优先级：破坏计时器和创建计时器
		for i=1,addCount do
			addTimer = addChannel:pop()
			mainThreadChannel:push(addTimer) --压入值到子线程
			timerList[addTimer.name] = {}
			timer = timerList[addTimer.name]
			timer.name = addTimer.name --名字
			timer.tickTime = addTimer.tickTime --滴答时间
			timer.staTime = 0 --开始时间
			timer.Channel = love.thread.getChannel(timer.name) --通道
			timer.runState = false --运行状态
		end
		for i=1,desCount do
			timer = timerList[desChannel:pop()]
			if timer then
				timer = nil
			else
				isError.error = "destory timer not seccess."
				isError.name = desTimer
			end
		end

		if isError.name then --出错
			error("\n'"..isError.name.."' this timer is not been added.\nErrorInfo: "..isError.error)
		end
	end

]]
--计时器系统子线程代码
local timerSysSubThreadCode = [[
	
	local timer
	local setRunCountTimer,setTickTimeTimer
	local mainData
	local timerList = {}

	local setRunCount,setTickCount,getRunCount,getTickCount,mainDataCount --计数

	local isError = { error=false, name=nil } --错误

	local setCountDataChannel = love.thread.getChannel("setCountData") --设定计时器运行计数通道
	local setTickTimeChannel = love.thread.getChannel("setTickTimeData") --设定计时器滴答时间通道
	local getCountChannelFlag = love.thread.getChannel("getCountFlag") --获取计时器运行计数标记
	local getCountDataChannel = love.thread.getChannel("getCountData") --获取计时器运行计数通道
	local getTickTimeChannelFlag = love.thread.getChannel("getTickTimeFlag") --获取计时器滴答时间标记
	local getTickTimeDataChannel = love.thread.getChannel("getTickTimeData") --获取计时器滴答时间通道

	local mainThreadChannel = love.thread.getChannel("subThread")
	local subThreadChannel = love.thread.getChannel("mainThread")

	while true do
		setRunCount = setCountDataChannel:getCount()
		setTickCount = setTickTimeChannel:getCount()
		getRunCount = getCountChannelFlag:getCount()
		getTickCount = getTickTimeChannelFlag:getCount()
		mainDataCount = mainThreadChannel:getCount()
	
		--第一优先级：主线程数据处理
		for i=1,mainDataCount do
			mainData = mainThreadChannel:pop()
			if type(mainData) == "table" then
				timerList[mainData.name] = {}
				timer = timerList[mainData.name]
				timer.tickTime = mainData.tickTime
				timer.runCount = 0
			else
				timer = timerList[mainData]
				timer.runCount = timer.runCount + 1
			end
		end
		
		--第二优先级：获取数据处理
		for i=1,getRunCount do
			timer = timerList[getCountChannelFlag:pop()]
			if timer then
				getCountDataChannel:push(timer.runCount)
			else
				isError.error = "get timer tick count not seccess."
				isError.name = getCountFlag
			end
		end
		for i=1,getTickCount do
			timer = timerList[getTickTimeChannelFlag:pop()]
			if timer then
				getTickTimeDataChannel:push(timer.tickTime)
			else
				isError.error = "get timer tick not seccess."
				isError.name = getTickTimeFlag
			end
		end

		--第三优先级：设置数据处理
		for i=1,setRunCount do
			setRunCountTimer = setCountDataChannel:pop()
			timer = timerList[setRunCountTimer.name]
			if timer then
				timer.runCount = setRunCountTimer.newCount
			else
				isError.error = "set timer tick count not seccess."
				isError.name = setCount.name
			end
		end
		for i=1,setTickCount do
			setTickTimeTimer = setTickTimeChannel:pop()
			timer = timerList[setTickTimeTimer.name]
			if timer then
				subThreadChannel:push(setTickTimeTimer) --压入值到主线程
				timer.tickTime = setTickTimeTimer.tickTime
			else
				isError.error = "set timer tick time not seccess."
				isError.name = setTickTime.name
			end
		end

		if isError.name then --出错
			error("\n'"..isError.name.."' this timer is not been added.\nErrorInfo: "..isError.error)
		end
	end

]]


function timer:initTimer() --初始化计时器

	runTimerMainThread = love.thread.newThread(timerSysMainThreadCode)
	runTimerSubThread = love.thread.newThread(timerSysSubThreadCode)

	runTimerMainThread:start()
	runTimerSubThread:start()

end


function timer:addTimer(name,tickTime) --添加一个计时器（暂时不能保证精度）

	if runTimerMainThread and runTimerSubThread then
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


function timer:runTimer(dt) --计时器运行（必须使用在update回调中）

	local error

	love.thread.getChannel("getTime"):push(dt)

	error = runTimerMainThread:getError()
	assert(not error, error)
	error = runTimerSubThread:getError()
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