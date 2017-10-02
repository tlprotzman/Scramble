

--[[
This is an attempt at a class to handle loading images and animations.
At a bare minimum it allows for all loading to be global and shared, and also allows for arbitrary frame animations and handling them nicer.

Usage:
pass in args to the creation, args can be:
A string filename of a file that returns a lua table divided into two sub tables, stills and animations.
the stills subtable then has sub tables of {imageKey, imageFilename}
the animations subtable has sub tables of {imageKey, numberOfFrames, firstPartOfFilename, secondPartOfFilename}
-- where the frame number (starting from 1 and including the number of frames), is combined between the first half and second half to form the full filename of each frame

It can also be a table with either:
a "filename" key, in which case it does the same as just passing the filename in.

two tables containing those subtables from above inside args.stills and args.animations.
]]--

ImageHandler = class()

function  ImageHandler:_init(args)
	if not args then
		args = {}
	end
	-- filename could be a config text
	self.images = {stills = {}, animations = {}} -- this will be sub-divided into self.images.animations and self.images.stills?
	-- animations will be keys of names leading to tables indexed from 1 to the number of frames
	-- there'll be a function to round a number to 1 if it's larger than the animation key

	if type(args) == "string" then
		local t = require args
		self:loadImages(t.stills, t.animations)
	elseif args.filename then
		local t = require args.filename
		self:loadImages(t.stills, t.animations)
	else
		self:loadImages(args.stills, args.animations)
	end
end

function ImageHandler:loadImages(stills, animations)
	-- given a list of filenames and number of frames, (and a bunch of stills) load the images
	local stills = stills or {}
	local animations = animations or {}
	for i, f in ipairs(stills) do
		-- f is a table of key, then filename
		self.images.stills[f[1]] = love.graphics.newImage(f[2])
	end
	for i, f in ipairs(animations) do
		-- f is a table of key, number of frames, first part of filename, second part of filename (the frame number is put in the middle)
		for frame = 1, animations[2] do
			self.images.animations[f[1]][frame] = love.graphics.newImage(f[3]..frame..f[4])
		end
	end
end

function ImageHandler:roundFrame(frame, animationName)
	if math.floor(frame) > #self.images.animations[animationName] then
		return 1
	end
	return frame -- keep it the same otherwise
end

function ImageHandler:getImage(frame, imageName)
	-- if frame is 0 then it's a still
	if frame < 1 then
		return self.images.stills[imageName]
	else
		return self.images.animations[imageName][math.floor(frame)]
	end
end

function ImageHandler:updateFrameCount(frame, dt, animationName)
	-- set your frame to be the return value of this function so that it'll handle everything for you.
	-- you should do this after you find what animation you're showing though, just in case the animation you really do has a smaller frame count
	return self:roundFrame(frame+dt, animationName)
end