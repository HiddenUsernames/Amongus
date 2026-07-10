local MyUiLibrary = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local activeNotifications = {}
local notificationUniqueId = "Potassium_Notification_Layer"

-- Automatically fetch the external theme module inside the library
local ThemesUrl = "https://raw.githubusercontent.com/HiddenUsernames/Amongus/refs/heads/main/library/Themese.lua" -- <-- PUT YOUR RAW THEMES.LUA LINK HERE
local Themes = loadstring(game:HttpGet(ThemesUrl))()

-- Color table that will hold active colors
local COLORS = {
    Window = Color3.fromRGB(15, 15, 20),
    Header = Color3.fromRGB(22, 22, 28),
    Sidebar = Color3.fromRGB(12, 12, 16),
    Group = Color3.fromRGB(22, 22, 28),
    Row = Color3.fromRGB(28, 28, 36),
    RowHover = Color3.fromRGB(34, 34, 44),
    Stroke = Color3.fromRGB(42, 42, 54),
    Accent = Color3.fromRGB(40, 120, 255),
    AccentOff = Color3.fromRGB(48, 48, 60),
    Title = Color3.fromRGB(245, 245, 250),
    Desc = Color3.fromRGB(120, 120, 140),
    Muted = Color3.fromRGB(150, 150, 170),
    GroupHeader = Color3.fromRGB(200, 200, 215),
}

local DEFAULT_TAB_ICONS = {
    Main = "rbxassetid://6031075938",
    Combat = "rbxassetid://6031225800",
    Settings = "rbxassetid://6031097225",
}

local function tween(instance, info, props)
    TweenService:Create(instance, info, props):Play()
end

local function createWindowControl(parent, config)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 16, 0, 16)
    button.Position = config.Position
    button.BackgroundTransparency = 1
    button.Text = ""
    button.AutoButtonColor = false
    button.ZIndex = 5
    button.Parent = parent

    local circle = Instance.new("ImageLabel")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.Image = "rbxassetid://6031094678"
    circle.ImageColor3 = config.Color
    circle.ScaleType = Enum.ScaleType.Stretch
    circle.Parent = button
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.new(0.5, 0, 0.5, 0)
    icon.Position = UDim2.new(0.5, 0, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0.5, 0.5)
    icon.BackgroundTransparency = 1
    icon.Image = config.Icon
    icon.ImageColor3 = Color3.fromRGB(50, 50, 55)
    icon.ScaleType = Enum.ScaleType.Fit
    icon.Parent = button

    button.MouseEnter:Connect(function()
        tween(circle, TweenInfo.new(0.12), {ImageTransparency = 0.2})
    end)
    button.MouseLeave:Connect(function()
        tween(circle, TweenInfo.new(0.12), {ImageTransparency = 0})
    end)
    button.MouseButton1Click:Connect(config.Callback)
end

-- Global reference tracker to recolor UI components on theme changes
local trackingObjects = {}
local function registerColorTrack(instance, property, colorKey)
    table.insert(trackingObjects, {Instance = instance, Property = property, Key = colorKey})
    instance.BackgroundColor3 = COLORS[colorKey] or instance.BackgroundColor3
end

function MyUiLibrary:SetTheme(themeName)
    if Themes and Themes[themeName] then
        local targetTheme = Themes[themeName]
        for key, color in pairs(targetTheme) do
            COLORS[key] = color
        end
        -- Dynamically recolor everything tracked
        for _, track in ipairs(trackingObjects) do
            if track.Instance and track.Instance.Parent then
                pcall(function()
                    track.Instance[track.Property] = COLORS[track.Key]
                end)
            end
        end
    end
end

function MyUiLibrary:CreateWindow(hubName, hubSubtitle, themeName)
    if themeName then
        self:SetTheme(themeName)
    end

    local uniqueName = "Potassium_Custom_Hub"
    local windowW, windowH = 620, 480
    local headerH = 54

    local oldUi = CoreGui:FindFirstChild(uniqueName)
    if oldUi then oldUi:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uniqueName
    ScreenGui.ResetOnSpawn = false
    pcall(function() ScreenGui.Parent = CoreGui end)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, windowW, 0, windowH)
    MainFrame.Position = UDim2.new(0.5, -windowW / 2, 0.5, -windowH / 2)
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false -- Set to false to let theme header dropdown overflow smoothly
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
    registerColorTrack(MainFrame, "BackgroundColor3", "Window")

    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Thickness = 1
    FrameStroke.Parent = MainFrame
    table.insert(trackingObjects, {Instance = FrameStroke, Property = "Color", Key = "Stroke"})
    FrameStroke.Color = COLORS.Stroke

    local HeaderBar = Instance.new("Frame")
    HeaderBar.Name = "HeaderBar"
    HeaderBar.Size = UDim2.new(1, 0, 0, headerH)
    HeaderBar.BorderSizePixel = 0
    HeaderBar.Parent = MainFrame
    Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 10)
    registerColorTrack(HeaderBar, "BackgroundColor3", "Header")

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, -1)
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = HeaderBar
    registerColorTrack(HeaderLine, "BackgroundColor3", "Stroke")

    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Size = UDim2.new(0, 56, 1, 0)
    ControlsContainer.Position = UDim2.new(0, 14, 0, 0)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = HeaderBar

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(1, 0, 1, -headerH)
    MainContainer.Position = UDim2.new(0, 0, 0, headerH)
    MainContainer.BackgroundTransparency = 1
    MainContainer.Parent = MainFrame

    local minimized = false

    createWindowControl(ControlsContainer, {
        Position = UDim2.new(0, 0, 0.5, -8),
        Color = Color3.fromRGB(242, 91, 91),
        Icon = "rbxassetid://6031094677",
        Callback = function() ScreenGui:Destroy() end
    })

    createWindowControl(ControlsContainer, {
        Position = UDim2.new(0, 24, 0.5, -8),
        Color = Color3.fromRGB(244, 191, 79),
        Icon = "rbxassetid://6031094676",
        Callback = function()
            minimized = not minimized
            MainContainer.Visible = not minimized
            FrameStroke.Enabled = not minimized
            MainFrame:TweenSize(
                minimized and UDim2.new(0, windowW, 0, headerH) or UDim2.new(0, windowW, 0, windowH),
                "Out", "Quint", 0.25, true
            )
        end
    })

    -- ==========================================
    -- HEADER THEME DROPDOWN CHANGER
    -- ==========================================
    local HeaderThemeBtn = Instance.new("TextButton")
    HeaderThemeBtn.Size = UDim2.new(0, 110, 0, 24)
    HeaderThemeBtn.Position = UDim2.new(0, 68, 0.5, -12)
    HeaderThemeBtn.Text = ""
    HeaderThemeBtn.ZIndex = 10
    HeaderThemeBtn.Parent = HeaderBar
    Instance.new("UICorner", HeaderThemeBtn).CornerRadius = UDim.new(0, 5)
    registerColorTrack(HeaderThemeBtn, "BackgroundColor3", "Group")

    local HTStroke = Instance.new("UIStroke")
    HTStroke.Thickness = 1
    HTStroke.Parent = HeaderThemeBtn
    table.insert(trackingObjects, {Instance = HTStroke, Property = "Color", Key = "Stroke"})
    HTStroke.Color = COLORS.Stroke

    local HTLabel = Instance.new("TextLabel")
    HTLabel.Size = UDim2.new(1, -22, 1, 0)
    HTLabel.Position = UDim2.new(0, 8, 0, 0)
    HTLabel.BackgroundTransparency = 1
    HTLabel.Text = themeName or "Default"
    HTLabel.TextColor3 = COLORS.Title
    HTLabel.TextSize = 11
    HTLabel.Font = Enum.Font.GothamBold
    HTLabel.TextXAlignment = Enum.TextXAlignment.Left
    HTLabel.ZIndex = 11
    HTLabel.Parent = HeaderThemeBtn
    table.insert(trackingObjects, {Instance = HTLabel, Property = "TextColor3", Key = "Title"})

    local HTChevron = Instance.new("ImageLabel")
    HTChevron.Size = UDim2.new(0, 10, 0, 10)
    HTChevron.Position = UDim2.new(1, -16, 0.5, -5)
    HTChevron.BackgroundTransparency = 1
    HTChevron.Image = "rbxassetid://6031097204"
    HTChevron.ImageColor3 = COLORS.Muted
    HTChevron.ZIndex = 11
    HTChevron.Parent = HeaderThemeBtn
    table.insert(trackingObjects, {Instance = HTChevron, Property = "ImageColor3", Key = "Muted"})

    local HTList = Instance.new("Frame")
    HTList.Size = UDim2.new(1, 0, 0, 0)
    HTList.Position = UDim2.new(0, 0, 1, 4)
    HTList.Visible = false
    HTList.ClipsDescendants = true
    HTList.ZIndex = 12
    HTList.Parent = HeaderThemeBtn
    Instance.new("UICorner", HTList).CornerRadius = UDim.new(0, 5)
    registerColorTrack(HTList, "BackgroundColor3", "Group")

    local HTListStroke = Instance.new("UIStroke")
    HTListStroke.Parent = HTList
    table.insert(trackingObjects, {Instance = HTListStroke, Property = "Color", Key = "Stroke"})
    HTListStroke.Color = COLORS.Stroke

    local HTScroll = Instance.new("ScrollingFrame")
    HTScroll.Size = UDim2.new(1, 0, 1, 0)
    HTScroll.BackgroundTransparency = 1
    HTScroll.BorderSizePixel = 0
    HTScroll.ScrollBarThickness = 2
    HTScroll.ZIndex = 13
    HTScroll.Parent = HTList

    local HTLayout = Instance.new("UIListLayout")
    HTLayout.Padding = UDim.new(0, 2)
    HTLayout.Parent = HTScroll
    Instance.new("UIPadding", HTScroll).PaddingTop = UDim.new(0, 4)

    -- Extract themes array from loaded source file
    local availableThemes = {"Default"}
    if Themes then
        for tName, _ in pairs(Themes) do
            if tName ~= "Default" then table.insert(availableThemes, tName) end
        end
    end
    HTScroll.CanvasSize = UDim2.new(0, 0, 0, #availableThemes * 26)

    local htExpanded = false
    for _, tName in ipairs(availableThemes) do
        local TBtn = Instance.new("TextButton")
        TBtn.Size = UDim2.new(1, -8, 0, 22)
        TBtn.Position = UDim2.new(0, 4, 0, 0)
        TBtn.Text = tName
        TBtn.TextColor3 = COLORS.Muted
        TBtn.TextSize = 10
        TBtn.Font = Enum.Font.GothamSemibold
        TBtn.ZIndex = 14
        TBtn.Parent = HTScroll
        Instance.new("UICorner", TBtn).CornerRadius = UDim.new(0, 3)
        registerColorTrack(TBtn, "BackgroundColor3", "Row")
        table.insert(trackingObjects, {Instance = TBtn, Property = "TextColor3", Key = "Muted"})

        TBtn.MouseButton1Click:Connect(function()
            htExpanded = false
            HTList.Visible = false
            HTList.Size = UDim2.new(1, 0, 0, 0)
            HTLabel.Text = tName
            self:SetTheme(tName)
        end)
    end

    HeaderThemeBtn.MouseButton1Click:Connect(function()
        htExpanded = not htExpanded
        HTList.Visible = htExpanded
        HTList.Size = htExpanded and UDim2.new(1, 0, 0, math.min(#availableThemes * 26 + 8, 140)) or UDim2.new(1, 0, 0, 0)
        tween(HTChevron, TweenInfo.new(0.15), {Rotation = htExpanded and 180 or 0})
    end)

    -- ==========================================

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.4, 0, 0.48, 0)
    TitleLabel.Position = UDim2.new(1, -20, 0.1, 0)
    TitleLabel.AnchorPoint = Vector2.new(1, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = hubName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Right
    TitleLabel.Parent = HeaderBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0.4, 0, 0.38, 0)
    SubtitleLabel.Position = UDim2.new(1, -20, 0.55, 0)
    SubtitleLabel.AnchorPoint = Vector2.new(1, 0)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = hubSubtitle or "Auto-Mission Client"
    SubtitleLabel.TextSize = 11
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
    SubtitleLabel.Parent = HeaderBar
    table.insert(trackingObjects, {Instance = SubtitleLabel, Property = "TextColor3", Key = "Muted"})
    SubtitleLabel.TextColor3 = COLORS.Muted

    local dragging, dragInput, dragStart, startPos
    local function updateDrag(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    HeaderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    HeaderBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            updateDrag(dragInput)
        end
    end)

    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 155, 1, 0)
    Sidebar.BackgroundTransparency = 0.15
    Sidebar.BorderSizePixel = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainContainer
    registerColorTrack(Sidebar, "BackgroundColor3", "Sidebar")

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 6)
    SidebarLayout.Parent = Sidebar
    local SidebarPad = Instance.new("UIPadding", Sidebar)
    SidebarPad.PaddingTop = UDim.new(0, 12)
    SidebarPad.PaddingLeft = UDim.new(0, 10)
    SidebarPad.PaddingRight = UDim.new(0, 10)

    SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sidebar.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 20)
    end)

    local ContentDisplay = Instance.new("Frame")
    ContentDisplay.Size = UDim2.new(1, -168, 1, -16)
    ContentDisplay.Position = UDim2.new(0, 162, 0, 8)
    ContentDisplay.BackgroundTransparency = 1
    ContentDisplay.Parent = MainContainer

    local WindowFeatures = {}
    local sectionsCreated = 0

    function WindowFeatures:CreateSection(sectionName, sectionIcon)
        sectionsCreated = sectionsCreated + 1
        local isFirst = sectionsCreated == 1
        local iconId = sectionIcon or DEFAULT_TAB_ICONS[sectionName]

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 90)
        TabPage.Visible = isFirst
        TabPage.Parent = ContentDisplay

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Parent = TabPage

        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 38)
        TabButton.BackgroundColor3 = isFirst and (COLORS.TabSelected or Color3.fromRGB(32, 32, 42)) or (COLORS.TabIdle or Color3.fromRGB(20, 20, 26))
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.ClipsDescendants = true
        TabButton.Parent = Sidebar
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 7)

        local SelectOverlay = Instance.new("Frame")
        SelectOverlay.Name = "SelectOverlay"
        SelectOverlay.Size = UDim2.new(1, 0, 1, 0)
        SelectOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectOverlay.BackgroundTransparency = 0.88
        SelectOverlay.BorderSizePixel = 0
        SelectOverlay.Visible = isFirst
        SelectOverlay.ZIndex = 1
        SelectOverlay.Parent = TabButton
        Instance.new("UICorner", SelectOverlay).CornerRadius = UDim.new(0, 7)

        local SelectIndicator = Instance.new("Frame")
        SelectIndicator.Name = "SelectIndicator"
        SelectIndicator.Size = UDim2.new(0, 4, isFirst and 0.75 or 0, 0)
        SelectIndicator.Position = UDim2.new(1, -6, 0.5, 0)
        SelectIndicator.AnchorPoint = Vector2.new(1, 0.5)
        SelectIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectIndicator.BorderSizePixel = 0
        SelectIndicator.Visible = isFirst
        SelectIndicator.ZIndex = 3
        SelectIndicator.Parent = TabButton
        Instance.new("UICorner", SelectIndicator).CornerRadius = UDim.new(1, 0)

        local TabIcon
        if iconId then
            TabIcon = Instance.new("ImageLabel")
            TabIcon.Name = "TabIcon"
            TabIcon.Size = UDim2.new(0, 16, 0, 16)
            TabIcon.Position = UDim2.new(0, 12, 0.5, -8)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = iconId
            TabIcon.ImageColor3 = isFirst and Color3.fromRGB(255, 255, 255) or COLORS.Muted
            TabIcon.ScaleType = Enum.ScaleType.Fit
            TabIcon.ZIndex = 2
            TabIcon.Parent = TabButton
        end

        local TabLabel = Instance.new("TextLabel")
        TabLabel.Name = "TabLabel"
        TabLabel.Size = UDim2.new(1, -40, 1, 0)
        TabLabel.Position = UDim2.new(0, iconId and 34 or 12, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = sectionName
        TabLabel.TextColor3 = isFirst and Color3.fromRGB(255, 255, 255) or COLORS.Muted
        TabLabel.TextSize = 13
        TabLabel.Font = Enum.Font.GothamSemibold
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.ZIndex = 2
        TabLabel.Parent = TabButton

        TabButton.MouseEnter:Connect(function()
            if not TabPage.Visible then
                tween(TabButton, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.TabHover or Color3.fromRGB(26, 26, 34)})
            end
        end)
        TabButton.MouseLeave:Connect(function()
            if not TabPage.Visible then
                tween(TabButton, TweenInfo.new(0.12), {BackgroundColor3 = COLORS.TabIdle or Color3.fromRGB(20, 20, 26)})
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(ContentDisplay:GetChildren()) do
                if page:IsA("ScrollingFrame") then
                    page.Visible = false
                end
            end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    setTabVisualState(btn, false)
                end
            end
            TabPage.Visible = true
            setTabVisualState(TabButton, true)
        end)

        local SectionFeatures = {}
        local activeGroup = TabPage

        local function bindCanvasUpdate(groupLayout)
            groupLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
            end)
        end

        function SectionFeatures:CreateSectionLevel(labelText)
            local GroupFrame = Instance.new("Frame")
            GroupFrame.Size = UDim2.new(1, -4, 0, 0)
            GroupFrame.AutomaticSize = Enum.AutomaticSize.Y
            GroupFrame.BorderSizePixel = 0
            GroupFrame.Parent = TabPage
            Instance.new("UICorner", GroupFrame).CornerRadius = UDim.new(0, 8)
            registerColorTrack(GroupFrame, "BackgroundColor3", "Group")

            local GStroke = Instance.new("UIStroke")
            GStroke.Thickness = 1
            GStroke.Parent = GroupFrame
            table.insert(trackingObjects, {Instance = GStroke, Property = "Color", Key = "Stroke"})
            GStroke.Color = COLORS.Stroke

            local GroupPad = Instance.new("UIPadding", GroupFrame)
            GroupPad.PaddingTop = UDim.new(0, 10)
            GroupPad.PaddingBottom = UDim.new(0, 10)
            GroupPad.PaddingLeft = UDim.new(0, 10)
            GroupPad.PaddingRight = UDim.new(0, 10)

            local GroupHeader = Instance.new("TextLabel")
            GroupHeader.Size = UDim2.new(1, 0, 0, 18)
            GroupHeader.BackgroundTransparency = 1
            GroupHeader.Text = string.upper(labelText)
            GroupHeader.TextSize = 11
            GroupHeader.Font = Enum.Font.GothamBold
            GroupHeader.TextXAlignment = Enum.TextXAlignment.Left
            GroupHeader.Parent = GroupFrame
            table.insert(trackingObjects, {Instance = GroupHeader, Property = "TextColor3", Key = "GroupHeader"})
            GroupHeader.TextColor3 = COLORS.GroupHeader

            local GroupContent = Instance.new("Frame")
            GroupContent.Name = "GroupContent"
            GroupContent.Size = UDim2.new(1, 0, 0, 0)
            GroupContent.Position = UDim2.new(0, 0, 0, 24)
            GroupContent.AutomaticSize = Enum.AutomaticSize.Y
            GroupContent.BackgroundTransparency = 1
            GroupContent.Parent = GroupFrame

            local GroupLayout = Instance.new("UIListLayout")
            GroupLayout.Padding = UDim.new(0, 6)
            GroupLayout.SortOrder = Enum.SortOrder.LayoutOrder
            GroupLayout.Parent = GroupContent

            bindCanvasUpdate(GroupLayout)
            activeGroup = GroupContent
        end

        local function createBaseElement(name, info, height, iconId)
            height = height or (info ~= "" and 58 or 46)
            local BaseFrame = Instance.new("Frame")
            BaseFrame.Size = UDim2.new(1, 0, 0, height)
            BaseFrame.BorderSizePixel = 0
            BaseFrame.Parent = activeGroup
            Instance.new("UICorner", BaseFrame).CornerRadius = UDim.new(0, 7)
            registerColorTrack(BaseFrame, "BackgroundColor3", "Row")

            local EStroke = Instance.new("UIStroke")
            EStroke.Thickness = 1
            EStroke.Parent = BaseFrame
            table.insert(trackingObjects, {Instance = EStroke, Property = "Color", Key = "Stroke"})
            EStroke.Color = COLORS.Stroke

            local textOffset = 12
            if iconId then
                local Icon = Instance.new("ImageLabel")
                Icon.Size = UDim2.new(0, 18, 0, 18)
                Icon.Position = UDim2.new(0, 12, 0.5, -9)
                Icon.BackgroundTransparency = 1
                Icon.Image = iconId
                Icon.ScaleType = Enum.ScaleType.Fit
                Icon.Parent = BaseFrame
                table.insert(trackingObjects, {Instance = Icon, Property = "ImageColor3", Key = "Accent"})
                Icon.ImageColor3 = COLORS.Accent
                textOffset = 38
            end

            local Title = Instance.new("TextLabel")
            Title.Size = (info ~= "") and UDim2.new(0.55, 0, 0, 20) or UDim2.new(0.55, 0, 1, 0)
            Title.Position = UDim2.new(0, textOffset, 0, (info ~= "") and 10 or 0)
            Title.BackgroundTransparency = 1
            Title.Text = name
            Title.TextSize = 13
            Title.Font = Enum.Font.GothamSemibold
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.TextYAlignment = (info ~= "") and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
            Title.Parent = BaseFrame
            table.insert(trackingObjects, {Instance = Title, Property = "TextColor3", Key = "Title"})
            Title.TextColor3 = COLORS.Title

            if info ~= "" then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(0.55, 0, 0, 16)
                Desc.Position = UDim2.new(0, textOffset, 0, 32)
                Desc.BackgroundTransparency = 1
                Desc.Text = info
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Parent = BaseFrame
                table.insert(trackingObjects, {Instance = Desc, Property = "TextColor3", Key = "Desc"})
                Desc.TextColor3 = COLORS.Desc
            end

            return BaseFrame
        end

        function SectionFeatures:CreateButton(config)
            local Frame = createBaseElement(config.Name or "Button", config.Info or "", nil, config.Icon)
            local HitButton = Instance.new("TextButton")
            HitButton.Size = UDim2.new(1, 0, 1, 0)
            HitButton.BackgroundTransparency = 1
            HitButton.Text = ""
            HitButton.Parent = Frame
            HitButton.MouseEnter:Connect(function() Frame.BackgroundColor3 = COLORS.RowHover end)
            HitButton.MouseLeave:Connect(function() Frame.BackgroundColor3 = COLORS.Row end)
            HitButton.MouseButton1Click:Connect(function() task.spawn(config.Callback or function() end) end)
        end

        function SectionFeatures:CreateToggle(config)
            local Frame = createBaseElement(config.Name or "Toggle", config.Info or "", nil, config.Icon)
            local state = config.CurrentValue or false
            local callback = config.Callback or function() end

            local HitButton = Instance.new("TextButton")
            HitButton.Size = UDim2.new(1, 0, 1, 0)
            HitButton.BackgroundTransparency = 1
            HitButton.Text = ""
            HitButton.Parent = Frame

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 42, 0, 22)
            Box.Position = UDim2.new(1, -54, 0.5, -11)
            Box.Parent = Frame
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)
            registerColorTrack(Box, "BackgroundColor3", state and "Accent" or "AccentOff")

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.Parent = Box
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            HitButton.MouseButton1Click:Connect(function()
                state = not state
                tween(Box, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = state and COLORS.Accent or COLORS.AccentOff
                })
                tween(Indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
                    Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                })
                task.spawn(callback, state)
            end)
        end

        function SectionFeatures:CreateSlider(config)
            local Frame = createBaseElement(config.Name or "Slider", config.Info or "", 78, config.Icon)
            local min = config.Min or 0
            local max = config.Max or 100
            local current = math.clamp(config.CurrentValue or min, min, max)
            local callback = config.Callback or function() end

            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Size = UDim2.new(0, 200, 0, 5)
            Track.Position = UDim2.new(1, -230, 0.5, 4)
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 62)
            Track.Parent = Frame
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
            Fill.Parent = Track
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            registerColorTrack(Fill, "BackgroundColor3", "Accent")

            local Thumb = Instance.new("Frame")
            Thumb.Size = UDim2.new(0, 14, 0, 14)
            Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
            Thumb.Position = UDim2.new((current - min) / (max - min), 0, 0.5, 0)
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.Parent = Track
            Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

            local ValBubble = Instance.new("TextLabel")
            ValBubble.Size = UDim2.new(0, 36, 0, 18)
            ValBubble.AnchorPoint = Vector2.new(0.5, 1)
            ValBubble.Position = UDim2.new((current - min) / (max - min), 0, 0, -6)
            ValBubble.Text = tostring(current)
            ValBubble.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValBubble.TextSize = 11
            ValBubble.Font = Enum.Font.GothamBold
            ValBubble.Parent = Track
            Instance.new("UICorner", ValBubble).CornerRadius = UDim.new(0, 4)
            registerColorTrack(ValBubble, "BackgroundColor3", "Accent")

            local MinLabel = Instance.new("TextLabel")
            MinLabel.Size = UDim2.new(0, 30, 0, 14)
            MinLabel.Position = UDim2.new(1, -230, 0.5, 14)
            MinLabel.BackgroundTransparency = 1
            MinLabel.Text = tostring(min)
            MinLabel.TextSize = 10
            MinLabel.Font = Enum.Font.Gotham
            MinLabel.TextXAlignment = Enum.TextXAlignment.Left
            MinLabel.Parent = Frame
            table.insert(trackingObjects, {Instance = MinLabel, Property = "TextColor3", Key = "Desc"})
            MinLabel.TextColor3 = COLORS.Desc

            local MaxLabel = Instance.new("TextLabel")
            MaxLabel.Size = UDim2.new(0, 30, 0, 14)
            MaxLabel.Position = UDim2.new(1, -60, 0.5, 14)
            MaxLabel.BackgroundTransparency = 1
            MaxLabel.Text = tostring(max)
            MaxLabel.TextSize = 10
            MaxLabel.Font = Enum.Font.Gotham
            MaxLabel.TextXAlignment = Enum.TextXAlignment.Right
            MaxLabel.Parent = Frame
            table.insert(trackingObjects, {Instance = MaxLabel, Property = "TextColor3", Key = "Desc"})
            MaxLabel.TextColor3 = COLORS.Desc

            local sliderDragging = false
            local function updateSlider(input)
                local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                current = math.floor(min + (percentage * (max - min)) + 0.5)
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                Thumb.Position = UDim2.new(percentage, 0, 0.5, 0)
                ValBubble.Position = UDim2.new(percentage, 0, 0, -6)
                ValBubble.Text = tostring(current)
                task.spawn(callback, current)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliderDragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliderDragging = false
                end
            end)
        end

        function SectionFeatures:CreateDropdown(config)
            local name = config.Name or "Dropdown"
            local info = config.Info or ""
            local options = config.Options or {}
            local callback = config.Callback or function() end
            local selected = config.CurrentOption or options[1] or "Choose"
            local expanded = false

            local Frame = createBaseElement(name, info, nil, config.Icon)

            local DropBox = Instance.new("TextButton")
            DropBox.Size = UDim2.new(0, 148, 0, 30)
            DropBox.Position = UDim2.new(1, -158, 0.5, -15)
            DropBox.Text = ""
            DropBox.AutoButtonColor = false
            DropBox.Parent = Frame
            Instance.new("UICorner", DropBox).CornerRadius = UDim.new(0, 6)
            registerColorTrack(DropBox, "BackgroundColor3", "InputBg")

            local DropStroke = Instance.new("UIStroke")
            DropStroke.Parent = DropBox
            table.insert(trackingObjects, {Instance = DropStroke, Property = "Color", Key = "Stroke"})
            DropStroke.Color = COLORS.Stroke

            local DropValue = Instance.new("TextLabel")
            DropValue.Size = UDim2.new(1, -28, 1, 0)
            DropValue.Position = UDim2.new(0, 10, 0, 0)
            DropValue.BackgroundTransparency = 1
            DropValue.Text = selected
            DropValue.TextSize = 12
            DropValue.Font = Enum.Font.GothamSemibold
            DropValue.TextXAlignment = Enum.TextXAlignment.Left
            DropValue.TextTruncate = Enum.TextTruncate.AtEnd
            DropValue.Parent = DropBox
            table.insert(trackingObjects, {Instance = DropValue, Property = "TextColor3", Key = "Title"})
            DropValue.TextColor3 = COLORS.Title

            local Chevron = Instance.new("ImageLabel")
            Chevron.Size = UDim2.new(0, 12, 0, 12)
            Chevron.Position = UDim2.new(1, -20, 0.5, -6)
            Chevron.BackgroundTransparency = 1
            Chevron.Image = "rbxassetid://6031097204"
            Chevron.ScaleType = Enum.ScaleType.Fit
            Chevron.Parent = DropBox
            table.insert(trackingObjects, {Instance = Chevron, Property = "ImageColor3", Key = "Muted"})
            Chevron.ImageColor3 = COLORS.Muted

            local DropList = Instance.new("Frame")
            DropList.Name = "DropList"
            DropList.Size = UDim2.new(0, 148, 0, 0)
            DropList.Position = UDim2.new(1, -158, 1, 4)
            DropList.Visible = false
            DropList.ClipsDescendants = true
            DropList.ZIndex = 20
            DropList.Parent = Frame
            Instance.new("UICorner", DropList).CornerRadius = UDim.new(0, 6)
            registerColorTrack(DropList, "BackgroundColor3", "InputBg")

            local ListStroke = Instance.new("UIStroke")
            ListStroke.Parent = DropList
            table.insert(trackingObjects, {Instance = ListStroke, Property = "Color", Key = "Stroke"})
            ListStroke.Color = COLORS.Stroke

            local ListScroll = Instance.new("ScrollingFrame")
            ListScroll.Size = UDim2.new(1, 0, 1, 0)
            ListScroll.BackgroundTransparency = 1
            ListScroll.BorderSizePixel = 0
            ListScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 30)
            ListScroll.ScrollBarThickness = 2
            ListScroll.ZIndex = 21
            ListScroll.Parent = DropList
            table.insert(trackingObjects, {Instance = ListScroll, Property = "ScrollBarImageColor3", Key = "Muted"})

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = ListScroll

            local listPad = Instance.new("UIPadding", ListScroll)
            listPad.PaddingTop = UDim.new(0, 4)
            listPad.PaddingBottom = UDim.new(0, 4)
            listPad.PaddingLeft = UDim.new(0, 4)
            listPad.PaddingRight = UDim.new(0, 4)

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, -4, 0, 26)
                OptBtn.Text = opt
                OptBtn.TextSize = 11
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.ZIndex = 22
                OptBtn.Parent = ListScroll
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)
                registerColorTrack(OptBtn, "BackgroundColor3", "Sidebar")
                table.insert(trackingObjects, {Instance = OptBtn, Property = "TextColor3", Key = "Muted"})
                OptBtn.TextColor3 = COLORS.Muted

                OptBtn.MouseEnter:Connect(function()
                    OptBtn.BackgroundColor3 = COLORS.RowHover
                    OptBtn.TextColor3 = COLORS.Title
                end)
                OptBtn.MouseLeave:Connect(function()
                    OptBtn.BackgroundColor3 = COLORS.Sidebar
                    OptBtn.TextColor3 = COLORS.Muted
                end)
                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    DropValue.Text = opt
                    expanded = false
                    DropList.Visible = false
                    DropList.Size = UDim2.new(0, 148, 0, 0)
                    task.spawn(callback, opt)
                end)
            end

            DropBox.MouseButton1Click:Connect(function()
                expanded = not expanded
                local listH = math.min(#options * 30 + 8, 130)
                DropList.Visible = expanded
                DropList.Size = expanded and UDim2.new(0, 148, 0, listH) or UDim2.new(0, 148, 0, 0)
                tween(Chevron, TweenInfo.new(0.15), {Rotation = expanded and 180 or 0})
            end)
        end

        function SectionFeatures:CreateInput(config)
            local Frame = createBaseElement(config.Name or "Input", config.Info or "", nil, config.Icon)
            local min = config.Min or 0
            local max = config.Max or 100
            local step = config.Step or 0.1
            local current = math.clamp(config.CurrentValue or min, min, max)
            local callback = config.Callback or function() end
            local decimals = config.Decimals or (step < 1 and 2 or 0)

            local function formatValue(val)
                if decimals > 0 then
                    return string.format("%." .. decimals .. "f", val)
                end
                return tostring(math.floor(val + 0.5))
            end

            local InputBox = Instance.new("Frame")
            InputBox.Size = UDim2.new(0, 90, 0, 30)
            InputBox.Position = UDim2.new(1, -100, 0.5, -15)
            InputBox.Parent = Frame
            Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 6)
            registerColorTrack(InputBox, "BackgroundColor3", "InputBg")

            local IStroke = Instance.new("UIStroke")
            IStroke.Parent = InputBox
            table.insert(trackingObjects, {Instance = IStroke, Property = "Color", Key = "Stroke"})
            IStroke.Color = COLORS.Stroke

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(1, -28, 1, 0)
            ValLabel.Position = UDim2.new(0, 8, 0, 0)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = formatValue(current)
            ValLabel.TextSize = 12
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextXAlignment = Enum.TextXAlignment.Left
            ValLabel.Parent = InputBox
            table.insert(trackingObjects, {Instance = ValLabel, Property = "TextColor3", Key = "Title"})
            ValLabel.TextColor3 = COLORS.Title

            local function setValue(val)
                current = math.clamp(val, min, max)
                ValLabel.Text = formatValue(current)
                task.spawn(callback, current)
            end

            local UpBtn = Instance.new("TextButton")
            UpBtn.Size = UDim2.new(0, 18, 0, 13)
            UpBtn.Position = UDim2.new(1, -22, 0, 3)
            UpBtn.BackgroundTransparency = 1
            UpBtn.Text = "▲"
            UpBtn.TextSize = 8
            UpBtn.Font = Enum.Font.GothamBold
            UpBtn.Parent = InputBox
            table.insert(trackingObjects, {Instance = UpBtn, Property = "TextColor3", Key = "Muted"})
            UpBtn.TextColor3 = COLORS.Muted
            UpBtn.MouseButton1Click:Connect(function() setValue(current + step) end)

            local DownBtn = Instance.new("TextButton")
            DownBtn.Size = UDim2.new(0, 18, 0, 13)
            DownBtn.Position = UDim2.new(1, -22, 1, -16)
            DownBtn.BackgroundTransparency = 1
            DownBtn.Text = "▼"
            DownBtn.TextSize = 8
            DownBtn.Font = Enum.Font.GothamBold
            DownBtn.Parent = InputBox
            table.insert(trackingObjects, {Instance = DownBtn, Property = "TextColor3", Key = "Muted"})
            DownBtn.TextColor3 = COLORS.Muted
            DownBtn.MouseButton1Click:Connect(function() setValue(current - step) end)
        end

        return SectionFeatures
    end

    return WindowFeatures
end

function MyUiLibrary:Notify(title, text, duration)
    duration = duration or 4
    local NotifGui = CoreGui:FindFirstChild(notificationUniqueId)
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = notificationUniqueId
        pcall(function() NotifGui.Parent = CoreGui end)
    end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 280, 0, 76)
    NotifFrame.Position = UDim2.new(1, 300, 1, -85)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifGui
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)
    registerColorTrack(NotifFrame, "BackgroundColor3", "Header")

    local NStroke = Instance.new("UIStroke")
    NStroke.Parent = NotifFrame
    table.insert(trackingObjects, {Instance = NStroke, Property = "Color", Key = "Stroke"})
    NStroke.Color = COLORS.Stroke

    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 4, 1, 0)
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = NotifFrame
    Instance.new("UICorner", SideAccent).CornerRadius = UDim.new(0, 8)
    registerColorTrack(SideAccent, "BackgroundColor3", "Accent")

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 24)
    NotifTitle.Position = UDim2.new(0, 14, 0, 8)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = title
    NotifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifTitle.TextSize = 13
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotifFrame

    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -20, 1, -36)
    NotifText.Position = UDim2.new(0, 14, 0, 30)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = text
    NotifText.TextSize = 12
    NotifText.Font = Enum.Font.Gotham
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.TextYAlignment = Enum.TextYAlignment.Top
    NotifText.TextWrapped = true
    NotifText.Parent = NotifFrame
    table.insert(trackingObjects, {Instance = NotifText, Property = "TextColor3", Key = "Muted"})
    NotifText.TextColor3 = COLORS.Muted

    table.insert(activeNotifications, NotifFrame)

    local function updatePositions()
        for index, frame in ipairs(activeNotifications) do
            local countFromBottom = #activeNotifications - index
            local targetYOffset = -85 - (countFromBottom * 84)
            tween(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -295, 1, targetYOffset)
            })
        end
    end

    updatePositions()

    task.delay(duration, function()
        if NotifFrame and NotifFrame.Parent then
            local slideOut = TweenService:Create(NotifFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(1, 300, NotifFrame.Position.X.Scale, NotifFrame.Position.Y.Offset)
            })
            slideOut:Play()
            slideOut.Completed:Wait()

            local foundIndex = table.find(activeNotifications, NotifFrame)
            if foundIndex then table.remove(activeNotifications, foundIndex) end
            NotifFrame:Destroy()
            updatePositions()
        end
    end)
end

return MyUiLibrary
