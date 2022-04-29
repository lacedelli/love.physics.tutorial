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

function love.load()
  world = love.physics.newWorld(0, 0, true)

  createWalls(love.physics)

  -- Define our colors
  colors = {green = {opaque = {.2, .8, .2},
                     translucent = {.2, .8, .2, .2}},
            white = {opaque = {1, 1, 1},
                     translucent = {1, 1, 1, .2}}}
end

function love.update(dt)
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
end
