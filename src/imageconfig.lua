-- sub tables are:
--[[
{key = required = name of image to use to retreive it
frames = optional, number of frames to load, if frames == nil or frames == 0 then it assumes it's a stil and won't use the frame number in the filename
filename1 = first half of filename, this is used as filename1..framenumber..filename2
filename2 = second half of filename,
filename = if neither filename1 or filename2 are used and it's a still image, then it'll use filename.
-- there may be other things like image offsets or animation settings, but not for now
}
]]


t = {
	{key = "snowball", filename = "images/assets/snowball.png"},
	{key = "selectionButton", frames = 6, filename1 = "images/assets/selectionButton", filename2 = ".png"},
	{key = "selectionArrow", frames = 7, filename1 = "images/assets/selectionArrow", filename2 = ".png"},
	{key = "playerIcon", frames = 12, filename1 = "images/assets/pointer", filename2 = ".png"},
	{key = "playerReadyIcon", frames = 9, filename1 = "images/assets/checkmark", filename2 = ".png"},
	{key = "boulder", filename = "images/assets/boulder.png"},



}


return t