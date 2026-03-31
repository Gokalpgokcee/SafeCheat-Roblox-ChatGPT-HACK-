local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G Premium | Mobile Edition",
   LoadingTitle = "Gokalp Script Executing...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "GG_Configs",
      FileName = "MainConfig"
   }
})

-- Variables
local IsEspEnabled = false
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ESP Fonksiyonu (Performans için Box Drawing)
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 0, 0)
    Box.Thickness = 1
    Box.Filled = false

    local function Update()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if IsEspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
                local RootPart = Player.Character.HumanoidRootPart
                local Position, OnScreen = game.Workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position)
                
                if OnScreen then
                    local Size = (game.Workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position - Vector3.new(0, 3, 0)).Y - game.Workspace.CurrentCamera:WorldToViewportPoint(RootPart.Position + Vector3.new(0, 2.6, 0)).Y)
                    Box.Size = Vector2.new(Size * 0.6, Size)
                    Box.Position = Vector2.new(Position.X - Box.Size.X / 2, Position.Y - Box.Size.Y / 2)
                    Box.Visible = true
                else
                    Box.Visible = false
                end
            else
                Box.Visible = false
                if not Player.Parent then
                    Box:Remove()
                    Connection:Disconnect()
                end
            end
        end)
    end
    coroutine.wrap(Update)()
end

-- Mevcut oyuncular için ESP hazırla
for _, player in pairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)

-- GUI Tabları
local MainTab = Window:CreateTab("Görsel (ESP)", 4483362458)

MainTab:CreateSection("Oyuncu ESP")

MainTab:CreateToggle({
   Name = "Box ESP Aktif",
   CurrentValue = false,
   Flag = "EspToggle",
   Callback = function(Value)
      IsEspEnabled = Value
   end,
})

MainTab:CreateColorPicker({
    Name = "ESP Rengi",
    Color = Color3.fromRGB(255, 0, 0),
    Flag = "EspColor",
    Callback = function(Value)
        -- ESP rengini dinamik değiştirebilirsin
    end
})

Rayfield:Notify({
   Title = "Sistem Hazır",
   Content = "ESP ve Arayüz başarıyla yüklendi.",
   Duration = 5,
   Image = 4483362458,
})
