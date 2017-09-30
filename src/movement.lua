require "class"

Movement = class()

function Movement:_init(_x, _y, _acceleration, _maxDX)
	self.gravity = 9.8


	self.pos = {x = _x, y = _y}
	self.vel = {dx = 0, dy = 0}
	self.maxDX = _maxDX
	self.acceleration = _acceleration

end

function Movement:move(dt, xScaler)
	ddx = xScaler * self.acceleration
	self.vel.dx += ddx * dt
	if (self.vel.dx > self.maxDX)
		self.vel.dx = self.maxDX
	end
	self.pos.x += self.vel.dx * dt
end