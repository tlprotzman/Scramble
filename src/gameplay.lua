require "platform"
require "snow"
require "player"
require "avalanche"
require "fallingrock"
require "item"
require "alert"

Gameplay = class()

function Gameplay:_init(game, inplayers)
	-- this is for the draw stack
	self.numPlayers = 2
	self.game = game
	self.players = {}
	if inplayers then
		for i, v in ipairs(inplayers) do
			table.insert(self.players, Player(self.game, (1920/ (#inplayers + 1))*i, 800, v.uid, v.color))
		end
	else
		for i = 1, self.numPlayers do
			table.insert(self.players, Player(self.game, (1920/(self.numPlayers + 1)) * i, 800, "k"..i, {math.random(1, 255), math.random(1, 255), math.random(1, 255)}))
		end
		-- uncomment this one for testing joysticks
		-- table.insert(self.players, Player(self.game, 1, {math.random(1, 255), math.random(1, 255), math.random(1, 255)}))
	end
	self.platforms = {}
	self.avalanches = {}
	self.fallingrocks = {}
	self.items = {}
	self.snowballs = {}
	self.alerts = {}
	self.itemColors = {{0, 255, 255}, {255, 0, 0}}
	self.gameOver = false
	
	camera.d.y = 0
	self.cameraTimer = 1
	self.standingNames = {"1st", "2nd", "3rd", "4th", "5th", "6th", "7th", "8th"}
	self.standings = {}
	
	self.drawUnder = false
	self.updateUnder = false
	
	self.platformSizes = {280, 500, 200}

	self.backgroundImage = love.graphics.newImage("images/assets/background.png")

	self.dayLightColor = {255, 200, 100, 30}
	self.targetColors = {{255, 255, 255, 40}, {255, 50, 50, 50}, {50, 50, 50, 100}, {255, 255, 50, 40}}
	self.targetColor = 1

	self.eventTimer = 0
	self.eventSpacing = 15 
	
	--table.insert(self.items, Item(900, 600, 2, self.itemColors))
	--table.insert(self.items, Item(1340, 200, 1, self.itemColors))
	
	self.chunkCount = 0
	self:generateNextChunk()

--	table.insert(self.platforms, Platform({x=0, y=1000, w=1920, style="wood", unbreakable=true}))

	
end

function Gameplay:load()
	-- run when the level is given control
	soundManager:stopSound("titlemusic")
end

function Gameplay:leave()
	-- run when the level no longer has control
end

function Gameplay:draw()

	love.graphics.setColor(220, 255, 240, 90)
	camera:draw(self.backgroundImage, 0, camera.pos.y%1080, 1, 1, 0, true)
	camera:draw(self.backgroundImage, 0, camera.pos.y%1080-1080, 1, 1, 0, true)
	
	love.graphics.setColor(255, 255, 255)
	for i, v in ipairs(self.platforms) do
		v:drawGears()
	end
	for i, v in ipairs(self.platforms) do
		v:draw()
	end
	for i, v in ipairs(self.snowballs) do
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
	for i, v in ipairs(self.alerts) do
		v:draw()
	end
	
	love.graphics.setColor(self.dayLightColor[1], self.dayLightColor[2], self.dayLightColor[3], self.dayLightColor[4])
	camera:rectangle("fill", 0, 0, 1920, 1820, true)
	
	if #self.players <=1 then
		for i, v in ipairs(self.standings) do
			if i==1 then
				love.graphics.setFont(MainFont[3])
			else
				love.graphics.setFont(MainFont[2])
			end
				
			love.graphics.setColor(0, 0, 0)
			love.graphics.printf(self.standingNames[i].." Place", 0, 1080/2-50*#self.standingNames+150*i+5, 1920, "center")
			love.graphics.setColor(unpack(v))
			love.graphics.printf(self.standingNames[i].." Place", 0, 1080/2-50*#self.standingNames+150*i, 1920, "center")
		end
	end
end

function Gameplay:update(dt)
	self.cameraTimer = self.cameraTimer + dt
	if (self.cameraTimer > 6) then
		camera.d.y = math.random(30, 60)
		self.cameraTimer = 0
	end

	--self:updateDayLight()
	
	for i, v in pairs(self.platforms) do
		v:update(dt)
	end

	for i, v in ipairs(self.players) do
		if v.dead then
			table.remove(self.players, i)
		else
			v:update(dt, self.platforms, self.players, self.avalanches, self.fallingrocks, self.items)
		end
	end
	for i, v in ipairs(self.platforms) do
		v:update(dt)
	end
	for i, v in ipairs(self.avalanches) do
		if v.dead then
			table.remove(self.avalanches, i)
		else
			v:update(dt)
		end
	end
	for i, v in ipairs(self.snowballs) do
		if v.dead then
			table.remove(self.snowballs, i)
		else
			v:update(dt)
		end
	end
	for i, v in ipairs(self.fallingrocks) do
		v:update(dt, self.platforms)
	end
	for i, v in ipairs(self.alerts) do
		if (not v:update(dt)) then
			table.remove(self.alerts, i)
		end
	end
	
	if math.abs(camera.pos.y) > self.chunkCount*1080 then
		self.chunkCount = self.chunkCount + 1
		self:generateNextChunk()
	end
	
	if not self.gameOver and #self.players==1 then
		table.insert(self.standings, 1, self.players[1].color)
		self.gameOver = true
	end
--[[
	if (camera.pos.y / self.spacing > self.lastChunkGenerated) then
		self:generateNextChunk(math.random(1, 2), self.lastChunkGenerated + 10)
		self.lastChunkGenerated = self.lastChunkGenerated + 10
	end ]]--
	if love.keyboard.isDown("escape") then
		game:popScreenStack()
	end

	self.eventTimer = self.eventTimer + dt
	if (self.eventTimer > self.eventSpacing) then
		if (math.random() < 0.001) then
			if (math.random() < 0.5) then
				local xpos = math.random(300, 1620)
				table.insert(self.avalanches, Avalanche(xpos, 3000, 5000))
				table.insert(self.alerts, Alert(xpos + 65, 3))

			else
				table.insert(self.fallingrocks, FallingRock(math.random(300, 1320), -camera.pos.y - 200, 500 * (math.random(0, 1) * 2 - 1)))		
			end
			self.eventTimer = 0
		end
	end
end

function Gameplay:updateDayLight()
	local numDif = 0
	for i = 1, 3 do
		if self.dayLightColor[i] ~= self.targetColors[self.targetColor][i] then
			numDif = numDif + 1
		end
	end
	if numDif == 0 then
		self.targetColor = self.targetColor + 1
		if self.targetColor > #self.targetColors then
			self.targetColor = 1
		end
	else
		local speed = (1*numDif)/4
		for i = 1, 4 do
			if self.dayLightColor[i] > self.targetColors[self.targetColor][i] then
				self.dayLightColor[i] = self.dayLightColor[i] - speed
			elseif self.dayLightColor[i] < self.targetColors[self.targetColor][i] then
				self.dayLightColor[i] = self.dayLightColor[i] + speed
			end
		end
	end
end

function Gameplay:resize(w, h)
	--
end

function Gameplay:handleinput(input)
	--
end


function Gameplay:generateNextChunk()

	local chunkType = math.random(1, 7)
	
	if chunkType == 1 then
		self:generatePlatform(100, 100,  1)
		self:generatePlatform(100, 400,  1)
		self:generatePlatform(100, 700,  1)
		self:generatePlatform(1300, 400, 2)
		self:generatePlatform(900, 800,  2)
	elseif chunkType == 2 then            
		self:generatePlatform(100, 100,  1)
		self:generatePlatform(1420, 100, 1)
		self:generatePlatform(100, 400,  3, 100, 1720-280, 0, 0)
		self:generatePlatform(200, 800,  2)
		self:generatePlatform(1220, 800, 2)
	elseif chunkType == 3 then           
		self:generatePlatform(200, 100,  3, 0, 0, 100, 880)
		self:generatePlatform(800, 850,  2)
		self:generatePlatform(700, 400,  3, 100, 500)
		self:generatePlatform(1480, 100, 1)
	elseif chunkType == 4 then           
		self:generatePlatform(100, 200,  3, 100, 1400, 50, 700)
		self:generatePlatform(100, 200,  3, 0, 0, 75, 700)
		self:generatePlatform(1500, 200, 3, 0, 0, 100, 700)
		self:generatePlatform(810, 0,  1)
	elseif chunkType == 5 then
		self:generatePlatform(100, 100, 3, 0, 0, 125, 922)
		self:generatePlatform(1400, 800, 1)
		self:generatePlatform(400, 800, 1)
		self:generatePlatform(1000, 500, 2)
		self:generatePlatform(400, 100, 1)
		self:generatePlatform(1400, 100, 1)
	elseif chunkType == 6 then
		self.chunkCount = self.chunkCount + 1
		self:generatePlatform(100, 100, 3, 0, 0, 125, 1900)
		self:generatePlatform(1000, 1800, 2)
		self:generatePlatform(400, 1800, 1)
		self:generatePlatform(700, 1500, 1)
		self:generatePlatform(1600, 1500, 2)
		self:generatePlatform(1300, 1100, 3)
		self:generatePlatform(300, 1175, 2)
		self:generatePlatform(400, 811, 1)
		self:generatePlatform(850, 700, 2)
		self:generatePlatform(1500, 700, 1)
		self:generatePlatform(420, 420, 1)
		self:generatePlatform(900, 200, 3, 70, 800, 0, 0)
		self:generatePlatform(600, 0, 2)
	elseif chunkType == 7 then
		self:generatePlatform(300, 750, 3, 70, 800, 0, 0)
		self:generatePlatform(1400, 600, 2)
		self:generatePlatform(50, 300, 1)
		self:generatePlatform(900, 100, 1)
		self:generatePlatform(150, 0, 3)
	elseif chunkType == 8 then


	end
end

function Gameplay:generatePlatform(x, y, w, vx, rx, vy, ry)
	local y0 = self.chunkCount*1080
	table.insert(self.platforms, Platform({x = x, y = y, w = self.platformSizes[w], style = style, vx = vx or 0, vy = vy or 0, rx = rx or 0, ry = ry or 0, y0 = y0, extra = math.random(-3, 4)}))
	local item = math.max(math.random(-5, 2))
	if item > 0 then
		table.insert(self.items, Item(x + self.platformSizes[w]/2 - 25, y - 50 - y0, item))
	end
end