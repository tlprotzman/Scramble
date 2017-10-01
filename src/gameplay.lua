require "platform"
require "player"
require "avalanche"
require "fallingrock"
require "item"

Gameplay = class()

function Gameplay:_init(game)
	-- this is for the draw stack
	self.numPlayers = 2
	self.game = game
	self.players = {}
	for i = 1, self.numPlayers do
		table.insert(self.players, Player(self.game, (1920/(self.numPlayers + 1)) * i, 800, i, {math.random(1, 255), math.random(1, 255), math.random(1, 255)}))
	end
	-- uncomment this one for testing joysticks
	-- table.insert(self.players, Player(self.game, 1, {math.random(1, 255), math.random(1, 255), math.random(1, 255)}))
	self.platforms = {}
	self.avalanches = {}
	self.fallingrocks = {}
	self.items = {}
	self.itemColors = {{0, 255, 255}, {255, 0, 0}}
	
	camera.d.y = 0
	self.cameraTimer = 3
	
	self.drawUnder = false
	self.updateUnder = false

	self:generateNextChunk(1, -4)
	self:generateNextChunk(1, 1)
	self:generateNextChunk(2, 11)
	self.lastChunkGenerated = 1
	
	self.backgroundImage = love.graphics.newImage("images/assets/background.png")


	table.insert(self.platforms, Platform({x=0, y=1000, w=1920, style="wood", unbreakable=true}))

	
end

function Gameplay:load()
	-- run when the level is given control
end

function Gameplay:leave()
	-- run when the level no longer has control
end

function Gameplay:draw()

	--camera:draw(self.backgroundImage, 0, 0)
	
	for i, v in ipairs(self.platforms) do
		v:draw()
	end
	for i, v in ipairs(self.items) do
		v:draw()
	end
	for i, v in ipairs(self.players) do
		v:draw()
	end
	for i, v in ipairs(self.fallingrocks) do
		v:draw()
	end
	for i, v in ipairs(self.avalanches) do
		v:draw()
	end
	love.graphics.print(camera.pos.y, 10, 10)
end

function Gameplay:update(dt)
	self.cameraTimer = self.cameraTimer + dt
	if (self.cameraTimer > 6) then
		-- camera.d.y = 0
		camera.d.y = math.random(40, 150)
		self.cameraTimer = 0
	end

	for i, v in pairs(self.platforms) do
		v:update(dt)
	end

	for i, v in ipairs(self.players) do
		v:update(dt, self.platforms, self.players, self.avalanches, self.fallingrocks, self.items)
	end
	for i, v in ipairs(self.platforms) do
		v:update(dt)
	end
	for i, v in ipairs(self.avalanches) do
		v:update(dt)
	end
	for i, v in ipairs(self.fallingrocks) do
		v:update(dt, self.platforms)
	end

	if (camera.pos.y / self.spacing > self.lastChunkGenerated) then
		self:generateNextChunk(math.random(1, 2), self.lastChunkGenerated + 10)
		self.lastChunkGenerated = self.lastChunkGenerated + 10
	end
end

function Gameplay:resize(w, h)
	--
end

function Gameplay:handleinput(input)
	--
end

function Gameplay:generateNextChunk(mode, offset)
	if (mode == 1) then
	self.variance = 0
	self.spacing = 250
		print("HIT")
		for i=1, 10 do
			j = i - offset
			if (math.random(0, 10) < 8) then
				if math.random(1,4)==1 then
					table.insert(self.platforms, Platform({x=math.random(0, 900), y=math.random(-self.variance, self.variance) + self.spacing * j, w=400, vx = 100, rx = 1000, style="wood"}))
				else
					table.insert(self.platforms, Platform({x=math.random(0, 1720), y=math.random(-self.variance, self.variance) + self.spacing * j, w=math.random(80, 200), style="wood"}))
					table.insert(self.platforms, Platform({x=math.random(0, 1720), y=math.random(-self.variance, self.variance) + self.spacing * j, w=math.random(80, 200), style="wood"}))
				end
			end
			table.insert(self.platforms, Platform({x=math.random(0, 1720), y=math.random(-self.variance, self.variance) + self.spacing * j, w=math.random(120, 200), style="wood"}))
			-- table.insert(self.platforms, Platform(1300, 160 * i + 80, 250, "wood"))
		end
	elseif (mode == 2) then
	self.variance = 50
	self.spacing = 300
		print("HIT")
		for i=1, 10 do
			j = i - offset
			if (math.random(0, 10) < 8) then
				table.insert(self.platforms, Platform({x=math.random(0, 1720), y=math.random(-self.variance, self.variance) + self.spacing * j, w=math.random(80, 200), style="wood"}))
			end
			table.insert(self.platforms, Platform({x=math.random(0, 1720), y=math.random(-self.variance, self.variance) + self.spacing * j, w=math.random(120, 200), style="wood"}))
			-- table.insert(self.platforms, Platform(1300, 160 * i + 80, 250, "wood"))
		end
	end
	
	--table.insert(self.avalanches, Avalanche(100, 3000, 5000))
	--table.insert(self.fallingrocks, FallingRock(100, 100, 500))		
end
