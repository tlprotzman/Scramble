require "helperfunctions"

require "game"
require "camera"

game = Game()
camera = Camera()

function love.load(args)
	love.window.setMode(1920/2, 1080/2, {resizable = false, vsync = true, fullscreen = false})
	love.graphics.setDefaultFilter( 'nearest',  'nearest',  0 ) 
	-- love.window.setTitle("MultiFarm")
	love.math.setRandomSeed(os.time())
	math.randomseed(os.time()) 
	game:init(args)
end


function love.update(dt)
	game:update(dt)
	camera:update(dt)
end

function love.draw()
	game:draw()
end

function love.keypressed(key, unicode)
	game:keypressed(key, unicode)
end

function love.keyreleased(key, unicode)
	game:keyreleased(key, unicode)
end

function love.mousepressed(button, x, y)
	game:mousepressed(button, x, y)
end

function love.mousereleased(button, x, y)
	game:mousereleased(button, x, y)
end

-- function love.resize(w, h)
-- 	game:resize(w, h)
-- end

-- function love.textinput(text)
-- 	game:textinput(text)
-- end