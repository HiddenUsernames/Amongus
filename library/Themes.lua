-- Easy theme file — add new themes by copying a block below and changing Accent (+ optional overrides)
local BASE = {
    Window = Color3.fromRGB(15, 15, 20),
    Header = Color3.fromRGB(22, 22, 28),
    Sidebar = Color3.fromRGB(12, 12, 16),
    Group = Color3.fromRGB(22, 22, 28),
    Row = Color3.fromRGB(28, 28, 36),
    RowHover = Color3.fromRGB(34, 34, 44),
    Stroke = Color3.fromRGB(42, 42, 54),
    AccentOff = Color3.fromRGB(48, 48, 60),
    Title = Color3.fromRGB(245, 245, 250),
    Desc = Color3.fromRGB(120, 120, 140),
    Muted = Color3.fromRGB(150, 150, 170),
    GroupHeader = Color3.fromRGB(200, 200, 215),
    TabSelected = Color3.fromRGB(32, 32, 42),
    TabIdle = Color3.fromRGB(20, 20, 26),
    TabHover = Color3.fromRGB(26, 26, 34),
    InputBg = Color3.fromRGB(20, 20, 28),
    DropBg = Color3.fromRGB(20, 20, 28),
    DropItem = Color3.fromRGB(32, 32, 42),
    DropItemHover = Color3.fromRGB(40, 40, 52),
    RowStroke = Color3.fromRGB(38, 38, 50),
    Track = Color3.fromRGB(50, 50, 62),
}

local function makeTheme(overrides)
    local theme = {}
    for key, value in pairs(BASE) do
        theme[key] = value
    end
    for key, value in pairs(overrides) do
        theme[key] = value
    end
    return theme
end

return {
    Default = makeTheme({
        Accent = Color3.fromRGB(40, 120, 255),
    }),

    ["Navy Blue"] = makeTheme({
        Accent = Color3.fromRGB(56, 100, 220),
        Window = Color3.fromRGB(10, 14, 28),
        Header = Color3.fromRGB(14, 20, 38),
        Sidebar = Color3.fromRGB(8, 12, 24),
        Group = Color3.fromRGB(14, 20, 36),
        Row = Color3.fromRGB(18, 26, 46),
        RowHover = Color3.fromRGB(22, 32, 56),
        Stroke = Color3.fromRGB(30, 45, 80),
        TabSelected = Color3.fromRGB(22, 34, 62),
        TabIdle = Color3.fromRGB(12, 18, 34),
        TabHover = Color3.fromRGB(16, 24, 44),
    }),

    Pink = makeTheme({
        Accent = Color3.fromRGB(236, 72, 153),
        Window = Color3.fromRGB(20, 12, 18),
        Header = Color3.fromRGB(28, 16, 24),
        Sidebar = Color3.fromRGB(16, 10, 14),
        Group = Color3.fromRGB(28, 16, 24),
        Row = Color3.fromRGB(36, 20, 30),
        RowHover = Color3.fromRGB(44, 26, 38),
        Stroke = Color3.fromRGB(70, 35, 55),
        TabSelected = Color3.fromRGB(48, 26, 40),
        TabIdle = Color3.fromRGB(24, 14, 20),
        TabHover = Color3.fromRGB(34, 18, 28),
    }),

    Purple = makeTheme({
        Accent = Color3.fromRGB(168, 85, 247),
        Window = Color3.fromRGB(16, 12, 24),
        Header = Color3.fromRGB(24, 16, 36),
        Sidebar = Color3.fromRGB(12, 8, 20),
        Group = Color3.fromRGB(24, 16, 36),
        Row = Color3.fromRGB(32, 22, 48),
        RowHover = Color3.fromRGB(40, 28, 58),
        Stroke = Color3.fromRGB(55, 40, 80),
        TabSelected = Color3.fromRGB(42, 28, 62),
        TabIdle = Color3.fromRGB(20, 14, 32),
        TabHover = Color3.fromRGB(30, 20, 44),
    }),

    Emerald = makeTheme({
        Accent = Color3.fromRGB(16, 185, 129),
        Window = Color3.fromRGB(10, 18, 16),
        Header = Color3.fromRGB(14, 26, 22),
        Sidebar = Color3.fromRGB(8, 14, 12),
        Group = Color3.fromRGB(14, 26, 22),
        Row = Color3.fromRGB(18, 34, 28),
        RowHover = Color3.fromRGB(22, 42, 34),
        Stroke = Color3.fromRGB(30, 60, 50),
        TabSelected = Color3.fromRGB(20, 40, 32),
        TabIdle = Color3.fromRGB(12, 22, 18),
        TabHover = Color3.fromRGB(16, 30, 24),
    }),

    Crimson = makeTheme({
        Accent = Color3.fromRGB(239, 68, 68),
        Window = Color3.fromRGB(20, 10, 10),
        Header = Color3.fromRGB(30, 14, 14),
        Sidebar = Color3.fromRGB(16, 8, 8),
        Group = Color3.fromRGB(30, 14, 14),
        Row = Color3.fromRGB(40, 18, 18),
        RowHover = Color3.fromRGB(50, 22, 22),
        Stroke = Color3.fromRGB(80, 35, 35),
        TabSelected = Color3.fromRGB(52, 24, 24),
        TabIdle = Color3.fromRGB(26, 12, 12),
        TabHover = Color3.fromRGB(36, 16, 16),
    }),

    Orange = makeTheme({
        Accent = Color3.fromRGB(249, 115, 22),
        Window = Color3.fromRGB(20, 14, 8),
        Header = Color3.fromRGB(30, 20, 12),
        Sidebar = Color3.fromRGB(16, 10, 6),
        Group = Color3.fromRGB(30, 20, 12),
        Row = Color3.fromRGB(40, 26, 14),
        RowHover = Color3.fromRGB(50, 32, 18),
        Stroke = Color3.fromRGB(80, 50, 25),
        TabSelected = Color3.fromRGB(52, 34, 18),
        TabIdle = Color3.fromRGB(26, 16, 8),
        TabHover = Color3.fromRGB(36, 24, 12),
    }),
}
