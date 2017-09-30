
MainMenu = class()

function MainMenu:init(args)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false
end

function MainMenu:load()
	-- run when the level is given control
end

function MainMenu:leave()
	-- run when the level no longer has control
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
	--
end