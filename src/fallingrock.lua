FallingRock = class()

function FallingRock:_init(x, y, vx, vy, s)
	self.x = x
	self.y = y
	self.vx = vx
	self.vy = vy or 0
	self.s = s or 100
	self.gravity = 2000
end

function FallingRock:draw()
	love.graphics.setColor(100, 100, 100)
	camera:circle("fill", self.x, self.y, self.s)
end

function FallingRock:update(dt, platforms)
	self.vy = self.vy + self.gravity*dt
	for i, v in ipairs(platforms) do
		if self.x + self.s > v.pos.x and self.x < v.pos.x + v.w then
			if self.y + self.s < v.pos.y and self.y + self.s + self.vy > v.pos.y then
				self.vy = -self.vy
			end
		end
	end
	self.x = self.x + self.vx*dt
	self.y = self.y + self.vy*dt
end