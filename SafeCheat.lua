local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- AYARLAR (LEGIT AYARLARI)
_G.SafeCheatConfig = {
    ESP = false,
    Traces = false,
    TeamCheck = true,
    Aimbot = false,
    AimSmoothness = 0.15, -- Ne kadar yüksekse o kadar yavaş ve belli etmeden kayar (0.1 - 0.5 ideal)
    NoRecoil = false,
    TriggerBot = false
}

-- [GUI OLUŞTURMA]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.Text = "SC"
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 300, 0, 320)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function CreateToggle(name, pos, configName)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 260, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": KAPALI"
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        btn.Text = name .. ": " .. (_G.SafeCheatConfig[configName] and "AÇIK" or "KAPALI")
        btn.TextColor3 = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

CreateToggle("ESP (Visual)", UDim2.new(0.06, 0, 0.15, 0), "ESP")
CreateToggle("Traces (Lines)", UDim2.new(0.06, 0, 0.30, 0), "Traces")
CreateToggle("Legit Aimbot", UDim2.new(0.06, 0, 0.45, 0), "Aimbot")
CreateToggle("Trigger Bot (Oto Ates)", UDim2.new(0.06, 0, 0.60, 0), "TriggerBot")
CreateToggle("No Recoil (Sarsinti Yok)", UDim2.new(0.06, 0, 0.75, 0), "NoRecoil")

-- TEAM CHECK FONKSİYONU
local function IsEnemy(player)
    if not _G.SafeCheatConfig.TeamCheck then return true end
    local char = player.Character
    if char then
        local tag = char:FindFirstChildOfClass("BillboardGui") or char:FindFirstChild("NameTag") or char:FindFirstChild("Head"):FindFirstChildOfClass("BillboardGui")
        return tag == nil
    end
    return false
end

-- ESP CACHE
local espCache = {}

-- ANA DÖNGÜ (LEGIT ÖZELLİKLER)
RunService.RenderStepped:Connect(function()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not espCache[player] then
                espCache[player] = {Highlight = Instance.new("Highlight", game.CoreGui), Line = Drawing.new("Line")}
                espCache[player].Line.Thickness = 1
            end

            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char.Humanoid.Health > 0 then
                local enemy = IsEnemy(player)
                local screenPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

                -- ESP & TRACES
                espCache[player].Highlight.Enabled = _G.SafeCheatConfig.ESP and enemy
                espCache[player].Highlight.Adornee = char
                
                if _G.SafeCheatConfig.Traces and onScreen and enemy then
                    espCache[player].Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    espCache[player].Line.To = Vector2.new(screenPos.X, screenPos.Y)
                    espCache[player].Line.Visible = true
                else
                    espCache[player].Line.Visible = false
                end

                -- AIMBOT İÇİN EN YAKIN DÜŞMANI BUL
                if enemy and onScreen then
                    local mouseDist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mouseDist < shortestDistance and mouseDist < 300 then -- 300 FOV sınırı
                        closestPlayer = char
                        shortestDistance = mouseDist
                    end
                end
            else
                espCache[player].Highlight.Enabled = false
                espCache[player].Line.Visible = false
            end
        end
    end

    -- LEGIT AIMBOT UYGULAMA
    if _G.SafeCheatConfig.Aimbot and closestPlayer then
        local aimPos = closestPlayer.HumanoidRootPart.Position
        local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, _G.SafeCheatConfig.AimSmoothness)
    end

    -- TRIGGER BOT
    if _G.SafeCheatConfig.TriggerBot and Mouse.Target then
        local targetChar = Mouse.Target.Parent
        if targetChar:FindFirstChild("Humanoid") and IsEnemy(Players:GetPlayerFromCharacter(targetChar)) then
            mouse1click() -- Bu fonksiyon Delta'da çalışır
        end
    end
end)

-- NO RECOIL (Basit Mantık)
if _G.SafeCheatConfig.NoRecoil then
    RunService.RenderStepped:Connect(function()
        if _G.SafeCheatConfig.NoRecoil then
            LocalPlayer.CameraMaxZoomDistance = 100 -- Bazı oyunlarda recoil'i etkileyen kamera değişkenlerini sabitler
            -- Not: Defusal özel recoil sistemi script bazlıysa burası oyun özelinde güncellenmelidir.
        end
    end)
end
