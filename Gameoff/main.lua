---- GAME
love.graphics.setDefaultFilter("nearest", "nearest")
Object = require "libs.classic"
anim8 = require "libs.anim8"
local bump = require 'libs.bump'
world = bump.newWorld()
Camera = require 'libs.camera'
camera = Camera()
--camera.scale = 0.2
local camX = 0 + 48*5
local camY = 0 + -48*7
local entities = require "entities"
local bullets = require "bullets"
local Barril = require "barril"
local Item = require "item"
gameover = false
local gameoverfade = 0
gamestate = "intro"
isEndGame = false
local introScene = 1
local introOpacity = 0
local endGameScene = 1
local endGameOpacity = 0
--player
local Player = require"player"
local player = Player(200, -672*-2)

--variables for map
bigmap = require "bigmap"
local biome = "dirt"
local map = {}
local rooms = {}
local levelNum = 100
local MAPWIDTH = 10
local MAPHEIGHT = 14
local tileSize = 48
local MAXROOMWIDTH = 2
local MINROOMWIDTH = 5
local MAXROOMHEIGHT = 2
local MINROOMHEIGHT = 4
local dirt = {}
local topdirt = {}
local brokendirt1 = {}
local brokendirt2 = {}
dirt["dirt"] = 10
dirt["sand"] = 12
dirt["rock"] = 14
dirt["ice"] = 16
topdirt["dirt"] = 1
topdirt["sand"] = 3
topdirt["rock"] = 5
topdirt["ice"] = 7
brokendirt1["dirt"] = 2
brokendirt1["sand"] = 4
brokendirt1["rock"] = 6
brokendirt1["ice"] = 9
brokendirt2["dirt"] = 11
brokendirt2["sand"] = 13
brokendirt2["rock"] = 15
brokendirt2["ice"] = 18
local pointX = 48*5
local pointY = 48*7
--
local Block = require "block"
local NPC = require "npc"
local SpikeBall = require "spikeball"

-----GEM ANIMATIONS

gem1Anims = {}
local gem1Grid = anim8.newGrid(16, 20, 64, 20)
gem1Anims.idle = anim8.newAnimation(gem1Grid(1, 1), 0.1)
gem1Anims.bright = anim8.newAnimation(gem1Grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
gem1Anim = gem1Anims.idle

gem2Anims = {}
local gem2Grid = anim8.newGrid(21, 21, 84, 21)
gem2Anims.idle = anim8.newAnimation(gem2Grid(1, 1), 0.1)
gem2Anims.bright = anim8.newAnimation(gem2Grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
gem2Anim = gem2Anims.idle

gem3Anims = {}
local gem3Grid = anim8.newGrid(20, 20, 80, 20)
gem3Anims.idle = anim8.newAnimation(gem3Grid(1, 1), 0.1)
gem3Anims.bright = anim8.newAnimation(gem3Grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
gem3Anim = gem3Anims.idle

gem4Anims = {}
local gem4Grid = anim8.newGrid(15, 15, 60, 15)
gem4Anims.idle = anim8.newAnimation(gem4Grid(1, 1), 0.1)
gem4Anims.bright = anim8.newAnimation(gem4Grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
gem4Anim = gem4Anims.idle

gem1Scale = 2
gem2Scale = 2
gem3Scale = 2
gem4Scale = 2

gemNum = 0
realGemNum = 0
updateGemTimer = 0
numScale = 2
------
local Fx2 = require "fx2"
local function resetMap()
    map = {}
    rooms = {}
    -- temp
    --entities = {}
    --
    for y = 1, MAPHEIGHT do
        map[y] = {}
        for x = 1, MAPWIDTH do
            map[y][x] = 0
        end
    end
end

local function loadResources()
    require "resources"
end

local function isIntersect(l, t, w, h, l2, t2, w2, h2)
    if l > l2 + w2 or l2 > l + w then
        return false
    end
    if t > t2 + h2 or t2 > t + h then
        return false
    end
    return true
end
local trytime = 100
local function buildMap()
  for i = 1, 100 do
    -- create room
    local roomwidth = love.math.random(MINROOMWIDTH, MAXROOMWIDTH)
    local roomheight = love.math.random(MINROOMHEIGHT, MAXROOMHEIGHT)
    local roomX = love.math.random(1, MAPWIDTH-roomwidth+1)
    local roomY = love.math.random(1, MAPHEIGHT-roomheight+1)
    local isTouch = false
    for i = 1, #rooms do
        -- if touch then touch = true
        if isIntersect(roomX, roomY, roomwidth, roomheight, rooms[i].x, rooms[i].y,rooms[i].width,rooms[i].height) then
            isTouch = true
            break
        end
    end
    if isTouch == false then
        for y = roomY, (roomY + roomheight)-1 do
            for x = roomX, (roomX + roomwidth)-1 do
                map[y][x] = 1
            end
        end
        local room = {}
        room.x = roomX
        room.y = roomY
        room.width = roomwidth
        room.height = roomheight
        room.centerX = room.x + math.floor(room.width/2)
        room.centerY = room.y + math.floor(room.height/2)
        table.insert(rooms, room)
    end
    ---- connect
      -- find nearest room
    for j = #rooms, 1, -1 do
        for i = 2, j do
            if rooms[i].centerY < rooms[i-1].centerY then
                ----swap room
                local temproom = {}
                temproom.x = rooms[i-1].x
                temproom.y = rooms[i-1].y
                temproom.width = rooms[i-1].width
                temproom.height = rooms[i-1].height
                temproom.centerX = rooms[i-1].centerX
                temproom.centerY = rooms[i-1].centerY
                --
                rooms[i-1].x = rooms[i].x
                rooms[i-1].y = rooms[i].y
                rooms[i-1].width = rooms[i].width
                rooms[i-1].height = rooms[i].height
                rooms[i-1].centerX = rooms[i].centerX
                rooms[i-1].centerY = rooms[i].centerY
                --
                rooms[i].x = temproom.x
                rooms[i].y = temproom.y
                rooms[i].width = temproom.width
                rooms[i].height = temproom.height
                rooms[i].centerX = temproom.centerX
                rooms[i].centerY = temproom.centerY
            end
        end
    end
      -- connect
    for i = 1, #rooms-1 do
        local currentX = rooms[i].centerX
        local currentY = rooms[i].centerY
        local targetX = rooms[i+1].centerX
        local targetY = rooms[i+1].centerY
        local turn = "horizontal" -- ngang
        while currentX ~= targetX or currentY ~= targetY do
            map[currentY][currentX] = 1
            if turn == "vertical" then
                if currentY < targetY then
                    currentY = currentY + 1
                elseif currentY > targetY then
                    currentY = currentY - 1
                end
                turn = "horizontal"
            elseif turn == "horizontal" then
                if currentX < targetX then
                    currentX = currentX + 1
                elseif currentX > targetX then
                    currentX = currentX - 1
                end
                turn = "vertical"
            end
        end
    end
  end
end

local function addToBigMap(i)
    bigmap[i] = {}
    bigmap[i].state = "on"
    bigmap[i].unit = {}
    for y = 1, #map do
        bigmap[i].unit[y] = {}
        for x = 1, #map[y] do
            bigmap[i].unit[y][x] = map[y][x]
        end
    end
end

local function addBlockTest(bg, ed)
  for t = bg, ed do
    local ox = 0
    local oy = -672*(t-1)
    --[[for x = 1, MAPWIDTH do
        if bigmap[t].unit[1][x] == 0 then
            table.insert(entities, Block(ox+(x-1)*48,oy+ 0*48, 10))
        end
        if bigmap[t].unit[MAPHEIGHT][x] == 0 then
            local id
            if bigmap[t].unit[MAPHEIGHT-1][x] == 1 then
                id = 1
            else
                id = 10
            end
            table.insert(entities, Block(ox+(x-1)*48, oy + (MAPHEIGHT-1)*48, id))
        end
    end
    for y = 2, MAPHEIGHT-1 do
        if bigmap[t].unit[y][1] == 0 then
            local id
            if bigmap[t].unit[y-1][1] == 1 then
                id = 1
            else
                id = 10
            end
            table.insert(entities, Block(ox+(1-1)*48, oy+(y-1)*48, id))
        end
        if bigmap[t].unit[y][MAPWIDTH] == 0 then
            local id
            if bigmap[t].unit[y-1][MAPWIDTH] == 1 then
                id = 1
            else
                id = 10
            end
            table.insert(entities, Block(ox+(MAPWIDTH-1)*48,oy+ (y-1)*48, id))
        end
    end
    for y = 2, #bigmap[t].unit-1 do
        for x = 2, #bigmap[t].unit[y]-1 do
            if bigmap[t].unit[y][x] == 0 then
                local id
                if bigmap[t].unit[y-1][x] == 1 then
                    id = 1
                else
                    local rd = love.math.random(1, 10)
                    if rd == 1 then
                        id = 2
                    elseif rd == 2 then
                        id = 11
                    else
                        id = 10
                    end
                end
                table.insert(entities, Block( ox +(x-1)*48, oy+ (y-1)*48, id))
            end
        end
    end]]
    if t < 50 then 
        biome = "dirt"
    elseif t >= 50 and t < 70 then
        biome = "sand"
    elseif t >= 70 and t < 80 then
        biome = "rock"
    elseif t >= 80 then
        biome = "ice"
    end
    for y = 1, #bigmap[t].unit do
        for x = 1, #bigmap[t].unit[y] do
            if bigmap[t].unit[y][x] ~= 1 and bigmap[t].unit[y][x]~="barril" and bigmap[t].unit[y][x]~="gem1" and bigmap[t].unit[y][x]~="gem2" and bigmap[t].unit[y][x]~="gem3" and bigmap[t].unit[y][x]~="gem4" and bigmap[t].unit[y][x]~="powerup" and bigmap[t].unit[y][x] ~= "spikeball" and bigmap[t].unit[y][x] ~= "hp" and bigmap[t].unit[y][x] ~= "shield" then
                local id
                if bigmap[t].unit[y][x] == "dirt" then
                    id = dirt[biome]
                elseif bigmap[t].unit[y][x] == "topdirt" then
                    id = topdirt[biome]
                elseif bigmap[t].unit[y][x] == "brokendirt1" then
                    id = brokendirt1[biome]
                elseif bigmap[t].unit[y][x] == "brokendirt2" then
                    id = brokendirt2[biome]
                end
                table.insert(entities, Block( ox +(x-1)*48, oy+ (y-1)*48, id, true))
            elseif bigmap[t].unit[y][x] == "barril" then
                table.insert(entities, Barril( ox +(x-1)*48, oy+ (y-1)*48))
            elseif bigmap[t].unit[y][x] == "gem1" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "gem1"))
            elseif bigmap[t].unit[y][x] == "gem2" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "gem2"))
            elseif bigmap[t].unit[y][x] == "gem3" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "gem3"))
            elseif bigmap[t].unit[y][x] == "gem4" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "gem4"))
            elseif bigmap[t].unit[y][x] == "powerup" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "powerup"))
            elseif bigmap[t].unit[y][x] == "spikeball" then
                table.insert(entities, SpikeBall( ox +(x-1)*48, oy+ (y-1)*48))
            elseif bigmap[t].unit[y][x] == "hp" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "hp"))
            elseif bigmap[t].unit[y][x] == "shield" then
                table.insert(entities, Item( ox +(x-1)*48, oy+ (y-1)*48, "shield"))
            end
        end
    end
  end
end

local function decorateMap()
    for y = 1, #map do
        for x = 1, #map[y] do
            if map[y][x] == 0 then
                local rd = love.math.random(1, 10)
                if rd == 1 then
                    map[y][x] = "brokendirt1"
                elseif rd == 2 then
                    map[y][x] = "brokendirt2"
                else
                    map[y][x] = "dirt"
                end
            end
        end
    end
    for x = 1, #map[1] do
        if map[1][x] == "dirt" then
            map[1][x] = "topdirt"
        end
    end
    for y = 2, #map do
        for x = 1, #map[y] do
            if map[y][x] == "dirt" then
                if map[y-1][x] == 1 then
                    map[y][x] = "topdirt"
                end
            end
        end
    end
    for i = 1, 3 do
        local rx = love.math.random(1, 10)
        local ry = love.math.random(1, 14)
        map[ry][rx] = "barril"
    end
    for i = 1, 5 do
        local rx = love.math.random(1, 10)
        local ry = love.math.random(1, 14)
        local gems = {"gem1", "gem2", "gem3", "gem4"}
        map[ry][rx] = gems[love.math.random(1, 4)]
    end
    local rx = love.math.random(1, 10)
    local ry = love.math.random(1, 14)
    map[ry][rx] = "powerup"
    for i = 1, 3 do
        local rx = love.math.random(1, 10)
        local ry = love.math.random(1, 14)
        map[ry][rx] = "spikeball"
    end
    rx = love.math.random(1, 10)
    ry = love.math.random(1, 14)
    map[ry][rx] = "hp"
    rx = love.math.random(1, 10)
    ry = love.math.random(1, 14)
    map[ry][rx] = "shield"
end

local function addNPC()
    table.insert(entities, NPC(120, 1400, "boar"))
    --table.insert(entities, NPC(100, 800, "boar"))
    table.insert(entities, NPC(180, 790, "horse"))
    table.insert(entities, NPC(280, 1300, "sheep"))
    table.insert(entities, NPC(340, 1000, "tiny"))
    table.insert(entities, NPC(200, 1200, "turtle"))
    table.insert(entities, NPC(200, -672*99, "master"))
end

local basePlatform = {{0, 0, 0, 0, 1, 0, 1, 0, 0, 0},
                      {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                      {0, 0, 1, 1, 0, 0, 0, 0, 0, 0},
                      {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                      {0, 0, 0, 0, 0, 0, 1, 1, 0, 0},
                      {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                      {0, 0, 1, 1, 1, 0, 0, 0, 0, 0},
                      {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                      {0, 0, 0, 0, 0, 1, 1, 1, 0, 0},
                      {0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                      {0, 0, 1, 1, 1, 0, 0, 0, 0, 0},
                      {0, 1, 1, 1, 1, 1, 0, 0, 0, 0},
                      {1, 1, 1, 1, 1, 1, 1, 0, 0, 0},
                      {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}}

local function buildBasePlatform()
    --for i = 1, MAPWIDTH do
    --    table.insert(entities, Block(48*(i-1), 672*2+48*3, 10, false))
    --end
    for y = 1, 14 do
        for x = 1, 10 do
            if basePlatform[y][x] == 1 then
                table.insert(entities, Block(48*(x-1), (y-1)*48 + 672 + 48*5, 10, false))
            end
        end
    end
end

----
for i = 1, levelNum do
    resetMap()
    buildMap()
    decorateMap()
    addToBigMap(i)
    --addBlock(0, -672*(i-1))
end
    addBlockTest(1, 2)
    buildBasePlatform()
    addNPC()

function love.load()
    loadResources()
end

----test area

--table.insert(entities, SpikeBall(300, 700))


local function delFilter(item)
    if item.isBlock then
        return true
    elseif item.isBarril then
        return true
    elseif item.isItem then
        return true
    elseif item.isSpikeBall then
        return true
    end
end

local function updateGems(dt)
    gem1Anim:update(dt)
    gem2Anim:update(dt)
    gem3Anim:update(dt)
    gem4Anim:update(dt)
    if gem1Anim == gem1Anims.bright then
        if gem1Anim.position == 7 then
            gem1Anim = gem1Anims.idle
        end
    end
    
    if gem2Anim == gem2Anims.bright then
        if gem2Anim.position == 7 then
            gem2Anim = gem2Anims.idle
        end
    end
    
    if gem3Anim == gem3Anims.bright then
        if gem3Anim.position == 7 then
            gem3Anim = gem3Anims.idle
        end
    end
    
    if gem4Anim == gem4Anims.bright then
        if gem4Anim.position == 7 then
            gem4Anim = gem4Anims.idle
        end
    end
    if gem1Scale > 2 then
        gem1Scale = gem1Scale - 0.1
    else
        gem1Scale = 2
    end
    if gem2Scale > 2 then
        gem2Scale = gem2Scale - 0.1
    else
        gem2Scale = 2
    end
    if gem3Scale > 2 then
        gem3Scale = gem3Scale - 0.1
    else
        gem3Scale = 2
    end
    if gem4Scale > 2 then
        gem4Scale = gem4Scale - 0.1
    else
        gem4Scale = 2
    end
    if realGemNum < gemNum then
        updateGemTimer = updateGemTimer + dt
        if updateGemTimer >=0.05 then
            updateGemTimer = 0
            realGemNum = realGemNum + 1
            numScale = 3
        end
    elseif realGemNum > gemNum then
        updateGemTimer = updateGemTimer + dt
        if updateGemTimer >=0.05 then
            updateGemTimer = 0
            realGemNum = realGemNum - 1
        end
    end
    if numScale > 2 then
        numScale = numScale - 0.1
    else
        numScale = 2
    end
end

function love.update(dt)
    if gamestate == "play" then
        for i, v in ipairs(entities) do
            v:update(dt)
        end
        for i, v in ipairs(bullets) do
            v:update(dt)
        end
        camera:update(dt)
        camera:follow(48*5, player.y)
        camera:setFollowStyle('PLATFORMER')
        --camera:setDeadzone(40, h/2 - 40, w - 80, 80)
        -- manage blocks 
        -- calculate player postion
        local key
        if player.y <= 672 and player.y > (#bigmap-1)*(-672) then
            key = math.abs(math.floor(player.y/672)) + 1
        elseif player.y <= (#bigmap-1)*(-672) then
            key = #bigmap
        elseif player.y > 672 then
            key = 1
        end
        -- check unit state 
        if key == 1 then
            if bigmap[key].state == "off" then
                addBlockTest(key, key)
                bigmap[key].state = "on"
            end
            for i = 3, #bigmap do
                if bigmap[i].state == "on" then
                    local dx = 48*5
                    local dy = 48*7 -672*(i-1) 
                    local items, len = world:queryRect(dx - 240 + 12,dy - 336 + 12,480-24,672-24, delFilter)
                    for j = 1, len do
                        items[j]:boom()
                    end
                    bigmap[i].state = "off"
                end
            end
        elseif key == #bigmap then
            if bigmap[key].state == "off" then
                addBlockTest(key, key)
                bigmap[key].state = "on"
            end
            for i = 1, #bigmap-2 do
                if bigmap[i].state == "on" then
                    local dx = 48*5
                    local dy = 48*7 -672*(i-1) 
                    local items, len = world:queryRect(dx - 240 + 12,dy - 336 + 12,480-24,672-24, delFilter)
                    for j = 1, len do
                        items[j]:boom()
                    end
                    bigmap[i].state = "off"
                end
            end
        else
            for i = 1, key - 2 do
                if bigmap[i].state == "on" then
                    local dx = 48*5
                    local dy = 48*7 -672*(i-1) 
                    local items, len = world:queryRect(dx - 240 + 12,dy - 336 + 12,480-24,672-24, delFilter)
                    for j = 1, len do
                        items[j]:boom()
                    end
                    bigmap[i].state = "off"
                end
            end
            for i = key+2, #bigmap do
                if bigmap[i].state == "on" then
                    local dx = 48*5
                    local dy = 48*7 -672*(i-1) 
                    local items, len = world:queryRect(dx - 240 + 12,dy - 336 + 12,480-24,672-24, delFilter)
                    for j = 1, len do
                        items[j]:boom()
                    end
                    bigmap[i].state = "off"
                end
            end
            if bigmap[key].state == "off" then
                addBlockTest(key, key)
                bigmap[key].state = "on"
            elseif bigmap[key-1].state == "off" then
                addBlockTest(key-1, key-1)
                bigmap[key-1].state = "on"
            elseif bigmap[key+1].state == "off" then
                addBlockTest(key+1, key+1)
                bigmap[key+1].state = "on"
            end
        end
        --
        player:update(dt)
        if gameover then
            if gameoverfade < 1 then
                gameoverfade = gameoverfade + 0.01
            else
                gameoverfade = 1
            end
        end
        updateGems(dt)
    elseif gamestate == "intro" then
        if introOpacity < 1 then
            introOpacity = introOpacity + 0.01
        else
            introOpacity = 1
        end
    elseif gamestate == "endgame" then
        table.insert(entities, Fx2(250 + love.math.random(-50, 50), 150 + love.math.random(-50, 50)))
        for i, v in ipairs(entities) do
            v:update(dt)
        end
        if endGameOpacity < 1 then
            endGameOpacity = endGameOpacity + 0.01
        else
            endGameOpacity = 1
        end
    end
end

function love.keypressed(key)
    if gamestate == "play" then
        if key == "w" then
            player:jump()
        elseif key == "space" then
            --addBlockTest(1, 1)
        elseif key == "return" then
            if gameover and gameoverfade >= 1 then
                gameoverfade = 0
                gemNum = 0
                gameover = false
                world:remove(player)
                player = Player(200, 480)
            end
            player:checkTalk()
        elseif key == "o" then
            isEndGame = true
        end
    elseif gamestate == "intro" then
        introScene = introScene + 1
        introOpacity = 0
        if introScene == 9 then
            gamestate = "play"
        end
    elseif gamestate == "endgame" then
        if endGameScene < 11 then
            endGameScene = endGameScene + 1
            endGameOpacity = 0
        end 
    end
end

local function testDelFilter(item)
    if item.isBlock then return true end
end

function love.mousepressed(x, y, button)
    if gamestate == "play" then
        if button == 1 then
            player:fire()
            --[[local mx, my = camera:toWorldCoords(love.mouse.getPosition())
            local items, len = world:queryPoint(mx,my, testDelFilter)
            for i = len, 1, -1 do
                items[i]:boom()
            end]]
        end
    elseif gamestate == "intro" then
        
    elseif gamestate == "endgame" then
        
    end
end

local function drawGems()
    gem1Anim:draw(gem1Img, 400-24, 48, 0, gem1Scale, gem1Scale, 8, 10)
    gem3Anim:draw(gem3Img, 400, 48+12, 0, gem3Scale, gem3Scale, 10, 10)
    gem4Anim:draw(gem4Img, 400+42, 48, 0, gem4Scale, gem4Scale, 7.5, 7.5)
    gem2Anim:draw(gem2Img, 400+20, 48, 0, gem2Scale, gem2Scale, 10.5, 10.5)
    local ones = (realGemNum%1000)%100%10
    local tens = math.floor(((realGemNum%1000)%100)/10)
    local hundreds = math.floor((realGemNum%1000)/100)
    local thousands = math.floor(realGemNum/1000)
    love.graphics.draw(numberImg, numberQuads[ones+1], 320, 30, 0, numScale, numScale)
    if realGemNum >= 10 then
        love.graphics.draw(numberImg, numberQuads[tens+1], 290, 30, 0, numScale, numScale)
    end
    if realGemNum >= 100 then
        love.graphics.draw(numberImg, numberQuads[hundreds+1], 260, 30, 0, numScale, numScale)
    end
    if realGemNum >= 1000 then
        love.graphics.draw(numberImg, numberQuads[thousands+1], 230, 30, 0, numScale, numScale)
    end
end

function love.draw()
    if gamestate == "play" then
        --[[for y = 1, #map do
            for x = 1, #map[y] do
                if map[y][x] == 0 then
                    love.graphics.setColor(1, 1, 1)
                else
                    love.graphics.setColor(1, 0, 0)
                end
                love.graphics.rectangle("fill", (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
            end
        end]]
        local level = math.floor((player.y + player.height/2)/-672) + 2
        if level < 50 then 
            love.graphics.draw(back1Img, 0, 0, 0, 8, 8)
            if gameover == false then
                music1:play()
                music2:stop()
                music3:stop()
                music4:stop()
            end
        elseif level >= 50 and level < 70 then
            love.graphics.draw(back2Img, 0, 0, 0, 8, 8)
            if gameover == false then
                music2:play()
                music1:stop()
                music3:stop()
                music4:stop()
            end
        elseif level >= 70 and level < 80 then
            love.graphics.draw(back3Img, 0, 0, 0, 8, 8)
            if gameover == false then
                music3:play()
                music1:stop()
                music2:stop()
                music4:stop()
            end
        elseif level >= 80 and level < 100 then
            love.graphics.draw(back4Img, 0, 0, 0, 8, 8)
            if gameover == false then
                music4:play()
                music1:stop()
                music2:stop()
                music3:stop()
            end
        elseif level >= 100 then
            if gameover == false then
                music4:play()
                music1:stop()
                music2:stop()
                music3:stop()
            end
            love.graphics.draw(back5Img, 0, 0, 0, 8, 8)
        end
        camera:attach()
        -- Draw your game here
        for i, v in ipairs(entities) do
            v:draw()
        end
        for i, v in ipairs(bullets) do
            v:draw()
        end
        player:draw()
        --[[love.graphics.setColor(1, 1, 1)
        for i = 1, #bigmap do
            love.graphics.rectangle("line", 0, -672*(i-1), 480, 672)
        end
        --
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("line", pointX - 480/2, pointY - 672/2, 480, 672)
        love.graphics.rectangle("fill", pointX - 5, pointY - 5, 10, 10)]]
        --[[
        local key
        if pointY <= 672 and pointY > (#bigmap-1)*(-672) then
            key = math.abs(math.floor(pointY/672)) + 1
        elseif pointY <= (#bigmap-1)*(-672) then
            key = #bigmap
        elseif pointY > 672 then
            key = 1
        end
        love.graphics.print(key, -200, -200)
        love.graphics.print(#entities, -500, -200)]]
        camera:detach()
        camera:draw()
        for i = 1, player.maxhp do
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(emptyheartImg, i*48, 54, 0, 3, 3, 6, 5.5)
        end
        for i = 1, player.hp do
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(fullheartImg, i*48, 54, 0, 3, 3, 6, 5.5)
        end
        love.graphics.setFont(bigfont)
        if gameover then
            love.graphics.setColor(0, 0, 0, gameoverfade)
            love.graphics.rectangle("fill", 0, 0, 480, 672)
            love.graphics.setColor(1, 1, 1, gameoverfade)
            love.graphics.print("GAME OVER", 80, 300)
        end
        drawGems()
    elseif gamestate == "intro" then
        if introScene == 1 then
            love.graphics.draw(back5Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.draw(cowImg, 180, 220, -math.pi/14, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("Hi, my name is moo ..... n. moo'n", 100, 440)
            love.graphics.draw(moonImg, 230, 200, 0, 6, 6, 45/2, 21)
            love.graphics.draw(nImg, 240, 170, -math.pi/3.5, 4, 4, 10, 10)
        elseif introScene == 2 then
            love.graphics.draw(back6Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.draw(cowImg, 200, 500, 0, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("My hobby is reading.", 100, 440)
            love.graphics.draw(book1Img, 100, 200, 0, 4, 4, 33/2, 43/2)
            love.graphics.draw(book2Img, 250, 200, 0, 4, 4, 33/2, 43/2)
            love.graphics.draw(book3Img, 400, 200, 0, 4, 4, 33/2, 43/2)
        elseif introScene == 3 then
            love.graphics.draw(back7Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.draw(cowImg, 200, 500, 0, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("Once I read the book Mystery of the Moon -\r\n an ancient book was born 1000 years ago, \r\nI had a dream, that is to go to the moon.", 20, 340)
            love.graphics.draw(openBookImg, 220, 200, 0, 4, 4, 72/2, 50/2)
        elseif introScene == 4 then
            love.graphics.draw(back2Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            --love.graphics.draw(cowImg, 200, 500, 0, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("The book says, there was a master named \r\n            MasterMoo \r\n he went to the moon, and since then \r\nhas possessed a rare superpower.", 10, 500)
            love.graphics.draw(openBookImg, 220, 400, 0, 4, 4, 72/2, 50/2)
            love.graphics.setColor(1, 1, 0, 0.3)
            love.graphics.polygon('fill', 50, 100, 220, 400, 400, 100)
            love.graphics.setColor(1, 1, 0)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            
        elseif introScene == 5 then
            love.graphics.draw(back2Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.setFont(smallfont)
            love.graphics.print("A strange guy told Moon Moon that\r\n he met Master Moo in a mountain\r\nand was gifted a golden gem\r\nthat could guide the owner to life's success", 20, 440)
            love.graphics.setColor(1, 1, 0)
            love.graphics.draw(cowImg, 200, 200, 0, 8, 8, 9, 5)
            
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("I advise you...", 120, 60)
            love.graphics.setColor(1, 1, 0, 0.5)
            love.graphics.draw(cowImg, 400, 200, 0, -4, 4, 9, 5)
            love.graphics.setFont(bigfont)
            love.graphics.print("?", 390, 180)
        elseif introScene == 6 then
            love.graphics.draw(back8Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.draw(cowImg, 200, 200, 0, 32, 32, 9, 5)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.draw(cowImg, 200, 300, 0, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("I've always dreamed of meeting him\r\n but people don't believe me\r\nThey say that story is just a legend.", 20, 440)
        elseif introScene == 7 then
            love.graphics.draw(back9Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.draw(cowImg, 200, 500, 0, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("They always make fun of me", 20, 440)
            love.graphics.draw(boarImg, 100, 300, 0, 4, 4, 7, 4)
            love.graphics.draw(horseImg, 200, 300, 0, 4, 4, 8, 6.5)
            love.graphics.draw(sheepImg, 300, 300, 0, -4, 4, 5.5, 4)
            love.graphics.draw(tinyImg, 350, 300, 0, -4, 4, 5, 3.5)
            love.graphics.draw(turtleImg, 400, 300, 0, -4, 4, 5.5, 3)
            love.graphics.print("Haha, this stupid cow", 20, 250)
            love.graphics.setColor(0, 1, 0)
            love.graphics.print("Master Moo is just a trick haha", 30, 230)
            love.graphics.setColor(1, 1, 0)
            love.graphics.print("Go home and eat grass! xD", 150, 200)
            love.graphics.setColor(0, 1, 1)
            love.graphics.print("Hahaha \r\n    Hihihi", 360, 235)
        elseif introScene == 8 then
            love.graphics.draw(back10Img, 0, 0, 0, 8, 8)
            love.graphics.setColor(1, 1, 1, introOpacity)
            love.graphics.draw(cowImg, 200, 500, 0, 4, 4, 9, 5)
            love.graphics.setFont(smallfont)
            love.graphics.print("Everything is over the limit \r\nI will prove to them that MasterMoo is real\r\nI will take the gem to prove to everyone\r\nPlease accompany me.", 20, 150)
        end
    elseif gamestate == "endgame" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(back5Img, 0, 0, 0, 8, 8) 
        if endGameScene == 1 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
        elseif endGameScene == 2 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("HEY KID!", 170, 100)
        elseif endGameScene == 3 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("Finally you can come here", 10, 100)    
        elseif endGameScene == 4 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("I've been waiting for this date for a long time", 10, 100)    
        elseif endGameScene == 5 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("The crazy guys think I don't exist", 80, 100)    
        elseif endGameScene == 6 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("But you are the exception.\r\nTo get here\r\nyou must have a perseverance\r\n and a strong belief", 10, 300)
        elseif endGameScene == 7 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("Thousands of years have passed\r\nI am too old. Before I die\r\nI want you to do me a favor.", 10, 300)
        elseif endGameScene == 8 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("Inherit this jewel, go to the moon \r\nto help the MooSho tribe\r\nThey are in desperate need of your help.", 10, 300)
        elseif endGameScene == 9 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("I believe in you, young man\r\nI used to be like you, who dared to dream\r\nPlease continue my peacekeeping career", 10, 300)
        elseif endGameScene == 10 then
            love.graphics.setFont(smallfont)
            love.graphics.setColor(1, 1, 1, endGameOpacity)
            for i, v in ipairs(entities) do
                if v.isFx2 then
                    v:draw()
                end
            end
            love.graphics.setColor(1, 1, 0, endGameOpacity)
            love.graphics.draw(cowImg, 250, 150, 0, 8, 8, 9, 5)
            love.graphics.print("Your journey has only just begun", 10, 300)
        elseif endGameScene == 11 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(bigfont)
            love.graphics.print(" THIS GAME TO BE\r\n     CONTINUED...", 0, 200)
        end
    end
end