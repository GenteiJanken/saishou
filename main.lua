--[[
	Saishou Sentou - a minimal stealth game originally intended for the LD48 Compo
]]--

PLAYER_COLOUR = {0, 0, 0}
ENEMY_COLOUR = {255, 0, 0}
COVER_COLOUR = {0, 255, 0}


SCREEN_SIZE = {800, 600}

--y value all entities sit at 
FLOOR = SCREEN_SIZE[2] / 2

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
		--initial x coordinate, alternate x coordinate (walks between these)
		guards = {},

		--scrolls represented by x coordinate (static)
		scrolls = {}
		
	}

}

function love.load()

end


function love.update(dt)

	player:update(dt)
end


function love.draw()

	player:draw()
end


function love.keypressed(key)

end

function love.keyreleased(key)

end

player = {}


function player:init(spawn)

	self.pos = spawn
	self.velocity = 0
	self.hidden = false
end


function player:draw()

	
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

