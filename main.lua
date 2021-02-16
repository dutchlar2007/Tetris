--=============================================================================
-- TETRIS
--
-- The awesome game of falling blocks
--
-- Author       - Dutch Larsen
-- Contributors - Christian Larsen, Lance Larsen
--=============================================================================

if unpack == nil then
  unpack = table.unpack
end

local BlockManager = {}
local score, updatable, drawable, block

--=============================================================================
-- List Metatable 
--=============================================================================
local List = {}
List.__index = List

---------------------------------------------------------------
-- Remove item from the list.
--
-- @param item The item to remove from the list.
--
function List:remove(item)
  for i = 1, #self do
    if self[i] == item then
      table.remove(self, i)
      return
    end
  end
end

---------------------------------------------------------------
-- Add items to the list.
-- 
-- @param ... Items to append to the list.
--
function List:append(...)
  local items = {...}
  for i = 1, #items do
    table.insert(self, items[i])
  end
end  

--=============================================================================
-- Block and background colors
--=============================================================================

local colors = {                        -- The format for items is {R,G,B, 'Color'}
  {255,0,0,1},     -- Red 
  {0,255,0,1},     -- Green
  {0,0,255,1},     -- Blue
  {255,255,0,1},   -- Yellow
  {255,0,255,1},   -- Purple
  {1,.5,0,1},      -- Orange
  {0,255,255,1},   -- Aqua 
}
colors[0] = {0,0,0,1} -- Black
colors.background = {0.6, 0.6, 0.6}

--=============================================================================

function rectBorder(block_color, ...)
  love.graphics.setColor(unpack(block_color))
  love.graphics.rectangle("fill", ...)
  love.graphics.setColor(unpack(colors.background))
  love.graphics.rectangle("line", ...)
end

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
  size = 30,
  listener = nil
}

---------------------------------------------------------------

function map:lineDropListener(listener)
  self.listener = listener
end

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
function map:update()
  local dropped = 0
  for y = 1, 20 do
    if map:isLineFilled(y) then
      dropped = dropped + 1
      for i = y, 2, -1 do 
        map[i] = map[i - 1]
      end 
      map[1] = {0,0,0,0,0,0,0,0,0,0}
    end
  end
  if dropped > 0 and self.listener then 
    self.listener:Lines(dropped)
  end
end

---------------------------------------------------------------
function map:draw()
  for Y = 1 , #self do 
    for X = 1, #self[Y] do
      rectBorder(colors[self[Y][X]], X*self.size+200, Y*self.size-30, self.size, self.size)
    end  
  end  
end

--=============================================================================
-- Scoring object
--
-- points    - The number of points that have been earned.
-- speed     - The time step before block moves.
-- fastSpeed - Speed when spped drop button is selected
-- numLines  - The number of lines that have been eliminated
--=============================================================================
score = {points = 0, speed = 1, fastSpeed = nil, numLines = 0}

---------------------------------------------------------------
-- Event to notify the score object of number of lines that were
-- dropped as a new block was added.
--
-- @param dropped The number of lines that were dropped.
--
function score:Lines(dropped)
  local scores = {100, 300, 600, 1000}
  self.points = self.points + scores[dropped]
  self.numLines = self.numLines + dropped
  self.speed = 0.8^(self.numLines/5)
end

---------------------------------------------------------------
-- Draw the score
--
function score:draw()
  love.graphics.setColor(unpack(colors[BlockManager.active.color]))
  love.graphics.print(string.format('Score: %d', self.points), 600, 150, 0, 2,2)
end

--=============================================================================
-- Block Metatable
--
-- dtotal - The time that has passed since the last block movement
--=============================================================================
local Block = {dtotal = 0}

Block.__index = Block

---------------------------------------------------------------
-- Create a new block and return it
--
function Block.new()
  local block = {x = 5, y = 0, dx  = {}, dy = {}, color = math.random(1,7)}
  setmetatable(block, Block)
  block:formation()
  return block
end

---------------------------------------------------------------
-- Update the block position. This is only used for the block
-- that is falling. Blocks in the BlockManager list are handled
-- by the BlockManager update function.
--
-- @param dt The change in time since the last update
--
function Block:update(dt)
  
  Block.dtotal = Block.dtotal + dt
  local timeLimit = score.speed
  if score.fastSpeed and score.fastSpeed <= score.speed then
    timeLimit = score.fastSpeed
  end
  
  if Block.dtotal >= timeLimit then
    if self:collision() then 
      self:setBlock()
      self:remove()
      BlockManager:getNextBlock()
      Block.dtotal = score.speed
      return
    end
  
    self.y = math.min(20, self.y + 1)
    Block.dtotal = 0
  end
end 

---------------------------------------------------------------
function Block:getX(i)
  return self.x + self.dx[i]
end

function Block:getY(i)
  return self.y + self.dy[i]
end

---------------------------------------------------------------
function Block:left()
  self.x = self.x - 1
end

function Block:right()
  self.x = self.x + 1
end

function Block:down()
  self.y = self.y + 1
end

---------------------------------------------------------------
function Block:clockwise()
  for i = 2, 4 do
    self.dx[i], self.dy[i] = -self.dy[i], self.dx[i]
  end
end

function  Block:counterClock()
  for i = 2, 4 do
    self.dx[i], self.dy[i] = self.dy[i], -self.dx[i]
  end  
end

---------------------------------------------------------------
function Block:onLeft()
  for i = 1, 4 do
    local y, x = self:getY(i), self:getX(i) - 1
    if self:getX(i) <= 1 or map:isFilled(x,y) then
      return
    end
  end
  self:left()
end

---------------------------------------------------------------
function Block:onRight()
  for i = 1, 4 do
    local y, x = self:getY(i), self:getX(i) + 1
    if self:getX(i) >= 10 or map:isFilled(x,y) then
      return
    end
  end
  self:right()
end

---------------------------------------------------------------
function Block:onDrop()
  while not self:collision() do
   self:down()
  end
  Block.dtotal = score.speed
end

---------------------------------------------------------------
function Block:onClockwise()
  self:clockwise()
  if self:collision() then
    self:counterClock()
  end
end

---------------------------------------------------------------
function Block:onCounterClock()
  self:counterClock()
  if self:collision() then
    self:clockwise()
  end
end

---------------------------------------------------------------
function Block:checkBounds()
  xmin = math.min(unpack(self.dx)) + self.x - 1
  xmax = math.max(unpack(self.dx)) + self.x - 10
  if xmin < 0 then self.x = self.x - xmin end 
  if xmax > 0 then self.x = self.x - xmax end
end

---------------------------------------------------------------
function Block:collision()
  for i = 1, 4 do
    if self:getY(i) >= 20 then
      return true
    end
    for i = 1, 4 do
      local y, x = self:getY(i), self:getX(i)
      if map:isFilled(x,y+1) or map:isFilled(x,y) then
        return true
      end
    end
  end
  
  return false
end

---------------------------------------------------------------
function Block:setBlock()
  for i = 1, 4 do
    local y, x = self:getY(i), self:getX(i)
    if 0 < y and y <= #map then
      if not map:isFilled(x, y) then
        map[y][x] = self.color
      end
    end
    if y < 0 then
      love.event.push("gameOver")
    end
  end
end

---------------------------------------------------------------
function Block:remove()
  updatable:remove(self)
  drawable:remove(self)  
end

---------------------------------------------------------------
function Block:init()
  self.y = 0
  self.x = 5
  updatable:append(self)
  drawable:append(self)
end

---------------------------------------------------------------
function Block:draw()
  local size = map.size
  
  for i = 1, 4 do
    rectBorder(colors[self.color], self:getX(i)*size+200, self:getY(i)*size-30, size, size)
  end
end
  
---------------------------------------------------------------
function Block:formation()
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
end

--=============================================================================
function BlockManager:update(dt)
  while #self < 3 do
    table.insert(self, Block.new())
  end
  for i = 1, 3 do 
    self[i].x = -2
    self[i].y = i*5
  end
  self.active:update(dt)
end

---------------------------------------------------------------
function BlockManager:getNextBlock()
  self.active = table.remove(self, 1)
  if not self.active then self.active = Block.new() end
  self.active:init()
end

---------------------------------------------------------------
function BlockManager:draw()
  for i = 1, #self do
    self[i]:draw()
  end
  self.active:draw()
end

--=============================================================================
drawable = setmetatable({}, List)

function love.draw()
  for i = 1, #drawable do
    drawable[i]:draw()
  end
end

---------------------------------------------------------------
function drawGameOver()
  love.graphics.print('Game Over', 300, 250, 0, 2,2)
  score:draw()
end  

--=============================================================================
updatable = setmetatable({}, List)

---------------------------------------------------------------
function love.update(dt)
  for i = 1, #updatable do
    updatable[i]:update(dt)
  end
end

---------------------------------------------------------------
function love.keypressed(key)
  if key == 'left' then
    BlockManager.active:onLeft()
  end
  if key == 'right' then
    BlockManager.active:onRight()
  end
  if key == 'space' then
    BlockManager.active:onDrop()
  end
  if key == 'up' then
    BlockManager.active:onCounterClock()
  end
  if key == 'down' then
    BlockManager.active:onClockwise()
  end
  if key == 'lshift' then
    score.fastSpeed = .07
  end
  BlockManager.active:checkBounds()
end

---------------------------------------------------------------
function love.keyreleased(key)
  if key == 'lshift' then
    score.fastSpeed = nil
  end
end

--=============================================================================
-- Register the Game Over Event
--=============================================================================

function gameOver()
  love.draw = drawGameOver
  love.update = nil
end

love.handlers.gameOver = gameOver

--=============================================================================

function love.load(arg)
  
  -- Initialize random numbers
  math.randomseed(os.time())
  
  -- Enable debugging when debug option is set
  if arg[#arg] == "-debug" then require("mobdebug").start() end
  
  love.graphics.setBackgroundColor(unpack(colors.background))
  tetris = love.audio.newSource('tetris.mp3', 'stream')
  tetris:setLooping( true )
  love.audio.play(tetris)

  map:lineDropListener(score)

  -- Get an active block
  BlockManager:getNextBlock()
  updatable:append(map, BlockManager)
  drawable:append(map, score, BlockManager)
end