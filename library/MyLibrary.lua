local MyUiLibrary = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local activeNotifications = {}
local notificationUniqueId = "Potassium_Notification_Layer"

function MyUiLibrary:CreateWindow(hubName, hubSubtitle)
    local uniqueName = "Potassium_Custom_Hub"
    
    local oldUi = CoreGui:FindFirstChild(uniqueName)
    if oldUi then oldUi:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = uniqueName
    pcall(function() ScreenGui.Parent = CoreGui end)
    
    -- Main Window Frame (Modern acrylic dark transparency)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 560, 0, 390)
    MainFrame.Position = UDim2.new(0.5, -280, 0.5, -195)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    MainFrame.BackgroundTransparency = 0.15 
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 9)
    
    -- Sleek thin border stroke
    local FrameStroke = Instance.new("UIStroke")
    FrameStroke.Color = Color3.fromRGB(45, 45, 55)
    FrameStroke.Thickness = 1
    FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    FrameStroke.Parent = MainFrame

    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then update(dragInput) end
    end)

    -- HEADER SETUP
    local HeaderBar = Instance.new("Frame")
    HeaderBar.Size = UDim2.new(1, 0, 0, 52)
    HeaderBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    HeaderBar.BorderSizePixel = 0
    HeaderBar.Parent = MainFrame
    Instance.new("UICorner", HeaderBar).CornerRadius = UDim.new(0, 9)

    local HeaderLine = Instance.new("Frame")
    HeaderLine.Size = UDim2.new(1, 0, 0, 1)
    HeaderLine.Position = UDim2.new(0, 0, 1, -1)
    HeaderLine.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    HeaderLine.BorderSizePixel = 0
    HeaderLine.Parent = HeaderBar

    -- Left-aligned Mac Style Control Container
    local ControlsContainer = Instance.new("Frame")
    ControlsContainer.Size = UDim2.new(0, 60, 1, 0)
    ControlsContainer.Position = UDim2.new(0, 16, 0, 0)
    ControlsContainer.BackgroundTransparency = 1
    ControlsContainer.Parent = HeaderBar

    -- Close Button with ImageLabel Icon
    local CloseButton = Instance.new("TextButton")
    CloseButton.Size = UDim2.new(0, 14, 0, 14)
    CloseButton.Position = UDim2.new(0, 0, 0.5, -7)
    CloseButton.BackgroundColor3 = Color3.fromRGB(242, 91, 91)
    CloseButton.Text = ""
    CloseButton.Parent = ControlsContainer
    Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(1, 0)

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.new(0, 8, 0, 8)
    CloseIcon.Position = UDim2.new(0.5, -4, 0.5, -4)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://10137932152" -- Premium X glyph icon
    CloseIcon.ImageColor3 = Color3.fromRGB(60, 0, 0)
    CloseIcon.Parent = CloseButton
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Minimize Button with ImageLabel Icon
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Size = UDim2.new(0, 14, 0, 14)
    MinimizeButton.Position = UDim2.new(0, 22, 0.5, -7)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(244, 191, 79)
    MinimizeButton.Text = ""
    MinimizeButton.Parent = ControlsContainer
    Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(1, 0)

    local MinimizeIcon = Instance.new("ImageLabel")
    MinimizeIcon.Size = UDim2.new(0, 8, 0, 8)
    MinimizeIcon.Position = UDim2.new(0.5, -4, 0.5, -4)
    MinimizeIcon.BackgroundTransparency = 1
    MinimizeIcon.Image = "rbxassetid://10137915383" -- Premium Minus glyph icon
    MinimizeIcon.ImageColor3 = Color3.fromRGB(70, 40, 0)
    MinimizeIcon.Parent = MinimizeButton

    local MainContainer = Instance.new("Frame")
    MainContainer.Size = UDim2.new(1, 0, 1, -52)
    MainContainer.Position = UDim2.new(0, 0, 0, 52)
    MainContainer.BackgroundTransparency = 1
    MainContainer.Parent = MainFrame

    local minimized = false
    MinimizeButton.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainContainer.Visible = not minimized
        FrameStroke.Enabled = not minimized
        MainFrame:TweenSize(minimized and UDim2.new(0, 560, 0, 52) or UDim2.new(0, 560, 0, 390), "Out", "Quint", 0.25, true)
    end)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    TitleLabel.Position = UDim2.new(0.4, -18, 0.12, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = hubName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 15
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Right
    TitleLabel.Parent = HeaderBar

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0.6, 0, 0.4, 0)
    SubtitleLabel.Position = UDim2.new(0.4, -18, 0.52, 0)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = hubSubtitle or "Auto-Mission Client"
    SubtitleLabel.TextColor3 = Color3.fromRGB(155, 155, 175)
    SubtitleLabel.TextSize = 11
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Right
    SubtitleLabel.Parent = HeaderBar

    -- Sidebar Container
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Size = UDim2.new(0, 145, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 16)
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.BorderSizePixel = 0
    Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    Sidebar.ScrollBarThickness = 0
    Sidebar.Parent = MainContainer

    local SidebarLayout = Instance.new("UIListLayout")
    SidebarLayout.Padding = UDim.new(0, 5)
    SidebarLayout.Parent = Sidebar
    Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 10)

    local ContentDisplay = Instance.new("Frame")
    ContentDisplay.Size = UDim2.new(1, -160, 1, -15)
    ContentDisplay.Position = UDim2.new(0, 153, 0, 8)
    ContentDisplay.BackgroundTransparency = 1
    ContentDisplay.Parent = MainContainer

    local WindowFeatures = {}
    local sectionsCreated = 0

    function WindowFeatures:CreateSection(sectionName)
        sectionsCreated = sectionsCreated + 1
        
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 85)
        TabPage.Visible = (sectionsCreated == 1)
        TabPage.Parent = ContentDisplay

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = TabPage
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
        end)

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -16, 0, 34)
        TabButton.Position = UDim2.new(0, 8, 0, 0)
        TabButton.BackgroundColor3 = (sectionsCreated == 1) and Color3.fromRGB(35, 35, 45) or Color3.fromRGB(22, 22, 26)
        TabButton.Text = "   " .. sectionName
        TabButton.TextColor3 = (sectionsCreated == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 165)
        TabButton.TextSize = 13
        TabButton.Font = Enum.Font.GothamSemibold
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.ClipsDescendants = true
        TabButton.Parent = Sidebar
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 5)

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = (sectionsCreated == 1) and Color3.fromRGB(70, 130, 240) or Color3.fromRGB(35, 35, 40)
        TabStroke.Thickness = 1
        TabStroke.Parent = TabButton

        -- Premium White Accent Indicator Frame (Right Side Line)
        local AccentLine = Instance.new("Frame")
        AccentLine.Size = UDim2.new(0, 3, 0, 18)
        AccentLine.Position = UDim2.new(1, -3, 0.5, -9)
        AccentLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        AccentLine.BackgroundTransparency = (sectionsCreated == 1) and 0 or 1
        AccentLine.BorderSizePixel = 0
        AccentLine.Parent = TabButton
        Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(0, 2)

        -- Transparent Premium White Background Overlay
        local SelectOverlay = Instance.new("Frame")
        SelectOverlay.Size = UDim2.new(1, 0, 1, 0)
        SelectOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SelectOverlay.BackgroundTransparency = (sectionsCreated == 1) and 0.94 or 1
        SelectOverlay.BorderSizePixel = 0
        SelectOverlay.Parent = TabButton

        TabButton.MouseButton1Click:Connect(function()
            for _, page in pairs(ContentDisplay:GetChildren()) do page.Visible = false end
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
                    btn.TextColor3 = Color3.fromRGB(150, 150, 165)
                    btn.UIStroke.Color = Color3.fromRGB(35, 35, 40)
                    if btn:FindFirstChild("Frame") then btn.Frame.BackgroundTransparency = 1 end
                    if btn:FindFirstChild("AccentLine") then btn.AccentLine.BackgroundTransparency = 1 end
                end
            end
            TabPage.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.UIStroke.Color = Color3.fromRGB(70, 130, 240)
            
            -- Smooth fade-in transitions for premium features
            TweenService:Create(AccentLine, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0}):Play()
            TweenService:Create(SelectOverlay, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 0.94}):Play()
        end)

        local SectionFeatures = {}

        local function createBaseElement(name, info)
            local BaseFrame = Instance.new("Frame")
            BaseFrame.Size = UDim2.new(1, -6, 0, 46)
            BaseFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
            BaseFrame.Parent = TabPage
            Instance.new("UICorner", BaseFrame).CornerRadius = UDim.new(0, 6)

            local EStroke = Instance.new("UIStroke")
            EStroke.Color = Color3.fromRGB(42, 42, 52)
            EStroke.Thickness = 1
            EStroke.Parent = BaseFrame

            local Title = Instance.new("TextLabel")
            Title.Size = (info ~= "") and UDim2.new(0.6, 0, 0, 22) or UDim2.new(0.6, 0, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, (info ~= "") and 5 or 0)
            Title.BackgroundTransparency = 1
            Title.Text = name
            Title.TextColor3 = Color3.fromRGB(245, 245, 250)
            Title.TextSize = 13
            Title.Font = Enum.Font.GothamSemibold
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = BaseFrame

            if info ~= "" then
                local Desc = Instance.new("TextLabel")
                Desc.Size = UDim2.new(0.6, 0, 0, 16)
                Desc.Position = UDim2.new(0, 12, 0, 25)
                Desc.BackgroundTransparency = 1
                Desc.Text = info
                Desc.TextColor3 = Color3.fromRGB(130, 130, 145)
                Desc.TextSize = 11
                Desc.Font = Enum.Font.Gotham
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.Parent = BaseFrame
            end
            return BaseFrame
        end

        function SectionFeatures:CreateButton(config)
            local Frame = createBaseElement(config.Name or "Button", config.Info or "")
            local HitButton = Instance.new("TextButton")
            HitButton.Size = UDim2.new(1, 0, 1, 0)
            HitButton.BackgroundTransparency = 1
            HitButton.Text = ""
            HitButton.Parent = Frame
            HitButton.MouseEnter:Connect(function() Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 40) end)
            HitButton.MouseLeave:Connect(function() Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 32) end)
            HitButton.MouseButton1Click:Connect(function() task.spawn(config.Callback or function() end) end)
        end

        function SectionFeatures:CreateToggle(config)
            local Frame = createBaseElement(config.Name or "Toggle", config.Info or "")
            local state = config.CurrentValue or false
            local callback = config.Callback or function() end

            local HitButton = Instance.new("TextButton")
            HitButton.Size = UDim2.new(1, 0, 1, 0)
            HitButton.BackgroundTransparency = 1
            HitButton.Text = ""
            HitButton.Parent = Frame

            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 38, 0, 20)
            Box.Position = UDim2.new(1, -50, 0.5, -10)
            Box.BackgroundColor3 = state and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(45, 45, 55)
            Box.Parent = Frame
            Instance.new("UICorner", Box).CornerRadius = UDim.new(1, 0)

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 14, 0, 14)
            Indicator.Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.Parent = Box
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            HitButton.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(Box, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {BackgroundColor3 = state and Color3.fromRGB(59, 130, 246) or Color3.fromRGB(45, 45, 55)}):Play()
                TweenService:Create(Indicator, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {Position = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}):Play()
                task.spawn(callback, state)
            end)
        end

        function SectionFeatures:CreateSlider(config)
            local Frame = createBaseElement(config.Name or "Slider", config.Info or "")
            local min = config.Min or 0
            local max = config.Max or 100
            local current = math.clamp(config.CurrentValue or min, min, max)
            local callback = config.Callback or function() end

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(0, 160, 0, 4)
            Track.Position = UDim2.new(1, -215, 0.5, -2)
            Track.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
            Track.Parent = Frame
            Instance.new("UICorner", Track)

            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new((current - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
            Fill.Parent = Track
            Instance.new("UICorner", Fill)

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0, 40, 0, 20)
            ValLabel.Position = UDim2.new(1, -45, 0.5, -10)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(current)
            ValLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
            ValLabel.TextSize = 12
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.Parent = Frame

            local dragging = false
            local function updateSlider(input)
                local percentage = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                local preciseVal = min + (percentage * (max - min))
                current = math.floor(preciseVal + 0.5)
                Fill.Size = UDim2.new(percentage, 0, 1, 0)
                ValLabel.Text = tostring(current)
                task.spawn(callback, current)
            end

            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
        end

        function SectionFeatures:CreateDropdown(config)
            local name = config.Name or "Dropdown"
            local options = config.Options or {}
            local callback = config.Callback or function() end
            local expanded = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -6, 0, 46)
            DropFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)
            
            local DEStroke = Instance.new("UIStroke")
            DEStroke.Color = Color3.fromRGB(42, 42, 52)
            DEStroke.Thickness = 1
            DEStroke.Parent = DropFrame

            local DropButton = Instance.new("TextButton")
            DropButton.Size = UDim2.new(1, 0, 0, 46)
            DropButton.BackgroundTransparency = 1
            DropButton.Text = ""
            DropButton.Parent = DropFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(0.9, 0, 1, 0)
            Title.Position = UDim2.new(0, 12, 0, 0)
            Title.BackgroundTransparency = 1
            Title.Text = name .. " :  <font color='rgb(130,130,145)'>[ Choose option ]</font>"
            Title.RichText = true
            Title.TextColor3 = Color3.fromRGB(240, 240, 245)
            Title.TextSize = 13
            Title.Font = Enum.Font.GothamSemibold
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = DropFrame

            local Container = Instance.new("ScrollingFrame")
            Container.Size = UDim2.new(1, -20, 0, math.min(#options * 32, 130))
            Container.Position = UDim2.new(0, 10, 0, 46)
            Container.BackgroundTransparency = 1
            Container.BorderSizePixel = 0
            Container.CanvasSize = UDim2.new(0, 0, 0, #options * 32)
            Container.ScrollBarThickness = 2
            Container.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
            Container.Parent = DropFrame

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 4)
            ListLayout.Parent = Container

            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, -4, 0, 28)
                OptBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 42)
                OptBtn.Text = "   " .. opt
                OptBtn.TextColor3 = Color3.fromRGB(185, 185, 200)
                OptBtn.TextSize = 12
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.Parent = Container
                Instance.new("UICorner", OptBtn).CornerRadius = UDim.new(0, 4)

                OptBtn.MouseButton1Click:Connect(function()
                    expanded = false
                    DropFrame:TweenSize(UDim2.new(1, -6, 0, 46), "Out", "Quint", 0.2, true)
                    Title.Text = name .. " :  <font color='rgb(59,130,246)'>" .. opt .. "</font>"
                    task.spawn(callback, opt)
                end)
            end

            DropButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                local targetHeight = expanded and (54 + math.min(#options * 32, 130)) or 46
                DropFrame:TweenSize(UDim2.new(1, -6, 0, targetHeight), "Out", "Quint", 0.2, true)
                task.wait(0.22)
                TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 15)
            end)
        end

        function SectionFeatures:CreateSectionLevel(labelText)
            local LevelLabel = Instance.new("TextLabel")
            LevelLabel.Size = UDim2.new(1, -5, 0, 28)
            LevelLabel.BackgroundTransparency = 1
            LevelLabel.Text = "—  " .. string.upper(labelText) .. "  —"
            LevelLabel.TextColor3 = Color3.fromRGB(90, 90, 110)
            LevelLabel.TextSize = 11
            LevelLabel.Font = Enum.Font.GothamBold
            LevelLabel.TextXAlignment = Enum.TextXAlignment.Center
            LevelLabel.Parent = TabPage
        end

        return SectionFeatures
    end

    return WindowFeatures
end

-- NOTIFICATION ENGINE
function MyUiLibrary:Notify(title, text, duration)
    duration = duration or 4
    local NotifGui = CoreGui:FindFirstChild(notificationUniqueId)
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = notificationUniqueId
        pcall(function() NotifGui.Parent = CoreGui end)
    end

    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 265, 0, 72)
    NotifFrame.Position = UDim2.new(1, 300, 1, -85)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifGui
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 6)
    
    local NStroke = Instance.new("UIStroke")
    NStroke.Color = Color3.fromRGB(45, 45, 55)
    NStroke.Parent = NotifFrame

    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 4, 1, 0)
    SideAccent.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = NotifFrame
    Instance.new("UICorner", SideAccent).CornerRadius = UDim.new(0, 6)

    local NotifTitle = Instance.new("TextLabel")
    NotifTitle.Size = UDim2.new(1, -20, 0, 24)
    NotifTitle.Position = UDim2.new(0, 14, 0, 6)
    NotifTitle.BackgroundTransparency = 1
    NotifTitle.Text = title
    NotifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifTitle.TextSize = 13
    NotifTitle.Font = Enum.Font.GothamBold
    NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
    NotifTitle.Parent = NotifFrame

    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, -20, 1, -36)
    NotifText.Position = UDim2.new(0, 14, 0, 28)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = text
    NotifText.TextColor3 = Color3.fromRGB(160, 160, 175)
    NotifText.TextSize = 12
    NotifText.Font = Enum.Font.Gotham
    NotifText.TextXAlignment = Enum.TextXAlignment.Left
    NotifText.TextYAlignment = Enum.TextYAlignment.Top
    NotifText.TextWrapped = true
    NotifText.Parent = NotifFrame

    table.insert(activeNotifications, NotifFrame)

    local function updatePositions()
        for index, frame in ipairs(activeNotifications) do
            local countFromBottom = #activeNotifications - index
            local targetYOffset = -85 - (countFromBottom * 80)
            TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Position = UDim2.new(1, -280, 1, targetYOffset)
            }):Play()
        end
    end

    updatePositions()

    task.delay(duration, function()
        local slideOut = TweenService:Create(NotifFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 300, NotifFrame.Position.X.Scale, NotifFrame.Position.Y.Offset)
        })
        slideOut:Play()
        slideOut.Completed:Wait()

        local foundIndex = table.find(activeNotifications, NotifFrame)
        if foundIndex then table.remove(activeNotifications, foundIndex) end
        NotifFrame:Destroy()
        updatePositions()
    end)
end

return MyUiLibrary
