Platform = class()

function Platform:_init(args)
	self.pos = {x = args.x, y = args.y - args.y0}
	self.vel = {x = args.vx or 0, y = args.vy or 0}
	self.startPos = {x = args.x, y = args.y - args.y0}
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
	self.gearFrame = 1
	
	self.image = love.graphics.newImage("images/assets/platform"..self.w..".png")
	
	if self.w == 200 then
		self.gearImage = {}
		for i = 1, 4 do
			self.gearImage[i] = love.graphics.newImage("images/assets/gear"..i..".png")
		end
	end
end

function Platform:draw(x, y, w, style)
	camera:rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
	love.graphics.setColor(255, 255, 255)
	camera:draw(self.image, self.pos.x, self.pos.y)
end

function Platform:drawGears(x, y, w, style)
	if self.w == 200 then
		love.graphics.setColor(0, 0, 0)
		love.graphics.setLineWidth(3)
		camera:line(self.startPos.x + 100, self.startPos.y + 25, self.startPos.x + 100 + (self.range.x or 0), self.startPos.y + 25 + (self.range.y or 0))
		love.graphics.setColor(255, 255, 255)
		camera:draw(self.gearImage[math.floor(self.gearFrame)], self.startPos.x + 75, self.startPos.y)
		camera:draw(self.gearImage[math.floor(self.gearFrame)], self.startPos.x + 75 + (self.range.x or 0), self.startPos.y + (self.range.y or 0))
	end
end

function Platform:update(dt)

	self.pos.x = self.pos.x + self.vel.x*dt
	self.pos.y = self.pos.y + self.vel.y*dt
	if not self.unbounded then
		if self.pos.x < self.startPos.x or self.pos.x > self.startPos.x + self.range.x then
			self.vel.x = - self.vel.x
		end
		if self.pos.y < self.startPos.y or self.pos.y > self.startPos.y + self.range.y then
			self.vel.y = - self.vel.y
		end
	end
	self.gearFrame = self.gearFrame + 10*dt
	if self.gearFrame >= 5 then
		self.gearFrame = 1
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