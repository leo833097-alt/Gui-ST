--// ОСНОВНОЕ МЕНЮ: Фон + кнопки R и K
--// НЕ ЗАВИСИТ ОТ ПОДМЕНЮ

local MainMenu = {}

local BTN_SIZE = 27
local SLOT_GAP = 5
local BG_HEIGHT = 33
local BG_WIDTH = BTN_SIZE*2 + SLOT_GAP + 16

local menuBg = nil
local slot1, slot2 = nil, nil
local slot1Attached, slot2Attached = true, true
local menuOpen = false
local onKClick = nil  -- колбэк для клика по K

function MainMenu:Init(callbacks)
    onKClick = callbacks.onKClick
end

function MainMenu:Create(mainButtonPos)
    if menuBg then return end
    
    menuBg = Instance.new("Frame")
    menuBg.Size = UDim2.new(0, BG_WIDTH, 0, BG_HEIGHT)
    menuBg.Position = UDim2.new(mainButtonPos.X.Scale, mainButtonPos.X.Offset - 80, mainButtonPos.Y.Scale, mainButtonPos.Y.Offset - 3)
    menuBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    menuBg.BackgroundTransparency = 0.3
    menuBg.BorderSizePixel = 0
    menuBg.Parent = screenGui
    menuBg.ZIndex = 8
    menuBg.Visible = false
    
    local cr = Instance.new("UICorner")
    cr.CornerRadius = UDim.new(0, BG_HEIGHT/2)
    cr.Parent = menuBg
    
    local p1 = UDim2.new(0, 8, 0, (BG_HEIGHT - BTN_SIZE)/2)
    local p2 = UDim2.new(0, 8 + BTN_SIZE + SLOT_GAP, 0, (BG_HEIGHT - BTN_SIZE)/2)
    
    -- Тени
    for _, p in ipairs({p1, p2}) do
        local sh = Instance.new("Frame")
        sh.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
        sh.Position = p
        sh.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
        sh.BackgroundTransparency = 0.2
        sh.BorderSizePixel = 0
        sh.Parent = menuBg
        local sc = Instance.new("UICorner")
        sc.CornerRadius = UDim.new(1, 0)
        sc.Parent = sh
    end
    
    -- Кнопка R
    slot1 = MainMenu:CreateSlot(p1, "R")
    -- Кнопка K
    slot2 = MainMenu:CreateSlot(p2, "K")
    
    return menuBg
end

function MainMenu:CreateSlot(position, text)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, BTN_SIZE, 0, BTN_SIZE)
    btn.Position = position
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = menuBg
    btn.ZIndex = 9
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = btn
    
    -- Перетаскивание (без колбэков, просто логика)
    local dragging = false
    local dStart = nil
    local sPos = nil
    local attached = true
    
    btn.InputBegan:Connect(function(input)
        if isDragging then return end
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragging = true
            dStart = input.Position
            sPos = btn.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dStart
            btn.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            dragging = false
            isDragging = false
            local bp = btn.AbsolutePosition
            local bs = btn.AbsoluteSize
            local bgp = menuBg.AbsolutePosition
            local bgs = menuBg.AbsoluteSize
            if bp.X + bs.X > bgp.X and bp.X < bgp.X + bgs.X and bp.Y + bs.Y > bgp.Y and bp.Y < bgp.Y + bgs.Y then
                attached = true
                btn.Parent = menuBg
                btn.Position = position
            else
                if attached then
                    attached = false
                    btn.Parent = screenGui
                    btn.Position = UDim2.new(0, bp.X, 0, bp.Y)
                end
            end
        end
    end)
    
    -- Клик для K
    if text == "K" then
        btn.MouseButton1Click:Connect(function()
            if not isDragging and onKClick then
                onKClick()
            end
        end)
    end
    
    return btn
end

function MainMenu:Open(mainButtonPos)
    menuOpen = true
    menuBg.Visible = true
    menuBg.Position = UDim2.new(mainButtonPos.X.Scale, mainButtonPos.X.Offset - 80, mainButtonPos.Y.Scale, mainButtonPos.Y.Offset - 3)
    -- Показываем кнопки (если прикреплены)
    if slot1 and slot1.Parent == menuBg then slot1.Visible = true end
    if slot2 and slot2.Parent == menuBg then slot2.Visible = true end
end

function MainMenu:Close()
    menuOpen = false
    menuBg.Visible = false
    if slot1 then slot1.Visible = false end
    if slot2 then slot2.Visible = false end
end

function MainMenu:IsOpen()
    return menuOpen
end

function MainMenu:GetBg()
    return menuBg
end

function MainMenu:GetSlot2()
    return slot2
end

function MainMenu:GetSlot2Attached()
    return slot2 and slot2.Parent == menuBg
end

function MainMenu:SetPosition(pos)
    if menuBg then
        menuBg.Position = UDim2.new(pos.X.Scale, pos.X.Offset - 80, pos.Y.Scale, pos.Y.Offset - 3)
    end
end

return MainMenu
