--// ЯДРО: Главная кнопка и перетаскивание
--// НЕ ЗАВИСИТ ОТ ОСТАЛЬНЫХ МОДУЛЕЙ

local Core = {}

local BTN_SIZE = 27
local mainButton = nil
local mainButtonPos = UDim2.new(1, -37, 0, 10)
local isDragging = false
local menuOpenCallback = nil  -- функция, которая вызывается при клике

function Core:Init(callback)
    menuOpenCallback = callback
    
    mainButton = Instance.new("TextButton")
    mainButton.Name = "MainButton"
    mainButton.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
    mainButton.Position = mainButtonPos
    mainButton.Text = "+"
    mainButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    mainButton.BackgroundTransparency = 0.2
    mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    mainButton.Font = Enum.Font.GothamBold
    mainButton.TextSize = 14
    mainButton.BorderSizePixel = 0
    mainButton.Parent = screenGui
    mainButton.ZIndex = 10
    
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(1, 0)
    mc.Parent = mainButton
    
    -- Перетаскивание
    local dragMain = false
    local dmStart = nil
    local smPos = nil
    
    mainButton.InputBegan:Connect(function(input)
        if isDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragMain = true
            dmStart = input.Position
            smPos = mainButton.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragMain and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dmStart
            mainButton.Position = UDim2.new(smPos.X.Scale, smPos.X.Offset + d.X, smPos.Y.Scale, smPos.Y.Offset + d.Y)
            mainButtonPos = mainButton.Position
            -- Вызываем колбэк для обновления позиции меню
            if callback and callback.onMainMove then
                callback.onMainMove(mainButtonPos)
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if dragMain and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragMain = false
            isDragging = false
            mainButtonPos = mainButton.Position
        end
    end)
    
    -- Клик
    mainButton.MouseButton1Click:Connect(function()
        if not isDragging then
            if callback and callback.onClick then
                callback.onClick()
            end
        end
    end)
end

function Core:SetText(text)
    if mainButton then mainButton.Text = text end
end

function Core:GetButton()
    return mainButton
end

function Core:GetPosition()
    return mainButtonPos
end

function Core:SetDragging(value)
    isDragging = value
end

return Core
