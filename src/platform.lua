Platform = class()

function Platform:_init(args)
	self.pos = {x = args.x, y = args.y}
	self.vel = {x = args.vx or 0, y = args.vy or 0}
	self.startPos = {x = args.x, y = args.y}
	self.range = {x = args.rx or 0, y = args.ry or 0}
	self.w = args.w
	self.h = 30
	self.style = args.style
	self.unbounded = args.unbounded

	self.breaking = false
	self.unbreakable = args.unbreakable
	self.broken = false
	self.brokenTimer = 0
	self.timeToBreak = 1
	
	self.image = love.graphics.newImage("images/assets/platform"..self.w..".png")
end

function Platform:draw(x, y, w, style)
	if (self.broken) then
		love.graphics.setColor(0, 0, 0)
	elseif (self.breaking) then
		love.graphics.setColor(250, 100, 100)
	else
		love.graphics.setColor(100, 100, 100)
	end
	camera:rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
	love.graphics.setColor(255, 255, 255)
	camera:draw(self.image, self.pos.x, self.pos.y)
end

function Platform:update(dt)

	self.pos.x = self.pos.x + self.vel.x*dt
	self.pos.y = self.pos.y + self.vel.y*dt
	if not self.unbouned then
		if self.pos.x < self.startPos.x or self.pos.x > self.startPos.x + self.range.x then
			self.vel.x = - self.vel.x
		end
		if self.pos.y < self.startPos.y or self.pos.y > self.startPos.y + self.range.y then
			self.vel.y = - self.vel.y
		end
	end
	
	--[[
	if (self.breaking) then
		self.brokenTimer = self.brokenTimer + dt
		if (self.brokenTimer > self.timeToBreak) then
			self.broken = true
			self.breaking = false
		end

	elseif (self.pos.y > -camera.pos.y + love.graphics.getHeight() / 2) then
		-- print(self.pos.y)
		if (math.random() < 0.001 and not self.unbreakable) then
			self.breaking = true
		end
	end
	
	 ]]--
end