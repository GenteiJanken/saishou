--[[
	Saishou Sentou - a minimal stealth game originally intended for the LD48 Compo
]]--

DEFAULT_COLOUR = {150, 150, 150}
PLAYER_COLOUR = {0, 0, 0}
ENEMY_COLOUR = {255, 0, 0}
COVER_COLOUR = {0, 255, 0}
SCROLL_COLOUR = {200, 160, 150}

SCREEN_SIZE = {800, 600}

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
		--initial x coordinate, alternate x coordinate (walks between these)
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
		--initial x coordinate, alternate x coordinate (walks between these)
		guards = {{}
		
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
		cover = {40, 60},

		--guards represented by
		--initial x coordinate, initial direction, alternate x coordinate (walks between these)
		guards = {{}, {}},

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
	--draw floor
	love.graphics.setColor(unpack(DEFAULT_COLOUR))
	love.graphics.setLine(10, "smooth")
	love.graphics.line(0, FLOOR, SCREEN_SIZE[1], FLOOR)


	--draw, guards, cover, scrolls, player
	world:draw()
	player:draw()
end


function love.keypressed(key)
	if key == ' ' then
		player:toggle_move()
	elseif key == 'escape' then
		love.event.push("quit")
	end
end

function love.keyreleased(key)
	if key == ' ' then
		player:toggle_move()
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
	love.graphics.setColor(unpack(PLAYER_COLOUR))
	love.graphics.rectangle("fill", self.pos - self.size/2, FLOOR - self.size, self.size, self.size) 
end


function player:toggle_move()
	self.velocity = self.velocity == 0 and 30 or 0
end

function player:update(dt)

	--if player has no forward velocity collisions with cover, scrolls is possible
	if self.velocity == 0  then
		
		for _, v in ipairs(world.cover) do

		end

		for _, v in ipairs(world.scrolls) do

		end


	end

	--check collisions with guard views (these count regardless of movement)

	self.pos = (self.pos + self.velocity * dt) % SCREEN_SIZE[1]
end

Guard = {}

function Guard:new(spawn, path)
	o = {} --create object
	self.pos = spawn
	self.size = 20
	self.velocity = 25
	self.path = path --indicates the 2 points guard moves between, one +x one -x
	self.currdest = self.path[2]
	setmetatable(o, self)
	self.__index = self
	return o
end


function Guard:update(dt)

	--check if at dest, if so turn
	if self.pos == self.currdest then
		self.velocity = -self.velocity
	end
	self.pos = self.pos + self.velocity * dt	
end

function Guard:draw()
	love.graphics.setColor(unpack(GUARD_COLOUR))
	love.graphics.rectangle("fill", self.pos - self.size/2, FLOOR - self.size/2, self.size, self.size) 
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
	love.graphics.setColor(unpack(COVER_COLOUR))
	love.graphics.rectangle("fill", self.pos - self.size/2, FLOOR - self.size, self.size, self.size) 
end


Scroll = {}

function Scroll:new(spawn)
	local o = {
		pos = spawn,
		size = 10
	}

	setmetatable(o, self)
	self.__index = self

	return o
end	

function Scroll:draw()
	love.graphics.setColor(unpack(SCROLL_COLOUR))
	love.graphics.rectangle("fill", self.pos - self.size, FLOOR - self.size, self.size, self.size) 
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
	end
end

function world:restart()

	player:init(LEVELS[self.leveli].spawn)
	self.guards = {}
	self.cover = {}
	self.scrolls = {}

	--place guards
	for _, v in ipairs(LEVELS[self.leveli].guards) do
		spawn = v[1] / LEVELS[self.leveli].size * SCREEN_SIZE[1]
		path = {v[2][1] / LEVELS[self.leveli].size * SCREEN_SIZE[1], 
				v[2][2] / LEVELS[self.leveli].size * SCREEN_SIZE[1],
				}
		table.insert(self.guards, Guard:new(spawn, path))
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
