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

  -- Just the usual body initiation stuff
  obj = {body = phys.newBody(world, love.graphics.getWidth() / 2, 
    love.graphics.getHeight() / 2, "dynamic")}
  obj.fixture = phys.newFixture(obj.body, shape)

  -- Manually override the angle toward a desired point
  -- TODO: do it
  function obj:setAngleTo(point)
  end
  function obj:setAngleToMouse()
    self:setAngleTo(mouse)
  end

  -- Settings for our pointer
  mouse = {0,0}
  love.graphics.setPointSize(8)
end

function love.mousepressed(x, y, b)
  if b == 1 then mouse[1], mouse[2] = x, y end
end

function love.update(dt)
  obj:setAngleToMouse()
  world:update(dt)
end

function love.draw()
  love.graphics.setColor(.9, .5, .5, .2)
  love.graphics.polygon("fill", obj.body:getWorldPoints(obj.fixture:getShape():getPoints()))
  love.graphics.setColor(.9, .5, .5, .9)
  love.graphics.polygon("line", obj.body:getWorldPoints(obj.fixture:getShape():getPoints()))

  love.graphics.setColor(1,1,1)
  love.graphics.points(mouse)

  love.graphics.print(
    "Body's angle: ".. math.deg(obj.body:getAngle()), 20, 20)
  -- TODO: make this work
  love.graphics.print(
    "Mouse's angle, relative to body: ".. math.deg(1), 20, 35)
end
