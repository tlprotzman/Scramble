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
	local offset = self:getOffset(ignoreCamera)
	love.graphics.rectangle(style, x + offset.x, y + offset.y, w, h)
end

function Camera:circle(style, x, y, r, ignoreCamera)
	local offset = self:getOffset(ignoreCamera)
	love.graphics.circle(style, x + offset.x, y + offset.y, r)
end

function Camera:arc(style, style2, x, y, r, angle1, angle2, ignoreCamera)
	local offset = self:getOffset(ignoreCamera)
	love.graphics.arc(style, style2, x + offset.x, y + offset.y, r, angle1, angle2)
end

function Camera:draw(drawable, x, y, flip, scale, ignoreCamera)
	local offset = self:getOffset(ignoreCamera)
	if not flip or sign(flip)==1 then
		love.graphics.draw(drawable, x + offset.x, y + offset.y, 0, 1 or scale, 1 or scale)
	else
		love.graphics.draw(drawable, x + offset.x + drawable:getWidth() , y + offset.y, 0, -1*(1 or scale), 1 or scale)
	end
end

function Camera:getOffset(ignoreCamera)
	local x, y = self.pos.x, self.pos.y
	if ignoreCamera then
		x, y = 0, 0
	end
	return {x = x, y = y}
end