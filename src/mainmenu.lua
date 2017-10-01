
require "menu"

MainMenu = class()

function MainMenu:_init(args)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false

	self.backgroundImage = love.graphics.newImage("images/assets/titleBackground.png")

	local menuButtons = {{text = "Play", rightOption = self.playButtonPressed},
							{text = "Credits", rightOption = self.creditsButton},
							{text = "Quit", leftOption = self.quitButton}}
	self.menu = Menu{parent = self, x = 4*1920/5-250, y = 100, buttonwidth = 500, buttons = menuButtons, oneSelection = true}
end


function MainMenu:playButtonPressed(text, player)
	-- ignore text
	game:addToScreenStack(game.preRunMenu)
	if player ~= "mouse" then
		-- then pretend it pressed join so that it's already a part of the next menu, wouldn't that be nice?
		game.preRunMenu:handleinput({inputtype = "join", player = player})
	end
end

function MainMenu:creditsButton(text)
	-- launch the credits window
end

function MainMenu:quitButton(text)
	love.event.quit()
end



function MainMenu:load()
	-- run when the level is given control
	inputManager:setSendMenuInputs(true) -- distribute things to the handleinput functions of all members of the screen stack.
	inputManager:addToInputStack(self)
	-- everyone should be able to control the main menu probably
	inputManager:ownMenu() -- leave it blank to let anyone control it
	love.mouse.setVisible(true)
end

function MainMenu:leave()
	-- run when the level no longer has control
	inputManager:setSendMenuInputs(false)
	inputManager:removeFromInputStack(self)
	love.mouse.setVisible(false)
end

function MainMenu:draw()
	love.graphics.draw(self.backgroundImage, 0, 0)
	self.menu:draw()
end

function MainMenu:update(dt)
	self.menu:update(dt)
end

function MainMenu:resize(w, h)
	--
end

function MainMenu:handleinput(input)
	-- return true if it did handle the input, which it should if it's on the top of the screen stack
	return self.menu:handleinput(input) -- if it returns true then it will no longer pass it further down the screen stack
end