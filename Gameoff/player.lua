local Player = Object:extend()
local bullets = require "bullets"
local Mooammo = require "mooammo"
local entities = require "entities"
function Player:new(x, y)
    self.x = x
    self.y = y
    self.width = 36
    self.height = 30
    self.isPlayer = true
    self.scaleX = 1
    self.gunRotation = 0
    self.gunSpeed = 200
    -- physics
    self.xVel = 0
    self.yVel = 0
    self.gravity = 1200
    self.terminalVelocity = 1000
    self.jumpVelocity = -600
    self.onGround = false
    --
    self.insane = false
    self.insaneEnergy = 0
    self.insaneReload = 0
    self.hp = 3
    self.maxhp = 3
    self.dead = false
    self.rotation = 0
    self.talking = false
    self.messageto = {}
    self.messageto["horse"] = {}
    self.messageto["horse"][1] = {}
    self.messageto["horse"][1].x = -40
    self.messageto["horse"][1].y = -120
    self.messageto["horse"][1].text = "Yesss"
    self.messageto["horse"][2] = {}
    self.messageto["horse"][2].x = -40
    self.messageto["horse"][2].y = -120
    self.messageto["horse"][2].text = "What is that?"
    self.messageto["horse"][3] = {}
    self.messageto["horse"][3].x = -40
    self.messageto["horse"][3].y = -120
    self.messageto["horse"][3].text = "Thank you."
    --
    self.messageto["boar"] = {}
    self.messageto["boar"][1] = {}
    self.messageto["boar"][1].x = -40
    self.messageto["boar"][1].y = -120
    self.messageto["boar"][1].text = "I want to go to the moon!"
    self.messageto["boar"][2] = {}
    self.messageto["boar"][2].x = -40
    self.messageto["boar"][2].y = -120
    self.messageto["boar"][2].text = "Yeah"
    self.messageto["boar"][3] = {}
    self.messageto["boar"][3].x = -40
    self.messageto["boar"][3].y = -120
    self.messageto["boar"][3].text = "Nahhh :(("
    --
    self.messageto["sheep"] = {}
    self.messageto["sheep"][1] = {}
    self.messageto["sheep"][1].x = -40
    self.messageto["sheep"][1].y = -120
    self.messageto["sheep"][1].text = "Okeyyyyy"
    self.messageto["sheep"][2] = {}
    self.messageto["sheep"][2].x = -40
    self.messageto["sheep"][2].y = -120
    self.messageto["sheep"][2].text = "Yeah"
    self.messageto["sheep"][3] = {}
    self.messageto["sheep"][3].x = -40
    self.messageto["sheep"][3].y = -120
    self.messageto["sheep"][3].text = "Ok man"
    --
    self.messageto["tiny"] = {}
    self.messageto["tiny"][1] = {}
    self.messageto["tiny"][1].x = -40
    self.messageto["tiny"][1].y = -120
    self.messageto["tiny"][1].text = "Thankkkk"
    --
    self.messageto["turtle"] = {}
    self.messageto["turtle"][1] = {}
    self.messageto["turtle"][1].x = -40
    self.messageto["turtle"][1].y = -120
    self.messageto["turtle"][1].text = "I know"
    self.messageto["turtle"][2] = {}
    self.messageto["turtle"][2].x = -40
    self.messageto["turtle"][2].y = -120
    self.messageto["turtle"][2].text = "Ok"
    self.messageto["turtle"][3] = {}
    self.messageto["turtle"][3].x = -40
    self.messageto["turtle"][3].y = -120
    self.messageto["turtle"][3].text = "WOW"
    self.talkTo = "none"
    self.talkToNumber = 0
    self.hurtReload = 0
    world:add(self, self.x, self.y, self.width, self.height)
end

local function playerFilter(item, other)
    if other.isBlock then
        if item.insane == false then
            return "slide"
        else
            return "cross"
        end
    elseif other.isItem then
        return "cross"
    elseif other.isNPC then
        return "cross"
    elseif other.isSpikeBall then
        return "cross"
    end
end

function Player:jump()
    if self.onGround and self.dead == false then
        self.yVel = self.jumpVelocity
        jumpSound:play()
    end
end

function Player:fire()
    if self.dead == false then
        self.gunSpeed = 200
        shootSound:stop()
        shootSound:play()
        --camera:shake(2, 0.15, 60)
        table.insert(bullets, Mooammo(self.x + self.width/2 - 7.5, self.y + self.height/2 - 7.5, self.gunRotation))
    end
end

local function angle(x, y, x2, y2)
  return math.atan2(y - y2, x - x2)
end

function Player:update(dt)
    if self.hurtReload >= 0 then
        self.hurtReload = self.hurtReload - dt
    end
    if self.dead then
        if self.rotation <= math.pi then
            self.rotation = self.rotation + math.pi/30
        end
    end
    if self.dead == false then
        if self.hp <= 0 then
            realGemNum = 0
            self.dead = true
            gameover = true
            self.xVel = 0
            self.yVel = self.jumpVelocity
        end
    end
    if self.insaneEnergy > 0 then
        self.insaneEnergy = self.insaneEnergy - dt
    end
    if self.insaneEnergy > 0 then
        self.insane = true
    else
        self.insane = false
    end
    if self.insane then
        self.insaneReload = self.insaneReload + dt
        if self.insaneReload >= 0.1 then
            self:fire()
            self.insaneReload = 0
        end
    end
    if self.dead == false then
        if love.keyboard.isDown("a") then
            self.xVel = -200
            self.scaleX = -1
        elseif love.keyboard.isDown("d") then
            self.xVel = 200
            self.scaleX = 1
        else
            self.xVel = 0
        end
    end
    if self.gunSpeed > 0 then
        self.gunSpeed = self.gunSpeed - 10
    end
    if self.insane == false then
        ---------------
        if self.yVel < self.terminalVelocity then
            self.yVel = self.yVel + self.gravity*dt
        else
            self.yVel = self.terminalVelocity
        end
    end
    self.onGround = false
    local goalX, goalY = self.x + self.xVel*dt + math.cos(self.gunRotation)*self.gunSpeed*dt, self.y + self.yVel*dt + math.sin(self.gunRotation)*self.gunSpeed*3*dt
    local actualX, actualY, cols, len = world:move(self, goalX, goalY, playerFilter)
    self.x, self.y = actualX, actualY
    --- check for collision
    ----
    self.talking = false
    for i = 1, len do
        local col = cols[i]
        local other = cols[i].other
        if (col.normal.y == -1 or col.normal.y == 1) and col.other.isBlock then
            if self.insane == false then
                self.yVel = 0
            end
        end
        if col.normal.y == -1 and col.other.isBlock then
            self.onGround = true
        end
        if other.isItem then
            other:updateBigMap()
            if other.dead == false then
                other.scale = 4
                if other.id ~= "powerup" and other.id ~= "hp" and other.id ~= "shield" then
                    other.anim = other.animations.bright
                    other.anim:gotoFrame(1)
                    if other.id == "gem1" then
                        gem1Scale = 4
                        gem1Anim = gem1Anims.bright
                        gem1Anim:gotoFrame(1)
                        gold1Sound:play()
                    elseif other.id == "gem2" then
                        gem2Scale = 4
                        gem2Anim = gem2Anims.bright
                        gem2Anim:gotoFrame(1)
                        gold2Sound:play()
                    elseif other.id == "gem3" then
                        gem3Scale = 4
                        gem3Anim = gem3Anims.bright
                        gem3Anim:gotoFrame(1)
                        gold3Sound:play()
                    elseif other.id == "gem4" then
                        gem4Scale = 4
                        gem4Anim = gem4Anims.bright
                        gem4Anim:gotoFrame(1)
                        gold4Sound:play()
                    end
                    gemNum = gemNum + 5
                end
                other.dead = true
                if other.id == "powerup" then
                    self.insaneEnergy = 3
                    self.yVel = 0
                    powerup1Sound:play()
                end
                if other.id == "hp" then
                    if self.hp < 3 then
                        self.hp = self.hp + 1
                    end
                    gold4Sound:play()
                end
                if other.id == "shield" then
                    self.hurtReload = 3
                    gold3Sound:play()
                end
            end
        end
        if other.isNPC then
            self.talking = true
            self.talkToNumber = other.currentTalk
            if other.name == "boar" then
                self.talkTo = "boar"
            elseif other.name == "horse" then
                self.talkTo = "horse"
            elseif other.name == "sheep" then
                self.talkTo = "sheep"
            elseif other.name == "tiny" then
                self.talkTo = "tiny"
            elseif other.name == "turtle" then
                self.talkTo = "turtle"
            end
        end
        if other.isSpikeBall then
            if self.hurtReload <= 0 then
                self.hp = self.hp - 1
                hitSound:stop()
                hitSound:play()
                camera:flash(0.2, {1, 0, 0, 0.5})
                camera:shake(8, 1, 60)
                self.hurtReload = 2
            end
        end
    end
    local mx, my = camera:toWorldCoords(love.mouse.getPosition())
    if self.dead == false then
        self.gunRotation = angle(self.x + self.width/2, self.y + self.height/2, mx, my)
    end
end

function Player:checkTalk()
    local actualX, actualY, cols, len = world:move(self, self.x, self.y, playerFilter)
    self.x, self.y = actualX, actualY
    for i = 1, len do
        local other= cols[i].other
        if other.isNPC then
            --if other.name == "boar" then
                if other.currentTalk < #other.message then
                    other.currentTalk = other.currentTalk + 1
                end
            --end
        end
    end
end

function Player:boom()
    
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.draw(cowImg, self.x + self.width/2, self.y + self.height/2, self.rotation, 3*self.scaleX, 3, 9, 5)
    love.graphics.draw(gunImg, self.x + self.width/2, self.y + self.height/2, self.gunRotation + math.pi/2, 2, 2, 5, 6.5)
    if self.talking then
        love.graphics.setFont(smallfont)
        love.graphics.setColor(1, 1, 0)
        love.graphics.print(self.messageto[self.talkTo][self.talkToNumber].text, self.x + self.width/2 + self.messageto[self.talkTo][self.talkToNumber].x, self.y + self.height/2 + self.messageto[self.talkTo][self.talkToNumber].y)
    end
    if self.hurtReload > 0 then
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(bubbleImg, self.x + self.width/2, self.y + self.height/2, 0, 5, 5, 6.5, 6.5)
    end
end

return Player