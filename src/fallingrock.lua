FallingRock = class()

function FallingRock:_init(x, y, vx, vy, s)
	self.x = x
	self.y = y
	self.vx = vx
	self.vy = vy or 0
	self.s = s or 100
	self.gravity = 2000
	self.angle = 0
	self.image = love.graphics.newImage("images/assets/boulder.png")
end

function FallingRock:draw()
--	love.graphics.setColor(100, 100, 100)
--	camera:circle("fill", self.x, self.y, self.s)
	love.graphics.setColor(255, 255, 255)
	camera:draw(self.image, self.x - self.s/2, self.y - self.s/2, 1, 1, self.angle)
end

function FallingRock:update(dt, platforms, players)
	self.vy = self.vy + self.gravity*dt

	for i, v in ipairs(platforms) do
		if self.x + self.s > v.pos.x and self.x - self.s < v.pos.x + v.w then
			if self.y + self.s < v.pos.y + 10 and self.y + self.s + self.vy*dt > v.pos.y then
				self.vy = -4*math.abs(self.vy)/5
				self.y = v.pos.y - self.s
				if self.y < -camera.pos.y + 1200 then
					soundManager:playSound("thud")
				end
			end
		end
	end
	
	if self.y + self.s > 1080 then
		self.vy = -4*math.abs(self.vy)/5
		self.y = 1080 - self.s
	end
	if self.x < 0 then
		self.vx = -self.vx
		self.x = 0
	elseif self.x + self.s > 1920 then
		self.vx = -self.vx
		self.x = 1920 - self.s
	end
	if math.abs(self.vy) < self.gravity*dt then
		self.vy = 0
	end
	
	self.angle = self.angle + .1
	if self.angle > math.pi*2 then
		self.angle = 0
	end
	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
end