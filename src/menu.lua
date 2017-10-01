-- this is a class that allows creation of menus and allows for controllers to navigate around them

require "button"

Menu = class()

function Menu:_init(args)
	if not args then
		args = {}
	end
	self.x = args.x
	self.y = args.y
	self.buttons = {}
	self.buttonSpacing = 20
	self.buttonHeight = 100
	self.width = args.buttonwidth or 500
	for i, v in ipairs(args.buttons) do
		-- each should have text, leftOption, rightOption
		local args = {parent = args.parent, x = self.x, y = self.y + (i-1)*(self.buttonSpacing+self.buttonHeight), width = self.width, height = args.buttonheight, text = v.text,
								leftOption = v.leftOption, rightOption = v.rightOption}
		table.insert(self.buttons, Button(args))
	end

	self.oneSelection = args.oneSelection or false
	self.singleSelection = 1 -- this just gets changed by everyone
	self.selections = {} -- the keys are the playerUIDs passed in from the input
	self.icons = {left = {}, right = {}}
	for i, v in ipairs(args.buttons) do
		self.icons.left[i] = {}
		self.icons.right[i] = {}
	end
end

function Menu:handleinput(input)
	if self.selections[input.player] == nil then
		if not self.oneSelection then
			-- add them to the game
			self.selections[input.player] = {index = 1, color = {0, 0, 0}, string = ""}
			self:addNewPlayerIcon(input.player)
			return -- for now when you are added you can't move around
		else
			-- if it's a single selection, I'm fine with it just working off the bat...
		end
	end
	if input.inputtype == "join" then
		-- they pressed start, so let them join in
		self.selections[input.player] = {index = 1, color = {0, 0, 0}, string = ""} -- perhaps also color and player number though
		self:addNewPlayerIcon(input.player)
	elseif input.inputtype == "menuup" then
		if not self.oneSelection then
			-- move the icon
			self:removePlayerIcon(input.player)

			-- move the selection -1
			self.selections[input.player].index = self.selections[input.player].index - 1
			if self.selections[input.player].index <= 0 then
				self.selections[input.player].index = #self.buttons
			end

			-- add yourself to the icon at the new spot
			local newSpot = self.selections[input.player].index
			if #self.icons.left[newSpot] > #self.icons.right[newSpot] then
				-- add yourself to right side
				table.insert(self.icons.right[newSpot], input.player)
			else
				table.insert(self.icons.left[newSpot], input.player)
			end
		else
			self.usedSingleSelection = true
			self.singleSelection = self.singleSelection - 1
			if self.singleSelection <= 0 then
				self.singleSelection = #self.buttons
			end
		end
	elseif input.inputtype == "menudown" then
		if not self.oneSelection then
			-- move the icon
			self:removePlayerIcon(input.player)


			self.selections[input.player].index = self.selections[input.player].index + 1
			if self.selections[input.player].index > #self.buttons then
				self.selections[input.player].index = 1
			end

			-- add yourself to the icon at the new spot
			local newSpot = self.selections[input.player].index
			if #self.icons.left[newSpot] > #self.icons.right[newSpot] then
				-- add yourself to right side
				table.insert(self.icons.right[newSpot], input.player)
			else
				table.insert(self.icons.left[newSpot], input.player)
			end
		else
			self.usedSingleSelection = true
			self.singleSelection = self.singleSelection + 1
			if self.singleSelection > #self.buttons then
				self.singleSelection = 1
			end
		end
	elseif input.inputtype == "menuleft" or input.inputtype == "menuright" then
		self.usedSingleSelection = true
		if not self.oneSelection then
			self.buttons[self.selections[input.player].index]:handleinput(input)
		else
			self.buttons[self.singleSelection]:handleinput(input)
		end
	elseif input.inputtype == "mousemoved" or input.inputtype == "mousepressed" then
		for i, v in ipairs(self.buttons) do
			if v:handleinput(input) then
				return true
			end
		end
	end
	return false
end

function Menu:addNewPlayerIcon(player)
	if player == "mouse" then return end
	if #self.icons.left[1] > #self.icons.right[1] then
		-- add yourself to right side
		table.insert(self.icons.right[1], player)
	else
		table.insert(self.icons.left[1], player)
	end
end

function Menu:removePlayerIcon(player)
	if not self.selections[player] then return end
	local found, index = iInTable(self.icons.left[self.selections[player].index], player)
	if found then
		table.remove(self.icons.left[self.selections[player].index], index)
	end
	local found, index = iInTable(self.icons.right[self.selections[player].index], player)
	if found then
		table.remove(self.icons.right[self.selections[player].index], index)
	end
end

function Menu:draw()
	for i, v in ipairs(self.buttons) do
		v:draw()
	end
	if not self.oneSelection then
		for buttonIndex, listOfPlayers in pairs(self.icons.left) do
			-- draw the player icons where they should be
			-- self.icons are a table of left ={buttonindex = {list of playerIDs that are there}}, right = same
			local x = self.x - 15
			local y = self.buttons[buttonIndex].y
			for i, player in ipairs(listOfPlayers) do
				love.graphics.setColor(self.selections[player].color)
				love.graphics.rectangle("fill", x, y, 20, self.buttonHeight)
				x = x - 30
			end
		end
		for buttonIndex, listOfPlayers in pairs(self.icons.right) do
			-- draw the player icons where they should be
			-- self.icons are a table of right ={buttonindex = {list of playerIDs that are there}}, left = same
			local x = self.x + self.width + 15
			local y = self.buttons[buttonIndex].y
			for i, player in ipairs(listOfPlayers) do
				love.graphics.setColor(self.selections[player].color)
				love.graphics.rectangle("fill", x, y, 20, self.buttonHeight)
				x = x - 30
			end
		end
	elseif self.usedSingleSelection or inputManager.numGamepads > 0 then
		-- draw the white rectangle around the boxes I guesss...
		love.graphics.setColor(255, 255, 100)
		love.graphics.rectangle("line", self.x, self.buttons[self.singleSelection].y, self.width, self.buttonHeight)
	end -- otherwise don't draw, they may be using the mouse
end

function Menu:update(dt)
	for i, v in ipairs(self.buttons) do
		v:update(dt)
	end
end