local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

_G.SafeCheatConfig = {
    Enabled = true,
    ESP = false,
    Traces = false,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 0, 0)
}

-- [GUI KODU AYNI KALDI - DELTA BUTONU VE MENU]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.Text = "SC"
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame)

ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function CreateToggle(name, pos, configName)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 240, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": KAPALI"
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        btn.Text = name .. ": " .. (_G.SafeCheatConfig[configName] and "AÇIK" or "KAPALI")
        btn.TextColor3 = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

CreateToggle("ESP (Rakipler)", UDim2.new(0.07, 0, 0.2, 0), "ESP")
CreateToggle("Traces (Çizgi)", UDim2.new(0.07, 0, 0.45, 0), "Traces")
CreateToggle("Team Check", UDim2.new(0.07, 0, 0.7, 0), "TeamCheck")

--- [YENİ: GÖRÜNTÜYE GÖRE ÖZEL TEAM CHECK] ---
local function IsEnemy(player)
    if not _G.SafeCheatConfig.TeamCheck then return true end
    
    local character = player.Character
    if character then
        -- 1. YÖNTEM: Karakter içindeki herhangi bir GUI objesini tara
        local tag = character:FindFirstChildOfClass("BillboardGui") or 
                    character:FindFirstChild("PlayerDisplay") or 
                    character:FindFirstChild("NameTag")
        
        -- 2. YÖNTEM: Kafasındaki TextLabel'ı kontrol et (Görüntüdeki sses550 yazısı gibi)
        local head = character:FindFirstChild("Head")
        if head then
            local headTag = head:FindFirstChildOfClass("BillboardGui")
            if headTag then return false end -- İsim etiketi varsa takımdır
        end

        -- 3. YÖNTEM: Roblox Standart Takım Kontrolü (Hala ihtimal dahilinde)
        if player.Team ~= nil and player.Team == LocalPlayer.Team then
            return false
        end

        -- 4. YÖNTEM: Eğer hiçbir etiket yoksa RAKİPTİR
        if not tag then
            return true
        end
    end
    return false
end

local espCache = {}

RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not espCache[player] then
                espCache[player] = {
                    Highlight = Instance.new("Highlight", game.CoreGui),
                    Line = Drawing.new("Line")
                }
                espCache[player].Line.Thickness = 1
                espCache[player].Line.Color = Color3.fromRGB(255, 255, 255)
            end

            local objects = espCache[player]
            local char = player.Character
            
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local enemy = IsEnemy(player)
                local screenPos, onScreen = Camera:WorldToViewportPoint(char.HumanoidRootPart.Position)

                -- ESP Uygula (SADECE RAKİPLERE)
                if _G.SafeCheatConfig.ESP and enemy then
                    objects.Highlight.Adornee = char
                    objects.Highlight.Enabled = true
                    objects.Highlight.FillColor = _G.SafeCheatConfig.BoxColor
                else
                    objects.Highlight.Enabled = false
                end

                -- Traces Uygula (SADECE RAKİPLERE VE EKRANDAYSA)
                if _G.SafeCheatConfig.Traces and onScreen and enemy then
                    objects.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    objects.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                    objects.Line.Visible = true
                else
                    objects.Line.Visible = false
                end
            else
                objects.Highlight.Enabled = false
                objects.Line.Visible = false
            end
        end
    end
end)
