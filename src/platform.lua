Platform = class()

function Platform:_init(args)
	self.pos = {x = args.x, y = args.y}
	self.vel = {x = args.vx or 0, y = args.vy or 0}
	self.startPos = {x = args.x, y = args.y}
	self.range = {x = args.rx or 0, y = args.ry or 0}
	self.w = args.w
	self.h = 30
	self.style = args.style
end

function Platform:draw(x, y, w, style)
	love.graphics.setColor(100, 100, 100)
	camera:rectangle("fill", self.pos.x, self.pos.y, self.w, self.h)
end

function Platform:update(dt)
	self.pos.x = self.pos.x + self.vel.x*dt
	self.pos.y = self.pos.y + self.vel.y*dt
	if self.pos.x < self.startPos.x or self.pos.x > self.startPos.x + self.range.x then
		self.vel.x = - self.vel.x
	end
	if self.pos.y < self.startPos.y or self.pos.y > self.startPos.y + self.range.y then
		self.vel.y = - self.vel.y
	end
end