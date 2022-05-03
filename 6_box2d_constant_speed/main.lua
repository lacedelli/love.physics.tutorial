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
  function player:modifyLinearToMaxSpeed()
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

  -- This works pretty similarly to the previous method, where the player
  -- body has linear acceleration and non-linear deceleration, the main 
  -- difference is that the body moves with applied forces, rather than
  -- through direct code interference to the linear velocity
  function player:applyMasslessForces()
    local x, y = self.body:getLinearVelocity()
    local state = self.move
    local movementScale = 1 -- Modify me for faster acceleration!
    local force = 0
    if state == moves.right then
      if x < self.moveForce then 
        force = self.moveForce * movementScale 
      end
    elseif state == moves.stop then
      force = x * -5
    elseif state == moves.left then
      if x > -self.moveForce then 
       force = -self.moveForce * movementScale  
      end
    end
    self.body:applyForce(force, 0)
  end

  -- Similar to the previous method, but the object's mass is taken
  -- into account when applying a force
  function player:applyMassForces()
    local x, y = self.body:getLinearVelocity()
    local desiredVelocity = 0
    local state = self.move
    -- Force needs to be magnified to be effective

    if state == moves.right then
      desiredVelocity = self.moveForce
    elseif state == moves.stop then
      desiredVelocity = 0
    elseif state == moves.left then
      desiredVelocity = -self.moveForce
    end

    local velocityChange = desiredVelocity - x
    -- force is calculated via the formula: f = mv/t
    -- (mass * velocity / time), the time being "a frame" of the game
    -- (this assumes the game runs at 60 fps), you could pass the delta time
    -- or call love.timer.getDelta
    local force = self.body:getMass() * velocityChange / (1/60)
    self.body:applyForce(force, 0)
  end

  -- This mehtod, for practical purposes is the same as the previous
  -- one, but box2d saves us inputting the the timestep value
  function player:applyImpulse()
    local x, y = self.body:getLinearVelocity()
    local desiredVelocity = 0
    local state = self.move

    if state == moves.right then
      desiredVelocity = self.moveForce
    elseif state == moves.stop then
      desiredVelocity = 0
    elseif state == moves.left then
      desiredVelocity = -self.moveForce
    end
    
    local velocityChange = desiredVelocity - x

    local impulse = self.body:getMass() * velocityChange

    self.body:applyLinearImpulse(impulse , 0)
  end

  -- The final method of the tutorial, a weird frankenstein of
  -- the previous method and the acceleration method from before
  function player:applyAcceleratedImpulse()
    local x, y = self.body:getLinearVelocity()
    local desiredVelocity = 0
    local state = self.move
    local increment = 10
    local falloffRate = .8

    if state == moves.right then
      desiredVelocity = math.min(x + increment, self.moveForce)
    elseif state == moves.stop then
      desiredVelocity = x * falloffRate
    elseif state == moves.left then
      desiredVelocity = math.max(x - increment, -self.moveForce)
    end
    
    local velocityChange = desiredVelocity - x

    local impulse = self.body:getMass() * velocityChange

    self.body:applyLinearImpulse(impulse , 0)
  end

  -- We'll do some fancy stuff with these boys
  player.movementIndex = 1

  -- Update an index within the movementMethods table size
  function player:updateMovementIndex()
    local limit = #player.movementMethods
    -- remember lua indexes on 1
    player.movementIndex = (player.movementIndex % limit) + 1
  end

  -- This'll help us dynamically switch between methods and let us see
  -- first hand how they feel
  player.movementMethods = {
    player.modifyLinearVelocity,
    player.modifyLinearToMaxSpeed,
    player.applyMasslessForces,
    player.applyMassForces,
    player.applyImpulse,
    player.applyAcceleratedImpulse
  }

  function player:update()
    -- Dynamically switch the movement methods during runtime
    self.movementMethods[self.movementIndex](self)
  end

  function player:currentMovement()
    local index = self.movementIndex
    local text = ""
    if index == 1 then
      text = "modify linear velocity"
    elseif index == 2 then
      text = "modify linear to max speed"
    elseif index == 3 then
      text = "apply massless forces"
    elseif index == 4 then
      text = "apply mass forces"
    elseif index == 5 then
      text = "apply impulse"
    elseif index == 6 then
      text = "apply accelerated impulse"
    end
    return text
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

function love.keypressed(k)
  if k == 'u' then player:updateMovementIndex() end
end

function love.update(dt)
  checkInput()
  player:update()
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

  love.graphics.print(player:currentMovement(), 30, 50)
  --[[ turns out I didn't need these
  local px, py = player.body:getLinearVelocity()
  love.graphics.print(
    ("player's linear impulse: \nx: %.4f\ny: %.4f"):format(px, py),
    30, 65)
   ]]--
end
