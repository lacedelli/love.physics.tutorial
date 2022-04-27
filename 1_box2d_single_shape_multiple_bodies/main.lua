-- Despite seeming like you can use a single body for multiple fixtures
-- love.physics.newFixture() copies the shape

function love.load()
  local phys = love.physics
  -- Create the world
  world = phys.newWorld(0, 9.81 * 30, true)

  objects = {}
  -- create the shape
  shape = phys.newRectangleShape(50, 50)

  -- Create each body and its fixture
  -- Note that the same shape is fixed to both bodies
  objects[1] = {
    body = phys.newBody(world, 100, 100, "dynamic")}
  objects[1].fixture = phys.newFixture(objects[1].body, shape)
  
  -- Make the box bounce
  objects[1].fixture:setRestitution(0.5)

  objects[2] = {
    body = phys.newBody(world, 70, 550, "static")}
  objects[2].fixture = phys.newFixture(objects[2].body, shape)

end

function love.update(dt)
  -- Update the physics
  world:update(dt)
end

function love.draw()
  -- Draw each object's shape
  for _,obj in pairs(objects) do
    love.graphics.polygon("fill", 
                          obj.body:getWorldPoints(shape:getPoints()))
  end
end
