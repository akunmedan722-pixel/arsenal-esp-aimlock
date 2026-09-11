--[[
    ARSENAL AIM LOCK + ESP SCRIPT (MOBILE OPTIMIZED - TOUCH ONLY)
    ==============================================================
    Pure touch-based interface for mobile
    Features:
    - Rayfield-style gray theme
    - 100% touch screen controls (NO KEYBOARD)
    - Resizable UI with drag/pinch
    - X-Ray ESP with player names above heads
    - Compact & lightweight
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuration
local Config = {
    AimLockEnabled = false,
    ESPEnabled = true,
    TargetPart = "Head",
    MaxDistance = 500,
    Smoothness = 0.1,
}

-- ESP Storage
local ESPObjects = {}
local LastESPUpdate = 0
local ESPUpdateInterval = 0.5

-- UI State
local MainGUI = nil
local HeaderButton = nil

-- Colors (Rayfield Gray Theme)
local Colors = {
    Background = Color3.fromRGB(30, 30, 30),
    Card = Color3.fromRGB(45, 45, 45),
    Header = Color3.fromRGB(25, 25, 25),
    Primary = Color3.fromRGB(100, 149, 237),
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 85, 105),
    Text = Color3.fromRGB(245, 248, 255),
    Muted = Color3.fromRGB(150, 150, 150),
    Border = Color3.fromRGB(60, 60, 60),
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function round(object, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = object
end

local function addStroke(object, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = thickness
    stroke.Transparency = 0.5
    stroke.Parent = object
end

-- ============================================
-- ESP FUNCTIONS (WITH XRAY)
-- ============================================

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    -- Box Adornment (X-Ray through walls)
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(3, 5, 3)
    espBox.Color3 = Colors.Primary
    espBox.Transparency = 0.2
    espBox.AlwaysOnTop = true
    espBox.Parent = humanoidRootPart
    
    -- Player name above head
    local headPart = character:FindFirstChild("Head")
    if headPart then
        local espLabel = Instance.new("BillboardGui")
        espLabel.Size = UDim2.new(4, 0, 1.5, 0)
        espLabel.MaxDistance = Config.MaxDistance
        espLabel.StudsOffset = Vector3.new(0, 3, 0)
        espLabel.Parent = headPart
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.fromScale(1, 1)
        textLabel.BackgroundTransparency = 0.2
        textLabel.BackgroundColor3 = Colors.Card
        textLabel.Text = player.Name
        textLabel.TextColor3 = Colors.Success
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamBold
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = espLabel
        round(textLabel, 6)
        addStroke(textLabel, Colors.Success, 1.5)
        
        ESPObjects[player] = {
            Box = espBox,
            Label = espLabel,
            NameLabel = textLabel,
        }
    else
        ESPObjects[player] = {
            Box = espBox,
            Label = nil,
        }
    end
end

local function removeESP(player)
    if ESPObjects[player] then
        pcall(function()
            ESPObjects[player].Box:Destroy()
            if ESPObjects[player].Label then
                ESPObjects[player].Label:Destroy()
            end
        end)
        ESPObjects[player] = nil
    end
end

local function updateESP()
    if not Config.ESPEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                if not ESPObjects[player] then
                    createESP(player)
                end
            else
                removeESP(player)
            end
        end
    end
end

local function clearAllESP()
    for player, _ in pairs(ESPObjects) do
        removeESP(player)
    end
end

-- ============================================
-- AIM LOCK FUNCTIONS
-- ============================================

local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = Config.MaxDistance
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            local targetPart = player.Character:FindFirstChild(Config.TargetPart)
            
            if humanoid and humanoid.Health > 0 and targetPart and LocalPlayer.Character then
                local distance = (targetPart.Position - LocalPlayer.Character.PrimaryPart.Position).Magnitude
                
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    
    return closestPlayer
end

local function aimLock()
    if not Config.AimLockEnabled or not LocalPlayer.Character then return end
    
    local target = getClosestPlayer()
    if target and target.Character then
        local targetPart = target.Character:FindFirstChild(Config.TargetPart)
        if targetPart then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, Config.Smoothness)
        end
    end
end

-- ============================================
-- UI CREATION (TOUCH ONLY)
-- ============================================

local function createMainUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ArsenalGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.fromOffset(320, 280)
    container.Position = UDim2.new(0.5, -160, 0, 45)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    round(container, 12)
    addStroke(container, Colors.Border, 1)
    
    -- Header (Draggable)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.12, 0)
    header.BackgroundColor3 = Colors.Header
    header.BorderSizePixel = 0
    header.Parent = container
    round(header, 12)
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -40, 1, 0)
    headerTitle.Position = UDim2.fromOffset(12, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "⚡ SKYZEN"
    headerTitle.TextColor3 = Colors.Primary
    headerTitle.TextSize = 14
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.fromOffset(25, 25)
    closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
    closeBtn.BackgroundColor3 = Colors.Error
    closeBtn.BackgroundTransparency = 0.4
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    round(closeBtn, 5)
    
    -- Draggable Header
    local dragging = false
    local dragStart = nil
    local containerPos = nil
    
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            containerPos = container.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            container.Position = UDim2.fromOffset(
                containerPos.X.Offset + delta.X,
                containerPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0.88, 0)
    content.Position = UDim2.fromScale(0, 0.12)
    content.BackgroundTransparency = 1
    content.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 10)
    padding.PaddingRight = UDim.new(0, 10)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingBottom = UDim.new(0, 8)
    padding.Parent = content
    
    -- ============================================
    -- AIM LOCK SECTION
    -- ============================================
    
    local aimSection = Instance.new("Frame")
    aimSection.Name = "AimSection"
    aimSection.Size = UDim2.new(1, 0, 0, 100)
    aimSection.BackgroundColor3 = Colors.Card
    aimSection.BorderSizePixel = 0
    aimSection.Parent = content
    round(aimSection, 8)
    addStroke(aimSection, Colors.Border, 1)
    
    local aimSectionPadding = Instance.new("UIPadding")
    aimSectionPadding.PaddingLeft = UDim.new(0, 10)
    aimSectionPadding.PaddingRight = UDim.new(0, 10)
    aimSectionPadding.PaddingTop = UDim.new(0, 8)
    aimSectionPadding.PaddingBottom = UDim.new(0, 8)
    aimSectionPadding.Parent = aimSection
    
    local aimTitle = Instance.new("TextLabel")
    aimTitle.Size = UDim2.new(1, 0, 0, 18)
    aimTitle.BackgroundTransparency = 1
    aimTitle.Text = "🎯 AIM LOCK"
    aimTitle.TextColor3 = Colors.Text
    aimTitle.TextSize = 11
    aimTitle.Font = Enum.Font.GothamBold
    aimTitle.TextXAlignment = Enum.TextXAlignment.Left
    aimTitle.Parent = aimSection
    
    local aimToggleBtn = Instance.new("TextButton")
    aimToggleBtn.Name = "AimToggle"
    aimToggleBtn.Size = UDim2.new(1, 0, 0, 28)
    aimToggleBtn.Position = UDim2.fromOffset(0, 22)
    aimToggleBtn.BackgroundColor3 = Colors.Error
    aimToggleBtn.BackgroundTransparency = 0.4
    aimToggleBtn.BorderSizePixel = 0
    aimToggleBtn.Text = "OFF"
    aimToggleBtn.TextColor3 = Colors.Text
    aimToggleBtn.TextSize = 11
    aimToggleBtn.Font = Enum.Font.GothamBold
    aimToggleBtn.Parent = aimSection
    round(aimToggleBtn, 5)
    addStroke(aimToggleBtn, Colors.Error, 1)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0, 16)
    targetLabel.Position = UDim2.fromOffset(0, 54)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target: Head"
    targetLabel.TextColor3 = Colors.Muted
    targetLabel.TextSize = 9
    targetLabel.Font = Enum.Font.GothamMedium
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = aimSection
    
    local targetContainer = Instance.new("Frame")
    targetContainer.Size = UDim2.new(1, 0, 0, 20)
    targetContainer.Position = UDim2.fromOffset(0, 73)
    targetContainer.BackgroundTransparency = 1
    targetContainer.Parent = aimSection
    
    local targetLayout = Instance.new("UIListLayout")
    targetLayout.FillDirection = Enum.FillDirection.Horizontal
    targetLayout.Padding = UDim.new(0, 4)
    targetLayout.Parent = targetContainer
    
    local targets = {"Head", "Torso", "Hand"}
    local targetKeys = {"Head", "Torso", "RightHand"}
    
    for i, target in ipairs(targets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.31, 0, 1, 0)
        btn.BackgroundColor3 = (i == 1) and Colors.Primary or Colors.Card
        btn.BackgroundTransparency = (i == 1) and 0.3 or 0.6
        btn.BorderSizePixel = 0
        btn.Text = target
        btn.TextColor3 = Colors.Text
        btn.TextSize = 8
        btn.Font = Enum.Font.GothamBold
        btn.Parent = targetContainer
        round(btn, 4)
        addStroke(btn, Colors.Border, 1)
        
        btn.MouseButton1Click:Connect(function()
            Config.TargetPart = targetKeys[i]
            targetLabel.Text = "Target: " .. target
            for _, child in ipairs(targetContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child == btn) and Colors.Primary or Colors.Card
                    child.BackgroundTransparency = (child == btn) and 0.3 or 0.6
                end
            end
        end)
    end
    
    -- ============================================
    -- ESP SECTION
    -- ============================================
    
    local espSection = Instance.new("Frame")
    espSection.Name = "ESPSection"
    espSection.Size = UDim2.new(1, 0, 0, 65)
    espSection.Position = UDim2.fromOffset(0, 105)
    espSection.BackgroundColor3 = Colors.Card
    espSection.BorderSizePixel = 0
    espSection.Parent = content
    round(espSection, 8)
    addStroke(espSection, Colors.Border, 1)
    
    local espSectionPadding = Instance.new("UIPadding")
    espSectionPadding.PaddingLeft = UDim.new(0, 10)
    espSectionPadding.PaddingRight = UDim.new(0, 10)
    espSectionPadding.PaddingTop = UDim.new(0, 8)
    espSectionPadding.PaddingBottom = UDim.new(0, 8)
    espSectionPadding.Parent = espSection
    
    local espTitle = Instance.new("TextLabel")
    espTitle.Size = UDim2.new(1, 0, 0, 18)
    espTitle.BackgroundTransparency = 1
    espTitle.Text = "👁️ ESP + X-RAY"
    espTitle.TextColor3 = Colors.Text
    espTitle.TextSize = 11
    espTitle.Font = Enum.Font.GothamBold
    espTitle.TextXAlignment = Enum.TextXAlignment.Left
    espTitle.Parent = espSection
    
    local espToggleBtn = Instance.new("TextButton")
    espToggleBtn.Name = "ESPToggle"
    espToggleBtn.Size = UDim2.new(1, 0, 0, 35)
    espToggleBtn.Position = UDim2.fromOffset(0, 22)
    espToggleBtn.BackgroundColor3 = Colors.Success
    espToggleBtn.BackgroundTransparency = 0.3
    espToggleBtn.BorderSizePixel = 0
    espToggleBtn.Text = "ON"
    espToggleBtn.TextColor3 = Colors.Text
    espToggleBtn.TextSize = 11
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.Parent = espSection
    round(espToggleBtn, 5)
    addStroke(espToggleBtn, Colors.Success, 1)
    
    -- ============================================
    -- RESIZE HANDLE
    -- ============================================
    
    local resizeHandle = Instance.new("Frame")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.fromOffset(30, 30)
    resizeHandle.Position = UDim2.new(1, -30, 1, -30)
    resizeHandle.BackgroundColor3 = Colors.Primary
    resizeHandle.BackgroundTransparency = 0.3
    resizeHandle.BorderSizePixel = 0
    resizeHandle.Parent = container
    round(resizeHandle, 5)
    
    local resizeIcon = Instance.new("TextLabel")
    resizeIcon.Size = UDim2.fromScale(1, 1)
    resizeIcon.BackgroundTransparency = 1
    resizeIcon.Text = "⧣"
    resizeIcon.TextColor3 = Colors.Primary
    resizeIcon.TextSize = 16
    resizeIcon.Font = Enum.Font.GothamBold
    resizeIcon.Parent = resizeHandle
    
    local resizing = false
    local resizeStartPos = nil
    local resizeStartSize = nil
    
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStartPos = input.Position
            resizeStartSize = container.Size
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - resizeStartPos
            local newWidth = math.max(250, math.min(450, resizeStartSize.X.Offset + delta.X))
            local newHeight = math.max(200, math.min(600, resizeStartSize.Y.Offset + delta.Y))
            container.Size = UDim2.fromOffset(newWidth, newHeight)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
    
    -- ============================================
    -- BUTTON EVENTS
    -- ============================================
    
    aimToggleBtn.MouseButton1Click:Connect(function()
        Config.AimLockEnabled = not Config.AimLockEnabled
        if Config.AimLockEnabled then
            aimToggleBtn.Text = "ON"
            aimToggleBtn.BackgroundColor3 = Colors.Success
            aimToggleBtn.BackgroundTransparency = 0.3
        else
            aimToggleBtn.Text = "OFF"
            aimToggleBtn.BackgroundColor3 = Colors.Error
            aimToggleBtn.BackgroundTransparency = 0.4
        end
    end)
    
    espToggleBtn.MouseButton1Click:Connect(function()
        Config.ESPEnabled = not Config.ESPEnabled
        if Config.ESPEnabled then
            espToggleBtn.Text = "ON"
            espToggleBtn.BackgroundColor3 = Colors.Success
            espToggleBtn.BackgroundTransparency = 0.3
        else
            espToggleBtn.Text = "OFF"
            espToggleBtn.BackgroundColor3 = Colors.Error
            espToggleBtn.BackgroundTransparency = 0.4
            clearAllESP()
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        container.Visible = false
        HeaderButton.Visible = true
    end)
    
    return gui, container
end

local function createHeaderButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "HeaderButtonGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    local button = Instance.new("TextButton")
    button.Name = "HeaderButton"
    button.Size = UDim2.fromOffset(120, 32)
    button.Position = UDim2.new(0.5, -60, 0, 12)
    button.BackgroundColor3 = Colors.Primary
    button.BackgroundTransparency = 0.2
    button.BorderSizePixel = 0
    button.Text = "⚡ SKYZEN"
    button.TextColor3 = Colors.Text
    button.TextSize = 12
    button.Font = Enum.Font.GothamBlack
    button.Parent = gui
    round(button, 8)
    addStroke(button, Colors.Primary, 1)
    
    button.MouseButton1Click:Connect(function()
        if MainGUI then
            MainGUI.MainContainer.Visible = true
            button.Visible = false
        end
    end)
    
    return button
end

-- ============================================
-- MAIN INITIALIZATION
-- ============================================

if not LocalPlayer.Character then
    LocalPlayer.CharacterAdded:Wait()
end

-- Create UI
local gui, mainContainer = createMainUI()
MainGUI = gui
HeaderButton = createHeaderButton()

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    if currentTime - LastESPUpdate >= ESPUpdateInterval then
        updateESP()
        LastESPUpdate = currentTime
    end
end)

-- Aim Lock Loop
RunService.RenderStepped:Connect(function()
    aimLock()
end)

-- Player Events
Players.PlayerAdded:Connect(function(player)
    task.wait(0.2)
    if Config.ESPEnabled then
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

print("✅ Arsenal Elite Loaded!")
print("📱 Touch-Only Mobile Interface")
print("🎯 Tap buttons to toggle • Drag header to move • Resize from corner")
