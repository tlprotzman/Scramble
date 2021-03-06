Avalanche = class()

function Avalanche:_init(x, duration, delay)
	self.x = x
	self.progress = -3000 - (delay or 0) - camera.pos.y
	self.w = 600
	self.duration = duration
	self.snow = {}
end

function Avalanche:draw()
	love.graphics.setColor(200, 200, 200, 245)
	--camera:rectangle("fill", self.x, self.progress, self.w, self.duration, true)

	love.graphics.setColor(255, 255, 255, 150)
	--camera:rectangle("fill", self.x, self.progress, self.w, self.duration)
	for i, v in ipairs(self.snow) do
		love.graphics.setColor(255, 255, 255, math.max(0, 255-v.size))
		camera:draw(imageManager:getImage("snowball"), v.x, v.y + self.progress, v.size)
		--[[
		camera:circle("fill", v.x, v.y + self.progress, v.size)
		love.graphics.setColor(100, 100, 100, math.max(0, 255-v.size))
		camera:arc("line", "open", v.x, v.y + self.progress, v.size, 0, math.pi) ]]--
	end
end

function Avalanche:update(dt)
	if not self.startedSound and self.progress + self.duration + 2000 > camera.pos.y then
		self.startedSound = true
		soundManager:playSound("avalanche")
	end
	if self.progress < 1800 then
		self.progress = self.progress + 2000*dt
		for i = 1, 3 do 
			table.insert(self.snow, {x=math.random(self.x-250, self.x+self.w-250), y=math.random(0, self.duration), size=0})
		end
		for i, v in ipairs(self.snow) do
			v.size = v.size + 10
			if v.size > 255 then
				table.remove(self.snow, i)
			end
		end
	else
		self.dead = true
	end
end