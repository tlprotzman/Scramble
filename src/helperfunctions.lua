-- io.stdout:setvbuf("no") -- this is so that sublime will print things when they come (rather than buffering).


function sign(n)
	-- returns 1 if n >= 0 or -1 if n < 0
	return (n < 0 and -1 or 1)
end

function zsign(n)
	-- returns 1 if n > 0, -1 if n < 0, and 0 if n == 0
	-- I don't know if this is helpful, but hey!
	return (n < 0 and -1) or (n > 0 and 1) or 0
end

function iInTable(t, item)
	-- this goes through all of the values of a table indexed by numbers and returns the index or -1 if it can't find the item
	for i = 1, #t do
		if t[i] == item then
			return true, i
		end
	end
	return false, -1
end

function inTable(t, item)
	-- this goes through all of the key value pairs and returns the key or nil if it can't find the item
	for k, v in pairs(t) do
		if v == item then
			return true, k
		end
	end
	return false, nil
end

function rectCollision(r1, r2)
	if r1.x + r1.width > r2.x and r1.x < r2.x + r2.width then
		if r1.y + r1.height > r2.y and r1.y < r2.y + r2.height then
			return true
		end
	end
	return false -- I may want to make it return the smallest resolution vector or something...
	-- also I should probably code something that accounts for fast movement to make things nice...
end

function coordsInsideRect(x, y, rx, ry, rw, rh)
  if x > rx and x < rx + rw then
    if y > ry and y < ry + rh then
      return true
    end
  end
  return false
end


-- we may be better off using HUMP (or the trimmed down version of this below) instead of this, but it works
function class(...)
  -- "cls" is the new class
  local cls, bases = {}, {...}
  -- copy base class contents into the new class
  for i, base in ipairs(bases) do
    for k, v in pairs(base) do
      cls[k] = v
    end
  end
  -- set the class's __index, and start filling an "is_a" table that contains this class and all of its bases
  -- so you can do an "instance of" check using my_instance.is_a[MyClass]
  cls.__index, cls.is_a = cls, {[cls] = true}
  for i, base in ipairs(bases) do
    for c in pairs(base.is_a) do
      cls.is_a[c] = true
    end
    cls.is_a[base] = true
  end
  -- the class's __call metamethod
  setmetatable(cls, {__call = function (c, ...)
    local instance = setmetatable({}, c)
    -- run the init method if it's there
    local init = instance._init
    if init then init(instance, ...) end
    return instance
  end})
  -- return the new class table, that's ready to fill with methods
  return cls
end

-- -- the trimmed down version of Classname = class(), but this requires calling Classname:new(args) to make a new object
-- Classname = {}
-- function Classname:new(args)
-- 	local object = {}
-- 	setmetatable(object, self)
-- 	self.__index = self
-- 	if args ~= nil then
-- 		object:init(args)
-- 	end
-- 	return object
-- end