Item = class()

function Item:_init(x, y, itemType, colors)
	self.x = x
	self.y = y
	self.w = 50
	self.h = 50
	self.colors = colors
	self.itemType = itemType
end

function Item:draw()
	love.graphics.setColor(unpack(self.colors[self.itemType]))
	camera:rectangle("fill", self.x, self.y, self.w, self.h)
end