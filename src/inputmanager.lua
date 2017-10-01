
InputManager = class()


function InputManager:_init(args)
	self.menuMovementThreshold = .1 -- minimum magnitude of a controller stick to trigger a menu movement
	self.menuMovementRepeatTime = .5

	if args == nil then
		args = {}
	end
	self.menuMapping = {} -- for player controls to menu controls

	self.playerValues = {} -- this is the table that stores all of the x and y coordinates for the relative controllers. It also has a subtable that handles menu timers and such.
	for k, v in ipairs({"k1", "k2", "k3"}) do
		self:addControllingMethod(v)
	end
	self.numGamepads = 0
	for k, v in ipairs(love.joystick.getJoysticks()) do
		if v:isGamepad() then
			self:gamepadadded(v)
			self.numGamepads = self.numGamepads + 1
		end
	end

	self.keyboardPlayerMapping = {w = "k1", a = "k1", s = "k1", d = "k1", c = "k1", v = "k1",
									i = "k2", j = "k2", k = "k2", l = "k2", ["."] = "k2", ["/"] = "k2",
									kp8 = "k3", kp4 = "k3", kp5 = "k3", kp6 = "k3", kp3 = "k3", kpenter = "k3"}
	self.keyboardKeyMapping = {k1 = {w = "up", a = "left", s = "down", d = "right", c = "grab", v = "use"},
								k2 = {i = "up", j = "left", k = "down", l = "right", ["."] = "grab", ["/"] = "use"},
								k3 = {kp8 = "up", kp4 = "left", kp5 = "down", kp6 = "right", kp3 = "grab", kpenter = "use"}}
	self.gamepadAxisMapping = {leftx = {"left", "right"}, lefty = {nil, "down"}, rightx = {nil, nil}, righty = {nil, nil}, triggerleft = {nil, "use"}, triggerright = {nil, "use"}}
	self.gamepadButtonMapping = {a = "up", b = "grab"}

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

function InputManager:setSendMenuInputs(sendBoolean)
	-- if sendBoolean then the menu stuff will be sent, otherwise no
	if sendBoolean and self.sendMenuInputs ~= sendBoolean then
		-- then reset all the controller's menu variables as well.
		for i, values in ipairs(self.playerValues) do
			for j, k in pairs(values.menu) do
				k.timer = 10000 -- the player needs to re-center their controls for the menus to have effect? probably. We'll see...
				k.value = values[j]
			end
		end
	end
	self.sendMenuInputs = sendBoolean
end

function InputManager:calculatePlayerStats(playerValueTable)
	-- currently this may be just for keyboards, because controllers have the opposite problem
	playerValueTable.x = playerValueTable.raw.right - playerValueTable.raw.left
	playerValueTable.y = playerValueTable.raw.down - playerValueTable.raw.up

	if self.sendMenuInputs then
		-- then deal with menu stats as well
		-- they get reset whenever you start sending menu inputs, so it's fine to stop updating these.
		-- local menuTable = {x = {timer = 0, value = 0}, y = {timer = 0, value = 0}} -- if value * the actual current x or y is negative or 0, then it should trigger the action if the current magnitude is > a parameter
		if math.abs(playerValueTable.x) > self.menuMovementThreshold then
			if playerValueTable.menu.x.timer <= 0 or playerValueTable.menu.x.value * playerValueTable.x <= 0 then
				-- then either the timer is 0, and it can do its thing, or the thumbstick was flicked really fast in the opposite direction, so it should move in that direction
				playerValueTable.menu.x.timer = self.menuMovementRepeatTime
				-- trigger that menu action pls.
				if playerValueTable.x > 0 then
					-- handle the "menuright" event
					self:distributeInput({inputtype = "menuright", player = playerValueTable.playerID})
				else
					-- we don't need an elseif, because it can't be 0
					-- handle the left event.
					self:distributeInput({inputtype = "menuleft", player = playerValueTable.playerID})
				end
			end
		else
			-- set the value to 0, and the timer to 0 as well
			playerValueTable.menu.x.value = 0
		end

		if math.abs(playerValueTable.y) > self.menuMovementThreshold then
			if playerValueTable.menu.y.timer <= 0 or playerValueTable.menu.y.value * playerValueTable.y <= 0 then
				-- then either the timer is 0, and it can do its thing, or the thumbstick was flicked really fast in the opposite direction, so it should move in that direction
				playerValueTable.menu.y.timer = self.menuMovementRepeatTime
				-- trigger that menu action pls.
				if playerValueTable.y > 0 then
					-- handle the "menudown" event, (keep in mind - is up...)
					self:distributeInput({inputtype = "menudown", player = playerValueTable.playerID})
				else
					-- we don't need an elseif, because it can't be 0
					-- handle the up event.
					self:distributeInput({inputtype = "menuup", player = playerValueTable.playerID})
				end
			end
		else
			-- set the value to 0, and the timer to 0 as well
			playerValueTable.menu.y.value = 0
		end
	end
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

	if self.sendMenuInputs and key == "escape" then
		-- send the menu back command.
		self:distributeInput({inputtype = "back", player = "mouse"})
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
end

function InputManager:getPlayerValues(playerID)
	return self.playerValues[playerID]
end

function InputManager:gamepadadded(gamepad)
	self:addControllingMethod(gamepad:getID())
	self.numGamepads = self.numGamepads + 1
end

function InputManager:addControllingMethod(key)
	local menuTable = {x = {timer = 0, value = 0}, y = {timer = 0, value = 0}} -- if value * the actual current x or y is negative or 0, then it should trigger the action if the current magnitude is > a parameter
	self.playerValues[key] = {x = 0, y = 0, playing = false, raw = {left = 0, right = 0, up = 0, down = 0, grab = 0, use = 0}, menu = menuTable, playerID = key}
	-- menu needs to be things. menu has to have timers for holding the key down moving repeatedly, it also should deal with reseting, so if you press twice it works both times...
	-- essentially, if an x or a y goes less than a certain value, or opposite the current magnitude, then it should set the timer to 0, if the x or y goes above a certain value then it should send the menu behavior
	-- plus if the timer is greater than whatever variable we choose, then it should re-trigger the menu action.
end

function InputManager:gamepadremoved(gamepad)
	self.playerValues[gamepad:getID()].playing = false
	self.numGamepads = self.numGamepads - 1
end

function InputManager:gamepadaxis(gamepad, axis, value)
	local values = self.playerValues[gamepad:getID()]
	if values == nil then
		error("JOYSTICK SOMEHOW WASN'T ADDED")
	end
	local mapping = self.gamepadAxisMapping[axis] -- this returns a table that has {negative thing, positive thing} but they could both be nil
	local didSomething = false
	if mapping[1] ~= nil then
		values.raw[mapping[1]] = -math.min(value, 0)
		didSomething = true
	end
	if mapping[2] ~= nil then
		values.raw[mapping[2]] = math.max(value, 0)
		didSomething = true
	end

	-- then recalculate the player x and y
	if didSomething then
		self:calculatePlayerStats(values)
	end
end

function InputManager:gamepadpressed(gamepad, button)
	local values = self.playerValues[gamepad:getID()]
	if values == nil then
		error("JOYSTICK SOMEHOW WASN'T ADDED")
	end
	local didSomething = false
	if self.gamepadButtonMapping[button] then
		values.raw[self.gamepadButtonMapping[button]] = 1
		didSomething = true
	end

	if didSomething then
		-- then recalculate the player x and y
		self:calculatePlayerStats(values)
	end
end

function InputManager:playerStartedPlaying()
	-- somehow we have to tell the game that a player wants to start playing. Maybe that should be a menu feature? That could actually make a ton of sense
end

function InputManager:gamepadreleased(gamepad, button)
	local values = self.playerValues[gamepad:getID()]
	if values == nil then
		error("JOYSTICK SOMEHOW WASN'T ADDED")
	end
	local didSomething = false
	if self.gamepadButtonMapping[button] then
		values.raw[self.gamepadButtonMapping[button]] = 0
		didSomething = true
	end

	if didSomething then
		-- then recalculate the player x and y
		self:calculatePlayerStats(values)
	end
end





function InputManager:mousepressed(x, y, button)
	if self.sendMenuInputs then
		self:distributeInput({inputtype = "mousepressed", x = x, y = y, button = button, value = 1, player = "mouse"})
	end
end

function InputManager:mousereleased(x, y, button)
	if self.sendMenuInputs then
		self:distributeInput({inputtype = "mousepressed", x = x, y = y, button = button, value = 0, player = "mouse"})
	end
end

function InputManager:mousemoved(x, y, dx, dy)
	if self.sendMenuInputs then
		self:distributeInput({inputtype = "mousemoved", x = x, y = y, dx = dx, dy = dy, player = "mouse"})
	end
end

-- function InputManager:textinput(text)
-- 	self:distributeInput({intype = "textinput", text = text})
-- end

function InputManager:addToInputStack(inputReceiver)
	table.insert(self.inputStack, inputReceiver)
	return true
end

function InputManager:removeFromInputStack(inputReceiver)
	local found, i = iInTable(self.inputStack, inputReceiver)
	if found then
		table.remove(self.inputStack, i)
	end
	return found
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