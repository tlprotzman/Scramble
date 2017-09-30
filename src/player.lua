require "movement"

Player = class()

function Player:_init(game)
	self.game = game
	self.uid = 1

	self.pos = {x = 250, y = 250}		-- Holds info about the players location and movement
	self.acceleration = 300
	self.maxDX = 500
	self.jumpStrength = 500
	self.move = Movement(self.pos.x, self.pos.y, self.acceleration, self.maxDX)

	self.onGround = false		-- Used for drawing the player
	self.crouching = false
	self.facing = 1

	self.size = {width = 160, height = 320}

	
end


function Player:movePlayer(dt)
	xScaler = 1--self.inputmanager:getPlayer(self.uid).x 		--PLACEHOLDER
	self.move:move(dt, xScaler)
	
	-- startJump = self.inputmanager:getPlayer(self.uid).jump and self.onGround
	-- if (startJump) then
	-- 	self.move.vel.dy = 500
	-- end
end



function Player:draw()
	love.graphics.rectangle("fill", self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
end
