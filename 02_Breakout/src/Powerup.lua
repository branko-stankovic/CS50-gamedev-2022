--[[
    GD50
    Breakout Remake

    -- Powerup Class --

    Author: Branko Stankovic
    branko.stankovic@gmail.com

    Represents a powerup that spawns on top of the screen and then falls down
    towards the bottom, and if it collides with the player (paddle), then
    it activates a certain powerup feature for the player.
]]

Powerup = Class{}

function Powerup:init()
    self.width = 16
    self.height = 16

    self.dy = 0
    self.dx = 0

    self.x = love.math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
end

function Powerup:reset()
    self.dy = 0
    self.dx = 0

    self.x = love.math.random(0, VIRTUAL_WIDTH - 16)
    self.y = -16
end

function Powerup:collides(target)
    if self.x > target.x + target.width or target.x > self.x + self.width then
        return false
    end

    if self.y > target.y + target.height or target.y > self.y + self.height then
        return false
    end

    return true
end

function Powerup:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.y > WINDOW_HEIGHT then
        powerup:reset()
    end
end

function Powerup:render()
    love.graphics.draw(gTextures['main'], gFrames['powerup'][1], self.x, self.y)
end
