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
	self.carrying = false
	self.playerGrabTimer = 0
	self.carrierBreakFree = 0 -- if this is 0 then you've broke free and will jump away
	self.carrierBreakFreeToggle = true -- you have to spam jump, which means it has to be 0 in between
	self.itemUseToggle = true -- when this is true, they can use an item, this is to prevent using both items when standing on top of an item when you already have one

	
	self.size = {width = 80, height = 170}
	
	self.animationFrame = 1
	self.celebrationFrame = 1
	self.imageOffset = {x = -152, y = -20}

	self.wasHanging = false
	self.hangingAnimationFrame = 1
	self.shimmyFrame = 1
	self.grabAnimationFrame = 0
	self.playerIconFrame = 1
	
	self.isAvalanched = false
	
	self.hasItem = 0 	-- 1 = pickaxe, 2 = dynamite
	
	self:loadImages()
	self.dead = false
end

function Player:loadImages()
	self.layerColors = {{170, 140, 132}, self.color, {255, 255, 255}}
	self:loadImageOfType("running", 14)
	self:loadImageOfType("runningPickUp", 14)
	self:loadImageOfType("idle", 7)
	self:loadImageOfType("idlePickUp", 7)
	self:loadImageOfType("fallDown", 5)
	self:loadImageOfType("jumpUp", 5)
	self:loadImageOfType("turn", 2)
	self:loadImageOfType("turnPickUp", 2)
	self:loadImageOfType("frontGrab", 6)
	self:loadImageOfType("shimmy", 5)
	self:loadImageOfType("pullUp", 13)
	self:loadImageOfType("pullOff", 10)
	self:loadImageOfType("celebration", 18)
end

function Player:loadImageOfType(name, frames)
	self[name.."Images"] = {{}, {}, {}}
	for i = 1, frames do
		-- self[name.."Images"][1][i] = love.graphics.newImage("images/player/"..name.."Skin"..i..".png")
		-- self[name.."Images"][2][i] = love.graphics.newImage("images/player/"..name.."Clothes"..i..".png")
		-- self[name.."Images"][3][i] = love.graphics.newImage("images/player/"..name.."Lines"..i..".png")
		self[name.."Images"][1][i] = images.player[name.."Images"][1][i]
		self[name.."Images"][2][i] = images.player[name.."Images"][2][i]
		self[name.."Images"][3][i] = images.player[name.."Images"][3][i]
	end
end

function Player:grab(players)
	if (inputManager:getPlayerValues(self.uid).raw.grab > 0.9) then
		-- print("ATTEMPTED")
		if (self.move.hanging) then
			for i, v in pairs(players) do
				if (v.move.onPlatform == self.move.onPlatform and v ~= self and v.move.onGround) then
					if (math.abs(v.move.pos.x - self.move.pos.x) < 50) then
						-- print ("HIT")
						v.move.pos.y = v.move.pos.y + 10
						v.move.vel.dy = 450
						v.move.noGrab = 1
						self.grabAnimationFrame = 1
					end
				end
			end
		elseif self.playerGrabTimer < 0 and not self.carrying and not self.move.carrier then -- you can't pick up another player if your grab timer is >0 or if you're already carrying or being carried
			-- try picking up a player nearby
			for i, other in pairs(players) do
				-- the other player can't be climbing, and can't be too far away, and can't be yourself.
				if other ~= self and self.move.pos.y < other.move.pos.y + 20 and self.move.pos.y > other.move.pos.y - 100 and not other.move.hanging then
					-- it's within grabbing height
					if math.abs(other.move.pos.x - self.move.pos.x) < 50 then
						other.move.carrier = self
						other.move.onGround = false -- they are no longer on the ground, so they shouldn't be able to jump away unless they break free
						other.carrierBreakFree = math.random(3, 6)
						self.playerGrabTimer = 1
						self.carrying = other
						break
					end
				end
			end
		end
	elseif self.carrying then -- throw the other player
		self.carrying.playerGrabTimer = 1 -- they can't jump for a second
		self.playerGrabTimer = 1 -- you can't grab immediately either
		self.carrying.move.carrier = false
		self.carrying.carrierBreakFree = 0
		self.carrying.move.onGround = false -- they shouldn't be able to jump after they're thrown.
		self.carrying.move.floatingJumpTimer = self.carrying.move.floatingJumpAllowance -- if this was 0 then they'd be able to jump! That's not supposed to happen
		self.carrying.move.jumpTimer = self.carrying.move.maxJumpTime -- this also needs to be set to prevent jumping. Wow. Jumping is really not obvious
		self.carrying.move.vel.dx = 600 * self.facing + self.move.vel.dx
		self.carrying.move.vel.dy = self.move.vel.dy + 200
		self.carrying.move.thrown = true
		self.carrying = false
	end
end

function Player:update(dt, platforms, players, avalanches, fallingrocks, items)
	self.playerIconFrame = imageManager:updateFrameCount("playerIcon", self.playerIconFrame, dt*10)
	if self.carrierBreakFree > 0 then
		if inputManager:getPlayerValues(self.uid).raw.up > .5 then
			if self.carrierBreakFreeToggle then
				self.carrierBreakFree = self.carrierBreakFree - 1
				self.carrierBreakFreeToggle = false
				if self.carrierBreakFree == 0 then
					-- jump away, free
					self.move.carrier.carrying = false
					self.move.carrier = false
					self.move.onGround = true -- If you break free you get to jump! Go you!
					self.playerGrabTimer = 1 -- you have a second after you break free that you can't carry to prevent grab reversals
					self.carrierBreakFreeToggle = true
				end
			end
		else
			self.carrierBreakFreeToggle = true
		end
	end
	self:getAvalanched(avalanches)
	self:getRocked(fallingrocks)
	self:getItems(items)
	self:useItem()
	self:movePlayer(dt, platforms)
	if self.move.climbUpTimer > 0 then
		self.size.height = 0
	else
		self.size.height = 170
	end
	if self.move.vel.dx ~= 0 then self.facing = sign(self.move.vel.dx) self.move.facing = self.facing end
	self:grab(players)
	self.playerGrabTimer = self.playerGrabTimer - dt

	self:animatePlayer(dt)
	self:makeSnow()

	self:die()

	if (self.move.noGrab > 0) then
		self.move.noGrab = self.move.noGrab + dt
		if (self.move.noGrab > 2) then
			self.move.noGrab =0
		end
	end
end

function Player:useItem()
	if (inputManager:getPlayerValues(self.uid).raw.use > 0.9) and self.itemUseToggle and not self.carrying then -- can't use items when you're carrying someone else
		if (self.hasItem == 1) then
			table.insert(self.game.gameplay.fallingrocks, FallingRock(self.move.pos.x + 200 * self.move.facing, self.move.pos.y, 500 * self.move.facing))		
			self.hasItem = 0
		elseif (self.hasItem == 2) then
			table.insert(self.game.gameplay.avalanches, Avalanche(self.move.pos.x-300, 3000, 5000))

			table.insert(self.game.gameplay.alerts, Alert(self.move.pos.x-65, 3))
			self.hasItem = 0
		end
		self.itemUseToggle = false
	elseif not (inputManager:getPlayerValues(self.uid).raw.use > 0.9) then
		self.itemUseToggle = true -- then reset the toggle, so you can do it again.
	end
end

function Player:die()
	if math.abs(self.move.pos.y + camera.pos.y) > 1080 + 30 and math.abs(self.move.pos.y + camera.pos.y) < 4000 then
		if not self.game.gameplay.gameOver then
			table.insert(self.game.gameplay.standings, 1, self.color)
		end
		soundManager:playSound("scream")
		self.dead = true
	end
end

function Player:makeSnow()
	if self.move.onGround and math.abs(self.move.vel.dx) > 50 and math.random(1, 10) == 5 and not self.move.carrier then -- don't make snow when you're being carried
		table.insert(self.game.gameplay.snowballs, Snow(self.move.pos.x - 180, self.move.pos.y - 70))
	end
end

function Player:movePlayer(dt, platforms)
	xScaler = inputManager:getPlayerValues(self.uid).x
	jump = inputManager:getPlayerValues(self.uid).raw.up > 0.9
	if not self.isAvalanched then
		self.move:collisions(platforms, self.size, not self.carrying, dt)
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
		if self.move.pos.x + self.size.width > v.x  and self.move.pos.x < v.x + v.s then
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
					soundManager:playSound("itemget")
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
	self.celebrationFrame = self.celebrationFrame + 15*dt
	if self.celebrationFrame > 18 then
		self.celebrationFrame = 1
	end
	if self.grabAnimationFrame > 0 then
		self.grabAnimationFrame = self.grabAnimationFrame + .1
		if self.grabAnimationFrame >= 6 then
			self.grabAnimationFrame = 0
		end
	end
end

function Player:draw()
	-- if the player is offscreen, draw the player icon below where they are so people can see.
	if self.move.pos.y + 180 < -camera.pos.y then
		-- they're offscreen, so draw the player icon showing what x they're at to make life easier
		love.graphics.setColor(self.layerColors[2])
		local icon = imageManager:getImage("playerIcon", self.playerIconFrame)
		love.graphics.draw(icon, self.move.pos.x+camera.pos.x+self.size.width/2, 50, math.pi/2, 1, 1, icon:getWidth()/2, icon:getHeight()/2)
	end
	for i = 1, 3 do
		love.graphics.setColor(self.layerColors[i])
		local idleFrames = self.idleImages
		local runningFrames = self.runningImages
		local turnFrames = self.turnImages
		local jumpUpFrames = self.jumpUpImages
		local fallDownFrames = self.fallDownImages
		local yOffset = 0
		if self.carrying then
			idleFrames = self.idlePickUpImages
			jumpUpFrames = self.idlePickUpImages
			fallDownFrames = self.idlePickUpImages
			runningFrames = self.runningPickUpImages
			turnFrames = self.turnPickUpImages
			yOffset = self.size.height
		end

		--drawing images on ground
		if self.move.carrier then
			local frame = math.floor((self.animationFrame-1)/2)+1
			camera:draw(self.idleImages[i][frame], self.move.pos.x + self.imageOffset.x + math.max(math.min(self.move.vel.dx/5, 25), -25), self.move.pos.y + self.imageOffset.y - yOffset - 20, 1, 1, math.pi/2)
		elseif self.grabAnimationFrame > 0 then
			local frame = math.floor(self.grabAnimationFrame)*2
			camera:draw(self.pullOffImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - 140, self.facing)
		elseif self.move.climbUpTimer > 0 then
			local frame = math.ceil(self.move.climbUpTimer)
			camera:draw(self.pullUpImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - 140, self.facing)
		elseif self.move.hanging then
			local frame = math.floor(self.hangingAnimationFrame)
			if frame > 6 then
				frame = math.floor(self.move.shimmyFrame)
				camera:draw(self.shimmyImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, self.facing)
			else
				camera:draw(self.frontGrabImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y, -self.facing)
			end
		--running
		elseif math.abs(self.move.vel.dx) > 150 then
			local frame = math.floor(self.animationFrame)
			camera:draw(runningFrames[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - yOffset, self.facing)
		elseif 	not self.move.onGround then
			if self.move.vel.dy < 0 then
				local frame = math.max(math.min(math.floor(math.abs(self.move.vel.dy)/160), 5), 1)
				camera:draw(fallDownFrames[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y - yOffset, self.facing)
			
			--falling down
			else
				local frame = 6-math.max(math.min(math.floor(math.abs(self.move.vel.dy)/160), 5), 1)
				camera:draw(jumpUpFrames[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y - yOffset, self.facing)
			end
		--turning
		elseif math.abs(self.move.vel.dx) > 50 then
			local frame = math.max(math.min(math.floor((self.move.vel.dx-50)/50), 2), 1)
			camera:draw(turnFrames[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - yOffset, self.facing)
			
		--idle
		else
		
			if self.move.onGround then
				if self.game.gameplay.gameOver then
					yOffset = self.size.height - 20
					local frame = math.ceil(self.celebrationFrame)
					camera:draw(self.celebrationImages[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - yOffset)
				else
					local frame = math.floor((self.animationFrame-1)/2)+1
					camera:draw(idleFrames[i][frame], self.move.pos.x + self.imageOffset.x, self.move.pos.y + self.imageOffset.y - yOffset)
				end
			else
				
			--jumping up
			
			end
			
		end
	
	end
	
	
	--love.graphics.setColor(0, 255, 0)
	--
	--if (self.hasItem ~= 0) then
	--	love.graphics.setColor(unpack(self.game.gameplay.itemColors[self.hasItem]))
	--end
	--camera:rectangle("line", self.move.pos.x, self.move.pos.y, self.size.width, self.size.height)
end
