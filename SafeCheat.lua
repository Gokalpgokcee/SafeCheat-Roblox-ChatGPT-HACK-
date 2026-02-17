    local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- AYARLAR
_G.SafeCheatConfig = {
    ESP = false,
    Traces = false,
    RGB_Mode = false,
    NoRecoil = false,
    BoxColor = Color3.fromRGB(0, 255, 255),
    TraceColor = Color3.fromRGB(255, 255, 255)
}

-- [MODERN GUI TASARIMI]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 340, 0, 380)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Neon Kenarlık
local UIStroke = Instance.new("UIStroke", MainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 255)

-- RGB Menü Kenarlığı Döngüsü
RunService.RenderStepped:Connect(function()
    if _G.SafeCheatConfig.RGB_Mode then
        local hue = tick() % 5 / 5
        UIStroke.Color = Color3.fromHSV(hue, 1, 1)
    else
        UIStroke.Color = Color3.fromRGB(0, 255, 255)
    end
end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "SAFE CHEAT V3.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.BackgroundTransparency = 1

-- AÇMA KAPAMA BUTONU
local ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 15, 0.5, 0)
ToggleBtn.Text = "SC"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
ToggleBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function CreateButton(name, pos, configName)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, 280, 0, 45)
    btn.Position = pos
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", btn)
    
    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = Color3.fromRGB(40, 40, 40)

    btn.MouseButton1Click:Connect(function()
        _G.SafeCheatConfig[configName] = not _G.SafeCheatConfig[configName]
        btn.TextColor3 = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(200, 200, 200)
        stroke.Color = _G.SafeCheatConfig[configName] and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(40, 40, 40)
    end)
end

CreateButton("ESP (Visuals)", UDim2.new(0.09, 0, 0.2, 0), "ESP")
CreateButton("Traces (Lines)", UDim2.new(0.09, 0, 0.35, 0), "Traces")
CreateButton("RGB Mode (Gökkuşağı)", UDim2.new(0.09, 0, 0.5, 0), "RGB_Mode")
CreateButton("No Recoil (Pro)", UDim2.new(0.09, 0, 0.65, 0), "NoRecoil")

--- [GELİŞMİŞ GÖRSEL VE RECOIL SİSTEMİ] ---
local espCache = {}

local function CreateESP(p)
    local h = Instance.new("Highlight", game.CoreGui)
    h.Enabled = false
    local l = Drawing.new("Line")
    l.Visible = false
    espCache[p] = {Highlight = h, Line = l}
end

Players.PlayerAdded:Connect(CreateESP)
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end

RunService.RenderStepped:Connect(function()
    local hue = tick() % 5 / 5
    local color = Color3.fromHSV(hue, 1, 1)

    for p, obj in pairs(espCache) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local root = p.Character.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            -- ESP Güncelleme
            if _G.SafeCheatConfig.ESP then
                obj.Highlight.Adornee = p.Character
                obj.Highlight.Enabled = true
                obj.Highlight.FillColor = _G.SafeCheatConfig.RGB_Mode and color or _G.SafeCheatConfig.BoxColor
            else
                obj.Highlight.Enabled = false
            end

            -- Traces Güncelleme
            if _G.SafeCheatConfig.Traces and onScreen then
                obj.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                obj.Line.To = Vector2.new(pos.X, pos.Y)
                obj.Line.Color = _G.SafeCheatConfig.RGB_Mode and color or _G.SafeCheatConfig.TraceColor
                obj.Line.Visible = true
            else
                obj.Line.Visible = false
            end
        else
            obj.Highlight.Enabled = false
            obj.Line.Visible = false
        end
    end

    -- [PRO NO RECOIL]
    if _G.SafeCheatConfig.NoRecoil then
        -- Silah ateşlendiğinde kameranın sarsılmasını anlık olarak nötralize eder
        local oldCFrame = Camera.CFrame
        RunService.RenderStepped:Wait()
        if _G.SafeCheatConfig.NoRecoil then
            -- Kamerayı bir önceki pozisyona hafifçe zorlayarak sekme etkisini azaltır
            Camera.CFrame = Camera.CFrame:Lerp(oldCFrame, 0.1) 
        end
    end
end)

print("Safe Cheat V3.0: RGB & No Recoil Sürümü Aktif!")
