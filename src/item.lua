Item = class()

function Item:_init(x, y, itemType)
	self.x = x
	self.y = y
	self.w = 50
	self.h = 50
	self.itemType = itemType
	if self.itemType == 1 then
		self.image = love.graphics.newImage("images/assets/pickaxe.png")
	else
		self.image = love.graphics.newImage("images/assets/megaphone.png")
	end	
end

function Item:draw()
	camera:draw(self.image, self.x, self.y)
end