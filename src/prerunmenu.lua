
require "menu"

PreRunMenu = class()


function PreRunMenu:_init(args)
	self.colorChangeAmount = 32

	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false

	local menuButtons = {{text = "Ready", rightOption = self.readyButton},
							{text = "Red", rightOption = self.colorIncreased, leftOption = self.colorDecreased, color = {255, 0, 0}},
							{text = "Green", rightOption = self.colorIncreased, leftOption = self.colorDecreased, color = {0, 255, 0}},
							{text = "Blue", rightOption = self.colorIncreased, leftOption = self.colorDecreased, color = {0, 0, 255}},
							{text = "Back", leftOption = self.backButtonPressed}}
	self.backgroundImage = love.graphics.newImage("images/assets/titleBackground.png")
	local buttonWidth = 500
	self.menu = Menu{parent = self, x = 1920/2-buttonWidth/2, y = 200, buttonwidth = buttonWidth, buttons = menuButtons}

	self.playerOrder = {} -- this is index to playerUID to get playernumber
	self.players = {} -- this gets reset on page load, it's full of a table with playerIDs, player colors, and not much else?
	self.numPlayers = 0
end

function PreRunMenu:load()
	-- run when the level is given control
	inputManager:setSendMenuInputs(true) -- distribute things to the handleinput functions of all members of the screen stack.
	inputManager:addToInputStack(self)
	-- everyone should be able to control the main menu probably
	inputManager:ownMenu() -- leave it blank to let anyone control it
	love.mouse.setVisible(true)
	for k, v in pairs(self.menu.selections) do
		v.ready = false
	end
	if not soundManager:isPlaying("titlemusic") then
		soundManager:playSound("titlemusic")
	end
end

function PreRunMenu:leave()
	-- run when the level no longer has control
	inputManager:setSendMenuInputs(false)
	inputManager:removeFromInputStack(self)
	love.mouse.setVisible(false)
end

function PreRunMenu:colorDecreased(text, player)
	if player == "mouse" then return end
	-- the text will be the key for what color
	local textToColor = {Red = 1, Green = 2, Blue = 3}
	self.players[player].color[textToColor[text]] = math.max(0, self.players[player].color[textToColor[text]] - self.colorChangeAmount)
	self.menu.selections[player].color[textToColor[text]] = self.players[player].color[textToColor[text]] -- change the color on the menu icon as well
end

function PreRunMenu:colorIncreased(text, player)
	if player == "mouse" then return end
	-- the text will be the key for what color
	local textToColor = {Red = 1, Green = 2, Blue = 3}
	self.players[player].color[textToColor[text]] = math.min(255, self.players[player].color[textToColor[text]] + self.colorChangeAmount)
	self.menu.selections[player].color[textToColor[text]] = self.players[player].color[textToColor[text]] -- change the color on the menu icon as well
end

function PreRunMenu:drawPlayer(x, y, frame, bodyColor, type)
	local colors = {{170, 140, 132}, bodyColor, {255, 255, 255}}
	local offset = 0
	if type=="celebration" then
		offset = -150
	end
	for i = 1, 3 do
		love.graphics.setColor(colors[i])
		love.graphics.draw(images.player[type.."Images"][i][math.floor(frame)], x, y + offset, 0, 1, 1, images.player[type.."Images"][i][math.floor(frame)]:getWidth()/2, 0)
	end
end

function PreRunMenu:readyButton(text, player)
	-- if the mouse presses it then the game starts,
	-- if a player presses it then they are ready
	-- if everyone is ready and there is mmore than 1 player, the game starts
	if player == "mouse" then
		for k, v in pairs(self.players) do
			v.ready = true
			self.menu.selections[player].ready = true
		end
	else
		-- change the status of the player's ready
		self.players[player].ready = not self.players[player].ready
		self.menu.selections[player].ready = self.players[player].ready
	end
	local numReady = 0
	local numNotReady = 0
	for k, v in pairs(self.players) do
		if v.ready then
			numReady = numReady + 1
		else
			numNotReady = numNotReady + 1
		end
	end
	if numNotReady == 0 and numReady >= 2 then
		-- start the game
		local inplayers = {}
		for k, v in pairs(self.players) do
			v.ready = false -- for next round
			self.menu.selections[player].ready = false
			table.insert(inplayers, math.random(1, #inplayers+1), {uid = k, color = v.color})
		end
		game.gameplay = Gameplay(game, inplayers)
		camera.pos.x = 0
		camera.pos.y = 0
		game:addToScreenStack(game.gameplay)
	end
end

function PreRunMenu:backButtonPressed(text, player)
	if player == "mouse" then
		for k, v in pairs(self.menu.selections) do
			self.menu:removePlayerIcon(k)
			self.menu.selections[k] = nil
			self.players[k] = nil
		end
		self.numPlayers = 0
		self.playerOrder = {}
	else
		local found, index = iInTable(self.playerOrder, player)
		if found then
			table.remove(self.playerOrder, index)
		end
		self.numPlayers = self.numPlayers - 1
		self.players[player] = nil
		-- print("REMOVED PLAYER "..tostring(player))
		self.menu:removePlayerIcon(player)
		self.menu.selections[player] = nil
	end
	if self.numPlayers <= 0 then
		-- exit out of this screen
		game:popScreenStack()
		self.menu:clearIcons()
	end
end

function PreRunMenu:draw()
	love.graphics.draw(self.backgroundImage, 0, 0)
	self.menu:draw()
	local x = 1920/(#self.playerOrder+1)
	local y = 1080-202
	for i, player in pairs(self.playerOrder) do
		if not self.players[player].ready then
			self:drawPlayer(x*i, y, self.players[player].frame, self.players[self.playerOrder[i]].color, "idle")
		else
			self:drawPlayer(x*i, y, self.players[player].frame, self.players[self.playerOrder[i]].color, "celebration")

		end
		-- x = x + 1920/(#self.playerOrder+1)
	end
end

function PreRunMenu:update(dt)
	self.menu:update(dt)
	if self.numPlayers <= 1 then
		-- set the back button text to be "back" since it goes back to the main menu
		self.menu.buttons[#self.menu.buttons].text = "Back"
	else
		--  otherwise "drop out"
		self.menu.buttons[#self.menu.buttons].text = "Drop Out"
	end
	for k, v in pairs(self.players) do
		v.frame = v.frame + dt * 10
		if v.ready and v.frame >= 18+1 then
			v.frame = 1
		elseif not v.ready and v.frame > 7+1 then
			v.frame = 1
		end
	end
end

-- function PreRunMenu:resize(w, h)
-- 	--
-- end

function PreRunMenu:handleinput(input)
	self.menu:handleinput(input)
	-- this should also add them to the game if they aren't added.
	if input.player == "mouse" then
		if input.inputtype == "back" then
			game:popScreenStack()
			self.menu:clearIcons()
		end
	else
		if self.players[input.player] == nil and self.menu.selections[input.player] then -- if self.menu.selections[input.player] is nil, then it literally just deleted it from this very tabble
			-- then add the player key to the live thing! it's party time!
			-- print("ADDED PLAYER "..tostring(player))
			self.players[input.player] = {key = input.player, color = {math.random(0, 255), math.random(0, 255), math.random(0, 255)}, ready = false, frame = math.random(1, 7)}
			self.menu.selections[input.player].color = self.players[input.player].color
			self.numPlayers = self.numPlayers + 1
			table.insert(self.playerOrder, input.player)
		end
	end
	return true -- because I'm too lazy to actually do this part probably...
end