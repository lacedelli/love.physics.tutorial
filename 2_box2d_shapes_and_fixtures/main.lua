-- Test to make various physics shapes
function love.load()
  local phys = love.physics
  world = phys.newWorld(0, 8.91 * 30, true)
  objects = {}
  -- fill our objects table with physics entitites
  -- Circle
  table.insert(objects, {body=phys.newBody(world, 30, 30, "dynamic"),
                         shape=phys.newCircleShape(0,0, 10)})
  -- Irregular polygon
  table.insert(objects, {body=phys.newBody(world, 90, 30, "dynamic"),
                         shape=phys.newPolygonShape(-10,-20,
                                                    -10,00,
                                                     0,30,
                                                     10,0,
                                                     10,-10)})
  -- Rectangle
  table.insert(objects, {body=phys.newBody(world, 150, 30, "dynamic"),
                         shape=phys.newRectangleShape(40, 20)})

  -- Line
  table.insert(objects, {body=phys.newBody(world, 90, 80, "static"),
                         shape=phys.newEdgeShape(-70,0, 140, 0)})

  -- multiple fixtures to one object
  table.insert(objects, {body=phys.newBody(world, 210, 30, "dynamic")})

  objects[5].fixtures = {}
  for i = 1, 4 do
    table.insert(objects[5].fixtures, 
                 phys.newFixture(objects[5].body, objects[i].shape))
  end

  for _,obj in pairs(objects) do
    if obj.shape then
      obj.fixture = phys.newFixture(obj.body, obj.shape)
    end
  end

end

function love.update(dt)
  world:update(dt)
  local body = objects[2].body
  --body:setAngle(body:getAngle() + 0.01)
end

function love.draw()
  -- get all the info for the first body with a circle shape
  love.graphics.setColor(1, 1, 1)
  local x, y = objects[1].body:getPosition()
  local r = objects[1].shape:getRadius()
  love.graphics.circle("line", x, y, r)
  -- First shape of fifth body
  x, y = objects[5].body:getPosition()
  r = objects[5].fixtures[1]:getShape():getRadius()
  love.graphics.circle("line", x, y, r)

  love.graphics.setColor(.8, .1, 0)
  -- get all the info for the second body with an irregular polygonal shape
  local body = objects[2].body
  local shape = objects[2].shape
  love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))
  -- Draw the second shape of the fifth body
  body = objects[5].body
  shape = body:getFixtures()[2]:getShape()
  love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))

  love.graphics.setColor(.3, .3, .9)
  -- get all the info for the third body, a rectangle
  local body = objects[3].body
  local shape = objects[3].shape
  love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))

  body = objects[5].body
  shape = body:getFixtures()[3]:getShape()
  love.graphics.polygon("line", body:getWorldPoints(shape:getPoints()))

  love.graphics.setColor(.2, .8, .2)
  local body = objects[4].body
  local shape = objects[4].shape
  love.graphics.line(body:getWorldPoints(shape:getPoints()))

end
