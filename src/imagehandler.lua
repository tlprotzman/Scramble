

--[[
This is an attempt at a class to handle loading images and animations.
At a bare minimum it allows for all loading to be global and shared, and also allows for arbitrary frame animations and handling them nicer.

Usage:
pass in args to the creation, args can be:
A string filename of a file that returns a lua table
it then has sub tables of {imageKey, numberOfFrames, firstPartOfFilename, secondPartOfFilename}
-- where the frame number (starting from 1 and including the number of frames), is combined between the first half and second half to form the full filename of each frame
-- if the number of frames is 0 then it's a still, and the filename is simply the two parts appended together

It can also be a table with either:
a "filename" key, in which case it does the same as just passing the filename in.

a table containing the subtables from above
]]--

ImageHandler = class()

function  ImageHandler:_init(args)
	if not args then
		args = {}
	end

	self.images = {}
	-- the keys are names leading to tables indexed from 1 to the number of frames, obviously for stills it's just 1 frame
	-- there'll be a function to round a number to 1 if it's larger than the animation key

	if type(args) == "string" then
		local t = require args
		self:loadImages(t)
	elseif args.filename then
		local t = require args.filename
		self:loadImages(t)
	else
		self:loadImages(args)
	end
end

function ImageHandler:loadImages(imagesIn)
	-- given a list of filenames and number of frames, (and a bunch of stills) load the images
	local imagesIn = imagesIn or {}
	for i, f in ipairs(imagesIn) do
		-- f is a table of key, number of frames, first part of filename, second part of filename (the frame number is put in the middle)
		if f[2] <= 0 then -- it's a still image
			self.images[f[1]][1] = love.graphics.newImage(f[3]..f[4])
		else
			for frame = 1, f[2] do
				self.images[f[1]][frame] = love.graphics.newImage(f[3]..frame..f[4])
			end
		end
	end
end

function ImageHandler:roundFrame(animationName, frame)
	if math.floor(frame) > #self.images[animationName] then
		return 1
	end
	return frame -- keep it the same otherwise
end

function ImageHandler:getImage(imageName, frame)
	-- if frame is 0 or nil, then it's a still
	if not frame or frame < 1 then
		return self.images[imageName][1]
	else
		return self.images[imageName][math.floor(frame)]
	end
end

function ImageHandler:updateFrameCount(frame, dt, animationName)
	-- set your frame to be the return value of this function so that it'll handle everything for you.
	-- you should do this after you find what animation you're showing though, just in case the animation you really do has a smaller frame count
	return self:roundFrame(frame+dt, animationName)
end