local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "G&G Premium V3 | Final Edition",
   LoadingTitle = "Gokalp SafeCheat Yükleniyor...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false }
})

-- AYARLAR
local Settings = {
    -- ESP
    EspEnabled = false,
    BoxColor = Color3.fromRGB(0, 255, 0),
    Names = false,
    Distances = false,
    Health = false,
    -- AIMBOT
    AimbotEnabled = false,
    TeamCheck = false,
    AimPart = "HumanoidRootPart",
    Sensitivity = 0.1, -- 0 ile 1 arası, düşük olan daha yumuşak (smooth) kitlenir
    FovRadius = 100,
    ShowFov = false
}

local Players = game:GetService("Players")
local RS = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- FOV Çemberi
local FovCircle = Drawing.new("Circle")
FovCircle.Thickness = 1
FovCircle.Color = Color3.fromRGB(255, 255, 255)
FovCircle.Filled = false
FovCircle.Visible = false

-- ESP SİSTEMİ
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    local Name = Drawing.new("Text")
    
    local Connection
    Connection = RS.RenderStepped:Connect(function()
        if Settings.EspEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") and Player ~= LocalPlayer then
            local Root = Player.Character.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)

            if OnScreen then
                local SizeY = (Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0)).Y - Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 2.6, 0)).Y)
                local SizeX = SizeY * 0.6

                Box.Visible = true
                Box.Color = Settings.BoxColor
                Box.Size = Vector2.new(SizeX, SizeY)
                Box.Position = Vector2.new(Pos.X - SizeX / 2, Pos.Y - SizeY / 2)
                Box.Thickness = 1

                if Settings.Names then
                    Name.Visible = true
                    Name.Text = Player.Name
                    Name.Position = Vector2.new(Pos.X, Pos.Y - (SizeY / 2) - 15)
                    Name.Center = true
                    Name.Outline = true
                    Name.Size = 14
                else Name.Visible = false end
            else
                Box.Visible = false
                Name.Visible = false
            end
        else
            Box.Visible = false
            Name.Visible = false
            if not Player.Parent then
                Box:Remove(); Name:Remove()
                Connection:Disconnect()
            end
        end
    end)
end

-- AIMBOT SİSTEMİ (En Yakın Oyuncuyu Bulma)
local function GetClosestPlayer()
    local Closest = nil
    local MaxDist = Settings.FovRadius

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Settings.AimPart) then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character[Settings.AimPart].Position)
            local Dist = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
            
            if Dist < MaxDist and OnScreen then
                Closest = v
                MaxDist =
            
