local Mooammo = Object:extend()
local listOfBullets = require "bullets"

function Mooammo:new(x, y, angle)
    self.x = x
    self.y = y
    self.angle = angle + math.pi
    self.width = 15
    self.height = 15
    self.isMooammo = true
    self.speed = 200
    self.lifeTime = 0
    world:add(self, self.x, self.y, self.width, self.height)
end

local function mooammoFilter(item, other)
    if other.isBlock then
        return "slide"
    elseif other.isBarril then
        return "slide"
    elseif other.isSpikeBall then
        return "slide"
    end
end

function Mooammo:update(dt)
    self.lifeTime = self.lifeTime + dt
    if self.lifeTime > 3 then
        self:boom()
        return 
    end
    self.xVel = math.cos(self.angle) * self.speed
    self.yVel = math.sin(self.angle) * self.speed
    local goalX, goalY = self.x + self.xVel*dt, self.y + self.yVel*dt
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, mooammoFilter)
    self.x, self.y = actualX, actualY
    for i = 1, len do
        local other = cols[i].other
        if other.isBlock and other.breakable then
            other.hp = other.hp - 1
            self:boom()
        elseif other.isBarril then
            other.scale = 3
            other.hp = other.hp - 1
            self:boom()
        elseif other.isSpikeBall then
            other.scale = 3
            other.hp = other.hp - 1
            self:boom()
        end
    end
end

function Mooammo:boom()
    for i = #listOfBullets, 1, -1 do
        if listOfBullets[i] == self then
            world:remove(self)
            table.remove(listOfBullets, i)
        end
    end
end

function Mooammo:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(mooAmmoImg, self.x + self.width/2, self.y + self.height/2, 0, 1, 1, 7.5, 7.5)
end

return Mooammo