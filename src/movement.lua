Movement = class()

SCREENHEIGHT = love.graphics.getHeight()

function Movement:_init(_x, _y, _acceleration, _maxDX)
	self.gravity = 9.8


	self.pos = {x = _x, y = _y}
	self.vel = {dx = 0, dy = 0}
	self.maxDX = _maxDX
	self.acceleration = _acceleration
	self.friction = 0.01

end

function Movement:move(dt, xScaler)
	ddx = xScaler * self.acceleration
	self.vel.dx = self.vel.dx + ddx * dt - self.vel.dx * self.friction
	if (self.vel.dx > self.maxDX) then
		self.vel.dx = self.maxDX
	end
	self.pos.x = self.pos.x + self.vel.dx * dt
	print(self.pos.x)
end

function Movement:collisions(elements, size)
	if (self.pos.y < SCREENHEIGHT) then
		self.pos.y = SCREENHEIGHT
		self.pos.dy = SCREENHEIGHT
	end

end