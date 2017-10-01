Platform = class()

function Platform:_init(x, y, w, style)
	self.pos = {x = x, y = y}
	self.w = w
	self.h = 30
	self.style = style
	self.breaking = false
	self.broken = false
	self.brokenTimer = 0
	self.timeToBreak = 1
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
end

function Platform:update(dt)
	if (self.breaking) then
		self.brokenTimer = self.brokenTimer + dt
		if (self.brokenTimer > self.timeToBreak) then
			self.broken = true
			self.breaking = false
		end

	elseif (self.pos.y > -camera.pos.y + love.graphics.getHeight() / 2) then
		print(self.pos.y)
		if (math.random() < 0.001) then
			self.breaking = true
		end
	end
end