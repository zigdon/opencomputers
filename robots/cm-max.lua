local r = require("robot")
local com = require("component")
local inv = com.inventory_controller

local function simpleMove(f, n)
  if n == nil then
    n = 1
  end
  if f == nil then
    f = r.forward
  end
  while n >0 do
    assert(f(), "Couldn't move!")
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
    simpleMove()
  end
end
local function cr()
  simpleMove(r.turnRight)
  simpleMove()
  simpleMove(r.turnLeft)
  simpleMove(r.back, 5)
end

local function buildSolid()
  for x=1, 5 do
    buildLine(5)
    cr()
  end
  simpleMove(r.turnLeft)
  simpleMove(r.forward, 5)
  simpleMove(r.turnRight)
end

function buildBorder(extra)
  for s =1, 4 do
    buildLine(4)
    simpleMove(r.turnRight)
  end
  if extra then
    simpleMove(r.turnRight)
    simpleMove(r.forward, 2)
    simpleMove(r.turnLeft)
    simpleMove()
    placeBlock()
    simpleMove()
    r.select(5)
    r.placeDown()
    simpleMove(r.back)
    r.swingDown()
    simpleMove(r.back)
    simpleMove(r.turnLeft)
    simpleMove(r.forward, 2)
    simpleMove(r.turnRight)
  end
end

simpleMove(r.forward, 2)
buildSolid()
simpleMove(r.up)
buildBorder(false)
simpleMove(r.up)
buildBorder(true)
simpleMove(r.up)
buildBorder(false)
simpleMove(r.up)
buildSolid()
simpleMove(r.back, 2)
simpleMove(r.down, 4)
toss(6)
