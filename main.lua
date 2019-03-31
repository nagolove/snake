local inspect = require "inspect"
local lg = love.graphics

local DIRECTION_LEFT = 0
local DIRECTION_UP = 1
local DIRECTION_RIGHT = 2
local DIRECTION_DOWN = 3

local UPDATE_TIME = 0.6
local FIELD_SIZE = 20 -- внимание: игровое поле индексируется с еденицы.

local W, H = lg.getDimensions()
local CELL_WIDTH = H / FIELD_SIZE

local FIELD_X_POS, FIELD_Y_POS = (W - H) / 2, 0

local snake = {}
local isRun = false
local isGameover = false

function getRandomDirection()
    return math.random(0, 3)
end

function love.load(argv)
    direction = getRandomDirection()
    table.insert(snake, { x = math.random(1, FIELD_SIZE), y = math.random(1, FIELD_SIZE) })
    table.insert(snake, { x = snake[1].x, y = snake[1].y - 1 })
    table.insert(snake, { x = snake[2].x, y = snake[2].y - 1 })
    eat = getEat()
    print("snake", inspect(snake))
    gameoverFont = lg.newFont(84)
    timestamp = love.timer.getTime()
end

function drawGrid()
    lg.setColor{0, 1, 0}
    lg.setLineWidth(3)
    local x, y = FIELD_X_POS, FIELD_Y_POS
    local x1, y1 = FIELD_X_POS, FIELD_Y_POS
    for i = 1, FIELD_SIZE + 1 do
        lg.line(x, y, x + H, y)
        y = y + CELL_WIDTH
        lg.line(x1, y1, x1, y1 + H)
        x1 = x1 + CELL_WIDTH
    end
    lg.setColor{1, 1, 1}
    lg.setLineWidth(1)
end

function drawSnake()
    lg.setColor{0.8, 0.8, 0.6}
    for k, v in pairs(snake) do
        lg.rectangle("fill", v.x * CELL_WIDTH + FIELD_X_POS, v.y * CELL_WIDTH + FIELD_Y_POS, CELL_WIDTH, CELL_WIDTH)
    end
end

function drawEat()
    if eat ~= {} then
        lg.setColor{1, 0, 0}
        lg.rectangle("fill", eat.x * CELL_WIDTH + FIELD_X_POS, eat.y * CELL_WIDTH + FIELD_Y_POS, CELL_WIDTH, CELL_WIDTH)
    end
end

function drawGameOver()
    lg.setColor{1, 1, 1}
    local default = lg.getFont()
    lg.setFont(gameoverFont)
    lg.printf("GameOver", 0, H / 2, W, "center")
    lg.setFont(default)
end

function drawPressAnyKey()
    lg.setColor{0.3, 0.5, 0.3}
    lg.printf("Press any key to start", 0, H * 3 / 4, W, "center")
end

function love.draw()
    if isRun then
        drawGrid()
        drawSnake()
        drawEat()
    else
        drawGameOver()
        drawPressAnyKey()
    end
end

function love.update(dt)
    -- проверка ввода
    -- проверка на пересечение границ поля
    -- проверка на самопересечение
    -- проверка на поглощение еды
    -- проверка приращение координат головы
    -- приращение координат остальных ячеек, вплоть до хвоста
    if not isRun then return end
    local lk = love.keyboard
    if lk.isDown("left") then direction = DIRECTION_LEFT
    elseif lk.isDown("up") then direction = DIRECTION_UP
    elseif lk.isDown("right") then direction = DIRECTION_RIGHT
    elseif lk.isDown("down") then direction = DIRECTION_DOWN end
    if love.timer.getTime() - timestamp >= UPDATE_TIME then
        timestamp = love.timer.getTime()
        -- update stuff below ↓
        if direction == DIRECTION_LEFT then
            snake[1].x = snake[1].x - 1
        elseif direction == DIRECTION_UP then
            snake[1].y = snake[1].y - 1
        elseif direction == DIRECTION_RIGHT then
            snake[1].x = snake[1].x + 1
        elseif direction == DIRECTION_DOWN then
            snake[1].y = snake[1].y + 1
        end
    end
end

local les = {1, 2, 3}
print("les", inspect(les))
table.insert(les, 2, 0)
print("les", inspect(les))
table.insert(les, 1, 0)
table.insert(les, 1, 0)
table.insert(les, 1, 0)
table.insert(les, 1, 0)
table.insert(les, 1, 0)
table.insert(les, 1, 0)
print("les", inspect(les))

function getEat()
    local eatPos = {}
    local stop = true
    repeat
        eatPos.x = math.random(1, FIELD_SIZE)
        eatPos.y = math.random(1, FIELD_SIZE)
        for k, v in pairs(snake) do
            if eatPos.x == v.x and eatPos.y == v.y then
                stop = false
                break
            end
        end
    until stop
    return eatPos
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
    elseif not isRun then
        isRun = true
    end
end
