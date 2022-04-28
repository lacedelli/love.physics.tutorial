function love.load()
  -- Usual setup, create our world, three dynamic bodies and a static
  -- line for them to fall on
  local phys = love.physics
  -- gravity in meters / second * our pixels / meter scale
  gravity = 8.91 * 30
  world = phys.newWorld(0, gravity, true)

  local shape = phys.newRectangleShape(40, 40)

  objs = {}

  for i=1, 3 do
    objs[i] = {body = phys.newBody(world, i * 100, 100, "dynamic")}
    objs[i].fixture = phys.newFixture(objs[i].body, shape)
  end

  line = {body = phys.newBody(world, 200, 550, "static")}
  line.fixture = phys.newFixture(line.body, 
    phys.newEdgeShape(-150, 0, 150, 0))
end

function love.update(dt)
  -- One way of cancelling gravity is applying the inverse force multiplied
  -- by the body's mass each update. If you cancel out the gravity
  -- after the first step the body will move for one frame
  objs[1].body:applyForce(0, objs[1].body:getMass() * -gravity)

  -- Another way of cancelling a body's gravity is the following
  objs[2].body:setGravityScale(0)

  -- You can also make bodies move faster
  objs[3].body:setGravityScale(objs[3].body:getGravityScale() * 1.1)

  world:update(dt)
end

function love.draw()
  -- Same drawing process as before, semi-transparent body and opaque
  -- perimeter for the squares, and a green line
  for _,obj in pairs(objs) do
    love.graphics.setColor(1,1,1, .2)
    love.graphics.polygon("fill", obj.body:getWorldPoints(
      obj.fixture:getShape():getPoints()))

    love.graphics.setColor(1,1,1)
    love.graphics.polygon("line", obj.body:getWorldPoints(
      obj.fixture:getShape():getPoints()))
  end

  love.graphics.setColor(.2, .8, .2)
  love.graphics.line(line.body:getWorldPoints(
    line.fixture:getShape():getPoints()))
end
