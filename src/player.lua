require "movement"

Player = class()

function Player:_init(game, x, y, uid, color)
	self.game = game
	self.uid = uid
	self.color = color

	local acceleration = 700
	local maxDX = 700
	
	self.move = Movement(x, y, acceleration, maxDX)

	self.facing = 1

	self.size = {width = 80, height = 170}
	
	self.animationFrame = 1
	self.imageOffset = {x = -152, y = -20}

	self.wasHanging = false
	self.hangingAnimationFrame = 1
	self.shimmyFrame = 1
	
	self.isAvalanched = false
	
	self.hasItem = 0 	-- 1 = pickaxe, 2 = dynamite

	self:loadImages()

end

function Player:loadImages()
	self.layerColors = {{170, 140, 132}, self.color, {255, 255, 255}}
	self:loadImageOfType("running", 14)
	self:loadImageOfType("idle", 7)
	self:loadImageOfType("fallDown", 5)
	self:loadImageOfType("jumpUp", 5)
	self:loadImageOfType("turn", 2)
	self:loadImageOfType("frontGrab", 6)
	self:loadImageOfType("shimmy", 5)
	self:loadImageOfType("pullUp", 13)
end

function Player:loadImageOfType(name, frames)
	self[name.."Images"] = {{}, {}, {}}
	for i = 1, frames do
		self[name.."Images"][1][i] = love.graphics.newImage("images/player/"..name.."Skin"..i..".png")
		self[name.."Images"][2][i] = love.graphics.newImage("images/player/"..name.."Clothes"..i..".png")
		self[name.."Images"][3][i] = love.graphics.newImage("images/player/"..name.."Lines"..i..".png")
	end
end

function Player:grab(players)
	if (inputManager:getPlayerValues(self.uid).raw.grab > 0.9) then
		-- print("ATTEMPTED")
		if (self.move.hanging) then
			for i, v in pairs(players) do
				if (v.move.onPlatform == self.move.onPlatform and v ~= self and v.move.onGround) then
					if (math.abs(v.move.pos.x - self.move.pos.x) < 20) then
						-- print ("HIT")
						v.move.pos.y = v.move.pos.y + 10
						v.move.vel.dy = 600
						v.move.noGrab = 1
					end
				end
			end
		end
	end
end


function Player:update(dt, platforms, players, avalanches, fallingrocks, items)

	self:getAvalanched(avalanches)
	self:getRocked(fallingrocks)
	self:getItems(items)
	self:useItem()
	self:movePlayer(dt, platforms)
	self:grab(players)
	self:animatePlayer(dt)

	if (self.move.noGrab > 0) then
		self.move.noGrab = self.move.noGrab + dt
		if (self.move.noGrab > 2) then
			self.move.noGrab =0
		end
	end
end

function Player:useItem()
	if (inputManager:getPlayerValues(self.uid).raw.use > 0.9) then
		if (self.hasItem == 1) then
			table.insert(self.game.gameplay.fallingrocks, FallingRock(self.move.pos.x + 200 * self.move.facing, self.move.pos.y, 500 * self.move.facing))		
			self.hasItem = 0
		elseif (self.hasItem == 0) then
			table.insert(self.game.gameplay.avalanches, Avalanche(self.move.pos.x, 3000, 5000))
			self.hasItem = 0
		end
	end
end

function Player:movePlayer(dt, platforms)
	xScaler = inputManager:getPlayerValues(self.uid).x
	jump = inputManager:getPlayerValues(self.uid).raw.up > 0.9
	if not self.isAvalanched then
		self.move:collisions(platforms, self.size, dt)
		if inputManager:getPlayerValues(self.uid).raw.down > 0.9 and ((self.move.onGround == true and self.move.onSolidGround == false) or self.move.hanging or self.move.climbUpTimer > 0) then
			self.move.climbUpTimer = 0
			self.move.onGround = false
			self.move.pos.y = self.move.pos.y + 20
		end
	end
	self.move:move(dt, xScaler, jump)
	
	-- startJump = self.inputmanager:getPlayer(self.uid).jump and self.onGround
	-- if (startJump) then
	-- 	self.move.vel.dy = 500
	-- end
end

function Player:getAvalanched(avalanches)
	self.isAvalanched = false
	for i, v in ipairs(avalanches) do
		if self.move.pos.y + self.size.height > v.progress and self.move.pos.y < v.progress + v.duration then
			if self.move.pos.x + self.size.width > v.x and self.move.pos.x < v.x + v.w then
				self.move.climbUpTimer = 0
				self.wasHanging = false
				self.move.onGround = false
				self.move.hanging = false
				self.move.onPlatform = false
				self.isAvalanched = true
			end
		end
	end
end

function Player:getRocked(rocks, dt)
	for i, v in ipairs(rocks) do
		if self.move.pos.x + self.size.width > v.x - v.s and self.move.pos.x < v.x + v.s then
			if self.move.pos.y + self.size.height > v.y - v.s and self.move.pos.y < v.y + v.s then
				self.move.vel.dx = self.move.vel.dx + v.vx/2
				self.move.vel.dy = math.max(self.move.vel.dy + v.vy/2, -1000)
				self.move.climbUpTimer = 0
				self.wasHanging = false
				self.move.onGround = false
				self.move.hanging = false
				self.move.onPlatform = false
			end
		end
	end
end

function Player:getItems(items)
	if (self.hasItem == 0) then
		for i, v in ipairs(items) do
			if self.move.pos.x + self.size.width > v.x and self.move.pos.x < v.x + v.w then
				if self.move.pos.y + self.size.height > v.y and self.move.pos.y < v.y + v.h then
					self.hasItem = v.itemType
					table.remove(items, i)
				end
			end
		end
	end
end

function Player:animatePlayer(dt)

	if self.move.hanging and not self.move.wasHanging then
		self.move.wasHanging = true
		self.hangingAnimationFrame = 1
	elseif not self.move.hanging then
		self.move.wasHanging = false
	elseif self.move.wasHanging then
		self.hangingAnimationFrame = self.hangingAnimationFrame + 20*dt
	end
	local animationSpeed = 12
	if self.move.onGround == false and math.abs(self.move.vel.dx) > 150 then
		animationSpeed = 16
	end
	self.animationFrame = self.animationFrame + animationSpeed*dt
	if self.animationFrame > 14 then
		self.animationFrame = 1
	end
end

function Player:draw()
	for i = 1, 3 do
		love.graphics.setColor(unpack(self.layerColors[i]))
		
		--drawing images on ground
		
			if self.move.climbUpTimer > 0 then
				local frame = math.ceil(self.move.climbUpTimer)
				camera:draw(self.pullUpImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - 140, sign(self.move.vel.dx))
			elseif self.move.hanging then
				local frame = math.floor(self.hangingAnimationFrame)
				if frame > 6 then
					frame = math.floor(self.move.shimmyFrame)
					camera:draw(self.shimmyImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, sign(self.move.vel.dx))
				else
					camera:draw(self.frontGrabImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, sign(self.move.vel.dx))
				end
			--running
			elseif math.abs(self.move.vel.dx) > 150 then
				local frame = math.floor(self.animationFrame)
				camera:draw(self.runningImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, sign(self.move.vel.dx))
			elseif 	not self.move.onGround then
				if self.move.vel.dy < 0 then
					local frame = math.max(math.min(math.floor(math.abs(self.move.vel.dy)/160), 5), 1)
					camera:draw(self.fallDownImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y)
				
				--falling down
				else
					local frame = 6-math.max(math.min(math.floor(math.abs(self.move.vel.dy)/160), 5), 1)
					camera:draw(self.jumpUpImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y)
				end
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
				
				end
				
			end
		
	end
	
	
	love.graphics.setColor(0, 255, 0)
	
	if (self.hasItem ~= 0) then
		love.graphics.setColor(unpack(self.game.gameplay.itemColors[self.hasItem]))
	end
	camera:rectangle("line", self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
end
