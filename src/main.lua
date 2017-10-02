io.stdout:setvbuf("no") -- this is so that sublime will print things when they come (rather than buffering).

require "helperfunctions"

require "game"
require "camera"
require "inputmanager"
require "soundmanager"


inputManager = InputManager()
game = Game()
camera = Camera()

soundManager = SoundManager(game, game.gameplay, "soundconfig.txt")

images = {}

function love.load(args)
	-- this is the draw type to make things pixel perfect:
	love.graphics.setDefaultFilter( 'nearest',  'nearest',  0 )
	loadImages()

	love.math.setRandomSeed(os.time())
	math.randomseed(os.time()) 
	game:delayedinit(args)
end

function loadPlayerImages()
	images.player = {}
	loadPlayerImageOfType("running", 14)
	loadPlayerImageOfType("runningPickUp", 14)
	loadPlayerImageOfType("idle", 7)
	loadPlayerImageOfType("idlePickUp", 7)
	loadPlayerImageOfType("fallDown", 5)
	loadPlayerImageOfType("jumpUp", 5)
	loadPlayerImageOfType("turn", 2)
	loadPlayerImageOfType("turnPickUp", 2)
	loadPlayerImageOfType("frontGrab", 6)
	loadPlayerImageOfType("shimmy", 5)
	loadPlayerImageOfType("pullUp", 13)
	loadPlayerImageOfType("pullOff", 10)
	loadPlayerImageOfType("celebration", 18)
end

function loadPlayerImageOfType(name, frames)
	images.player[name.."Images"] = {{}, {}, {}}
	for i = 1, frames do
		images.player[name.."Images"][1][i] = love.graphics.newImage("images/player/"..name.."Skin"..i..".png")
		images.player[name.."Images"][2][i] = love.graphics.newImage("images/player/"..name.."Clothes"..i..".png")
		images.player[name.."Images"][3][i] = love.graphics.newImage("images/player/"..name.."Lines"..i..".png")
	end
end

function loadImages()
	images.snowballImage = love.graphics.newImage("images/assets/snowball.png")
	images.selectionButton = {}
	for i = 1, 6 do
		table.insert(images.selectionButton, love.graphics.newImage("images/assets/selectionButton"..i..".png"))
	end
	images.selectionArrow = {}
	for i = 1, 7 do
		table.insert(images.selectionArrow, love.graphics.newImage("images/assets/selectionArrow"..i..".png"))
	end
	loadPlayerImages()
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