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

	self.size = {width = 80, height = 170}
	
	self.animationFrame = 1
	self.imageOffset = {x = -152, y = -30}

	self:loadImages()

end

function Player:loadImages()
	self.idleImages = {{}, {}, {}}
	self.idleColors = {{255, 255, 255}, {0, 255, 0}, {255, 255, 255}}
	for i = 1, 7 do
		self.idleImages[1][i] = love.graphics.newImage("images/player/idleSkin"..i..".png")
		self.idleImages[2][i] = love.graphics.newImage("images/player/idleClothes"..i..".png")
		self.idleImages[3][i] = love.graphics.newImage("images/player/idleLine"..i..".png")
	end
end

function Player:update(dt)
	self:movePlayer(dt)
	self:animatePlayer(dt)
end

function Player:movePlayer(dt)
	xScaler = inputManager:getPlayerValues(self.uid).x
	jump = inputManager:getPlayerValues(self.uid).raw.up > 0.9
	self.move:move(dt, xScaler, jump)
	self.move:collisions({}, self.size)
	
	-- startJump = self.inputmanager:getPlayer(self.uid).jump and self.onGround
	-- if (startJump) then
	-- 	self.move.vel.dy = 500
	-- end
end

function Player:animatePlayer(dt)
	self.animationFrame = self.animationFrame + 10*dt
	if self.animationFrame > 7 then
		self.animationFrame = 1
	end
end

function Player:draw()
	for i = 1, 3 do
		love.graphics.setColor(unpack(self.idleColors[i]))
		camera:draw(self.idleImages[i][math.floor(self.animationFrame)], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y)
	end
	love.graphics.setColor(0, 255, 0)
	camera:rectangle("line", self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
end
