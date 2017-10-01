Avalanche = class()

function Avalanche:_init(x, duration, delay)
	self.x = x
	self.progress = -3000 - (delay or 0)
	self.w = 600
	self.duration = duration
	self.snow = {}
end

function Avalanche:draw()
	love.graphics.setColor(200, 200, 200, 245)
	--camera:rectangle("fill", self.x, self.progress, self.w, self.duration, true)
	for i, v in ipairs(self.snow) do
		love.graphics.setColor(220, 220, 220, math.max(0, 255-v.size))
		camera:circle("fill", v.x, v.y + self.progress, v.size)
		love.graphics.setColor(100, 100, 100, math.max(0, 255-v.size))
		love.graphics.arc("line", "open", v.x, v.y + self.progress, v.size, 0, math.pi)
	end
end

function Avalanche:update(dt)
	self.progress = self.progress + 2000*dt
	for i = 1, 10 do
		table.insert(self.snow, {x=math.random(self.x, self.w), y=math.random(0, self.duration), size=0})
	end
	for i, v in ipairs(self.snow) do
		v.size = v.size + 10
		if v.size > 255 then
			table.remove(self.snow, i)
		end
	end
end