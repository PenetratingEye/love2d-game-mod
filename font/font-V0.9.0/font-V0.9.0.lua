local font = {}


function font:initFont()

	fontTable = {}

end


function font:addFont(name,path)
	
	fontTable[name] = {}
	fontTable[name].font = {}
	for size=1,32 do
		fontTable[name].font[size] = love.graphics.setNewFont(path,size)
	end

end


function font:printf(text,x,y,name,size,...)
	
	local color = ... or {255,255,255}

	if color then
		love.graphics.setColor(color[1],color[2],color[3])
	end

	love.graphics.setFont(fontTable[name].font[size])
	love.graphics.print(text,x,y)
	love.graphics.setColor(255,255,255)

end


return font