require "platform"
require "player"

Gameplay = class()

function Gameplay:_init(game)
	-- this is for the draw stack
	self.game = game
	self.players = {}
	for i = 1, 2 do
		table.insert(self.players, Player(self.game, "k"..i, {math.random(1, 255), math.random(1, 255), math.random(1, 255)}))
	end
	-- uncomment this one for testing joysticks
	-- table.insert(self.players, Player(self.game, 1, {math.random(1, 255), math.random(1, 255), math.random(1, 255)}))
	self.platforms = {}
	
	camera.d.y = 0
	self.cameraTimer = 3
	
	self.drawUnder = false
	self.updateUnder = false
	for i = -100, 6 do
		if (math.random(0, 10) < 8) then
			table.insert(self.platforms, Platform(math.random(0, 1800), math.random(-40, 40) + 160 * i, math.random(100, 500), "wood"))
		end
		table.insert(self.platforms, Platform(math.random(0, 1800), math.random(-40, 40) + 160 * i, math.random(100, 500), "wood"))
		-- table.insert(self.platforms, Platform(1300, 160 * i + 80, 250, "wood"))
	end
end

function Gameplay:load()
	-- run when the level is given control
end

function Gameplay:leave()
	-- run when the level no longer has control
end

function Gameplay:draw()

	camera:rectangle("fill", 100, 100, 100, 100)
	
	for i, v in ipairs(self.platforms) do
		v:draw()
	end
	for i, v in ipairs(self.players) do
		v:draw()
	end
	love.graphics.print(camera.pos.y, 10, 10)
end

function Gameplay:update(dt)
	self.cameraTimer = self.cameraTimer + dt
	if (self.cameraTimer > 6) then
		camera.d.y = math.random(40, 150)
		self.cameraTimer = 0
	end

	for i, v in pairs(self.platforms) do
		v:update(dt)
	end

	for i, v in ipairs(self.players) do
		v:update(dt, self.platforms)
	end
end

function Gameplay:resize(w, h)
	--
end

function Gameplay:handleinput(input)
	--
end