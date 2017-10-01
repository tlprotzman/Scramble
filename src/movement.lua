Movement = class()


function Movement:_init(_x, _y, _acceleration, _maxDX)
	self.gravity = 2000


	self.pos = {x = _x, y = _y}
	self.vel = {dx = 0, dy = 0}
	self.maxDX = _maxDX
	self.acceleration = _acceleration
	self.friction = 0.2
	self.hangingSpeed = 200

	self.onGround = false
	self.onSolidGround = false
	self.hanging = false
	self.maxJumpTime = 0.4
	self.jumpTimer = 0
	self.climbUpTimer = 0
	self.shimmyFrame = 1
	self.noGrab = 0

end

function Movement:setFriction(value)
	self.friction = value
end

function Movement:xMove(dt, xScaler)

	if (self.climbUpTimer > 0) then
		xScaler = 0
		self.vel.dx = 0
	end


	if (self.hanging) then
		self.vel.dx = xScaler * self.hangingSpeed
		self.shimmyFrame = self.shimmyFrame + zsign(xScaler)*.2
		if self.shimmyFrame < 1 then
			self.shimmyFrame = 5.9
		elseif self.shimmyFrame >= 6 then
			self.shimmyFrame = 1
		end
	else
		ddx = xScaler * self.acceleration
		if (not self.onGround) then
			xScaler = xScaler * 1.3
		end
		self.vel.dx = self.vel.dx + ddx * dt
		if (self.onGround and (math.abs(xScaler) < 0.05 or xScaler * self.vel.dx < 0)) then
			self.vel.dx = self.vel.dx - self.vel.dx * self.friction
		end
		if (self.vel.dx > self.maxDX) then
			self.vel.dx = self.maxDX
		elseif math.abs(self.vel.dx) < 0.1 then
			self.vel.dx = 0
		end
	end
	
	self.pos.x = self.pos.x + self.vel.dx * dt
end

function Movement:yMove(dt, jumping)
	-- print(self.jumpTimer)
	if (self.climbUpTimer > 12) then
		self.climbUpTimer = 0
		self.pos.x = self.pos.x + 50
	end

	if ((jumping and self.hanging) or self.climbUpTimer > 0) then
		self.pos.y = self.pos.y - 3
		self.climbUpTimer = self.climbUpTimer + 10*dt
		return
	end


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
	

	if (self.onGround and self.onPlatform) or (self.hanging and self.onPlatform) or (self.climbUpTimer > 0 and self.onPlatform) then
		self.pos.x = self.pos.x + self.onPlatform.vel.x*dt*2
		self.pos.y = self.pos.y + self.onPlatform.vel.y*dt*2

	end
end

function Movement:collisions(elements, size, dt)
	
	self.onGround = false
	self.onSolidGround = false
	if (self.climbUpTimer == 0) then
		self.onPlatform = false
	end
	self.hanging = false
	
	for i, v in pairs(elements) do
		if (not v.broken and self.pos.x + size.width > v.pos.x and self.pos.x < v.pos.x + v.w) then
			if ( self.pos.y + size.height < v.pos.y + 10 and self.pos.y + size.height + self.vel.dy * dt > v.pos.y) then			--not v.broken and
				-- print(self.pos.y)
			-- if (self.pos.y < v.pos.y and self.pos.y + self.vel.dy > v.pos.y) then
				self.pos.y = v.pos.y - size.height
				self.vel.dy = 0
				self.onGround = true
				self.onPlatform = v
			
			-- Code to check for hanging conditions
			elseif (not v.broken and self.noGrab == 0 and self.vel.dy > 10  and self.pos.y  < v.pos.y + 40 and self.pos.y + self.vel.dy * dt > v.pos.y + 30) then
				-- print(self.pos.y)
			-- if (self.pos.y < v.pos.y and self.pos.y + self.vel.dy > v.pos.y) then
				self.pos.y = v.pos.y + 30
				self.vel.dy = 0
				self.hanging = true
				self.onPlatform = v
			end 
		end
	end			

	if (self.pos.y + size.height > 1080) then
		self.pos.y = 1080 - size.height
		self.vel.dy = 0
		self.onGround = true
		self.onSolidGround = true
	end
	-- print(self.pos.x)
	if (self.pos.x < 0) then
		self.pos.x = 0
		self.vel.dx = 0
	end
	if (self.pos.x + size.width > 1920) then
		self.pos.x = 1920 - size.width
		self.vel.dx = 0
	end
end