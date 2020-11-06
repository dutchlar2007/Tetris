local dtotal = 0
if unpack == nil then
  unpack = table.unpack
end
--=============================================================================
local colors = {                        -- The format for items is {R,G,B, 'Color'}
  {255,0,0,1},     -- Red 
  {0,255,0,1},     -- Green
  {0,0,255,1},     -- Blue
  {255,255,0,1},   -- Yellow
  {255,0,255,1},   -- Purple
  {255,255,255,1}, -- White
  {0,255,255,1},   -- Aqua 
}
colors[0] = {0,0,0, 1} -- Black

--=============================================================================


local map = {
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  {0,0,0,0,0,0,0,0,0,0},
  size = 30
}

---------------------------------------------------------------
function map:draw()
  for Y = 1 , #self do 
    for X = 1, #self[Y] do
      love.graphics.setColor(unpack(colors[self[Y][X]]))
      love.graphics.rectangle("fill", X*self.size+200, Y*self.size-30, self.size, self.size)
    end  
  end  
end

--=============================================================================
local score = {points = 0, speed = 1}
--=============================================================================
local block = {dtotal = 0, x = {5,1,1,1}, y = {1,1,1,1},color=7}

function block:update(dt)
  self.dtotal = self.dtotal + dt
  if self.dtotal >= 1/score.speed then
    self.y[1] = math.min(20, self.y[1] + 1)
    self.y[2] = math.min(20, self.y[2] + 1)
    self.y[3] = math.min(20, self.y[3] + 1)
    self.y[4] = math.min(20, self.y[4] + 1)
    self.dtotal = 0
    return dtotal
  end
end

---------------------------------------------------------------

function block:moveBlock(key)
  if key == 'left' and block.y < 20 then
    block.x[1] = math.max(1, block.x[1] - 1)
    block.x[2] = math.max(1, block.x[2] - 1)
    block.x[3] = math.max(1, block.x[3] - 1)
    block.x[4] = math.max(1, block.x[4] - 1)
    
  end
end

---------------------------------------------------------------
function block:formation()
  if self.color == 1 then
    
  end
end

---------------------------------------------------------------

function block:clockwize(x,y)
  return -y, x
end

---------------------------------------------------------------

function block:draw()
  local size = map.size
  love.graphics.setColor(unpack(colors[self.color]))
  for i = 1, #self.x do
    love.graphics.rectangle("fill", self.x[i]*size+200, self.y[i]*size-30, size, size)
  end
  block:setBlock()
end

---------------------------------------------------------------
function block:setBlock()
  local hitLine20 = false
  for i = 1, #self.y do
    if self.y[i] >= 20 then 
      hitLine20 = true 
    end
  end
  if hitLine20 then
    for i = 1, #self.y do
      map[self.y[i]][self.x[i]] = self.color
    end 
  end
end

--=============================================================================
--=============================================================================
love.graphics.setBackgroundColor(160, 0, 255, 1)

function love.draw()
  map:draw()
  block:draw()
end

---------------------------------------------------------------
function love.update(dt)
  block:update(dt)
end

---------------------------------------------------------------
function love.keypressed(key)
  if key == 'left' and block.y[1] and block.y[2] and block.y[3] and block.y[4] < 20 and block.x[1] and block.x[2] and block.x[3] and block.x[4] > 1 then
    block.x[1] = math.max(1, block.x[1] - 1)
    block.x[2] = math.max(1, block.x[2] - 1)
    block.x[3] = math.max(1, block.x[3] - 1)
    block.x[4] = math.max(1, block.x[4] - 1)
  end
  if key == 'right' and block.y[1] and block.y[2] and block.y[3] and block.y[4] < 20 and block.x[1] and block.x[2] and block.x[3] and block.x[4] < 10 then
    block.x[1] = math.min(10, block.x[1] + 1)
    block.x[2] = math.min(10, block.x[2] + 1)
    block.x[3] = math.min(10, block.x[3] + 1)
    block.x[4] = math.min(10, block.x[4] + 1)
  end
end


