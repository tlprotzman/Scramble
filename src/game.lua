
require "mainmenu"
require "gameplay"
require "prerunmenu"

Game = class()
MainFont = { love.graphics.newFont("fonts/ferrum.otf", 3), love.graphics.newFont("fonts/ferrum.otf", 72), love.graphics.newFont("fonts/ferrum.otf", 144) }


function Game:delayedinit(args)
	self.args = args

	-- self.inputManager = InputManager({inputStack = {self}})
	self.debug = true

	-- self.font = love.graphics.newFont(13)
	self.gameplay = Gameplay(self)

	self.mainMenu = MainMenu()
	self.preRunMenu = PreRunMenu()

	self.screenStack = {}
	self.drawLayersStart = 0

	self:addToScreenStack(self.mainMenu)
	-- self:addToScreenStack(self.preRunMenu)
	-- self:addToScreenStack(self.gameplay)

	-- these are things for scaling the screen
	self.SCREENWIDTH = 1920
	self.SCREENHEIGHT = 1080
	self.fullCanvas = love.graphics.newCanvas(self.SCREENWIDTH, self.SCREENHEIGHT)
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
	-- this is for screen scaling:
	love.graphics.setCanvas(self.fullCanvas)
	love.graphics.clear()

	love.graphics.setBackgroundColor(200, 230, 255)
	
	for i = self.drawLayersStart, #self.screenStack, 1 do
		self.screenStack[i]:draw()
	end

	if self.debug then
		love.graphics.setColor(255, 0, 0)
		love.graphics.setFont(MainFont[1])
		love.graphics.print("FPS: "..love.timer.getFPS(), 10, 1080-45)
		love.graphics.setColor(255, 255, 255)
	end


	-- this is also for screen scaling:
	love.graphics.setCanvas()
	love.graphics.setColor(255, 255, 255)
	if true or self.fullscreen then
		local width = love.graphics.getWidth()
		local height = love.graphics.getHeight()
		local scale = math.min(height/1080, width/1920)
		-- width/2-300*scale
		love.graphics.draw(self.fullCanvas, width/2-1920/2*scale, height/2-1080/2*scale, 0, scale, scale)
		love.graphics.setColor(0, 0, 0)
		-- the left and right bars
		love.graphics.rectangle("fill", 0, 0, width/2-1920/2*scale, height)
		love.graphics.rectangle("fill", width/2+1920/2*scale, 0, width/2-1920/2*scale, height)
		-- the top and bottom bars
		-- love.graphics.setColor(255, 0, 0)
		love.graphics.rectangle("fill", 0, 0, width, height/2-1080/2*scale)
		love.graphics.rectangle("fill", 0, height, width, -(height/2-1080/2*scale))
		love.graphics.setColor(255, 255, 255)
	else
		local scale = math.min(love.graphics.getHeight()/1080, love.graphics.getWidth()/1920)
		love.graphics.draw(self.fullCanvas, 0, 0, 0, scale, scale)
	end
end

function Game:realToFakeMouse(x, y)
	-- converts from what the screen sees to what the game wants to see
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local scale = math.min(height/1080, width/1920)
	if false and not self.fullscreen then
		return x/scale, y/scale
	else
		return (x-(width/2-1920/2*scale))/scale, (y-(height/2-1080/2*scale))/scale -- returns two numbers that are the x and y as though the screen were 1920, 1080
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
