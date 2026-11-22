--[[
    BLACK DRAGON HUB
    Standalone Roblox client script
    Dark Red / Black - Compact Mobile UI
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SETTINGS
local Settings = {
    WalkSpeed = 16,
    JumpPower = 50,
    FPSCap = 60,
    ESP = false,
    Noclip = false,
    AntiVoid = false,
    AntiAFK = false,
    InfiniteJump = false,
    FPSBoost = false
}

local DefaultSettings = {
    WalkSpeed = 16,
    JumpPower = 50,
    FPSCap = 60,
    ESP = false,
    Noclip = false,
    AntiVoid = false,
    AntiAFK = false,
    InfiniteJump = false,
    FPSBoost = false
}

local Controls = {}
local ConfigFolder = "BlackDragonHub"
local ConfigFile = ConfigFolder .. "/config.json"

local Connections = {}
local ESPObjects = {}
local CurrentPage = "Main"

-- COLORS
local BG = Color3.fromRGB(13, 13, 16)
local PANEL = Color3.fromRGB(23, 23, 28)
local RED = Color3.fromRGB(210, 30, 45)
local WHITE = Color3.fromRGB(245, 245, 245)
local GRAY = Color3.fromRGB(145, 145, 155)

-- CLEAN OLD GUI
pcall(function()
    local old = game.CoreGui:FindFirstChild("BlackDragonHub")
    if old then old:Destroy() end
end)

-- GUI PARENT
local GUIParent = game:GetService("CoreGui")
pcall(function()
    if gethui then
        GUIParent = gethui()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BlackDragonHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GUIParent

-- HELPERS
local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = object
    return c
end

local function stroke(object, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or RED
    s.Thickness = thickness or 1
    s.Parent = object
    return s
end

local function makeLabel(parent, text, size, position, textSize)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = size
    label.Position = position
    label.Text = text
    label.TextColor3 = WHITE
    label.TextSize = textSize or 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function notify(title, message)
    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(0, 220, 0, 58)
    toast.Position = UDim2.new(1, -235, 0, 75)
    toast.BackgroundColor3 = PANEL
    toast.BorderSizePixel = 0
    toast.Parent = ScreenGui
    corner(toast, 8)
    stroke(toast, RED)

    local titleLabel = makeLabel(
        toast, title, UDim2.new(1, -15, 0, 23),
        UDim2.new(0, 10, 0, 5), 13
    )
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = RED

    makeLabel(
        toast, message, UDim2.new(1, -15, 0, 22),
        UDim2.new(0, 10, 0, 29), 11
    )

    task.delay(2.5, function()
        if toast then toast:Destroy() end
    end)
end

local function getHumanoid()
    local character = Player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local character = Player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end


-- BLACK DRAGON ULTIMATE UI
local TweenService = game:GetService("TweenService")

local ACCENT = Color3.fromRGB(235, 35, 55)
local DARK = Color3.fromRGB(9, 9, 12)
local PANEL = Color3.fromRGB(19, 19, 25)
local PANEL2 = Color3.fromRGB(27, 27, 35)
local MUTED = Color3.fromRGB(145, 145, 155)

-- FLOATING LOGO
local Logo = Instance.new("TextButton")
Logo.Name = "BDButton"
Logo.Size = UDim2.fromOffset(50, 50)
Logo.Position = UDim2.new(0, 15, 0.42, 0)
Logo.BackgroundColor3 = DARK
Logo.Text = "BD"
Logo.TextColor3 = ACCENT
Logo.TextSize = 19
Logo.Font = Enum.Font.GothamBlack
Logo.Parent = ScreenGui
corner(Logo, 15)
stroke(Logo, ACCENT, 2)

-- MAIN WINDOW
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(360, 420)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = DARK
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = ScreenGui
corner(Main, 14)
stroke(Main, ACCENT, 1.5)

-- BLACK DRAGON RGB LIGHTING
local RGBStroke = Instance.new("UIStroke")
RGBStroke.Name = "RGBBorder"
RGBStroke.Thickness = 3
RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
RGBStroke.Parent = Main

local RGBGlow = Instance.new("UIStroke")
RGBGlow.Name = "RGBGlow"
RGBGlow.Thickness = 7
RGBGlow.Transparency = 0.35
RGBGlow.Parent = Main

local RGBGradient = Instance.new("UIGradient")
RGBGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 170, 0)),
    ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(170, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
RGBGradient.Parent = RGBStroke

local GlowGradient = RGBGradient:Clone()
GlowGradient.Parent = RGBGlow

task.spawn(function()
    while ScreenGui.Parent do
        local rotation = (os.clock() * 65) % 360

        RGBGradient.Rotation = rotation
        GlowGradient.Rotation = rotation

        task.wait(0.03)
    end
end)

local MainScale = Instance.new("UIScale")
MainScale.Scale = 1
MainScale.Parent = Main

-- HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Main

local HeaderAccent = Instance.new("Frame")
HeaderAccent.Size = UDim2.new(1, 0, 0, 2)
HeaderAccent.Position = UDim2.new(0, 0, 1, -2)
HeaderAccent.BackgroundColor3 = ACCENT
HeaderAccent.BorderSizePixel = 0
HeaderAccent.Parent = Header

local HeaderTitle = makeLabel(
    Header,
    "BLACK DRAGON",
    UDim2.new(1, -100, 0, 25),
    UDim2.new(0, 15, 0, 8),
    17
)
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextColor3 = WHITE

local Subtitle = makeLabel(
    Header,
    "ULTIMATE EDITION  •  MOBILE",
    UDim2.new(1, -100, 0, 17),
    UDim2.new(0, 16, 0, 34),
    9
)
Subtitle.TextColor3 = ACCENT
Subtitle.Font = Enum.Font.GothamBold

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(34, 32)
Close.Position = UDim2.new(1, -45, 0, 14)
Close.BackgroundColor3 = Color3.fromRGB(65, 19, 27)
Close.Text = "×"
Close.TextColor3 = WHITE
Close.TextSize = 22
Close.Font = Enum.Font.GothamBold
Close.Parent = Header
corner(Close, 8)

Close.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

Logo.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- DRAGGING
local function makeDraggable(object, handle)
    local dragging = false
    local dragStart
    local startPosition

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = object.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            object.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

makeDraggable(Main, Header)
makeDraggable(Logo, Logo)

-- NAVIGATION

-- LEFT SIDE NAVIGATION
local Nav = Instance.new("Frame")
Nav.Size = UDim2.new(0, 82, 1, -82)
Nav.Position = UDim2.new(0, 10, 0, 72)
Nav.BackgroundColor3 = PANEL
Nav.Parent = Main
corner(Nav, 9)

local NavLayout = Instance.new("UIListLayout")
NavLayout.FillDirection = Enum.FillDirection.Vertical
NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
NavLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NavLayout.Padding = UDim.new(0, 9)
NavLayout.Parent = Nav

local NavPadding = Instance.new("UIPadding")
NavPadding.PaddingTop = UDim.new(0, 10)
NavPadding.Parent = Nav

-- CONTENT AREA
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -112, 1, -82)
Content.Position = UDim2.new(0, 102, 0, 72)
Content.BackgroundColor3 = DARK
Content.BorderSizePixel = 0
Content.Parent = Main

local Pages = {}
local NavButtons = {}

for _, pageName in ipairs({
    "Main", "Teleport", "Player", "Misc"
}) do

    local page = Instance.new("ScrollingFrame")
    page.Name = pageName .. "Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = pageName == "Main"
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 9)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    Pages[pageName] = page

    local tab = Instance.new("TextButton")
    tab.Name = pageName .. "Tab"
    tab.Size = UDim2.new(1, -12, 0, 48)
    tab.BackgroundColor3 = pageName == "Main"
        and Color3.fromRGB(70, 18, 28)
        or PANEL2
    tab.Text = pageName
    tab.TextColor3 = pageName == "Main" and ACCENT or MUTED
    tab.TextSize = 10
    tab.Font = Enum.Font.GothamBold
    tab.TextWrapped = true
    tab.Parent = Nav
    corner(tab, 8)

    NavButtons[pageName] = tab

    tab.MouseButton1Click:Connect(function()
        for name, otherPage in pairs(Pages) do
            otherPage.Visible = name == pageName

            local selected = name == pageName
            local button = NavButtons[name]

            TweenService:Create(
                button,
                TweenInfo.new(0.2),
                {
                    BackgroundColor3 = selected
                        and Color3.fromRGB(70, 18, 28)
                        or PANEL2
                }
            ):Play()

            button.TextColor3 = selected and ACCENT or MUTED
        end
    end)
end

-- SECTION LABEL

local function section(parent, title)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 30)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 17)
    line.Position = UDim2.new(0, 2, 0.5, -8)
    line.BackgroundColor3 = ACCENT
    line.BorderSizePixel = 0
    line.Parent = holder
    corner(line, 4)

    local label = makeLabel(
        holder,
        string.upper(title),
        UDim2.new(1, -15, 1, 0),
        UDim2.new(0, 12, 0, 0),
        11
    )

    label.Font = Enum.Font.GothamBlack
    label.TextColor3 = ACCENT

    return holder
end

-- BUTTON
local function createButton(parent, title, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 36)
    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0
    button.Text = title
    button.TextColor3 = WHITE
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.Parent = parent
    corner(button, 7)
    stroke(button, Color3.fromRGB(55, 35, 40))

    button.MouseButton1Click:Connect(function()
        callback()
    end)

    return button
end

-- TOGGLE
local function createToggle(parent, title, defaultValue, callback, settingKey)
    local state = defaultValue

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, 36)
    button.BackgroundColor3 = PANEL
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = parent
    corner(button, 7)

    makeLabel(
        button, title, UDim2.new(0.72, 0, 1, 0),
        UDim2.new(0, 10, 0, 0), 12
    )

    local indicator = Instance.new("TextLabel")
    indicator.Size = UDim2.new(0, 48, 0, 23)
    indicator.Position = UDim2.new(1, -56, 0.5, -11)
    indicator.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    indicator.Text = "OFF"
    indicator.TextColor3 = WHITE
    indicator.TextSize = 10
    indicator.Font = Enum.Font.GothamBold
    indicator.Parent = button
    corner(indicator, 6)

    local function update()
        indicator.Text = state and "ON" or "OFF"
        indicator.BackgroundColor3 = state and RED
            or Color3.fromRGB(65, 65, 65)

        callback(state)
    end

    local function setState(value)
        state = value
        update()
    end

    if settingKey then
        Controls[settingKey] = setState
    end

    button.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    update()

    return button
end

-- MOBILE SLIDER
local function createSlider(parent, title, minValue, maxValue, defaultValue, callback, settingKey)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -4, 0, 65)
    holder.BackgroundColor3 = PANEL
    holder.BorderSizePixel = 0
    holder.Parent = parent
    corner(holder, 8)

    local name = makeLabel(
        holder, title, UDim2.new(0.72, 0, 0, 24),
        UDim2.new(0, 10, 0, 4), 12
    )
    name.Font = Enum.Font.GothamBold

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 55, 0, 24)
    valueLabel.Position = UDim2.new(1, -65, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = RED
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextSize = 12
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = holder

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -24, 0, 8)
    bar.Position = UDim2.new(0, 12, 0, 42)
    bar.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
    bar.BorderSizePixel = 0
    bar.Parent = holder
    corner(bar, 8)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue), 0, 1, 0
    )
    fill.BackgroundColor3 = RED
    fill.BorderSizePixel = 0
    fill.Parent = bar
    corner(fill, 8)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
    knob.BackgroundColor3 = WHITE
    knob.BorderSizePixel = 0
    knob.Parent = bar
    corner(knob, 20)

    local hitbox = Instance.new("TextButton")
    hitbox.Size = UDim2.new(1, 0, 0, 30)
    hitbox.Position = UDim2.new(0, 0, 0.5, -15)
    hitbox.BackgroundTransparency = 1
    hitbox.Text = ""
    hitbox.Parent = bar
    hitbox.ZIndex = 5

    local dragging = false

local function setValue(value)
    value = math.clamp(
        math.floor(value + 0.5),
        minValue,
        maxValue
    )

    local percent = (value - minValue) / (maxValue - minValue)

    fill.Size = UDim2.new(percent, 0, 1, 0)
    knob.Position = UDim2.new(percent, 0, 0.5, 0)
    valueLabel.Text = tostring(value)

    callback(value)
end

if settingKey then
    Controls[settingKey] = setValue
end

    local function updateFromX(x)
        local width = bar.AbsoluteSize.X
        if width <= 0 then return end

        local percent = math.clamp(
            (x - bar.AbsolutePosition.X) / width, 0, 1
        )

        local value = math.floor(
            minValue + percent * (maxValue - minValue) + 0.5
        )
        
        setValue(value)
    end

    hitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            updateFromX(input.Position.X)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return holder
end

-- MAIN PAGE
section(Pages.Main, "WELCOME")

local welcome = Instance.new("Frame")
welcome.Size = UDim2.new(1, -4, 0, 75)
welcome.BackgroundColor3 = PANEL
welcome.Parent = Pages.Main
corner(welcome, 8)

local welcomeTitle = makeLabel(
    welcome, "BLACK DRAGON HUB",
    UDim2.new(1, -20, 0, 27),
    UDim2.new(0, 10, 0, 8), 16
)
welcomeTitle.Font = Enum.Font.GothamBlack
welcomeTitle.TextColor3 = RED

makeLabel(
    welcome, "Compact mobile control panel",
    UDim2.new(1, -20, 0, 22),
    UDim2.new(0, 10, 0, 38), 11
).TextColor3 = GRAY

createButton(Pages.Main, "Hide Hub", function()
    Main.Visible = false
end)

createButton(Pages.Main, "Show Hub", function()
    Main.Visible = true
end)

-- PLAYER PAGE
section(Pages.Player, "MOVEMENT SETTINGS")

createSlider(Pages.Player, "Run Speed", 16, 200, 16, function(value)
    Settings.WalkSpeed = value
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.WalkSpeed = value
    end
end, "WalkSpeed")

createSlider(Pages.Player, "Jump Power", 50, 200, 50, function(value)
    Settings.JumpPower = value
    local humanoid = getHumanoid()
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end, "JumpPower")

section(Pages.Player, "PLAYER OPTIONS")

createToggle(Pages.Player, "Player ESP", false, function(enabled)
    Settings.ESP = enabled

    for _, object in pairs(ESPObjects) do
        if object then object:Destroy() end
    end
    table.clear(ESPObjects)

    if enabled then
        for _, target in ipairs(Players:GetPlayers()) do
            if target ~= Player and target.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = RED
                highlight.OutlineColor = WHITE
                highlight.FillTransparency = 0.65
                highlight.Adornee = target.Character
                highlight.Parent = target.Character
                ESPObjects[target] = highlight
            end
        end
    end
end, "ESP")

createToggle(Pages.Player, "Noclip", false, function(enabled)
    Settings.Noclip = enabled
end, "Noclip")

createToggle(Pages.Player, "Infinite Jump", false, function(enabled)
    Settings.InfiniteJump = enabled
    notify(
        "Infinite Jump",
        enabled and "Enabled" or "Disabled"
    )
end, "InfiniteJump")

createToggle(Pages.Player, "Anti-Void", false, function(enabled)
    Settings.AntiVoid = enabled
end, "AntiVoid")

-- CONFIG MANAGER UI

section(Pages.Misc, "CONFIG MANAGER")

createButton(Pages.Misc, "SAVE CONFIG", function()
    SaveConfig()
end)

createButton(Pages.Misc, "LOAD CONFIG", function()
    LoadConfig()
end)

createButton(Pages.Misc, "RESET DEFAULTS", function()
    ResetConfig()
end)

-- MISC PAGE
section(Pages.Misc, "PERFORMANCE")

createSlider(Pages.Misc, "FPS Cap", 30, 240, 60, function(value)
    Settings.FPSCap = value
    if setfpscap then
        pcall(setfpscap, value)
    end
end, "FPSCap")

createToggle(Pages.Misc, "FPS Boost", false, function(enabled)
    Settings.FPSBoost = enabled

    if enabled then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        Lighting.Brightness = 1

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Smoke")
            or obj:IsA("Fire") then
                obj.Enabled = false
            end
        end

        notify("FPS Boost", "Visual effects reduced")
    else
        notify("FPS Boost", "Rejoin to fully restore visuals")
    end
end, "FPSBoost")

-- INFINITE JUMP
Connections.InfiniteJump = UIS.JumpRequest:Connect(function()
    if not Settings.InfiniteJump then
        return
    end

    local humanoid = getHumanoid()

    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

createToggle(Pages.Misc, "Anti-AFK", false, function(enabled)
    Settings.AntiAFK = enabled
    notify("Anti-AFK", enabled and "Enabled" or "Disabled")
end, "AntiAFK")

section(Pages.Misc, "LIVE STATS")

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -4, 0, 48)
StatsLabel.BackgroundColor3 = PANEL
StatsLabel.TextColor3 = WHITE
StatsLabel.TextSize = 12
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.Text = "FPS: --    PING: --"
StatsLabel.Parent = Pages.Misc
corner(StatsLabel, 8)


-- MACHINE RUNNING
section(Pages.Teleport, "MACHINE RUNNING")

local PathfindingService = game:GetService("PathfindingService")
local ActiveMachineRun = false

local function findMachine(name)
    local searchName = string.lower(name)
    local partialMatch = nil

    -- Search Models first to avoid selecting random machine parts
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("Model") then
            local objectName = string.lower(object.Name)

            if objectName == searchName then
                return object
            elseif string.find(objectName, searchName, 1, true) then
                partialMatch = partialMatch or object
            end
        end
    end

    if partialMatch then
        return partialMatch
    end

    -- Fall back to individual parts
    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") then
            local objectName = string.lower(object.Name)

            if objectName == searchName
            or string.find(objectName, searchName, 1, true) then
                return object
            end
        end
    end

    return nil
end

local function getMachinePosition(machine, root)
    local center
    local size

    if machine:IsA("Model") then
        center, size = machine:GetBoundingBox()
    else
        center = machine.CFrame
        size = machine.Size
    end

    local direction = Vector3.new(
        root.Position.X - center.Position.X,
        0,
        root.Position.Z - center.Position.Z
    )

    if direction.Magnitude < 0.1 then
        direction = Vector3.new(0, 0, 1)
    else
        direction = direction.Unit
    end

    local distance = math.max(size.X, size.Z) / 2 + 5

    return center.Position + direction * distance
end

local function runToMachine(name)
    -- Stop previous movement
    ActiveMachineRun = false
    task.wait(0.2)

    local machine = findMachine(name)
    local humanoid = getHumanoid()
    local root = getRoot()

    if not machine then
        notify("BLACK DRAGON", name .. " not found")
        return
    end

    if not humanoid or not root then
        notify("BLACK DRAGON", "Character not available")
        return
    end

    ActiveMachineRun = true

    notify("BLACK DRAGON", "Finding route to " .. name)

    task.spawn(function()
        local failedAttempts = 0

        while ActiveMachineRun do
            humanoid = getHumanoid()
            root = getRoot()

            if not humanoid or not root or humanoid.Health <= 0 then
                break
            end

            if not machine.Parent then
                notify("BLACK DRAGON", name .. " disappeared")
                break
            end

            local targetPosition = getMachinePosition(machine, root)

            if (root.Position - targetPosition).Magnitude <= 7 then
                notify("BLACK DRAGON", "Reached " .. name)
                break
            end

            local path = PathfindingService:CreatePath({
                AgentRadius = 2,
                AgentHeight = 5,
                AgentCanJump = true,
                AgentCanClimb = true,
                WaypointSpacing = 5
            })

            local success = pcall(function()
                path:ComputeAsync(root.Position, targetPosition)
            end)

            if success and path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                local blocked = false

                local blockedConnection = path.Blocked:Connect(function()
                    blocked = true
                end)

                for _, waypoint in ipairs(waypoints) do
                    if not ActiveMachineRun or blocked then
                        break
                    end

                    humanoid = getHumanoid()
                    root = getRoot()

                    if not humanoid or not root then
                        break
                    end

                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                    end

                    humanoid:MoveTo(waypoint.Position)

                    local reached = humanoid.MoveToFinished:Wait()

                    if not reached then
                        blocked = true
                        break
                    end
                end

                blockedConnection:Disconnect()

                if blocked then
                    failedAttempts = failedAttempts + 1
                    task.wait(0.5)
                else
                    failedAttempts = 0
                end
            else
                failedAttempts = failedAttempts + 1
                task.wait(1)
            end

            if failedAttempts >= 5 then
                notify("BLACK DRAGON", "Could not reach " .. name)
                break
            end

            task.wait(0.2)
        end

        ActiveMachineRun = false
    end)
end

createButton(Pages.Teleport, "Run to Compressor", function()
    runToMachine("Compressor")
end)

createButton(Pages.Teleport, "Run to Smelter", function()
    runToMachine("Smelter")
end)

createButton(Pages.Teleport, "Stop Running", function()
    ActiveMachineRun = false

    local humanoid = getHumanoid()

    if humanoid then
        humanoid:Move(Vector3.zero)
        humanoid:MoveTo(getRoot().Position)
    end

    notify("BLACK DRAGON", "Movement stopped")
end)

createButton(Pages.Teleport, "Run to Compressor", function()
    runToMachine("Compressor")
end)

createButton(Pages.Teleport, "Run to Smelter", function()
    runToMachine("Smelter")
end)

createButton(Pages.Teleport, "Run to Trader John", function()
    runToMachine("Trader John")
end)

createButton(Pages.Teleport, "Stop Running", function()
    ActiveMachineRun = false

    local humanoid = getHumanoid()
    if humanoid then
        humanoid:Move(Vector3.zero)
    end

    notify("Running", "Movement stopped")
end)

-- SERVER TOOLS
section(Pages.Teleport, "SERVER OPTIONS")

createButton(Pages.Teleport, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, Player)
end)

createButton(Pages.Teleport, "Copy Job ID", function()
    if setclipboard then
        setclipboard(game.JobId)
        notify("Server", "Job ID copied")
    else
        notify("Server", "Clipboard unavailable")
    end
end)

createButton(Pages.Teleport, "Server Hop", function()
    notify("Server", "Searching for another server...")

    local success, result = pcall(function()
        local url = "https://games.roblox.com/v1/games/"
            .. game.PlaceId
            .. "/servers/Public?sortOrder=Asc&limit=100"

        local response
        if request then
            response = request({Url = url, Method = "GET"}).Body
        elseif game.HttpGet then
            response = game:HttpGet(url)
        else
            error("HTTP request unavailable")
        end

        return HttpService:JSONDecode(response)
    end)

    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.id ~= game.JobId and server.playing < server.maxPlayers then
                TeleportService:TeleportToPlaceInstance(
                    game.PlaceId, server.id, Player
                )
                return
            end
        end
    end

    notify("Server", "Could not find another server")
end)

-- CHARACTER SETTINGS ON RESPAWN
local function applyCharacterSettings(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if not humanoid then return end

    humanoid.WalkSpeed = Settings.WalkSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = Settings.JumpPower
end

Player.CharacterAdded:Connect(applyCharacterSettings)

if Player.Character then
    task.spawn(applyCharacterSettings, Player.Character)
end

-- PLAYER ESP FOR NEW PLAYERS
Players.PlayerAdded:Connect(function(target)
    target.CharacterAdded:Connect(function(character)
        task.wait(1)

        if Settings.ESP then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = RED
            highlight.OutlineColor = WHITE
            highlight.FillTransparency = 0.65
            highlight.Adornee = character
            highlight.Parent = character
            ESPObjects[target] = highlight
        end
    end)
end)

Players.PlayerRemoving:Connect(function(target)
    if ESPObjects[target] then
        ESPObjects[target]:Destroy()
        ESPObjects[target] = nil
    end
end)

-- CONTINUOUS FEATURES
Connections.Main = RunService.Stepped:Connect(function()
    local character = Player.Character
    local root = getRoot()

    if Settings.Noclip and character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    if Settings.AntiVoid and root and root.Position.Y < -50 then
        local spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if spawn then
            root.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
        end
    end
end)

Connections.Stats = RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait(), 0.001))
    local ping = "--"

    pcall(function()
        ping = tostring(math.floor(
            Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        )) .. " ms"
    end)

    StatsLabel.Text = "FPS: " .. tostring(fps) .. "    PING: " .. ping
end)

-- ANTI-AFK
Player.Idled:Connect(function()
    if Settings.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- CONFIG MANAGER

local function SaveConfig()
    if not (writefile and makefolder and isfolder) then
        notify("Config", "File saving unavailable")
        return
    end

    local success = pcall(function()
        if not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end

        writefile(ConfigFile, HttpService:JSONEncode(Settings))
    end)

    notify("Config", success and "Config saved!" or "Save failed")
end

local function LoadConfig()
    if not (readfile and isfile) then
        notify("Config", "File loading unavailable")
        return
    end

    if not isfile(ConfigFile) then
        notify("Config", "No saved config")
        return
    end

    local success, data = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigFile))
    end)

    if not success or type(data) ~= "table" then
        notify("Config", "Invalid config")
        return
    end

    for key, default in pairs(DefaultSettings) do
        local value = data[key]

        if value ~= nil and type(value) == type(default) then
            Settings[key] = value
        end
    end

    -- Update actual sliders and toggles
    for key, setter in pairs(Controls) do
        if Settings[key] ~= nil then
            setter(Settings[key])
        end
    end

    notify("Config", "Settings restored!")
end

local function ResetConfig()
    for key, value in pairs(DefaultSettings) do
        Settings[key] = value
    end

    for key, setter in pairs(Controls) do
        if Settings[key] ~= nil then
            setter(Settings[key])
        end
    end

    notify("Config", "Default settings restored!")
end

-- AUTO LOAD CONFIG
LoadConfig()

notify("BLACK DRAGON", "Hub loaded successfully")
