function love.load()

  local phys = love.physics
  world = phys.newWorld(0, 9.81 * 30, true)

  -- create our body
  obj = {}
  obj.body = phys.newBody(world, 100, 50, "dynamic")
  obj.fixtures = {}

  -- Make and attach the four shapes to the body, four squares offset
  -- to make a cross-like pattern
  for i = 25, -25, -50 do 
    table.insert(obj.fixtures,
      phys.newFixture(obj.body, phys.newRectangleShape(i, 0 , 50, 50, 0)))
    table.insert(obj.fixtures,
      phys.newFixture(obj.body, phys.newRectangleShape(0, i, 50, 50, 0)))
  end
  
  --[[ Previous code equivalent to :
  table.insert(obj.fixtures, 
    phys.newFixture(obj.body, phys.newRectangleShape(25, 0, 50, 50, 0)))
  table.insert(obj.fixtures, 
    phys.newFixture(obj.body, phys.newRectangleShape(0, 25, 50, 50, 0)))
  table.insert(obj.fixtures, 
    phys.newFixture(obj.body, phys.newRectangleShape(-25, 0, 50, 50, 0)))
  table.insert(obj.fixtures, 
    phys.newFixture(obj.body, phys.newRectangleShape(0, -25, 50, 50, 0)))
  ]]--

  -- You can set the density for each fixture to its own value
  for i,fix in ipairs(obj.fixtures) do
    -- Both friction and restitution take a value of up to 1
    fix:setFriction(i/4)
    -- Restitution defines how much the body bounces upon impact
    -- i.e. The amount of energy the body conserves after a collision
    -- occurs
    fix:setRestitution(i/4)
  end

  -- Create the line that the body will interact with.
  line = {}
  line.body = phys.newBody(world, 100, 400, "static")
  line.fixture = phys.newFixture(line.body, 
    phys.newEdgeShape(-100, -30, 800, 100))
end

function love.update(dt)
  world:update(dt)
end

function love.draw()
  -- draw the polygon's area and perimeter, only difference is that
  -- each of the squares' area has lower opacity 
  for _,fixture in pairs(obj.fixtures) do
    love.graphics.setColor(1,1,1, .2)
    love.graphics.polygon("fill", 
      obj.body:getWorldPoints(fixture:getShape():getPoints()))

    love.graphics.setColor(1,1,1)
    love.graphics.polygon("line",
      obj.body:getWorldPoints(fixture:getShape():getPoints()))
  end

  -- Draw the line
  love.graphics.setColor(0, .8, 0)
  love.graphics.line(line.body:getWorldPoints(
    line.fixture:getShape():getPoints()))
end
