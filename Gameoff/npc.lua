local NPC = Object:extend()
local entities = require "entities"
function NPC:new(x, y, name)
    self.x = x
    self.y = y
    self.name = name
    self.width = 54
    if self.name == "boar" then
        self.height = 30
        self.currentTalk = 1
        self.message = {}
        self.message[1] = {}
        self.message[1].x = -40
        self.message[1].y = -80
        self.message[1].text = "W, A, S, D to move."
        self.message[2] = {}
        self.message[2].x = -40
        self.message[2].y = -80
        self.message[2].text = "Click to shoot"
        self.message[3] = {}
        self.message[3].x = -40
        self.message[3].y = -80
        self.message[3].text = "Powerup lets you fly fast\r\nbut beware of falling out forever" 
    elseif self.name == "horse" then
        self.height = 34
        self.currentTalk = 1
        self.message = {}
        self.message[1] = {}
        self.message[1].x = -40
        self.message[1].y = -80
        self.message[1].text = "Are you really going?"
        self.message[2] = {}
        self.message[2].x = -40
        self.message[2].y = -80
        self.message[2].text = "I give you a tip"
        self.message[3] = {}
        self.message[3].x = -200
        self.message[3].y = -80
        self.message[3].text = "Jump as high as you can then spam shotgun\r\nyou will go high" 
    elseif self.name == "sheep" then
        self.height = 14
        self.currentTalk = 1
        self.message = {}
        self.message[1] = {}
        self.message[1].x = -300
        self.message[1].y = -80
        self.message[1].text = "Hello, I don't know if you can reach the moon\r\n but I have something you need to know ahead of time."
        self.message[2] = {}
        self.message[2].x = -40
        self.message[2].y = -80
        self.message[2].text = "Pick up the gems."
        self.message[3] = {}
        self.message[3].x = -40
        self.message[3].y = -80
        self.message[3].text = "Stay away from spike ball" 
    elseif self.name == "tiny" then
        self.height = 14
        self.currentTalk = 1
        self.message = {}
        self.message[1] = {}
        self.message[1].x = -300
        self.message[1].y = -80
        self.message[1].text = "The oil tank will explode within 9 cells"
    elseif self.name == "turtle" then
        self.height = 16
        self.currentTalk = 1
        self.message = {}
        self.message[1] = {}
        self.message[1].x = -200
        self.message[1].y = -80
        self.message[1].text = "Use guns to destroy all obstacles"
        self.message[2] = {}
        self.message[2].x = -40
        self.message[2].y = -80
        self.message[2].text = "Be wise or be stuck forever"
        self.message[3] = {}
        self.message[3].x = -200
        self.message[3].y = -80
        self.message[3].text = "Also remember to pick up shields and health" 
    end
    self.scale = 3
    self.isNPC = true
    self.talking = false
    -- physics
    self.xVel = 0
    self.yVel = 0
    self.gravity = 1200
    self.terminalVelocity = 1000
    self.jumpVelocity = -600
    self.onGround = false
    --
    self.rot = 0
    self.spinTurn = "right"
    -- physics
    self.xVel = 0
    self.yVel = 0
    self.gravity = 1200
    self.terminalVelocity = 1000
    self.jumpVelocity = -600
    self.onGround = false
    --
    world:add(self, self.x, self.y, self.width, self.height)
end

local function npcFilter(item, other)
    if other.isPlayer then
        return "cross"
    elseif other.isBlock then
        return "slide"
    end
end

function NPC:update(dt)
    if self.yVel < self.terminalVelocity then
        self.yVel = self.yVel + self.gravity*dt
    else
        self.yVel = self.terminalVelocity
    end
    local goalX, goalY = self.x + self.xVel*dt, self.y + self.yVel*dt
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, npcFilter)
    self.x, self.y = actualX, actualY
    self.talking = false
    for i = 1, len do
        local other = cols[i].other
        if other.isPlayer then
            self.talking = true
        end
    end
    
    if self.talking then
        self.scale = 4
        if self.spinTurn == "right" then
            if self.rot < math.pi/16 then
                self.rot = self.rot + math.pi/40
            else
                self.spinTurn = "left"
            end
        elseif self.spinTurn == "left" then
            if self.rot > -math.pi/16 then
                self.rot = self.rot - math.pi/40
            else
                self.spinTurn = "right"
            end
        end
    else
        self.scale = 3
        self.rot = 0
    end
end

function NPC:boom()
    for i = #entities, 1, -1 do
        if entities[i] == self then
            world:remove(self)
            table.remove(entities, i)
        end
    end
end

function NPC:draw()
    love.graphics.setColor(1, 1, 1)
    if self.name == "cow" then
        love.graphics.draw(cowImg, self.x + self.width/2, self.y + self.height/2, self.rot, self.scale, self.scale, 9, 5)
    elseif self.name == "boar" then
        love.graphics.draw(boarImg, self.x + self.width/2, self.y + self.height/2, self.rot, self.scale, self.scale, 7, 4)
    elseif self.name == "horse" then
        love.graphics.draw(horseImg, self.x + self.width/2, self.y + self.height/2, self.rot, self.scale, self.scale, 8, 6.5)
    elseif self.name == "sheep" then
        love.graphics.draw(sheepImg, self.x + self.width/2, self.y + self.height/2, self.rot, -self.scale, self.scale, 5.5, 4)
    elseif self.name == "tiny" then
        love.graphics.draw(tinyImg, self.x + self.width/2, self.y + self.height/2, self.rot, -self.scale, self.scale, 5, 3.5)
    elseif self.name == "turtle" then
        love.graphics.draw(turtleImg, self.x + self.width/2, self.y + self.height/2, self.rot, self.scale, self.scale, 5.5, 3)
    end
    if self.talking then
        love.graphics.setFont(smallfont)
        love.graphics.setColor(51/255, 153/255, 102/255)
        love.graphics.print(self.message[self.currentTalk].text, self.x + self.width/2 + self.message[self.currentTalk].x, self.y + self.height/2 + self.message[self.currentTalk].y)
        love.graphics.setColor(0, 0, 1)
        if self.currentTalk < #self.message then
            love.graphics.print("PRESS ENTER>", self.x, self.y+40)
        else
            love.graphics.print("END.", self.x, self.y+40)
        end
    end
    --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end

return NPC