

--[[
This is an attempt at a class to handle loading images and animations.
At a bare minimum it allows for all loading to be global and shared, and also allows for arbitrary frame animations and handling them nicer.

Usage:
pass in args to the creation, args can be:
A string filename of a file that returns a lua table
it then has sub tables of {key = imageKey, frames = numberOfFrames, filename1 = firstPartOfFilename, filename2 = secondPartOfFilename}
-- where the frame number (starting from 1 and including the number of frames), is combined between the first half and second half to form the full filename of each frame
-- if the number of frames is 0 then it's a still, and the filename is simply the two parts appended together

It can also be a table with either:
a "filename" key, in which case it does the same as just passing the filename in.

a table containing the subtables from above
]]--

ImageManager = class()

function  ImageManager:_init(args)
	if not args then
		args = {}
	end
	self.images = {}
	-- the keys are names leading to tables indexed from 1 to the number of frames, obviously for stills it's just 1 frame
	-- there'll be a function to round a number to 1 if it's larger than the animation key

	if type(args) == "string" then
		local t = require(args)
		self:loadImages(t)
	elseif args.filename then
		local t = require(args.filename)
		self:loadImages(t)
	else
		self:loadImages(args)
	end
end

function ImageManager:loadImages(imagesIn)
	-- given a list of filenames and number of frames, (and a bunch of stills) load the images
	local imagesIn = imagesIn or {}
	for i, f in ipairs(imagesIn) do
		-- f is a table of key, number of frames, first part of filename, second part of filename (the frame number is put in the middle)
		if f.key == nil then
			if debug then
				print("Error loading image table -- key == nil")
			end
		elseif f.frames == nil or f.frames <= 0 then -- it's a still image
			local filename = ""
			if f.filename1 ~= nil then
				filename = filename .. f.filename1
			end
			if f.filename2 ~= nil then 
				filename = filename .. f.filename2
			end
			if f.filename ~= nil and filename == "" then
				filename = f.filename -- totally replace the filename with f.filename
			end
			self.images[f.key] = {}
			self.images[f.key][1] = love.graphics.newImage(filename)
			if debug then
				print("Successfully loaded still '"..tostring(f.key).."' from filename '"..tostring(filename).."'")
			end
		else
			self.images[f.key] = {}
			for frame = 1, f.frames do
				self.images[f.key][frame] = love.graphics.newImage(f.filename1..frame..f.filename2)
			end
			if debug then
				print("Successfully loaded animation '"..tostring(f.key).."' from filenames '"..tostring(f.filename1).."[frame]"..tostring(f.filename2).."'")
			end
		end
	end
end

function ImageManager:roundFrame(animationName, frame)
	if math.floor(frame) > #self.images[animationName] then
		return 1
	end
	return frame -- keep it the same otherwise
end

function ImageManager:getImage(imageName, frame)
	-- if frame is 0 or nil, then it's a still, so get frame 1
	if not frame or frame < 1 then
		return self.images[imageName][1]
	else
		return self.images[imageName][math.floor(frame)]
	end
end

function ImageManager:updateFrameCount(animationName, frame, dt)
	-- set your frame to be the return value of this function so that it'll handle everything for you.
	-- you should do this after you find what animation you're showing though, just in case the animation you really do has a smaller frame count
	return self:roundFrame(animationName, frame+dt)
end

function ImageManager:getRandomFrame(animationName)
	-- returns a random frame, used to offset the animations
	return math.random(1, #self.images[animationName])
end