-- Help improve readability
function createWalls(phys)
  walls = {}

  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  local shape = phys.newRectangleShape(10, height - 40)
  -- An interesting detail I found out is that if you redefine the
  -- body of the walls, instead of declaring a new table, the reference
  -- to the object doesn't change, therefore overriding the bodies already
  -- inserted into the table

  -- create our first wall, the vertical shape and affix it
  local wall = {body= phys.newBody(world, 20, height/2, "static")}
  wall.fixture = phys.newFixture(wall.body, shape)
  table.insert(walls, wall)

  -- Create our second wall, using a similar process
  wall = {body = phys.newBody(world, width - 20, height/2, "static")}
  wall.fixture = phys.newFixture(wall.body, shape)
  table.insert(walls, wall)

  -- Redefine the shape for the next bodies
  shape = phys.newRectangleShape(width - 40, 10)
  -- Create the remaining two bodies, fixtures, and insert to table
  wall = {body = phys.newBody(world, width/2, 20, "static")}
  wall.fixture = phys.newFixture(wall.body, shape)
  table.insert(walls, wall)

  wall = {body = phys.newBody(world, width/2, height - 20, "static")}
  wall.fixture = phys.newFixture(wall.body, shape)
  table.insert(walls, wall)
end

-- Create our player-controlled box; a table with a body, a fixture and
-- a holder for our movement variable, as well as movement methods
function createPlayer(phys)
  player = {}
  player.move = nil
  player.moveForce = 250
  player.body = phys.newBody(world,
    love.graphics.getWidth()/2, love.graphics.getHeight()/2, "dynamic")
  player.fixture = phys.newFixture(player.body, phys.newRectangleShape(20,20))
  -- Pretty much what the name implies, grab the velocity and directly
  -- modify it
  function player:modifyLinearVelocity()
    local x, y = self.body:getLinearVelocity()
    local state = self.move
    if state == moves.right then    x = self.moveForce
    elseif state == moves.stop then x = 0
    elseif state == moves.left then x = -self.moveForce
    end
    self.body:setLinearVelocity(x, y)
  end
  
  -- Similar to the previous function, but you get more control over the
  -- dynamics of the player's movement, by setting the increment to a higher
  -- value, the player will accelerate faster; and by setting it to a
  -- lower value, the player will take some time before reaching top 
  -- speed.
  -- If you set the falloff rate to a value closer to 1, the slower
  -- the player loses velocity, the closer to 0, the faster the player
  -- stops, you can control "friction" this way, unless box2d has better
  -- options for that.
  function player:accelerateToMaxSpeed()
    local increment = 10
    local falloffRate = 0.88
    local x, y = self.body:getLinearVelocity()
    local state = self.move
    if state == moves.right then    
      x = math.min(x + increment, self.moveForce)
    elseif state == moves.stop then 
      x = x * falloffRate
    elseif state == moves.left then 
      x = math.max(x - increment, -self.moveForce)
    end
    self.body:setLinearVelocity(x, y)
  end
end

-- Check the inputs for the player, this implementation only allows for
-- horizontal movement, if the player doesn't press anything, the 
-- player stops
function checkInput()
  player.move = moves.stop
  if love.keyboard.isDown('d') then
    player.move = moves.right
  elseif love.keyboard.isDown('a') then
    player.move = moves.left
  end
end

function love.load()
  world = love.physics.newWorld(0, 9.81 * 30, true)

  -- an "enum" to set possible move "states"
  -- I personally dislike this implementation, but whatever
  moves = {stop = 1, right = 2, left = 3}

  createWalls(love.physics)
  createPlayer(love.physics)

  -- Define our colors
  colors = {green = {opaque = {.2, .8, .2},
                     translucent = {.2, .8, .2, .2}},
            white = {opaque = {1, 1, 1},
                     translucent = {1, 1, 1, .2}}}
end


function love.update(dt)
  checkInput()
  -- This tutorial implements various movement methods, you can try them
  -- all out!
  -- player:modifyLinearVelocity()
  player:accelerateToMaxSpeed()
  world:update(dt)
end

function love.draw()
  for _,wall in pairs(walls) do
    love.graphics.setColor(colors.green.translucent)
    love.graphics.polygon("fill", wall.body:getWorldPoints(
      wall.fixture:getShape():getPoints()))

    love.graphics.setColor(colors.green.opaque)
    love.graphics.polygon("line", wall.body:getWorldPoints(
      wall.fixture:getShape():getPoints()))
  end

  love.graphics.setColor(colors.white.translucent)
  love.graphics.polygon("fill", player.body:getWorldPoints(
    player.fixture:getShape():getPoints()))

  love.graphics.setColor(colors.white.opaque)
  love.graphics.polygon("line", player.body:getWorldPoints(
    player.fixture:getShape():getPoints()))
end
