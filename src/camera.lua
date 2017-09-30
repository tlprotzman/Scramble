Camera = class()

function Camera:_init()
	self.pos = {x = 0, y = 0}
	self.d = {x = 0, y = 0}
end

function Camera:update(dt)
	self.pos.x = math.ceil(self.pos.x + self.d.x*dt)
	self.pos.y = math.ceil(self.pos.y + self.d.y*dt)
end

function Camera:rectangle(style, x, y, w, h, ignoreCamera)
	local offset = getOffset(ignoreCamera)
	love.graphics.rectangle(style, x + offset.x, y + offset.y, w, h)
end

function Camera:draw(drawable, x, y, flip, ignoreCamera)
	local offset = getOffset(ignoreCamera)
	if not flip then
		love.graphics.draw(drawable, x + offset.x, y + offset.y)
	else
		love.graphics.draw(drawable, x + offset.x, y + offset.y, 0, -1, 1)
	end
end

function Camera:getOffset(ignoreCamera)
	local x, y = self.pos.x, self.pos.y
	if ignoreCamera then
		x, y = 0, 0
	end
	return {x = x, y = y}
end