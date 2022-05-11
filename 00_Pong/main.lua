-- push is a library that will allow us to draw our game at a virtual
-- resolution, instead of howere large our window is; used to provide
-- a more retro aesthetic
--
-- https://github.com/Ulydev/push
push = require 'push'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- [[ Runs when the game first starts up ]]
function love.load()
    -- use nearest-neighbor filtering
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- initialize our virtual resolution, which will be rendered within our
    -- actual window no matter its dimensions; replaces our love.window.setMode
    -- from last example
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

-- [[ keyboard input handling, called each frame]]
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end
end

-- [[ called after update, used to draw anything on screen, updated or not ]]
function love.draw()
    -- begin rendering at virtual resolution
    push:apply('start')

    -- note we are now using virtual width and height for text placement
    love.graphics.printf('Hello Pong!', 0, VIRTUAL_HEIGHT / 2 - 6, VIRTUAL_WIDTH, 'center')

    -- end rendering at virtual resolution
    push:apply('end')
end
