r = require("robot")
com = require("component")
inv = com.inventory_controller

local function move(f, n)
  if n == nil then
    n = 1
  end
  if f == nil then
    f = r.forward
  end
  while n >0 do
    if not f() then
      print("Couldn't move!")
      die()
    end
    n = n - 1
  end
end

local function toss(x)
  r.select(x)
  r.drop(1)
end

function placeBlock()
  local stack = 3
  if inv.getStackInInternalSlot(3) == nil then
    stack = 4
  end
  r.select(stack)
  r.placeDown()
end

function buildLine(l)
  for y=1, l do
    placeBlock()
    move()
  end
end
local function cr()
  move(r.turnRight)
  move()
  move(r.turnLeft)
  move(r.back, 5)
end

local function buildSolid()
  for x=1, 5 do
    buildLine(5)
    cr()
  end
  move(r.turnLeft)
  move(r.forward, 5)
  move(r.turnRight)
end

function buildBorder(extra)
  for s =1, 4 do
    buildLine(4)
    move(r.turnRight)
  end
  if extra then
    move(r.turnRight)
    move(r.forward, 2)
    move(r.turnLeft)
    move()
    placeBlock()
    move()
    r.select(5)
    r.placeDown()
    move(r.back)
    r.swingDown()
    move(r.back)
    move(r.turnLeft)
    move(r.forward, 2)
    move(r.turnRight)
  end
end

move(r.forward, 2)
buildSolid()
move(r.up)
buildBorder(false)
move(r.up)
buildBorder(true)
move(r.up)
buildBorder(false)
move(r.up)
buildSolid()
move(r.back, 2)
move(r.down, 4)
toss(6)
