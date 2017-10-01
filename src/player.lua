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
	self.layerColors = {{170, 140, 132}, self.color, {255, 255, 255}}
	self:loadImageOfType("running", 14)
	self:loadImageOfType("idle", 7)
	self:loadImageOfType("fallDown", 5)
	self:loadImageOfType("jumpUp", 5)
	self:loadImageOfType("turn", 2)
end

function Player:loadImageOfType(name, frames)
	self[name.."Images"] = {{}, {}, {}}
	for i = 1, frames do
		self[name.."Images"][1][i] = love.graphics.newImage("images/player/"..name.."Skin"..i..".png")
		self[name.."Images"][2][i] = love.graphics.newImage("images/player/"..name.."Clothes"..i..".png")
		self[name.."Images"][3][i] = love.graphics.newImage("images/player/"..name.."Lines"..i..".png")
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
	if inputManager:getPlayerValues(self.uid).raw.down > 0.9 and ((self.move.onGround == true and self.move.onSolidGround == false) or self.move.hanging) then
		self.move.onGround = false
		self.move.pos.y = self.move.pos.y + 20
	end
	self.move:move(dt, xScaler, jump)
	
	-- startJump = self.inputmanager:getPlayer(self.uid).jump and self.onGround
	-- if (startJump) then
	-- 	self.move.vel.dy = 500
	-- end
end

function Player:animatePlayer(dt)
	self.animationFrame = self.animationFrame + 10*dt
	if self.animationFrame > 14 then
		self.animationFrame = 1
	end
end

function Player:draw()
	for i = 1, 3 do
		love.graphics.setColor(unpack(self.layerColors[i]))
		
		--drawing images on ground
		
			--running
			if math.abs(self.move.vel.dx) > 150 then
				local frame = math.floor(self.animationFrame)
				camera:draw(self.runningImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, sign(self.move.vel.dx))
				
			--turning
			elseif math.abs(self.move.vel.dx) > 50 then
				local frame = math.max(math.min(math.floor((self.move.vel.dx-50)/50), 2), 1)
				camera:draw(self.turnImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, sign(self.move.vel.dx))
				
			--idle
			else
			
				if self.move.onGround then
					local frame = math.floor((self.animationFrame-1)/2)+1
					camera:draw(self.idleImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y)
				else
					
				--jumping up
					if self.move.vel.dy < 0 then
						local frame = math.max(math.min(math.floor(math.abs(self.move.vel.dy)/160), 5), 1)
						camera:draw(self.fallDownImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y)
					
					--falling down
					else
						local frame = 6-math.max(math.min(math.floor(math.abs(self.move.vel.dy)/160), 5), 1)
						camera:draw(self.jumpUpImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y)
					end
				end
				
			end
		
	end
	love.graphics.setColor(0, 255, 0)
	camera:rectangle("line", self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
end
