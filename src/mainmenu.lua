
MainMenu = class()

function MainMenu:init(args)
	-- this is for the draw stack
	self.inputManager = args.inputManager
	self.drawUnder = false
	self.updateUnder = false
end

function MainMenu:load()
	-- run when the level is given control
	inputManager.sendMenuInputs = true -- distribute things to the handleinput functions of all members of the screen stack.
	-- everyone should be able to control the main menu probably
	inputManager:ownMenu() -- leave it blank to let anyone control
end

function MainMenu:leave()
	-- run when the level no longer has control
	inputManager.sendMenuInputs = false
end

function MainMenu:draw()
	--
end

function MainMenu:update(dt)
	--
end

function MainMenu:resize(w, h)
	--
end

function MainMenu:handleinput(input)
	-- return true if it did handle the input, which it should if it's on the top of the screen stack
	return true -- then it will no longer pass it further down the screen stack
end