Movement = class()


function Movement:_init(_x, _y, _acceleration, _maxDX)
	self.gravity = 2000

	self.floatingJumpAllowance = .1 -- the amount of time after someone falls off of a platform that they're still allowed to jump
	self.floatingJumpTimer = 0

	self.pos = {x = _x, y = _y}
	self.vel = {dx = 0, dy = 0}
	self.maxDX = _maxDX
	self.acceleration = _acceleration
	self.friction = 0.2
	self.hangingSpeed = 200

	self.facing = 1
	self.onGround = false
	self.onSolidGround = false
	self.hanging = false
	self.maxJumpTime = 0.4
	self.jumpTimer = 0
	self.climbUpTimer = 0
	self.shimmyFrame = 1
	self.noGrab = 0

	self.carrier = false -- this is either false or the player that is carrying it...
	self.thrown = false -- if this is the case, there is no limit on max dx or dy until you hit something, to allow for super fast throws

end

function Movement:setFriction(value)
	self.friction = value
end

function Movement:xMove(dt, xScaler)
	if self.carrier then
		-- move with the carrier
		self.pos.x = self.carrier.move.pos.x
		self.vel.dx = self.carrier.move.vel.dx
		return
	end

	if (xScaler > 0) then
		self.facing = 1
	elseif (xScaler < 0) then
		self.facing = -1
	end

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
		local ddx = xScaler * self.acceleration
		if (not self.onGround) then
			xScaler = xScaler * 1.3
		end
		self.vel.dx = self.vel.dx + ddx * dt
		if (self.onGround and (math.abs(xScaler) < 0.05 or xScaler * self.vel.dx < 0)) then
			self.vel.dx = self.vel.dx - self.vel.dx * self.friction
		end
		if (math.abs(self.vel.dx) > self.maxDX and not self.thrown) then
			self.vel.dx = sign(self.vel.dx)*self.maxDX
		elseif math.abs(self.vel.dx) < 0.1 then
			self.vel.dx = 0
		end
	end


	self.pos.x = self.pos.x + self.vel.dx * dt
end

function Movement:yMove(dt, jumping)
	if self.carrier then
		-- you're being carried unless you spam the jump button
		self.thrown = false
		self.pos.y = self.carrier.move.pos.y - 100
		self.vel.dy = self.carrier.move.vel.dy
		return
	end
	-- print(self.jumpTimer)
	if (self.climbUpTimer > 12) then
		self.climbUpTimer = 0
		self.pos.x = self.pos.x + 25
		if self.facing == -1 then
			self.pos.x = self.pos.x - 65
		end
		self.pos.y = self.pos.y - 200
	end

	if ((jumping and self.hanging) or self.climbUpTimer > 0) then
		self.climbUpTimer = self.climbUpTimer + 10*dt
		return
	end

	if (self.onGround) then 
		self.jumpTimer = 0
		self.floatingJumpTimer = 0
	end

	if (jumping) then
		self.jumpTimer = self.jumpTimer + dt
		if (self.onGround or (self.floatingJumpTimer < self.floatingJumpAllowance) or self.jumpTimer < self.maxJumpTime) then
			if not self.playedJumpSound then
				soundManager:playSound("grunt")
				self.playedJumpSound = true
			end
			self.vel.dy = -800*((self.maxJumpTime-self.jumpTimer+self.maxJumpTime*3)/(self.maxJumpTime*4)) -- this tries to reduce the "double jump feeling"
			-- one attempted thing: -500*((self.maxJumpTime-self.jumpTimer+self.maxJumpTime*.999)/(self.maxJumpTime*1.999))
			self.floatingJumpTimer = self.floatingJumpAllowance -- no longer allowed to jump
		end
		self.onGround = false
	else
		self.playedJumpSound = false
	end
	
	if (not jumping and not self.onGround) then
		self.jumpTimer = self.maxJumpTime
	end

	self.floatingJumpTimer = self.floatingJumpTimer + dt -- this allows the player to jump in mid-air after they just fell off of a platform


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

function Movement:collisions(elements, size, allowedToHang, dt)
	
	self.onGround = false
	self.onSolidGround = false
	if (self.climbUpTimer == 0) then
		self.onPlatform = false
	end
	local wasHanging = self.hanging
	self.hanging = false
	
	for i, v in pairs(elements) do
		if (not v.broken and self.pos.x + size.width > v.pos.x and self.pos.x < v.pos.x + v.w) then
			if ( self.pos.y + size.height < v.pos.y + 10 and self.pos.y + size.height + self.vel.dy * dt > v.pos.y) then			--not v.broken and
				-- print(self.pos.y)
			-- if (self.pos.y < v.pos.y and self.pos.y + self.vel.dy > v.pos.y) then
				self.pos.y = v.pos.y - size.height
				self.vel.dy = 0
				self.onGround = true
				self.thrown = false
				self.onPlatform = v
			
			-- Code to check for hanging conditions
			elseif (not v.broken and allowedToHang and self.noGrab == 0 and self.vel.dy > 10  and self.pos.y  < v.pos.y + 40 and self.pos.y + self.vel.dy * dt > v.pos.y + 30) then
				-- print(self.pos.y)
			-- if (self.pos.y < v.pos.y and self.pos.y + self.vel.dy > v.pos.y) then
				self.pos.y = v.pos.y + 30
				self.vel.dy = 0
				self.hanging = true
				self.onPlatform = v
			elseif wasHanging and not v.broken and self.noGrab == 0 and self.pos.y  < v.pos.y + 40 and self.pos.y + self.vel.dy * dt > v.pos.y + 30 then
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
		self.thrown = false
		self.onSolidGround = true
	end
	-- print(self.pos.x)
	if (self.pos.x < 0) then
		self.pos.x = 0
		self.vel.dx = 0
		self.thrown = false
	end
	if (self.pos.x + size.width > 1920) then
		self.pos.x = 1920 - size.width
		self.vel.dx = 0
		self.thrown = false
	end
end