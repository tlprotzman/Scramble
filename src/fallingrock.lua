FallingRock = class()

function FallingRock:_init(x, y, vx, vy, s)
	self.x = x
	self.y = y
	self.vx = vx
	self.vy = vy or 0
	self.s = s or 100
	self.gravity = 2000
	self.image = love.graphics.newImage("images/assets/boulder.png")
end

function FallingRock:draw()
	--love.graphics.setColor(100, 100, 100)
	--camera:circle("fill", self.x, self.y, self.s)
	love.graphics.setColor(255, 255, 255)
	camera:draw(self.image, self.x, self.y)
end

function FallingRock:update(dt, platforms, players)
	self.vy = self.vy + self.gravity*dt
	for i, v in ipairs(platforms) do
		if self.x + self.s > v.pos.x and self.x - self.s < v.pos.x + v.w then
			if self.y + self.s < v.pos.y + 10 and self.y + self.s + self.vy*dt > v.pos.y then
				self.vy = -4*math.abs(self.vy)/5
				self.y = v.pos.y - self.s
			end
		end
	end
	
	if self.y + self.s > love.graphics.getHeight() then
		self.vy = -4*math.abs(self.vy)/5
		self.y = love.graphics.getHeight() - self.s
	end
	if self.x - self.s < 0 then
		self.vx = -self.vx
		self.x = self.s
	elseif self.x + self.s > love.graphics.getWidth() then
		self.vx = -self.vx
		self.x = love.graphics.getWidth() - self.s
	end
	if math.abs(self.vy) < self.gravity*dt then
		self.vy = 0
	end
	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
end