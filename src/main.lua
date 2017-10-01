io.stdout:setvbuf("no") -- this is so that sublime will print things when they come (rather than buffering).

require "helperfunctions"

require "game"
require "camera"
require "inputmanager"

inputManager = InputManager()
game = Game()
camera = Camera()

function love.load(args)
	-- this is the draw type to make things pixel perfect:
	love.graphics.setDefaultFilter( 'nearest',  'nearest',  0 ) 


	love.math.setRandomSeed(os.time())
	math.randomseed(os.time()) 
	game:delayedinit(args)
end

function love.update(dt)
	inputManager:update(dt)
	game:update(dt)
	camera:update(dt)
end

function love.draw()
	game:draw()
end

function love.keypressed(key, unicode)
	game:keypressed(key, unicode) -- still keeping this around because of quitting with escape, we should remove this
	inputManager:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	inputManager:keyreleased(key, unicode)
end

function love.mousepressed(button, x, y)
	inputManager:mousepressed(button, game:realToFakeMouse(x, y))
end

function love.mousereleased(button, x, y)
	inputManager:mousereleased(button, game:realToFakeMouse(x, y))
end

function love.mousemoved(x, y, dx, dy)
	inputManager:mousemoved(game:realToFakeMouse(x, y), dx, dy)
end

function love.joystickadded(gamepad)
	if gamepad:isGamepad() then
		inputManager:gamepadadded(gamepad)
	end
end

function love.joystickremoved(gamepad)
	if gamepad:isGamepad() then
		inputManager:gamepadremoved(gamepad)
	end
end

function love.gamepadaxis(gamepad, axis, value)
	inputManager:gamepadaxis(gamepad, axis, value)
end

function love.gamepadpressed(gamepad, button)
	inputManager:gamepadpressed(gamepad, button)
end

function love.gamepadreleased(gamepad, button)
	inputManager:gamepadreleased(gamepad, button)
end

-- function love.resize(w, h)
-- 	game:resize(w, h)
-- end

-- function love.textinput(text)
-- 	game:textinput(text)
-- end