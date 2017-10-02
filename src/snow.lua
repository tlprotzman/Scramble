Snow = class()

function Snow:_init(x, y)
	self.x = x
	self.y = y
	self.s = 0
	self.image = images.snowballImage
end

function Snow:draw()
	love.graphics.setColor(255, 255, 255, 255-self.s*25)
	camera:draw(self.image, self.x, self.y, 1, 0.03*self.s)
end

function Snow:update(dt)
	self.s = self.s+math.random(1, 10)*dt
	if self.s > 10 then
		self.dead = true
	end
end