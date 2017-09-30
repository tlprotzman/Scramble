require "movement"

Player = class()

function Player:_init(game)
	self.game = game
	self.uid = "k1"

	self.x = 250		-- Holds info about the players location and movement
	self.y = 250
	self.acceleration = 1500
	self.maxDX = 1000
	self.jumpStrength = 500
	self.move = Movement(self.x, self.y, self.acceleration, self.maxDX)

	self.onGround = false		-- Used for drawing the player
	self.crouching = false
	self.facing = 1

	self.size = {width = 160, height = 320}

	self:loadImages()

end

function Player:loadImages()
	self.idleLines, self.idleClothes, self.idleSkin = {}, {}, {}
	for i = 1, 7 do
		self.idleLines[i] = love.graphics.newImage("images/player/playerIdle"..i..".png")
		self.idleClothes[i] = love.graphics.newImage("images/player/playerIdleClothes"..i..".png")
		self.idleSkin[i] = love.graphics.newImage("images/player/playerIdleSkin"..i..".png")
	end
end

function Player:update(dt, platforms)
	self:movePlayer(dt, platforms)
end

function Player:movePlayer(dt, platforms)
	xScaler = inputManager:getPlayerValues(self.uid).x
	jump = inputManager:getPlayerValues(self.uid).raw.up > 0.9
	self.move:move(dt, xScaler, jump)
	self.move:collisions(platforms, self.size)
	
	-- startJump = self.inputmanager:getPlayer(self.uid).jump and self.onGround
	-- if (startJump) then
	-- 	self.move.vel.dy = 500
	-- end
end

function Player:draw()
	love.graphics.setColor(255, 255, 255)
	camera:draw(self.idleSkin[1], self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
	love.graphics.setColor(255, 0, 0)
	camera:draw(self.idleClothes[1], self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
	love.graphics.setColor(255, 255, 255)
	camera:draw(self.idleLines[1], self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
end
