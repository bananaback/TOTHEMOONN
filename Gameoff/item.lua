local Item = Object:extend()
local entities = require "entities"
local Fx2 = require "fx2"
function Item:new(x, y, id)
    self.x = x
    self.y = y
    self.width = 48
    self.height = 48
    self.id = id
    if self.id == "gem1" then
        self.grid = anim8.newGrid(16, 20, 64, 20)
        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid(1, 1), 0.1)
        self.animations.bright = anim8.newAnimation(self.grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
        self.anim = self.animations.idle
        self.brightTimer = 0
    elseif self.id == "gem2" then
        self.grid = anim8.newGrid(21, 21, 84, 21)
        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid(1, 1), 0.1)
        self.animations.bright = anim8.newAnimation(self.grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
        self.anim = self.animations.idle
        self.brightTimer = 0
    elseif self.id == "gem3" then
        self.grid = anim8.newGrid(20, 20, 80, 20)
        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid(1, 1), 0.1)
        self.animations.bright = anim8.newAnimation(self.grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
        self.anim = self.animations.idle
        self.brightTimer = 0
    elseif self.id == "gem4" then
        self.grid = anim8.newGrid(15, 15, 60, 15)
        self.animations = {}
        self.animations.idle = anim8.newAnimation(self.grid(1, 1), 0.1)
        self.animations.bright = anim8.newAnimation(self.grid(1, 1, 2, 1, 3, 1, 4, 1, 3, 1, 2, 1, 1, 1), 0.1)
        self.anim = self.animations.idle
        self.brightTimer = 0
    elseif self.id == "powerup" then
        
    elseif self.id == "hp" then
        
    elseif self.id == "shield" then
        
    end
    self.isItem = true
    self.waitTime = love.math.random(1, 10)/10 + 1
    self.dead = false
    self.t = math.floor((self.y + self.height/2)/-672) + 2
    self.xid = math.floor((self.x + self.width/2)/48) + 1
    self.yid = math.floor( ( (self.y + self.height/2) % 672) /48) + 1
    self.scale = 2
    world:add(self, self.x, self.y, self.width, self.height)
end

function Item:updateBigMap()
    --print(bigmap[self.t].unit[self.yid][self.xid])
    bigmap[self.t].unit[self.yid][self.xid] = 1
end

function Item:update(dt)
    if self.id == "gem1" or self.id == "gem2" or self.id == "gem3" or self.id == "gem4" then
        self.anim:update(dt)
        if self.anim == self.animations.idle then
            self.brightTimer = self.brightTimer + dt
            if self.brightTimer > self.waitTime then
                self.brightTimer = 0
                self.anim = self.animations.bright
                self.anim:gotoFrame(1)
            end
        elseif self.anim == self.animations.bright then
            if self.anim.position == 7 then
                self.anim = self.animations.idle
            end
        end
        if self.dead then
            self.scale = self.scale - 0.1
            if self.scale <= 2 then
                self:boom()
            end
        end
    elseif self.id == "powerup" or self.id == "hp" or self.id == "shield" then
        if self.dead then
            self.scale = self.scale - 0.1
            if self.scale <= 2 then
                self:boom()
            end
        end
    end
end

function Item:boom()
    for i = #entities, 1, -1 do
        if entities[i] == self then
            table.insert(entities, Fx2(self.x + self.width/2 - 17, self.y + self.height/2 - 17))
            world:remove(self)
            table.remove(entities, i)
        end
    end
end

function Item:draw()
    if self.id == "gem1" then
        love.graphics.setColor(1, 1, 1)
        self.anim:draw(gem1Img, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 8, 10)
    elseif self.id == "gem2" then
        love.graphics.setColor(1, 1, 1)
        self.anim:draw(gem2Img, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 10.5, 10.5)
    elseif self.id == "gem3" then
        love.graphics.setColor(1, 1, 1)
        self.anim:draw(gem3Img, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 10, 10)
    elseif self.id == "gem4" then
        love.graphics.setColor(1, 1, 1)
        self.anim:draw(gem4Img, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 7.5, 7.5)
    elseif self.id == "powerup" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(powerup1Img, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 12, 9.5)
    elseif self.id == "hp" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(fullheartImg, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 6, 5.5)
    elseif self.id == "shield" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(bubbleImg, self.x + self.width/2, self.y + self.height/2, 0, self.scale, self.scale, 6.5, 6.5)
    end
end

return Item