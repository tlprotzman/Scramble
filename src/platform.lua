Platform = class()

function Platform:init(x, y, w, style)
	self.pos = {x = x, y = y}
	self.w = w
	self.h = h
	self.style = style
end

function Platform:draw(x, y, w, style)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end