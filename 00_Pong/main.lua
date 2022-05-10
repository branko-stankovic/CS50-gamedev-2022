WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- [[ Runs when the game first starts up ]]
function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })
end

-- [[ called after update, used to draw anything to the screen ]]
function love.draw()
    love.graphics.printf(
        'Hello Pong!',          -- text to render
        0,                      -- starting X
        WINDOW_HEIGHT / 2 - 6,  -- starting Y
        WINDOW_WIDTH,           -- number of pixels to center withing
        'center')               -- alignment mode
end
