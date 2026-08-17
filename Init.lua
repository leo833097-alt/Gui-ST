--// ГЛАВНЫЙ ФАЙЛ: Точка входа и связь модулей
--// Загружает Core, MainMenu, SubMenu и инициализирует интерфейс

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Удаляем старый GUI, если есть
if PlayerGui:FindFirstChild("RadialMenu") then
    PlayerGui:FindFirstChild("RadialMenu"):Destroy()
end

-- 1. СОЗДАЁМ ГЛОБАЛЬНЫЙ КОНТЕЙНЕР (ScreenGui)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RadialMenu"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- 2. ОБЪЯВЛЯЕМ ГЛОБАЛЬНЫЕ ПЕРЕМЕННЫЕ ДЛЯ МОДУЛЕЙ
_G.screenGui = screenGui
_G.UserInputService = UserInputService
_G.isDragging = false  -- общая блокировка для перетаскивания

-- 3. ЗАГРУЖАЕМ МОДУЛИ (считаем, что они лежат рядом в репозитории)
local Core = require(script.Core)
local MainMenu = require(script.MainMenu)
local SubMenu = require(script.SubMenu)

-- 4. ИНИЦИАЛИЗИРУЕМ ПОДМЕНЮ (оно не требует колбэков)
SubMenu:Create()  -- создаём фон подменю, но пока скрыто

-- 5. ИНИЦИАЛИЗИРУЕМ ОСНОВНОЕ МЕНЮ (передаём колбэк для клика по K)
MainMenu:Init({
    onKClick = function()
        -- Открываем/закрываем подменю
        SubMenu:Toggle()
        
        -- Обновляем позицию подменю после переключения
        local refX, refY
        if MainMenu:GetSlot2Attached() then
            -- Если K прикреплена к основному фону, считаем от кнопки "-"
            local btn = Core:GetButton()
            local pos = btn.AbsolutePosition
            refX = pos.X
            refY = pos.Y + 27  -- высота кнопки
        else
            -- Если K свободна, считаем от неё самой
            local slot2 = MainMenu:GetSlot2()
            if slot2 then
                local pos = slot2.AbsolutePosition
                refX = pos.X
                refY = pos.Y + 27
            else
                return
            end
        end
        
        local screen = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
        SubMenu:UpdatePosition(refX, refY, screen)
    end
})

-- 6. ИНИЦИАЛИЗИРУЕМ ЯДРО (главная кнопка + колбэки)
Core:Init({
    -- Что делать при клике по кнопке "+"
    onClick = function()
        if not MainMenu:IsOpen() then
            -- Открываем основное меню
            MainMenu:Open(Core:GetPosition())
            
            -- Восстанавливаем подменю, если оно было открыто до закрытия
            if SubMenu:WasOpen() and MainMenu:GetSlot2Attached() then
                SubMenu:Open()
                -- Обновляем позицию подменю
                local btn = Core:GetButton()
                local pos = btn.AbsolutePosition
                local screen = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
                SubMenu:UpdatePosition(pos.X, pos.Y + 27, screen)
            end
        else
            -- Закрываем основное меню
            MainMenu:Close()
            
            -- Если подменю открыто, запоминаем его состояние и закрываем
            if SubMenu:IsOpen() then
                SubMenu:SetWasOpen(MainMenu:GetSlot2Attached())
                SubMenu:Close()
            else
                SubMenu:SetWasOpen(false)
            end
        end
    end,
    
    -- Что делать при перетаскивании главной кнопки
    onMainMove = function(pos)
        if MainMenu:IsOpen() then
            -- Двигаем основное меню следом
            MainMenu:SetPosition(pos)
            
            -- Если подменю открыто и K прикреплена к основному фону, двигаем и его
            if SubMenu:IsOpen() and MainMenu:GetSlot2Attached() then
                local btn = Core:GetButton()
                local btnPos = btn.AbsolutePosition
                local screen = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
                SubMenu:UpdatePosition(btnPos.X, btnPos.Y + 27, screen)
            end
        end
    end
})

-- 7. СОЗДАЁМ ОСНОВНОЕ МЕНЮ (фон с кнопками R и K)
MainMenu:Create(Core:GetPosition())

-- 8. ГОТОВО!
print("Радиальное меню загружено. Нажмите '+' для открытия.")
