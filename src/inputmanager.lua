
InputManager = class()


function InputManager:init(args)
	self.context = args.context or "menu"
	self.menumap = {space = "select", up = "up", down = "down", left = "left", right = "right", enter = "select"}
	self.gameplaymap = {w = "moveup", a = "moveleft", s = "movedown", d = "moveright", ["-"] = "zoomout", ["="]="zoomin", space = "test", f2 = "fullscreen", escape = "pause"}
	self.allmaps = args.allmaps or {menu = self.menumap, gameplay = self.gameplaymap}
	self.valuemap = {}
	self.mouseX = love.mouse.getX()
	self.mouseY = love.mouse.getY()

	-- I'm going to need to deal with contexts for this.

	self.inputBuffer = {}
	-- this is a list of all inputs along with delays until the next input, along with context at the time of the input, all so that it can recreate
	-- things for multiplayer.
	-- 1 = {input = "inputType", value = "inputValue", dt = time until next input or -1, time = time it occured, context = "context input was made in"}
	-- we only care about the first context, since that was what was confirmed. All the other contexts should be re-evaluated after you get an input confirmation by the
	-- server. That way we avoid having issues like opening chests when we shouldn't have, and instead we open the player's inventory instead of closing the chest.

	self.inputStack = args.inputStack or {} -- this is so that things can claim the inputs
end

function InputManager:pruneInputHistory(pruneTime)
	-- walk through the history list and remove all the things before the time.
	local i = 1
	for i, input in ipairs(self.inputBuffer) do
		if input.time > pruneTime then
			break
		end
	end
	for i = i -1, 1, -1 do
		table.remove(self.inputBuffer, i)
	end
end

--[[
I think what needs to happen is that everything has to be undoable? So that when something is confirmed or denied, what happens is that the input manager prunes to that time,
the client unwinds everything, then the changes are made (or not made? If it accepts it then do we need to do this? probably not.), then the inputs are all re-simulated, (and the
things not controlled by the player are just stepped forward however they are.) -- what happens when you hit someone in the re-wind but not the original?

This farming game is pretty basic. The only things we may need to be able to roll back are ground types (i.e. both people try to plant something at the same time, or chop down a
tree, or whatever.) and there's also animal attraction, but that doesn't need to be rolled back neccisarily, since it can just occur, and be less precise. I may want leads though,
but that's a simple thing of "lead denied" and the lead will just stop. The planting issue is easy as well since the server will just send the definitive ground type when it
occurs. Thus all that needs to happen in this game is re-simulation of movements based on the confirmed player location.

Next games will be harder, but that's fine. For now we can do this.

My goal is to do things. I want to have the base game done within the week. I can work on art later. For now I want to do collision and changing the ground type on the test
client. I should then make a fake networking connection between the server and the real client to test things easier? May as well.
]]

function InputManager:update(dt)
	self.mouseX = love.mouse.getX()
	self.mouseY = love.mouse.getY()
end

function InputManager:keypressed(key, unicode)
	if self.allmaps[self.context][key] then -- it's mapped to an input
		self:distributeInput({intype = "input", input = self.allmaps[self.context][key], value = 1, raw = key})
	else
		-- just send the raw keypress
		self:distributeInput({intype = "raw", value = 1, raw = key})
	end
end

function InputManager:keyreleased(key, unicode)
	if self.allmaps[self.context][key] then -- it's an actual input
		self:distributeInput({intype = "input", input = self.allmaps[self.context][key], value = 0, raw = key})
	else
		-- send the raw keypress
		self:distributeInput({intype = "raw", value = 0, raw = key})
	end
end

function InputManager:setContext(newContext)
	self.context = newContext
end

function InputManager:mousepressed(x, y, button)
	self:distributeInput({intype = "mousepressed", x = x, y = y, button = button, value = 1})
end

function InputManager:mousereleased(x, y, button)
	self:distributeInput({intype = "mousepressed", x = x, y = y, button = button, value = 0})
end

function InputManager:mousemoved(x, y, dx, dy)
	self:distributeInput({intype = "mousemoved", x = x, y = y, dx = dx, dy = dy})
end

function InputManager:textinput(text)
	self:distributeInput({intype = "textinput", text = text})
end

function InputManager:addToInputStack(inputReceiver)
	-- this is for things like text entry boxes which can claim inputs, so that you can't select menu buttons with space while entering things for example
	-- I'm not quite certain the best way to do this, since there are things like textinput and keypressed, which currently create two separate inputs.
	-- There probably will have to be some sort of stack thing though, and a way to remove yourself from the stack.
	table.insert(self.inputStack, inputReceiver)
	return true
end

function InputManager:removeFromInputStack(inputReceiver)
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