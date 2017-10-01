Movement = class()


function Movement:_init(_x, _y, _acceleration, _maxDX)
	self.gravity = 2000


	self.pos = {x = _x, y = _y}
	self.vel = {dx = 0, dy = 0}
	self.maxDX = _maxDX
	self.acceleration = _acceleration
	self.friction = 0.2

	self.onGround = false
	self.onSolidGround = false
	self.maxJumpTime = 0.4
	self.jumpTimer = 0

end

function Movement:setFriction(value)
	self.friction = value
end

function Movement:xMove(dt, xScaler)
	ddx = xScaler * self.acceleration
	self.vel.dx = self.vel.dx + ddx * dt
	if (self.onGround and (math.abs(xScaler) < 0.05 or xScaler * self.vel.dx < 0)) then
		self.vel.dx = self.vel.dx - self.vel.dx * self.friction
	end
	if (self.vel.dx > self.maxDX) then
		self.vel.dx = self.maxDX
	end
	self.pos.x = self.pos.x + self.vel.dx * dt
end

function Movement:yMove(dt, jumping)
	-- print(self.jumpTimer)
	if (jumping) then
		self.onGround = false
		self.jumpTimer = self.jumpTimer + dt
		if (self.onGround or self.jumpTimer < self.maxJumpTime) then
			self.vel.dy = -800*((self.maxJumpTime-self.jumpTimer+self.maxJumpTime*3)/(self.maxJumpTime*4)) -- this tries to reduce the "double jump feeling"
			-- one attempted thing: -500*((self.maxJumpTime-self.jumpTimer+self.maxJumpTime*.999)/(self.maxJumpTime*1.999))
		end
	end
	
	if (not jumping and not self.onGround) then
		self.jumpTimer = self.maxJumpTime
	end

	if (self.onGround) then 
		self.jumpTimer = 0
	end
	
	self.vel.dy = self.vel.dy + self.gravity * dt
	self.pos.y = self.pos.y + self.vel.dy * dt
end

function Movement:move(dt, xScaler, jumping, onGround)
	self:xMove(dt, xScaler)
	self:yMove(dt, jumping)
end

function Movement:collisions(elements, size, dt)
	
	self.onGround = false
	self.onSolidGround = false
	
	for i, v in pairs(elements) do
		if (self.pos.x + size.width > v.pos.x and self.pos.x < v.pos.x + v.w) then
			if (not v.broken and self.pos.y + size.height < v.pos.y + 10 and self.pos.y + size.height + self.vel.dy * dt > v.pos.y) then
				-- print(self.pos.y)
			-- if (self.pos.y < v.pos.y and self.pos.y + self.vel.dy > v.pos.y) then
				self.pos.y = v.pos.y - size.height
				self.vel.dy = 0
				self.onGround = true
			end 
		end
	end			

	if (self.pos.y + size.height > love.graphics.getHeight()) then
		self.pos.y = love.graphics.getHeight() - size.height
		self.vel.dy = 0
		self.onGround = true
		self.onSolidGround = true
	end
	-- print(self.pos.x)
	if (self.pos.x < 0) then
		self.pos.x = 0
		self.vel.dx = 0
	end
	if (self.pos.x + size.width > love.graphics.getWidth()) then
		self.pos.x = love.graphics.getWidth() - size.width
		self.vel.dx = 0
	end
end