local UserInputService = game:GetService("UserInputService")
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
    BoxColor = Color3.fromRGB(0, 255, 255),
    TraceColor = Color3.fromRGB(255, 255, 255)
}

-- GUI OLUŞTURMA (MODERN & DRAGGABLE)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SafeCheatV2_1"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- AÇMA/KAPAMA BUTONU (DELTA İÇİN)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "SC"
ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 255)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)

-- ANA PANEL
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
MainFrame.Active = true
MainFrame.Draggable = true

local Corner = Instance.new("UICorner", MainFrame)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "SAFE CHEAT V2.1"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

-- MENÜ BUTON FONKSİYONU
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
    btn.Font = Enum.Font.Gotham
    btn.Parent = MainFrame
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        btn.Text = name .. ": " .. (_G.SafeCheatConfig[configName] and "AÇIK" or "KAPALI")
        btn.TextColor3 = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

CreateToggle("ESP (Kutu)", UDim2.new(0.06, 0, 0.25, 0), "ESP")
CreateToggle("Traces (Çizgi)", UDim2.new(0.06, 0, 0.45, 0), "Traces")
CreateToggle("Team Check", UDim2.new(0.06, 0, 0.65, 0), "TeamCheck")

--- ULTRA OPTİMİZE ESP & TRACES SİSTEMİ ---
local espCache = {} -- Objeleri hafızada tutarak kasmayı önleriz

local function GetPlayerTeam(player)
    -- Hem normal takımı hem de renk bazlı takımı kontrol eder
    if player.Team then return player.Team.Name end
    if player.TeamColor then return tostring(player.TeamColor) end
    return nil
end

local function IsTeammate(player)
    if not _G.SafeCheatConfig.TeamCheck then return false end
    
    local myTeam = GetPlayerTeam(LocalPlayer)
    local enemyTeam = GetPlayerTeam(player)

    -- İkisinin de takımı belli ise ve aynıysa takım arkadaşıdır
    if myTeam and enemyTeam and myTeam == enemyTeam then
        return true
    end
    
    -- Takımlar belli değilse (FFA veya lobi durumu) kimseyi takım sayma
    return false
end

-- Tek Bir Döngü (FPS Dostu)
RunService.RenderStepped:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- Oyuncu için ESP objeleri yoksa oluştur
            if not espCache[player] then
                espCache[player] = {
                    Highlight = Instance.new("Highlight"),
                    Line = Drawing.new("Line")
                }
                -- Highlight Ayarları
                espCache[player].Highlight.Name = "SafeESP"
                espCache[player].Highlight.FillColor = _G.SafeCheatConfig.BoxColor
                espCache[player].Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                espCache[player].Highlight.Parent = game.CoreGui
                
                -- Çizgi Ayarları
                espCache[player].Line.Thickness = 1.5
                espCache[player].Line.Color = _G.SafeCheatConfig.TraceColor
            end

            local objects = espCache[player]
            local character = player.Character
            
            -- Karakter hayattaysa ve ekrandaysa işlem yap
            if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local rootPos = character.HumanoidRootPart.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
                local teammate = IsTeammate(player)

                -- ESP Görünürlüğü
                if _G.SafeCheatConfig.ESP and not teammate then
                    objects.Highlight.Adornee = character
                    objects.Highlight.Enabled = true
                else
                    objects.Highlight.Enabled = false
                end

                -- Traces Görünürlüğü
                if _G.SafeCheatConfig.Traces and onScreen and not teammate then
                    objects.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Ekran alt orta
                    objects.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                    objects.Line.Visible = true
                else
                    objects.Line.Visible = false
                end
            else
                -- Karakter öldüyse veya yoksa gizle
                objects.Highlight.Enabled = false
                objects.Line.Visible = false
            end
        end
    end
end)

-- Oyuncu çıkarsa objelerini sil (Hafıza sızıntısını önler)
Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        espCache[player].Highlight:Destroy()
        espCache[player].Line:Remove()
        espCache[player] = nil
    end
end)

print("Safe Cheat V2.1: Defusal/FPS Optimize Sürüm Yüklendi!")
