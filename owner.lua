local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Owner Hub",
    LoadingTitle = "Rayfield Interface Suite",
    LoadingSubtitle = "by Sirius",
    ConfigurationSaving = {
       Enabled = true,
       FolderName = nil, -- Create a custom folder for your hub/game
       FileName = "Big Hub"
    },
    Discord = {
       Enabled = false,
       Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ABCD would be ABCD
       RememberJoins = true -- Set this to false to make them join the discord every time they load it up
    },
    KeySystem = true, -- Set this to true to use our key system
    KeySettings = {
       Title = "Key System",
       Subtitle = "Key System",
       Note = "Get key from dev",
       FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
       SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
       GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
       Key = {"dev24"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
    },
    Mobile = {
        Enabled = true, -- Enable mobile support
        Scale = 0.7, -- Scale of the UI (1 is default, 0.5 would be half size)
        Offset = {0, -50} -- Offset of the UI (x, y)
    }
})

-- Mobile-specific settings
Window:SetSize(UDim2.new(0, 300, 0, 400)) -- Set the window size to 300x400 pixels
Window:SetPosition(UDim2.new(0, 0, 0, 0)) -- Set the window position to the top-left corner
Window:SetBackgroundTransparency(0.5) -- Set the background transparency to 50%
