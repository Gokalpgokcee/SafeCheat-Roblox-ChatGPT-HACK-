local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- AYARLAR
_G.SafeCheatConfig = {
    Enabled = true,
    ESP = false,
    Traces = false,
    TeamCheck = true,
    BoxColor = Color3.fromRGB(255, 0, 0), -- Rakipler genelde kırmızı olur
    TraceColor = Color3.fromRGB(255, 255, 255)
}

-- GUI (Öncekiyle aynı, Delta uyumlu)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeCheatV2_2"
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "SC"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame)

ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function CreateToggle(name, pos, configName)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 260, 0, 40)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name .. ": KAPALI"
    btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    btn.Parent = MainFrame
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        btn.Text = name .. ": " .. (_G.SafeCheatConfig[configName] and "AÇIK" or "KAPALI")
        btn.TextColor3 = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

CreateToggle("ESP (Rakipler)", UDim2.new(0.06, 0, 0.25, 0), "ESP")
CreateToggle("Traces (Çizgi)", UDim2.new(0.06, 0, 0.45, 0), "Traces")
CreateToggle("Team Check (Aktif)", UDim2.new(0.06, 0, 0.65, 0), "TeamCheck")

--- YENİ NESİL TEAM CHECK MANTIĞI ---
local function IsEnemy(player)
    if not _G.SafeCheatConfig.TeamCheck then return true end -- Team check kapalıysa herkes düşman
    
    local char = player.Character
    if char then
        -- Oyunun takım arkadaşlarını işaretlemek için kullandığı yaygın objeleri kontrol ediyoruz
        -- 1. BillboardGui kontrolü (İsim etiketi kafasında var mı?)
        local hasTag = char:FindFirstChildOfClass("BillboardGui") or char:FindFirstChild("NameTag") or char:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BillboardGui")
        
        -- Eğer kafasında bir etiket VARSA, o senin takımıdır.
        -- Eğer etiket YOKSA, o rakiptir.
        if hasTag then
            return false -- Takım arkadaşı
        else
            return true -- Rakip
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
                    Highlight = Instance.new("Highlight"),
                    Line = Drawing.new("Line")
                }
                espCache[player].Highlight.FillColor = _G.SafeCheatConfig.BoxColor
                espCache[player].Highlight.Parent = game.CoreGui
                espCache[player].Line.Thickness = 1.5
                espCache[player].Line.Color = _G.SafeCheatConfig.TraceColor
            end

            local objects = espCache[player]
            local character = player.Character
            
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local rootPos = character.HumanoidRootPart.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
                
                local enemy = IsEnemy(player) -- Yeni kontrol

                -- ESP Sadece Rakiplere
                if _G.SafeCheatConfig.ESP and enemy then
                    objects.Highlight.Adornee = character
                    objects.Highlight.Enabled = true
                else
                    objects.Highlight.Enabled = false
                end

                -- Çizgi Sadece Rakiplere
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

print("Safe Cheat V2.2: İsim Etiketi Tabanlı Team Check Yüklendi!")
