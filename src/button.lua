
--[[
This a button class which does magic things
It has left and right buttons that do things
If you use the mouse you can just click on the play, or on the right arrow
if you use the controllers however you have to use the right side thing? or the jump button as well would work unless you're using the up as jump...
]]--

Button = class()

function Button:_init(args)
	self.parent = args.parent
	self.x = args.x
	self.y = args.y
	self.width = args.width or 500
	self.height = args.height or 100
	self.leftOption = args.leftOption -- pass in nil if there's no option for that side, it's a function that's called when that option is chosen
	self.rightOption = args.rightOption
	self.text = args.text or ""

	self.leftSelected = false
	self.rightSelected = false

	self.arrowWidth = args.arrowWidth or 50
	self.arrowSpacing = args.arrowSpacing or 5 -- the space between the main text and the arrow
end

function Button:setColor(selected)
	if selected then
		love.graphics.setColor(60, 70, 90)
	else
		love.graphics.setColor(100, 110, 130)
	end
end

function Button:draw()
	self:setColor((self.leftSelected and self.leftOption) or (self.rightSelected and self.rightOption))
	local fullArrowWidth = self.arrowWidth + self.arrowSpacing
	love.graphics.rectangle("fill", self.x+fullArrowWidth, self.y, self.width-2*fullArrowWidth, self.height)
	love.graphics.setColor(255, 255, 255)
	love.graphics.printf(self.text, self.x+fullArrowWidth, self.y, self.width-2*fullArrowWidth)
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", self.x+fullArrowWidth, self.y, self.width-2*fullArrowWidth, self.height)
	if self.leftOption then
		self:setColor(self.leftSelected)
		self:drawArrow(false)
	end
	if self.rightOption then
		self:setColor(self.rightSelected)
		self:drawArrow(true)
	end
end

function Button:drawArrow(isRightSide)
	local x = isRightSide and (self.x + self.width - self.arrowWidth) or self.x
	local y = self.y
	local width = self.arrowWidth
	local height = self.height
	love.graphics.rectangle("fill", x, y, width, height)
	love.graphics.setColor(255, 255, 255)
	-- draw the arrow
	if isRightSide then
		love.graphics.line(x, y, x+width, y+height/2)
		love.graphics.line(x, y+height, x+width, y+height/2)
	else
		love.graphics.line(x+width, y, x, y+height/2)
		love.graphics.line(x+width, y+height, x, y+height/2)
	end
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("line", x, y, width, height)
end

function Button:update(dt)
	--
end

function Button:handleinput(input)
	if input.inputtype == "mousemoved" then
		if not (self.leftOption and self.rightOption) then
			self.leftSelected = coordsInsideRect(love.mouse.getX(), love.mouse.getY(), self.x, self.y, self.width, self.height)
			self.rightSelected = self.leftSelected
		else
			-- check both sides independently
			local mx = love.mouse.getX()
			local my = love.mouse.getY()
			self.leftSelected = coordsInsideRect(mx, my, self.x, self.y, self.arrowWidth, self.height)
			self.rightSelected = coordsInsideRect(mx, my, self.x + self.width - self.arrowWidth, self.y, self.arrowWidth, self.height)
		end
	elseif input.inputtype == "mousepressed" and input.value == 0 then
		if self.rightSelected and self.rightOption then
			-- press the right option
			self.rightOption(self.parent, self.text, input.player)
			return true
		elseif self.leftSelected and self.leftOption then
			-- the left option
			self.leftOption(self.parent, self.text, input.player)
			return true
		end
	elseif input.inputtype == "menuright" then
		if self.rightOption then
			self.rightOption(self.parent, self.text, input.player)
			return true
		end
	elseif input.inputtype == "menuleft" then
		if self.leftOption then
			self.leftOption(self.parent, self.text, input.player)
			return true
		end
	end
	return false
end