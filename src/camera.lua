Camera = class()

function Camera:_init()
	self.pos = {x = 0, y = 0}
	self.d = {x = 0, y = 0}
end

function Camera:update(dt)
	self.pos.x = math.ceil(self.pos.x + self.d.x*dt)
	self.pos.y = math.ceil(self.pos.y + self.d.y*dt)
end

function Camera:rectangle(style, x, y, w, h, ignoreCamera)
	local offX, offY = self.pos.x, self.pos.y
	if ignoreCamera then
		offX, offY = 0, 0
	end
	love.graphics.rectangle(style, x + offX, y + offY, w, h)
end