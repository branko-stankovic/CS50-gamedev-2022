--[[
    GD50
    Breakout Remake

    -- PlayState Class --

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Represents the state of the game in which we are actively playing;
    player should control the paddle, with the ball actively bouncing between
    the bricks, walls, and the paddle. If the ball goes below the paddle, then
    the player should lose one point of health and be taken either to the Game
    Over screen if at 0 health or the Serve screen otherwise.
]]

PlayState = Class{__includes = BaseState}

--[[
    We initialize what's in our PlayState via a state table that we pass between
    states as we go from playing to serving.
]]
function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.highScores = params.highScores
    self.ball = params.ball
    self.level = params.level

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    powerup = Powerup()
    local powerupActive = false

    key = Key()
    gKeyActive = false

    balls = {}
    table.insert(balls, self.ball)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on velocity
    self.paddle:update(dt)

    for b, ball in pairs(balls) do
        ball:update(dt)
    end

    powerup:update(dt)

    key:update(dt)

    for b, ball in pairs(balls) do
        if ball:collides(self.paddle) then
            -- raise ball above paddle in case it goes below it, then reverse dy
            ball.y = self.paddle.y - 8
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if we hit the paddle on its left side while moving left
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))

                -- else if we hit the paddle on its right side while moving right
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()

            if love.math.random(1, 10) > 8 and not powerupActive then
                powerup.dy = 30
            elseif love.math.random(1, 10) > 8 then
                key.dy = 30
            end
        end
    end

    if powerup:collides(self.paddle) then
        powerup:reset()
        powerupActive = true

        self.ball2 = Ball()
        self.ball2.skin = love.math.random(7)

        self.ball2.x = self.paddle.x + self.paddle.width / 2 - self.ball2.width / 2
        self.ball2.y = self.paddle.y - self.ball2.height

        self.ball2.dx = love.math.random(-200, 200)
        self.ball2.dy = love.math.random(-50, -60)

        table.insert(balls, self.ball2)

        self.ball3 = Ball()
        self.ball3.skin = love.math.random(7)

        self.ball3.x = self.paddle.x + self.paddle.width / 2 - self.ball3.width / 2
        self.ball3.y = self.paddle.y - self.ball3.height

        self.ball3.dx = love.math.random(-200, 200)
        self.ball3.dy = love.math.random(-50, -60)

        table.insert(balls, self.ball3)
    end

    if key:collides(self.paddle) then
        key:reset()
        gKeyActive = true
    end

    -- detect collision across all bricks with the ball
    for b, ball in pairs(balls) do
        for k, brick in pairs(self.bricks) do

            -- only check collision if we're in play
            if brick.inPlay and ball:collides(brick) then

                -- add to score
                self.score = self.score + (brick.tier * 200 + brick.color * 25)

                -- trigger the brick's hit function, which removes it from play
                brick:hit()

                -- give some random chance to
                -- increase paddle size if not already maxed out
                if love.math.random(1, 10) > 8  and self.health == 1 then
                    self.paddle:increase()
                end

                -- go to our victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        highScores = self.highScores,
                        ball = self.ball
                    })
                end

                --
                -- collision code for bricks
                --
                -- we check to see if the opposite side of our velocity is outside of the brick;
                -- if it is, we trigger a collision on that side. Else we're within the X + width of
                -- the brick and should check to see if the top or bottom edge is outside of the brick,
                -- colliding on the top or bottom accordingly
                --

                -- left edge; only check if we're moving right
                if ball.x + 2 < brick.x and ball.dx > 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - 8

                -- right edge; only check if we're moving left
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then

                    -- flip x velocity and reset position outside of brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + 32

                -- top edge if no X collisions, always check
                elseif ball.y < brick.y then

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - 8

                -- bottom edge if no X collisions or top collisions, last possibility
                else

                    -- flip y velocity and reset position outside of brick
                    ball.dy = -ball.dy
                    ball.y = brick.y + 16
                end

                -- slightly scale the y velocity to speed up the game
                ball.dy = ball.dy * 1.02

                -- only allow colliding with one brick, for corners
                break
            end
        end
    end

    -- if ball goes below bounds, revert to serve state and decrease health
    for b, ball in pairs(balls) do
        if ball.y >= VIRTUAL_HEIGHT and #balls == 2 then
            powerupActive = false
            table.remove(balls, b)
        elseif ball.y >= VIRTUAL_HEIGHT and #balls == 1 then
            self.health = self.health - 1
            self.paddle:decrease()
            powerupActive = false
            powerup:reset()
            gSounds['hurt']:play()
            gKeyActive = false

            if self.health == 0 then
                gStateMachine:change('game-over', {
                    score = self.score,
                    highScores = self.highScores
                })
            else
                gStateMachine:change('serve', {
                    paddle = self.paddle,
                    bricks = self.bricks,
                    health = self.health,
                    score = self.score,
                    highScores = self.highScores,
                    level = self.level
                })
            end
        elseif ball.y >= VIRTUAL_HEIGHT and #balls > 1 then
            table.remove(balls, b)
        end
    end

    -- for rendering particle systems
    for k, brick in pairs(self.bricks) do
        brick:update(dt)
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    -- render all particle systems
    for k, brick in pairs(self.bricks) do
        brick:renderParticles()
    end

    self.paddle:render()

    for b, ball in pairs(balls) do
        ball:render()
    end

    powerup:render()
    key:render()

    renderScore(self.score)
    renderHealth(self.health)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end
