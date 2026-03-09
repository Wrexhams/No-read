--[[
    Hide & Seek Premium Hub (Luna Edition)
    Основа: Luna Interface Suite
    Функции: Ragdoll, AntiFling, Collect Credits, ESP IT/SEEK, TeleKill, Speed/Jump
]]

-- Загрузка Luna
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/master/source.lua", true))()

-- Создание окна (ключ 1234, как в примере)
local Window = Luna:CreateWindow({
    Name = "Hide & Seek Premium",
    Subtitle = "by Kustlly",
    LogoID = "82795327169782",
    LoadingEnabled = true,
    LoadingTitle = "Hide & Seek Hub",
    LoadingSubtitle = "loading...",
    ConfigSettings = {
        ConfigFolder = "HideSeekHub"
    },
    KeySystem = true,
    KeySettings = {
        Title = "Hub Key",
        Subtitle = "Enter key",
        Note = "Проверка на премиум игрока",
        SaveKey = true,
        Key = {"14789234"},
        SecondAction = {
            Enabled = false
        }
    }
})

-- Домашняя вкладка (информация)
Window:CreateHomeTab({
    SupportedExecutors = {
        "Synapse X", "Krnl", "Fluxus", "Delta", "Arceus X", "Script-Ware", "Xeno"
    },
    DiscordInvite = "n/a",
    Icon = 1
})

-- Основная вкладка для функций
local Tab = Window:CreateTab({
    Name = "Hide & Seek",
    Icon = "visibility",
    ImageSource = "Material",
    ShowTitle = true
})

-- Небольшое приветствие
Luna:Notification({
    Title = "Hide & Seek Hub",
    Icon = "info",
    ImageSource = "Material",
    Content = "Premium functions loaded!"
})

-- ========== СЕРВИСЫ И ПЕРЕМЕННЫЕ ==========
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
end)

-- Переменные для ESP
local ESP_IT_ENABLED = false
local ESP_SEEK_ENABLED = false
local ESP_IT_FOLDER = Instance.new("Folder")
ESP_IT_FOLDER.Name = "ESP_IT"
ESP_IT_FOLDER.Parent = workspace.CurrentCamera
local ESP_SEEK_FOLDER = Instance.new("Folder")
ESP_SEEK_FOLDER.Name = "ESP_SEEK"
ESP_SEEK_FOLDER.Parent = workspace.CurrentCamera

-- Переменные для Speed/Jump
local currentSpeed = 100
local currentJump = 150
local speedEnabled = false
local jumpEnabled = false

-- ========== ФУНКЦИИ ==========

-- Ragdoll
local function toggleRagdoll(state)
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if state then
        hum:ChangeState(Enum.HumanoidStateType.FallingDown)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, true)
    else
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- AntiFling
local antiFlingEnabled = false
local antiFlingConnection = nil
local function toggleAntiFling(state)
    antiFlingEnabled = state
    if state and not antiFlingConnection then
        antiFlingConnection = RunService.Heartbeat:Connect(function()
            if not antiFlingEnabled or not hrp then return end
            local vel = hrp.Velocity
            local horiz = vel.X*vel.X + vel.Z*vel.Z
            if horiz > (humanoid.WalkSpeed*1.3)^2 then
                hrp.Velocity = Vector3.new(0, vel.Y, 0)
                hrp.RotVelocity = Vector3.new()
            end
        end)
    elseif not state and antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
end

-- Collect Credits
local function collectCredits()
    for _, obj in workspace:FindFirstChild("GameObjects"):GetDescendants() do
        if obj.Name == "Credit" or obj:FindFirstChild("TouchInterest") then
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if part then
                firetouchinterest(hrp, part, 0)
                task.wait()
                firetouchinterest(hrp, part, 1)
            end
        end
    end
end

-- ESP IT
local function updateESPIT()
    if not ESP_IT_ENABLED then
        ESP_IT_FOLDER:ClearAllChildren()
        return
    end
    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local isIt = false
            pcall(function() isIt = plr.PlayerData.It.Value end)
            if isIt then
                -- Box
                local box = Instance.new("BoxHandleAdornment")
                box.Size = root.Size + Vector3.new(0.5,0.5,0.5)
                box.Color3 = Color3.fromRGB(255,0,0)
                box.Transparency = 0.6
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Adornee = root
                box.Parent = ESP_IT_FOLDER
                -- Tag
                if head then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0,100,0,30)
                    bill.AlwaysOnTop = true
                    bill.Adornee = head
                    bill.Parent = ESP_IT_FOLDER
                    local label = Instance.new("TextLabel", bill)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.DisplayName.." [IT]"
                    label.TextColor3 = Color3.fromRGB(255,0,0)
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 16
                end
            end
        end
    end
end

-- ESP SEEK
local function updateESPSeek()
    if not ESP_SEEK_ENABLED then
        ESP_SEEK_FOLDER:ClearAllChildren()
        return
    end
    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local isIt = false
            pcall(function() isIt = plr.PlayerData.It.Value end)
            if not isIt then
                local box = Instance.new("BoxHandleAdornment")
                box.Size = root.Size + Vector3.new(0.5,0.5,0.5)
                box.Color3 = Color3.fromRGB(0,255,0)
                box.Transparency = 0.6
                box.AlwaysOnTop = true
                box.ZIndex = 10
                box.Adornee = root
                box.Parent = ESP_SEEK_FOLDER
                if head then
                    local bill = Instance.new("BillboardGui")
                    bill.Size = UDim2.new(0,100,0,30)
                    bill.AlwaysOnTop = true
                    bill.Adornee = head
                    bill.Parent = ESP_SEEK_FOLDER
                    local label = Instance.new("TextLabel", bill)
                    label.Size = UDim2.new(1,0,1,0)
                    label.BackgroundTransparency = 1
                    label.Text = plr.DisplayName.." [SEEK]"
                    label.TextColor3 = Color3.fromRGB(0,255,0)
                    label.TextStrokeTransparency = 0
                    label.TextStrokeColor3 = Color3.new(0,0,0)
                    label.Font = Enum.Font.GothamBold
                    label.TextSize = 16
                end
            end
        end
    end
end

-- Запуск обновления ESP
RunService.RenderStepped:Connect(function()
    updateESPIT()
    updateESPSeek()
end)

-- TeleKill
local function teleKill()
    for _, plr in Players:GetPlayers() do
        if plr ~= player and plr.Character and plr.PlayerData and plr.PlayerData.InGame and plr.PlayerData.InGame.Value then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                hrp.CFrame = root.CFrame + Vector3.new(0,3,0)
                task.wait(0.1)
            end
        end
    end
end

-- Speed
local function toggleSpeed(state)
    speedEnabled = state
    if humanoid then
        humanoid.WalkSpeed = state and currentSpeed or 16
    end
end

-- Jump
local function toggleJump(state)
    jumpEnabled = state
    if humanoid then
        humanoid.JumpPower = state and currentJump or 50
    end
end

-- ========== СОЗДАНИЕ ЭЛЕМЕНТОВ ВКЛАДКИ ==========

-- Раздел "Основное"
Tab:CreateSection("Основные функции")

-- Ragdoll Toggle
Tab:CreateToggle({
    Name = "Ragdoll",
    CurrentValue = false,
    Callback = toggleRagdoll
}, "Ragdoll")

-- AntiFling Toggle
Tab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Callback = toggleAntiFling
}, "AntiFling")

-- Collect Credits Button
Tab:CreateButton({
    Name = "Collect All Credits",
    Callback = collectCredits
})

-- Раздел "ESP"
Tab:CreateSection("ESP (подсветка)")

-- ESP IT Toggle
Tab:CreateToggle({
    Name = "ESP IT (красный)",
    CurrentValue = false,
    Callback = function(v) ESP_IT_ENABLED = v end
}, "ESP_IT")

-- ESP SEEK Toggle
Tab:CreateToggle({
    Name = "ESP SEEK (зелёный)",
    CurrentValue = false,
    Callback = function(v) ESP_SEEK_ENABLED = v end
}, "ESP_SEEK")

-- TeleKill Button
Tab:CreateButton({
    Name = "TeleKill (Только IT)",
    Callback = teleKill
})

-- Раздел "Скорость и прыжок"
Tab:CreateSection("Передвижение")

-- Speed Toggle
Tab:CreateToggle({
    Name = "Speed",
    CurrentValue = false,
    Callback = toggleSpeed
}, "SpeedToggle")

-- Speed Slider
Tab:CreateSlider({
    Name = "Speed Value",
    Range = {16, 250},
    Increment = 1,
    CurrentValue = currentSpeed,
    Callback = function(v)
        currentSpeed = v
        if speedEnabled and humanoid then
            humanoid.WalkSpeed = v
        end
    end
}, "SpeedSlider")

-- Jump Toggle
Tab:CreateToggle({
    Name = "Jump",
    CurrentValue = false,
    Callback = toggleJump
}, "JumpToggle")

-- Jump Slider
Tab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 500},
    Increment = 1,
    CurrentValue = currentJump,
    Callback = function(v)
        currentJump = v
        if jumpEnabled and humanoid then
            humanoid.JumpPower = v
        end
    end
}, "JumpSlider")

-- Раздел "Прочее"
Tab:CreateSection("Дополнительно")

-- Можно добавить кнопку перезагрузки персонажа или информацию
Tab:CreateParagraph({
    Title = "Информация",
    Text = "ESP обновляется автоматически.\nAnti-Fling защищает от сброса читеров."
})

print("Hide & Seek Premium Hub (Luna Edition) loaded!")
