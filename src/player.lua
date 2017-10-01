require "movement"

Player = class()

function Player:_init(game, uid, color)
	self.game = game
	self.uid = uid
	self.color = color

	local x = 250		-- Holds info about the players location and movement
	local y = 250
	local acceleration = 700
	local maxDX = 700
	
	self.move = Movement(x, y, acceleration, maxDX)

	self.facing = 1

	self.size = {width = 80, height = 170}
	
	self.animationFrame = 1
	self.imageOffset = {x = -152, y = -20}


	self:loadImages()

end

function Player:loadImages()
	self.idleImages = {{}, {}, {}}
	self.idleColors = {{170, 140, 132}, self.color, {255, 255, 255}}
	for i = 1, 7 do
		self.idleImages[1][i] = love.graphics.newImage("images/player/idleSkin"..i..".png")
		self.idleImages[2][i] = love.graphics.newImage("images/player/idleClothes"..i..".png")
		self.idleImages[3][i] = love.graphics.newImage("images/player/idleLines"..i..".png")
	end
end

function Player:update(dt, platforms)
	self:movePlayer(dt, platforms)
	self:animatePlayer(dt)
end

function Player:movePlayer(dt, platforms)
	xScaler = inputManager:getPlayerValues(self.uid).x
	jump = inputManager:getPlayerValues(self.uid).raw.up > 0.9
	self.move:collisions(platforms, self.size, dt)
	if inputManager:getPlayerValues(self.uid).raw.down > 0.9 and self.move.onGround == true and self.move.onSolidGround == false then
		self.move.onGround = false
		self.move.pos.y = self.move.pos.y + 10
	end
	self.move:move(dt, xScaler, jump)
	
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
