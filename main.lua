local inspect = require "inspect"
local Timer = require "Timer"
local lg = love.graphics

local DIRECTION_LEFT = 0
local DIRECTION_UP = 1
local DIRECTION_RIGHT = 2
local DIRECTION_DOWN = 3

local UPDATE_TIME = 0.3
local FIELD_SIZE = 20 -- внимание: игровое поле индексируется с еденицы.

local W, H = lg.getDimensions()
local CELL_WIDTH = H / FIELD_SIZE

local FIELD_X_POS, FIELD_Y_POS = (W - H) / 2, 0

local snake = {}
local isRun = false
local isGameover = false
local isPaused = false

function getRandomDirection()
    return math.random(0, 3)
end

function makeSmallSnake()
    direction = getRandomDirection()
    snake = {}
    table.insert(snake, { x = math.random(5, FIELD_SIZE - 5), y = math.random(5, FIELD_SIZE - 5) })
    table.insert(snake, { x = snake[1].x, y = snake[1].y - 1 })
    table.insert(snake, { x = snake[2].x, y = snake[2].y - 1 })
end

function love.load(argv)
    math.randomseed(os.time())
    makeSmallSnake()
    eat = getEat()
    print("snake", inspect(snake))
    gameoverFont = lg.newFont(84)
    local record, _ = love.filesystem.read("record.txt")
    print("record", inspect(record), "size", size)
    record = record and tonumber(record) or 0
    recordValue = record
    headScale = 1
    timer = Timer()
    timestamp = love.timer.getTime()
end

function drawGrid()
    lg.setColor{0, 1, 0}
    lg.setLineWidth(3)
    local x, y = FIELD_X_POS, FIELD_Y_POS
    for i = 1, FIELD_SIZE + 1 do
        lg.line(FIELD_X_POS, y, FIELD_X_POS + H, y)
        y = y + CELL_WIDTH
        lg.line(x, FIELD_Y_POS, x, FIELD_Y_POS + H)
        x = x + CELL_WIDTH
    end
    lg.setColor{1, 1, 1}
    lg.setLineWidth(1)
end

function drawSnake()
    lg.setColor{0.3, 0.45, 0.15}
    local v = snake[1]
    lg.circle("fill", v.x * CELL_WIDTH + FIELD_X_POS + CELL_WIDTH / 2, 
                      v.y * CELL_WIDTH + FIELD_Y_POS + CELL_WIDTH / 2, 
                      (CELL_WIDTH / 2) * headScale)
    for i = 2, #snake do
        local v = snake[i]
        --lg.rectangle("fill", v.x * CELL_WIDTH + FIELD_X_POS, v.y * CELL_WIDTH + FIELD_Y_POS, CELL_WIDTH, CELL_WIDTH)
        lg.setColor{0.8, 0.8, 0.6}
        lg.circle("fill", v.x * CELL_WIDTH + FIELD_X_POS + CELL_WIDTH / 2, 
                          v.y * CELL_WIDTH + FIELD_Y_POS + CELL_WIDTH / 2, CELL_WIDTH / 2)
        lg.setColor{0, 0, 0}
        lg.circle("line", v.x * CELL_WIDTH + FIELD_X_POS + CELL_WIDTH / 2, 
                          v.y * CELL_WIDTH + FIELD_Y_POS + CELL_WIDTH / 2, 0.8 * CELL_WIDTH / 2)
    end

    lg.setColor{0, 0, 0}
    for i = 1, #snake - 1 do
        local v = snake[i]
        local w = snake[i + 1]
        if not (math.abs(v.x - w.x) > 1) or not (math.abs(v.y - w.y) > 1) then
                lg.line(v.x * CELL_WIDTH + FIELD_X_POS + CELL_WIDTH / 2, 
                        v.y * CELL_WIDTH + FIELD_Y_POS + CELL_WIDTH / 2, 
                        w.x * CELL_WIDTH + FIELD_X_POS + CELL_WIDTH / 2, 
                        w.y * CELL_WIDTH + FIELD_Y_POS + CELL_WIDTH / 2)
        end
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

function drawRecord()
    if recordValue > 0 then
        lg.setColor{1, 1, 1}
        lg.printf(string.format("Record snake length is %d", recordValue), 0, H * 3 / 4 - lg.getFont():getHeight(), W, "center")
    end
end

function drawPressAnyKey()
    lg.setColor{0.3, 0.5, 0.3}
    lg.printf("Press any key to start", 0, H * 3 / 4, W, "center")
end

function drawInfo()
    local gap = 10
    local x0, y0 = FIELD_X_POS + H + gap, lg.getFont():getHeight()
    lg.setColor{1, 1, 1}
    lg.print(string.format("Lenght %d", #snake), x0, y0)
end

function love.draw()
    if isRun then
        drawGrid() drawSnake() drawEat() drawInfo()
    else
        drawGameOver() drawRecord() drawPressAnyKey()
    end
end

function love.update(dt)
    timer:update(dt)
    -- проверка ввода
    -- проверка на пересечение границ поля
    -- проверка на поглощение еды
    -- проверка приращение координат головы
    -- приращение координат остальных ячеек, вплоть до хвоста
    if not isRun or isPaused then return end
    local lk = love.keyboard
    if lk.isDown("left") or lk.isScancodeDown("a") then direction = DIRECTION_LEFT
    elseif lk.isDown("up") or lk.isScancodeDown("w") then direction = DIRECTION_UP
    elseif lk.isDown("right") or lk.isScancodeDown("d") then direction = DIRECTION_RIGHT
    elseif lk.isDown("down") or lk.isScancodeDown("s") then direction = DIRECTION_DOWN end
    if love.timer.getTime() - timestamp >= UPDATE_TIME then
        timestamp = love.timer.getTime()
        -- ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
        local assoc = {[DIRECTION_LEFT] = { x = snake[1].x - 1, y = snake[1].y },
        [DIRECTION_UP] = { x = snake[1].x, y = snake[1].y - 1 },
        [DIRECTION_RIGHT] = { x = snake[1].x + 1, y = snake[1].y },
        [DIRECTION_DOWN] = { x = snake[1].x, y = snake[1].y + 1 } }
        -- ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
        local head = assoc[direction]
        for i = 2, #snake do -- проверка на самопересечение
            if snake[i].x == head.x and snake[i].y == head.y then 
                gameOver()
                break
            end 
        end
        if direction == DIRECTION_LEFT and head.x < 0 then
            head.x = FIELD_SIZE - 1
        elseif direction == DIRECTION_UP and head.y < 0 then
            head.y = FIELD_SIZE - 1
        elseif direction == DIRECTION_RIGHT and head.x > FIELD_SIZE - 1 then
            head.x = 0
        elseif direction == DIRECTION_DOWN and head.y > FIELD_SIZE - 1 then
            head.y = 0
        end
        table.insert(snake, 1, assoc[direction])
        if head.x == eat.x and head.y == eat.y then
            eat = getEat()
        else
            if #snake > 1 then 
                table.remove(snake, #snake)
            end
        end
    end
end

function gameOver()
    isGameover = true 
    isRun = false
    local record, size = love.filesystem.read("record.txt")
    record = record and tonumber(record) or 0
    if #snake > record then
        love.filesystem.write("record.txt", tostring(#snake))
        recordValue = #snake
    end
    makeSmallSnake()
end

function getEat()
    local eatPos = {}
    local stop
    repeat
        stop = true
        eatPos.x = math.random(1, FIELD_SIZE - 1)
        eatPos.y = math.random(1, FIELD_SIZE - 1)
        for k, v in pairs(snake) do
            if eatPos.x == v.x and eatPos.y == v.y then
                stop = false
                break
            end
        end
    until stop
    print("getEat()", inspect(eatPos))
    return eatPos
end

function love.keypressed(key, scancode)
    if key == "escape" then
        love.event.quit()
    elseif key == "p" then isPaused = not isPaused
    elseif not isRun then
        isRun = true
    end
end
