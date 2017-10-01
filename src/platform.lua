Platform = class()

function Platform:_init(x, y, w, style)
	self.pos = {x = x, y = y}
	self.w = w
	self.h = 10
	self.style = style
end

function Platform:draw(x, y, w, style)
	camera:rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
end