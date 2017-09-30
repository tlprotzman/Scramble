require "platform"
require "player"

Gameplay = class()

function Gameplay:_init(game)
	-- this is for the draw stack
	self.game = game
	self.player = Player(self.game)
	self.platforms = {}
	
	--camera.d.y = 10
	
	self.drawUnder = false
	self.updateUnder = false

	table.insert(self.platforms, Platform(250, 350, 250, "wood"))
end

function Gameplay:load()
	-- run when the level is given control
end

function Gameplay:leave()
	-- run when the level no longer has control
end

function Gameplay:draw()

	camera:rectangle("fill", 100, 100, 100, 100)
	
	for i, v in ipairs(self.platforms) do
		v:draw()
	end
	self.player:draw()
	love.graphics.print(camera.pos.y, 10, 10)
end

function Gameplay:update(dt)
	self.player:update(dt, self.platforms)
end

function Gameplay:resize(w, h)
	--
end

function Gameplay:handleinput(input)
	--
end