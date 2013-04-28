--[[
	Saishou Sentou - a minimal stealth game originally intended for the LD48 Compo
]]--




COLOURS = {
	DEFAULT = {150, 150, 150},
	PLAYER = {0, 0, 0},
	GUARD = {255, 0, 0},
	COVER = {0, 255, 0},
	SCROLL = {200, 160, 150}
}
SCREEN_SIZE = {800, 600}

IMAGES = {
	BG = love.graphics.newImage("bg.png"),
	NINJA = love.graphics.newImage("ninsmall.png"),
	GUARD = love.graphics.newImage("tekismall.png"),
	SCROLL = love.graphics.newImage("scroll.png"),
	COVER = love.graphics.newImage("tokusmall.png")
	
}

SOUNDS = {


}

--y value all entities sit at 
FLOOR = (2 * SCREEN_SIZE[2]) / 3

LEVELS = {

	--Level 1 (just has scrolls)
	{
		--horizontal length of level
		size = 100,
		--player spawns at initial x coordinate
		spawn = 10, 
		
		--pieces of cover
		cover = {90},

		--guards represented by
		--initial x coordinate, initial dir, alternate x coordinate (walks between these)
		guards = {},
		--scrolls represented by x coordinate (static)
		scrolls = {40, 60, 80}		
	},

	--Level 2 (introduces guards)
	{
		--horizontal length of level
		size = 100,
		--player spawns at initial x coordinate
		spawn = 10, 
		
		--pieces of cover
		cover = {40, 60},


		--guards represented by
		--initial x coordinate, intial dir, alternate x coordinate (walks between these)
		guards = {
					{
						spawn =	35,
						dir = 1,
						path = {35, 70}
					}
		
		},

		--scrolls represented by x coordinate (static)
		scrolls = {30, 50, 70}
	},

	--Level 3
	{
		--horizontal length of level
		size = 100,
		--player spawns at initial x coordinate
		spawn = 10, 
		
		--pieces of cover
		cover = {40, 60, 80},

		--guards represented by
		--initial x coordinate, initial direction, alternate x coordinate (walks between these)
		guards = {
					{
						spawn =	35,
						dir = 1,
						path = {35, 70}
					},
					{
						spawn =	70,
						dir = -1,
						path = {70, 35}
					}
 
		},

		--scrolls represented by x coordinate (static)
		scrolls = {80}
	}
}

function love.load()
	love.graphics.setMode(unpack(SCREEN_SIZE))
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.setCaption("Saishou")
	world:init()
end


function love.update(dt)

	world:update(dt)
	player:update(dt)

end


function love.draw()
	--draw background
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(IMAGES.BG, 0, 0)
	--draw floor
	love.graphics.setColor(unpack(COLOURS.DEFAULT))
	love.graphics.setLine(10, "smooth")
	love.graphics.line(0, FLOOR, SCREEN_SIZE[1], FLOOR)


	--draw, guards, cover, scrolls, player
	world:draw()
	player:draw()
end


function love.keypressed(key)
	if key == ' ' then
		player.velocity = 50
	elseif key == 'escape' then
		love.event.push("quit")
	end
end

function love.keyreleased(key)
	if key == ' ' then
		player.velocity = 0
	end
end

player = {}


function player:init(spawn)
	self.pos = spawn
	self.velocity = 0
	self.hidden = false
	self.size = 40
end


function player:draw()
	
	if self.hidden then
		love.graphics.setColor(255, 255, 255, 125)
	else
		love.graphics.setColor(255, 255, 255, 255)
	end
	--love.graphics.rectangle("fill", self.pos - self.size/2, FLOOR - self.size, self.size, self.size) 
	love.graphics.draw(IMAGES.NINJA, self.pos - self.size/2, FLOOR - self.size, 0, 0.5, 0.5, 0, 0)
	love.graphics.setColor(255, 255, 255, 255)
end


function player:toggle_move()
	self.velocity = self.velocity == 0 and 50 or 0
end

function player:update(dt)

	--if player has no forward velocity collisions with cover, scrolls is possible
	if self.velocity == 0  then
		--check cover
		for _, v in ipairs(world.cover) do
			if distance(self.pos, v.pos) <= v.size then
				self.hidden = true
			end
		end
		--check scrolls
		for i, v in ipairs(world.scrolls) do
			if distance(self.pos, v.pos) <= v.size then
				table.remove(world.scrolls, i)
				break
			end

		end
	else
		self.hidden = false

	end

	--check collisions with guard views (these count regardless of movement)
	for _, v in ipairs(world.guards) do

		if distance(self.pos, v.pos) <= v.size  and v:in_front(self.pos) and not self.hidden  then
			world:restart() --FAILURE
		end
	end
	
	self.pos = (self.pos + self.velocity * dt) % SCREEN_SIZE[1]
	self.hidden = false --
end

Guard = {}

function Guard:new(spawn, path, dir)
	--create object
	local o = {
		pos = spawn,
		size = 40,
		velocity = dir * 40,
		path = path --indicates the 2 points guard moves between, one +x one -x
	} 
		o.currdest = path[2]		

	setmetatable(o, self)
	self.__index = self
	return o
end


function Guard:update(dt)

	--check if at dest, if so turn
	if (self:dir() == 1 and self.pos >= self.currdest) or (self:dir() ==-1 and self.pos <= self.currdest) then
		self.velocity = -self.velocity
		self.currdest = self.currdest == path[2] and path[1] or path[2]
	end
	self.pos = self.pos + self.velocity * dt	
end

function Guard:draw()
	love.graphics.draw(IMAGES.GUARD, self.pos - self.size/2, FLOOR - self.size*1.2, 0, 0.5, 0.5, 0, 0)
end

function Guard:dir()
	return self.velocity / math.abs(self.velocity)
end

--checks if a position is in in the Guard's current trajectory
function Guard:in_front(pos)
	if self:dir() == -1 then
		return pos <= self.pos
	elseif self:dir() == 1 then
		return pos >= self.pos
	end
end

Cover = {}

function Cover:new(spawn)

	local o = {
		pos = spawn,
		size = 60
	}
	setmetatable(o, self)
	self.__index = self

	return o
end

function Cover:draw()
	love.graphics.setColor(255, 255, 255)
	--love.graphics.rectangle("fill", self.pos - self.size/2, FLOOR - self.size, self.size, self.size) 
	love.graphics.draw(IMAGES.COVER, self.pos - self.size/2, FLOOR - self.size, 0, 0.6, 0.6, 0, 0)
end


Scroll = {}

function Scroll:new(spawn)
	local o = {
		pos = spawn,
		size = 50
	}

	setmetatable(o, self)
	self.__index = self

	return o
end	

function Scroll:draw()

	--love.graphics.rectangle("fill", self.pos - self.size, FLOOR - self.size, self.size, self.size) 
	love.graphics.draw(IMAGES.SCROLL, self.pos - self.size, FLOOR - self.size )
end

world = {}

function world:init()
	self.leveli = 1

	self:restart()
end

function world:next_level()

	if self.leveli < #LEVELS then
		self.leveli = self.leveli + 1
		self:restart()
	else
		
	end
end

function world:restart()

	player:init(LEVELS[self.leveli].spawn)
	self.guards = {}
	self.cover = {}
	self.scrolls = {}

	--place guards
	for _, v in ipairs(LEVELS[self.leveli].guards) do
		spawn = v.spawn / LEVELS[self.leveli].size * SCREEN_SIZE[1]
		path = {v.path[1] / LEVELS[self.leveli].size * SCREEN_SIZE[1], 
				v.path[2] / LEVELS[self.leveli].size * SCREEN_SIZE[1],
				}
		table.insert(self.guards, Guard:new(spawn, path, v.dir))
	end
	
	--place cover
	for _, v in ipairs(LEVELS[self.leveli].cover) do

		spawn = v / LEVELS[self.leveli].size * SCREEN_SIZE[1]
		table.insert(self.cover, Cover:new(spawn))
	end
	
	--place scrolls
	for _, v in ipairs(LEVELS[self.leveli].scrolls) do
		spawn = v / LEVELS[self.leveli].size * SCREEN_SIZE[1]
		table.insert(self.scrolls, Scroll:new(spawn))
	end


end

function world:update(dt)

	--if scrolls are all collected, advance	
	if #self.scrolls == 0 then
		self:next_level()
	end

	for _, v in ipairs(self.guards) do
		v:update(dt)
	end
end

function world:draw()

	--draw guards
	for _, v in ipairs(self.guards) do
		v:draw()
	end
	--draw cover
	for _, v in ipairs(self.cover) do
		v:draw()
	end
	--draw scrolls
	for _, v in ipairs(self.scrolls) do
		v:draw()
	end
end

--Custom colour setter to handle alpha values
function setColour(c, a)
	love.graphics.setColor(c[1], c[2], c[3], a)
end

function distance(x1, x2)
	return math.abs(x1 - x2)
end
