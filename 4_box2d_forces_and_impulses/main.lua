function love.load()
  -- The usual, create a world, a shape and three bodies to attach the
  -- shape to, after that, a line for the cubes to fall on
  local phys = love.physics
  world = phys.newWorld(0, 8.91 * 30, true)

  objs = {}

  local shape = phys.newRectangleShape(40, 40)

  for i=1,3 do
    table.insert(objs, {
      body = phys.newBody(world, i * 100, 100, "dynamic")})
    objs[i].fixture = phys.newFixture(objs[i].body, shape)
  end

  line = {body = phys.newBody(world, 200, 450, "static"),
          shape = phys.newEdgeShape(-170, 0, 170, 0)}
  line.fixture = phys.newFixture(line.body, line.shape)
end

function love.keypressed(key)
  -- A linear impusle can be applied to the center of mass
  if key == "w" then
    objs[2].body:applyLinearImpulse(0, -1000)
  elseif key == 'a' then
    -- Or to any point, even one outside the space of the fixture/shape
    local x, y = objs[2].body:getWorldPoints(
      objs[2].fixture:getShape():getPoints())
    objs[2].body:applyLinearImpulse(0, -800, x, y)

  elseif key == "e" then
    -- A body can be placed by hand, but it's better to learn how to use
    -- impulses, box2d is a physics engine after all
    objs[3].body:setPosition(300, 100)
    if not objs[3].body:isAwake() then 
      objs[3].body:setAwake(true)
    end
  -- As well as applying linear forces, the same can be done with
  -- angular ones
  elseif key == 's' then
    objs[1].body:applyAngularImpulse(5000)
  elseif key == 'z' then
    love.load()
  end
end

function love.update(dt)
  -- A force differs from an impulse in that the force is applied before
  -- gravity is, and impulses are applied after, therefore, making the 
  -- force seem weaker by comparison
  if love.keyboard.isDown('q') then
    local body = objs[1].body
    body:applyForce(0, -1000)
  end

  if love.keyboard.isDown('d') then
    objs[3].body:applyTorque(5000)
  end
  world:update(dt)
end

function love.draw()
  for _,obj in pairs(objs) do
    love.graphics.setColor(1,1,1, .2)
    love.graphics.polygon("fill",
      obj.body:getWorldPoints(obj.fixture:getShape():getPoints()))

    love.graphics.setColor(1,1,1)
    love.graphics.polygon("line",
      obj.body:getWorldPoints(obj.fixture:getShape():getPoints()))
  end

  love.graphics.setColor(.2, .8, .2)
  love.graphics.line(line.body:getWorldPoints(line.shape:getPoints()))
end
