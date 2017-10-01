Alert = class()

function Alert:_init(xPos, duration)
	self.xPos = xPos
	self.duration = duration
	self.timer = 0
	self.images = {}
	for i=1, 3 do
		self.images[i] = love.graphics.newImage("images/assets/danger"..i..".png")
	end
end

function Alert:update(dt)
	self.timer = self.timer + dt
	if (self.timer > self.duration) then
		return false
	end
	return true
end

function Alert:draw()
	camera:draw(self.images[(math.floor(10 * self.timer)) % 3 + 1], self.xPos, 50, 1, 1, 0, true)
end