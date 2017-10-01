io.stdout:setvbuf("no") -- this is so that sublime will print things when they come (rather than buffering).

require "helperfunctions"

require "game"
require "camera"
require "inputmanager"

inputManager = InputManager()
game = Game()
camera = Camera()

function love.load(args)
	love.window.setMode(1920/2, 1080/2, {resizable = false, vsync = true, fullscreen = false})
	love.graphics.setDefaultFilter( 'nearest',  'nearest',  0 ) 
	-- love.window.setTitle("MultiFarm")
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time()) 
	game:delayedinit(args)
end

function love.update(dt)
	InputManager:update(dt)
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
	inputManager:mousepressed(button, x, y)
end

function love.mousereleased(button, x, y)
	inputManager:mousereleased(button, x, y)
end

function love.gamepadadded(gamepad)
	inputManager:gamepadadded(gamepad)
end

function love.gamepadremoved(gamepad)
	inputManager:gamepadremoved(gamepad)
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