require "player"

Gameplay = class()

function Gameplay:_init(game)
	-- this is for the draw stack
	self.game = game
	self.player = Player(self.game)
	self.platforms = {}
	
	self.drawUnder = false
	self.updateUnder = false
end

function Gameplay:load()
	-- run when the level is given control
end

function Gameplay:leave()
	-- run when the level no longer has control
end

function Gameplay:draw()
	self.player:draw()
	love.graphics.rectangle("fill", 100, 100, 100, 100)
	for i, v in ipairs(self.platforms) do
		v:draw()
	end
end

function Gameplay:update(dt)
	self.player:movePlayer(dt)
end

function Gameplay:resize(w, h)
	--
end

function Gameplay:handleinput(input)
	--
end