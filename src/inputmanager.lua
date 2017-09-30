
InputManager = class()


function InputManager:_init(args)
	if args == nil then
		args = {}
	end
	self.menuMapping = {} -- for player controls to menu controls
	self.gamepads = {} -- gamepads get added to this whenever they're added to the game. we use their uids to index self.players for the player input tables.

	self.playerValues = {k1 = {x = 0, y = 0, playing = false, raw = {left = 0, right = 0, up = 0, down = 0}},
							k2 = {x = 0, y = 0, playing = false, raw = {left = 0, right = 0, up = 0, down = 0}},
							k3 = {x = 0, y = 0, playing = false, raw = {left = 0, right = 0, up = 0, down = 0}}  } -- add a player table to this, the key for this is what gets passed
	for k, v in pairs(love.joystick.getJoysticks()) do
		if v:isGamepad() then
			self:gamepadadded(v)
		end
	end

	self.keyboardPlayerMapping = {w = "k1", a = "k1", s = "k1", d = "k1",
									i = "k2", j = "k2", k = "k2", l = "k2",
									kp8 = "k3", kp4 = "k3", kp5 = "k3", kp6 = "k3"}
	self.keyboardKeyMapping = {k1 = {w = "up", a = "left", s = "down", d = "right"},
								k2 = {i = "up", j = "left", k = "down", l = "right"},
								k3 = {kp8 = "up", kp4 = "left", kp5 = "down", kp6 = "right"}}

	-- I'm going to need to deal with contexts for this.

	self.inputStack = args.inputStack or {} -- this is so that things can claim the inputs

	self.playerOwners = {} -- these are player uids that are allowed to control the menu currently
	self.sendMenuInputs = false -- if you want menu inputs distributed upon keypresses etc, then this should be true, otherwise it won't do things
end

function InputManager:ownMenu(playerUID)
	-- pass in nothing if you want to clear the uids that are controlling it.
	if playerUID == nil then
		self.playerOwners = {} -- if it's empty, anyone can use it, if it's not empty then only those uids can control it 
	else
		table.insert(self.playerOwners, playerUID)
	end
end

function InputManager:update(dt)
	self.mouseX = love.mouse.getX()
	self.mouseY = love.mouse.getY()

	if self.sendMenuInputs then
		-- send the menu inputs
	end
end

function InputManager:calculatePlayerStats(playerValueTable)
	-- currently this may be just for keyboards, because controllers have the opposite problem
	playerValueTable.x = playerValueTable.raw.right - playerValueTable.raw.left
	playerValueTable.y = playerValueTable.raw.down - playerValueTable.raw.up
end

function InputManager:keypressed(key, unicode)
	local player = self.keyboardPlayerMapping[key]
	if player == nil then
		return
	end
	self.playerValues[player].playing = true
	local keyAction = self.keyboardKeyMapping[player][key]
	self.playerValues[player].raw[keyAction] = 1

	-- then recalculate the player x and y
	self:calculatePlayerStats(self.playerValues[player])

	-- if it's in a menu, distribute the menu stuff
	if self.sendMenuInputs then
		-- send the menu input pls.
	end
end

function InputManager:keyreleased(key, unicode)
	local player = self.keyboardPlayerMapping[key]
	if player == nil then
		return
	end
	local keyAction = self.keyboardKeyMapping[player][key]
	self.playerValues[player].raw[keyAction] = 0

	-- then recalculate the player x and y
	self:calculatePlayerStats(self.playerValues[player])

	-- if it's in a menu, distribute the menu stuff
	if self.sendMenuInputs then
		-- send the menu input pls.
	end
end

function InputManager:getPlayerValues(playerID)
	return self.playerValues[playerID]
end

function InputManager:gamepadadded(gamepad)
	self.playerValues[gamepad:getID()] = {x = 0, y = 0, playing = false, raw = {left = 0, right = 0, up = 0, down = 0}}
end

function InputManager:gamepadremoved(gamepad)
	self.playerValues[gamepad:getID()].playing = false
end

function InputManager:gamepadaxis(gamepad, axis, value)
	local values = self.playerValues[gamepad:getID()]
	if values == nil then
		error("JOYSTICK SOMEHOW WASN'T ADDED")
	end
	if axis == "leftx" then
		-- this is where binding should be a thing
		values.x = value
		if value >= 0 then
			values.raw.right = value
			values.raw.left = 0
		elseif value < 0 then
			values.raw.right = 0
			values.raw.left = -value
		end
	end
end




function InputManager:mousepressed(x, y, button)
	-- self:distributeInput({intype = "mousepressed", x = x, y = y, button = button, value = 1})
end

function InputManager:mousereleased(x, y, button)
	-- self:distributeInput({intype = "mousepressed", x = x, y = y, button = button, value = 0})
end

function InputManager:mousemoved(x, y, dx, dy)
	-- self:distributeInput({intype = "mousemoved", x = x, y = y, dx = dx, dy = dy})
end

-- function InputManager:textinput(text)
-- 	self:distributeInput({intype = "textinput", text = text})
-- end

function InputManager:addToInputStack(inputReceiver)
	-- this is for things like menus that need it? I guess? this is left over stuff that may get scrapped
	table.insert(self.inputStack, inputReceiver)
	return true
end

function InputManager:removeFromInputStack(inputReceiver)
	-- this is also left over, plus this is duplicated code from the helperfunctions file
	for i = 1, #self.inputStack do
		if self.inputStack[i] == inputReceiver then
			table.remove(self.inputStack, i)
			return true
		end
	end
	return false
end

function InputManager:distributeInput(input)
	-- there should probably also be a thing about storing the input in this function, so that it's all distributed.
	for i = #self.inputStack, 1, -1 do
		if self.inputStack[i]:handleinput(input) then
			return true
		end
	end
	return false
end


--[[
Use case:
Main Menu:
Mouse pressing on things as well as player controlls doing things
Can players control menus? Is there a pause game that only one person can unpause?
We want owning menus, so there should be a way to own menu controls?

Menu wise:
if you send a thing to inputmanager saying: broadcast menu controls, then it will do so.
Otherwise, during the gameplay itself, we only want to check in the player:update() function anyways, so that doesn't matter
It's only in menus that we need to deal with getting keypresses.
Then you can also send a variable to the input manager which restricts what player can influence a menu if the player owns the menu.


]]--