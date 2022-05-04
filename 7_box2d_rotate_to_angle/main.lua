function love.load()
  local phys = love.physics
  world = phys.newWorld(0, 0, true)

  -- Make a hexagon
  local points = {}
  for i = 1, 6 do
    local angle = (i - 1)  / 6.0 * math.rad(360)
    points[#points + 1] = math.sin(angle) * 20
    points[#points + 1] = math.cos(angle) * 20
  end

  -- change one of the sides to become pointy
  points[8] = points[8] * 4
  local shape = phys.newPolygonShape(points)

  obj = {body = phys.newBody(world, love.graphics.getWidth() / 2, 
    love.graphics.getHeight() / 2, "dynamic")}
  obj.fixture = phys.newFixture(obj.body, shape)
end

function love.update(dt)
end

function love.draw()
  love.graphics.setColor(.9, .5, .5, .2)
  love.graphics.polygon("fill", obj.body:getWorldPoints(obj.fixture:getShape():getPoints()))
  love.graphics.setColor(.9, .5, .5, .9)
  love.graphics.polygon("line", obj.body:getWorldPoints(obj.fixture:getShape():getPoints()))
end
