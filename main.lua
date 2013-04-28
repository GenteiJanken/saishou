--[[
	Saishou Sentou - a minimal stealth game originally intended for the LD48 Compo
]]--

PLAYER_COLOUR = {0, 0, 0}
ENEMY_COLOUR = {255, 0, 0}
COVER_COLOUR = {0, 255, 0}


SCREEN_SIZE = {800, 600}

--y value all entities sit at 
FLOOR = (2 * SCREEN_SIZE[2]) /3

levels = {

	--Level 1 (just has scrolls)
	{
		--horizontal length of level
		size = 100,
		--player spawns at initial x coordinate
		spawn = 0, 
		
		--pieces of cover
		cover = {},

		--guards represented by
		--initial x coordinate, alternate x coordinate (walks between these)
		guards = {},
		--scrolls represented by x coordinate (static)
		scrolls = {}
		
	},

	--Level 2 (introduces guards)
	{
		--horizontal length of level
		size = 100,
		--player spawns at initial x coordinate
		spawn = 0, 
		
		--pieces of cover
		cover = {},


		--guards represented by
		--initial x coordinate, alternate x coordinate (walks between these)
		guards = {},

		--scrolls represented by x coordinate (static)
		scrolls = {}
		
	},

	--Level 3
	{
		--horizontal length of level
		size = 100,
		--player spawns at initial x coordinate
		spawn = 0, 
		
		--pieces of cover
		cover = {},

		--guards represented by
		--initial x coordinate, initial direction, alternate x coordinate (walks between these)
		guards = {},

		--scrolls represented by x coordinate (static)
		scrolls = {}
		
	}

}

function love.load()
	love.graphics.setMode(unpack(SCREEN_SIZE))
	love.graphics.setBackgroundColor(255, 255, 255)
	love.graphics.setCaption("Saishou")
	currlevel = levels[1]
	player:init(currlevel.spawn)
end


function love.update(dt)

	player:update(dt)
end


function love.draw()
	--draw floor
	love.graphics.setColor(0, 0, 0)
	love.graphics.setLine(10, "smooth")
	love.graphics.line(0, FLOOR, SCREEN_SIZE[1], FLOOR)

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
	self.size = 20
end


function player:draw()
	love.graphics.setColor(unpack(PLAYER_COLOUR))
	love.graphics.rectangle("fill", self.pos - self.size/2, FLOOR - self.size/2, self.size, self.size) 
end


function player:toggle_move()
	self.velocity = self.velocity == 0 and 10 or 0
end

function player:update(dt)

	--if player has no forward velocity collisions with cover, scrolls is possible
	if self.velocity == 0  then

	end

	--check collisions with guard views (these count regardless of movement)

end

function Guard:new(spawn, path)
	o = {} --create object
	self.pos = spawn
	self.size = 20
	self.velocity = 8
	self.path = path --indicates the 2 points guard moves between, one +x one -x
	self.currdest = self.path[2]
	setmetatable(o, self)
	
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

function Cover:new(spawn)
	o = {}

	setmetatable(o, self)
	return o
end


function Scroll:new(spawn)
	o = {}

	setmetatable(o, self)
	
	return o
end	


world = {}

function world:init()

end

function world:next_level()

end

function world:restart()

end

--Custom colour setter to handle alpha values

function setColour(c, a)
	love.graphics.setColor(c[1], c[2], c[3], a)
end
