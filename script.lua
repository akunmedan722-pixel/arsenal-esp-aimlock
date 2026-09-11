--[[
    ARSENAL AIM LOCK + ESP SCRIPT (MOBILE TOUCH UI)
    ====================================================
    Rayfield-style GUI dengan Touch Control
    Features:
    - GUI always-on dengan header di atas
    - Touch buttons (Mobile Optimized)
    - Aim Lock dengan target selection
    - ESP toggle
    - No keyboard required
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
local isExpanded = false

-- Colors (SkyZen Palette)
local Colors = {
    Primary = Color3.fromRGB(0, 170, 255),
    Secondary = Color3.fromRGB(80, 215, 255),
    Success = Color3.fromRGB(0, 255, 136),
    Error = Color3.fromRGB(255, 85, 105),
    Background = Color3.fromRGB(10, 15, 30),
    Card = Color3.fromRGB(15, 20, 40),
    Text = Color3.fromRGB(245, 248, 255),
    Muted = Color3.fromRGB(120, 140, 180),
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
    stroke.Transparency = 0.3
    stroke.Parent = object
end

-- ============================================
-- ESP FUNCTIONS
-- ============================================

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = Vector3.new(3, 5, 3)
    espBox.Color3 = Colors.Primary
    espBox.Transparency = 0.3
    espBox.AlwaysOnTop = true
    espBox.Parent = humanoidRootPart
    
    local espLabel = Instance.new("BillboardGui")
    espLabel.Size = UDim2.new(4, 0, 2, 0)
    espLabel.MaxDistance = Config.MaxDistance
    espLabel.Parent = humanoidRootPart
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1, 1)
    textLabel.BackgroundTransparency = 0.2
    textLabel.BackgroundColor3 = Colors.Background
    textLabel.Text = player.Name
    textLabel.TextColor3 = Colors.Success
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = espLabel
    round(textLabel, 6)
    addStroke(textLabel, Colors.Success, 1.5)
    
    ESPObjects[player] = {
        Box = espBox,
        Label = espLabel,
    }
end

local function removeESP(player)
    if ESPObjects[player] then
        pcall(function()
            ESPObjects[player].Box:Destroy()
            ESPObjects[player].Label:Destroy()
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
-- UI CREATION (TOUCH OPTIMIZED)
-- ============================================

local function createMainUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ArsenalGUI"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui
    
    -- Main Container (Mobile Size: 90% width)
    local container = Instance.new("Frame")
    container.Name = "MainContainer"
    container.Size = UDim2.new(0.9, 0, 0, 420)
    container.Position = UDim2.new(0.05, 0, 0, 50)
    container.BackgroundColor3 = Colors.Background
    container.BorderSizePixel = 0
    container.Parent = gui
    round(container, 15)
    addStroke(container, Colors.Primary, 2)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.08, 0)
    header.BackgroundColor3 = Colors.Card
    header.BorderSizePixel = 0
    header.Parent = container
    round(header, 15)
    
    local headerTitle = Instance.new("TextLabel")
    headerTitle.Size = UDim2.new(1, -50, 1, 0)
    headerTitle.Position = UDim2.fromOffset(15, 0)
    headerTitle.BackgroundTransparency = 1
    headerTitle.Text = "⚡ SKYZEN ARSENAL"
    headerTitle.TextColor3 = Colors.Primary
    headerTitle.TextSize = 14
    headerTitle.Font = Enum.Font.GothamBlack
    headerTitle.TextXAlignment = Enum.TextXAlignment.Left
    headerTitle.Parent = header
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.fromOffset(40, 30)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -15)
    closeBtn.BackgroundColor3 = Colors.Error
    closeBtn.BackgroundTransparency = 0.3
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Colors.Text
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = header
    round(closeBtn, 6)
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0.92, 0)
    content.Position = UDim2.fromScale(0, 0.08)
    content.BackgroundTransparency = 1
    content.Parent = container
    
    local scrolling = Instance.new("UIListLayout")
    scrolling.Padding = UDim.new(0, 12)
    scrolling.FillDirection = Enum.FillDirection.Vertical
    scrolling.SortOrder = Enum.SortOrder.LayoutOrder
    scrolling.Parent = content
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.PaddingTop = UDim.new(0, 12)
    padding.PaddingBottom = UDim.new(0, 12)
    padding.Parent = content
    
    -- ============================================
    -- AIM LOCK SECTION
    -- ============================================
    
    local aimSection = Instance.new("Frame")
    aimSection.Name = "AimSection"
    aimSection.Size = UDim2.new(1, 0, 0, 140)
    aimSection.BackgroundColor3 = Colors.Card
    aimSection.BorderSizePixel = 0
    aimSection.Parent = content
    aimSection.LayoutOrder = 1
    round(aimSection, 10)
    addStroke(aimSection, Colors.Primary, 1)
    
    local aimSectionPadding = Instance.new("UIPadding")
    aimSectionPadding.PaddingLeft = UDim.new(0, 12)
    aimSectionPadding.PaddingRight = UDim.new(0, 12)
    aimSectionPadding.PaddingTop = UDim.new(0, 10)
    aimSectionPadding.PaddingBottom = UDim.new(0, 10)
    aimSectionPadding.Parent = aimSection
    
    local aimTitle = Instance.new("TextLabel")
    aimTitle.Size = UDim2.new(1, 0, 0, 22)
    aimTitle.BackgroundTransparency = 1
    aimTitle.Text = "🎯 AIM LOCK"
    aimTitle.TextColor3 = Colors.Text
    aimTitle.TextSize = 13
    aimTitle.Font = Enum.Font.GothamBold
    aimTitle.TextXAlignment = Enum.TextXAlignment.Left
    aimTitle.Parent = aimSection
    
    local aimToggleBtn = Instance.new("TextButton")
    aimToggleBtn.Name = "AimToggle"
    aimToggleBtn.Size = UDim2.new(1, 0, 0, 40)
    aimToggleBtn.Position = UDim2.fromOffset(0, 28)
    aimToggleBtn.BackgroundColor3 = Colors.Error
    aimToggleBtn.BackgroundTransparency = 0.3
    aimToggleBtn.BorderSizePixel = 0
    aimToggleBtn.Text = "OFF"
    aimToggleBtn.TextColor3 = Colors.Text
    aimToggleBtn.TextSize = 14
    aimToggleBtn.Font = Enum.Font.GothamBold
    aimToggleBtn.Parent = aimSection
    round(aimToggleBtn, 6)
    addStroke(aimToggleBtn, Colors.Error, 1.5)
    
    local targetLabel = Instance.new("TextLabel")
    targetLabel.Size = UDim2.new(1, 0, 0, 18)
    targetLabel.Position = UDim2.fromOffset(0, 72)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "Target: Head"
    targetLabel.TextColor3 = Colors.Muted
    targetLabel.TextSize = 11
    targetLabel.Font = Enum.Font.GothamMedium
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.Parent = aimSection
    
    -- Target Buttons
    local targetContainer = Instance.new("Frame")
    targetContainer.Size = UDim2.new(1, 0, 0, 32)
    targetContainer.Position = UDim2.fromOffset(0, 95)
    targetContainer.BackgroundTransparency = 1
    targetContainer.Parent = aimSection
    
    local targetLayout = Instance.new("UIListLayout")
    targetLayout.FillDirection = Enum.FillDirection.Horizontal
    targetLayout.Padding = UDim.new(0, 6)
    targetLayout.Parent = targetContainer
    
    local targets = {"Head", "Torso", "RightHand"}
    local targetKeys = {"Head", "Torso", "RightHand"}
    
    for i, target in ipairs(targets) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.31, 0, 1, 0)
        btn.BackgroundColor3 = (i == 1) and Colors.Primary or Colors.Card
        btn.BackgroundTransparency = (i == 1) and 0.2 or 0.5
        btn.BorderSizePixel = 0
        btn.Text = target:sub(1, 1)
        btn.TextColor3 = Colors.Text
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.Parent = targetContainer
        round(btn, 4)
        addStroke(btn, Colors.Primary, 1)
        
        btn.MouseButton1Click:Connect(function()
            Config.TargetPart = targetKeys[i]
            targetLabel.Text = "Target: " .. target
            for _, child in ipairs(targetContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = (child == btn) and Colors.Primary or Colors.Card
                    child.BackgroundTransparency = (child == btn) and 0.2 or 0.5
                end
            end
        end)
    end
    
    -- ============================================
    -- ESP SECTION
    -- ============================================
    
    local espSection = Instance.new("Frame")
    espSection.Name = "ESPSection"
    espSection.Size = UDim2.new(1, 0, 0, 100)
    espSection.BackgroundColor3 = Colors.Card
    espSection.BorderSizePixel = 0
    espSection.Parent = content
    espSection.LayoutOrder = 2
    round(espSection, 10)
    addStroke(espSection, Colors.Secondary, 1)
    
    local espSectionPadding = Instance.new("UIPadding")
    espSectionPadding.PaddingLeft = UDim.new(0, 12)
    espSectionPadding.PaddingRight = UDim.new(0, 12)
    espSectionPadding.PaddingTop = UDim.new(0, 10)
    espSectionPadding.PaddingBottom = UDim.new(0, 10)
    espSectionPadding.Parent = espSection
    
    local espTitle = Instance.new("TextLabel")
    espTitle.Size = UDim2.new(1, 0, 0, 22)
    espTitle.BackgroundTransparency = 1
    espTitle.Text = "👁️ ESP"
    espTitle.TextColor3 = Colors.Text
    espTitle.TextSize = 13
    espTitle.Font = Enum.Font.GothamBold
    espTitle.TextXAlignment = Enum.TextXAlignment.Left
    espTitle.Parent = espSection
    
    local espToggleBtn = Instance.new("TextButton")
    espToggleBtn.Name = "ESPToggle"
    espToggleBtn.Size = UDim2.new(1, 0, 0, 50)
    espToggleBtn.Position = UDim2.fromOffset(0, 28)
    espToggleBtn.BackgroundColor3 = Colors.Success
    espToggleBtn.BackgroundTransparency = 0.2
    espToggleBtn.BorderSizePixel = 0
    espToggleBtn.Text = "ON"
    espToggleBtn.TextColor3 = Colors.Text
    espToggleBtn.TextSize = 14
    espToggleBtn.Font = Enum.Font.GothamBold
    espToggleBtn.Parent = espSection
    round(espToggleBtn, 6)
    addStroke(espToggleBtn, Colors.Success, 1.5)
    
    -- ============================================
    -- INFO SECTION
    -- ============================================
    
    local infoSection = Instance.new("Frame")
    infoSection.Name = "InfoSection"
    infoSection.Size = UDim2.new(1, 0, 0, 70)
    infoSection.BackgroundColor3 = Colors.Card
    infoSection.BackgroundTransparency = 0.5
    infoSection.BorderSizePixel = 0
    infoSection.Parent = content
    infoSection.LayoutOrder = 3
    round(infoSection, 10)
    
    local infoPadding = Instance.new("UIPadding")
    infoPadding.PaddingLeft = UDim.new(0, 12)
    infoPadding.PaddingRight = UDim.new(0, 12)
    infoPadding.PaddingTop = UDim.new(0, 10)
    infoPadding.PaddingBottom = UDim.new(0, 10)
    infoPadding.Parent = infoSection
    
    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, 0, 1, 0)
    infoText.BackgroundTransparency = 1
    infoText.Text = "📱 Touch Control:\nTap buttons untuk toggle fitur\nTap ✕ untuk close"
    infoText.TextColor3 = Colors.Muted
    infoText.TextSize = 10
    infoText.Font = Enum.Font.GothamMedium
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.Parent = infoSection
    
    -- ============================================
    -- BUTTON EVENTS
    -- ============================================
    
    aimToggleBtn.MouseButton1Click:Connect(function()
        Config.AimLockEnabled = not Config.AimLockEnabled
        if Config.AimLockEnabled then
            aimToggleBtn.Text = "ON"
            aimToggleBtn.BackgroundColor3 = Colors.Success
            aimToggleBtn.BackgroundTransparency = 0.2
        else
            aimToggleBtn.Text = "OFF"
            aimToggleBtn.BackgroundColor3 = Colors.Error
            aimToggleBtn.BackgroundTransparency = 0.3
        end
    end)
    
    espToggleBtn.MouseButton1Click:Connect(function()
        Config.ESPEnabled = not Config.ESPEnabled
        if Config.ESPEnabled then
            espToggleBtn.Text = "ON"
            espToggleBtn.BackgroundColor3 = Colors.Success
        else
            espToggleBtn.Text = "OFF"
            espToggleBtn.BackgroundColor3 = Colors.Error
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
    button.Size = UDim2.fromOffset(180, 45)
    button.Position = UDim2.new(0.5, -90, 0, 10)
    button.BackgroundColor3 = Colors.Primary
    button.BorderSizePixel = 0
    button.Text = "⚡ SKYZEN"
    button.TextColor3 = Colors.Text
    button.TextSize = 16
    button.Font = Enum.Font.GothamBlack
    button.Parent = gui
    round(button, 8)
    addStroke(button, Colors.Primary, 2)
    
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

print("✅ Arsenal Lite Loaded!")
print("📱 Mobile Touch Control Enabled")
print("UI Style: Rayfield (SkyZen)")
