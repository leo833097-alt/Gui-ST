--// ПОДМЕНЮ ДЛЯ K
--// НЕ ЗАВИСИТ ОТ ОСНОВНОГО МЕНЮ

local SubMenu = {}

local SUB_SIZE = 27
local SUB_WIDTH = 40
local SUB_PADDING = 4
local MAX_SUB = 6

local subBg = nil
local subScroll = nil
local subPlus = nil
local subButtons = {}
local subCount = 0
local subOpen = false
local subWasOpen = false

function SubMenu:Create()
    if subBg then return end
    
    subBg = Instance.new("Frame")
    subBg.Size = UDim2.new(0, SUB_WIDTH, 0, 40)
    subBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    subBg.BackgroundTransparency = 0.3
    subBg.BorderSizePixel = 0
    subBg.Parent = screenGui
    subBg.ZIndex = 7
    subBg.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = subBg
    
    subScroll = Instance.new("ScrollingFrame")
    subScroll.Size = UDim2.new(1, -SUB_PADDING*2, 1, -35)
    subScroll.Position = UDim2.new(0, SUB_PADDING, 0, SUB_PADDING)
    subScroll.BackgroundTransparency = 1
    subScroll.BorderSizePixel = 0
    subScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    subScroll.ScrollBarThickness = 3
    subScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    subScroll.Parent = subBg
    
    subPlus = Instance.new("TextButton")
    subPlus.Size = UDim2.new(1, -SUB_PADDING*2, 0, 25)
    subPlus.Position = UDim2.new(0, SUB_PADDING, 1, -30)
    subPlus.Text = "+"
    subPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    subPlus.BackgroundTransparency = 0.2
    subPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
    subPlus.Font = Enum.Font.GothamBold
    subPlus.TextSize = 16
    subPlus.BorderSizePixel = 0
    subPlus.Parent = subBg
    subPlus.ZIndex = 8
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 6)
    pc.Parent = subPlus
    
    subPlus.MouseButton1Click:Connect(function()
        SubMenu:AddButton()
    end)
end

function SubMenu:AddButton()
    if subCount >= 10 then return end
    subCount = subCount + 1
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, SUB_SIZE, 0, SUB_SIZE)
    btn.Position = UDim2.new(0, (SUB_WIDTH - SUB_SIZE)/2, 0, (subCount-1)*SUB_SIZE + SUB_PADDING)
    btn.Text = tostring(subCount)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.BackgroundTransparency = 0.2
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.BorderSizePixel = 0
    btn.Parent = subScroll
    btn.ZIndex = 9
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = btn
    
    local shadow = Instance.new("Frame")
    shadow.Size = btn.Size
    shadow.Position = btn.Position
    shadow.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    shadow.BackgroundTransparency = 0.2
    shadow.BorderSizePixel = 0
    shadow.Parent = subScroll
    shadow.ZIndex = 8
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(1, 0)
    sc.Parent = shadow
    
    table.insert(subButtons, {button = btn, shadow = shadow})
    SubMenu:UpdateSize()
end

function SubMenu:UpdateSize()
    if not subBg then return end
    local total = #subButtons
    local visible = math.min(total, MAX_SUB)
    local height = SUB_PADDING*2 + 25
    if visible > 0 then
        height = height + visible * SUB_SIZE + SUB_PADDING
    else
        height = height + 10
    end
    if total > MAX_SUB then
        height = SUB_PADDING*2 + 25 + MAX_SUB * SUB_SIZE + SUB_PADDING
    end
    subBg.Size = UDim2.new(0, SUB_WIDTH, 0, height)
    
    local corner = subBg:FindFirstChild("UICorner")
    if corner then
        corner.CornerRadius = UDim.new(0, height/2)
    end
    
    if subScroll then
        local ch = total * SUB_SIZE + SUB_PADDING
        subScroll.CanvasSize = UDim2.new(0, 0, 0, ch)
        subScroll.ScrollBarThickness = (total > MAX_SUB) and 3 or 0
    end
end

function SubMenu:UpdatePosition(refX, refY, screen)
    if not subOpen or not subBg then return end
    local size = subBg.AbsoluteSize
    local x = refX
    local y = refY + 3
    
    if y + size.Y > screen.Y then
        y = refY - size.Y - 3
    end
    if x < 0 then x = 0 end
    if x + size.X > screen.X then x = screen.X - size.X end
    
    subBg.Position = UDim2.new(0, x, 0, y)
end

function SubMenu:Open()
    if not subBg then SubMenu:Create() end
    subOpen = true
    subWasOpen = true
    subBg.Visible = true
    SubMenu:UpdateSize()
end

function SubMenu:Close()
    if subOpen then
        subOpen = false
        if subBg then subBg.Visible = false end
    end
end

function SubMenu:Toggle()
    if subOpen then
        SubMenu:Close()
        subWasOpen = false
    else
        SubMenu:Open()
    end
end

function SubMenu:IsOpen()
    return subOpen
end

function SubMenu:WasOpen()
    return subWasOpen
end

function SubMenu:SetWasOpen(value)
    subWasOpen = value
end

function SubMenu:GetBg()
    return subBg
end

return SubMenu
