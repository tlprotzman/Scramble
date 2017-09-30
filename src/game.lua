
require "mainmenu"
require "gameplay"

Game = class()

function Game:init(args)
	self.args = args

	-- self.inputManager = InputManager({inputStack = {self}})
	self.debug = true

	-- self.font = love.graphics.newFont(13)
	self.gameplay = Gameplay()

	self.mainMenu = MainMenu()

	self.screenStack = {}
	self.drawLayersStart = 0

	self:addToScreenStack(self.gameplay)
end

function Game:calculateDrawUpdateLevels()
	self.drawLayersStart = 1 -- this will become the index of the lowest item to draw
	for i = #self.screenStack, 1, -1 do
		self.drawLayersStart = i
		if not self.screenStack[i].drawUnder then
			break
		end
	end
end

function Game:addToScreenStack(newScreen)
	if self.screenStack[#self.screenStack] ~= nil then
		self.screenStack[#self.screenStack]:leave()
	end
	self.screenStack[#self.screenStack+1] = newScreen
	newScreen:load()
	self:calculateDrawUpdateLevels()
end

function Game:popScreenStack()
	self.screenStack[#self.screenStack]:leave()
	self.screenStack[#self.screenStack] = nil
	self.screenStack[#self.screenStack]:load()
	self:calculateDrawUpdateLevels()
end

function Game:draw()
	-- this is so that the things earlier in the screen stack get drawn first, so that things like pause menus get drawn on top.
	for i = self.drawLayersStart, #self.screenStack, 1 do
		self.screenStack[i]:draw()
	end

	if self.debug then
		love.graphics.setColor(255, 0, 0)
		love.graphics.print("FPS: "..love.timer.getFPS(), 10, love.graphics.getHeight()-45)
		love.graphics.setColor(255, 255, 255)
	end
end

function Game:update(dt)
	-- self.joystickManager:update(dt)
	for i = #self.screenStack, 1, -1 do
		self.screenStack[i]:update(dt)
		if self.screenStack[i] and not self.screenStack[i].updateUnder then
			break
		end
	end
end

function Game:resize(w, h)
	self.screenStack[#self.screenStack]:resize(w, h)
end

function Game:handleinput(input)
	return self.screenStack[#self.screenStack]:handleinput(input)
end

function Game:keypressed(key, unicode)
	if key == "f1" then
		love.event.quit()
	elseif key == "escape" then
		if #self.screenStack == 1 then
			love.event.quit()
		end
	end
end


-- function Game:textinput(text)
-- 	inputManager:textinput(text)
-- end

-- function love.gamepadpressed()
-- 	--
-- end
