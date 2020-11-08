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
  {255,165,0,1},   -- Orange
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
function map:isFilled(x,y)
  if y < 1 or #map < y then return false end
  if x < 1 or #map[1] < x then return false end
  return map[y] and map[y][x] and map[y][x] ~= 0
end


---------------------------------------------------------------

function map:isLineFilled(y)
  for x = 1, #map[y] do
    if not map:isFilled(x,y) then return false end
  end
  return true
end
---------------------------------------------------------------

---------------------------------------------------------------
function map:dropLine()
  for y = 1, 20 do
    if map:isLineFilled(y) then
      for i = y, 2, -1 do 
        map[i] = map[i - 1]
      end 
      map[1] = {0,0,0,0,0,0,0,0,0,0}
    end
  end
end

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
local score = {points = 0, speed = 1.5}
--=============================================================================
local block = {dtotal = 0, x = 5, y = 1, dx  = {}, dy = {}, reset = 1, color=7}

function block:update(dt)
  self.dtotal = self.dtotal + dt
  if self.dtotal >= 1/score.speed then
    self.y = math.min(20, self.y + 1)
    self.dtotal = 0
    return dtotal
  end
end 

---------------------------------------------------------------

function block:getX(i)
  return self.x + self.dx[i]
end

---------------------------------------------------------------

function block:getY(i)
  return self.y + self.dy[i]
end

---------------------------------------------------------------

function block:collision()
  for i = 1, 4 do
    if self:getY(i) >= 20 then 
      self.reset = true
      return true
    end
    for i = 1, 4 do
      local y, x = self:getY(i) + 1, self:getX(i)
      if map:isFilled(x,y) then
        self.reset = true 
        return true
      end
    end
  end
  
  return false
end

---------------------------------------------------------------

function block:setBlock()
  for i = 1, 4 do
    local y, x = self:getY(i), self:getX(i)
    if not map:isFilled(x, y) then
      map[y][x] = self.color
    end
  end 
end

---------------------------------------------------------------

function block:clockwise()
  for i = 2,4 do
    self.dx[i], self.dy[i] = -self.dy[i], self.dx[i]
  end
end

function  block:counterClock()
  for i = 2,4 do
    self.dx[i], self.dy[i] = self.dy[i], -self.dx[i]
  end  
end
---------------------------------------------------------------

function block:draw()
  local size = map.size
  if block:collision() then 
    block:setBlock()
  end
  if self.reset then
    block:formation()
  end
  love.graphics.setColor(unpack(colors[self.color]))
  for i = 1, 4 do
    love.graphics.rectangle("fill", self:getX(i)*size+200, self:getY(i)*size-30, size, size)
  end
end
  
---------------------------------------------------------------
function block:formation()
  self.color = math.random(1,7)
  if self.color == 1 then
    self.dx = {0,-1,0,1}
    self.dy = {0,0,-1,-1}
  end
  if self.color == 2 then
    self.dx = {0,-1,0,1}
    self.dy = {0,-1,-1,0}
  end
  if self.color == 3 then
    self.dx = {0,-1,0,0}
    self.dy = {0,0,-1,-2}
  end
  if self.color == 4 then
    self.dx = {0,1,0,1}
    self.dy = {0,0,-1,-1}
  end
  if self.color == 5 then
    self.dx = {0,-1,1,0}
    self.dy = {0,0,0,-1}
  end
  if self.color == 6 then
    self.dx = {0,1,0,0}
    self.dy = {0,0,-1,-2}
  end
  if self.color == 7 then
    self.dx = {0,0,0,0}
    self.dy = {0,-1,-2,-3}
  end
  self.x = 5
  self.y = 0
  self.reset = false
end
block:formation()

---------------------------------------------------------------

--=============================================================================
--=============================================================================
love.graphics.setBackgroundColor(0.6, 0.6, 0.6)

function love.draw()
  map:draw()
  block:draw()
end

---------------------------------------------------------------
function love.update(dt)
  block:update(dt)
  map:dropLine()
end

---------------------------------------------------------------
function love.keypressed(key)
  if key == 'left' then
    for i = 1, 4 do
      local y, x = block:getY(i), block:getX(i) - 1
      if block:getX(i) <= 1 or map:isFilled(x,y) then
        goto skip1
      end
    end
    block.x = block.x - 1
    ::skip1::
  end
  if key == 'right' then
    for i = 1, 4 do
      local y, x = block:getY(i), block:getX(i) + 1
      if block:getX(i) >= 10 or map:isFilled(x,y) then
        goto skip2
      end
    end
    block.x = block.x + 1
    ::skip2::
  end
  if key == 'up' then
    block:counterClock()
  end
  if key == 'down' then
    block:clockwise()
  end
  xmin = math.min(unpack(block.dx)) + block.x - 1
  xmax = math.max(unpack(block.dx)) + block.x - 10
  if xmin < 0 then block.x = block.x - xmin end 
  if xmax > 0 then block.x = block.x - xmax end
end

function love.load(arg)
  math.randomseed(os.time())
  if arg[#arg] == "-debug" then require("mobdebug").start() end
end