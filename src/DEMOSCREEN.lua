
Screen = class()


function Screen:init(args)
	-- this is for the draw stack
	self.drawUnder = false
	self.updateUnder = false
end

function Screen:load()
	-- run when the level is given control
end

function Screen:leave()
	-- run when the level no longer has control
end

function Screen:draw()
	--
end

function Screen:update(dt)
	--
end

function Screen:resize(w, h)
	--
end

function Screen:handleinput(input)
	--
end