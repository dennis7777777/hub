local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "My_first_hub",
   LoadingTitle = "Streetz war 2 hub",
   LoadingSubtitle = "by Hamburgstatus",
   ConfigurationSaving = {
      Enabled = false,
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
      Title = "My_first_hub Key system",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "My_first_key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"dev24","key22"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})

local MainTab = Window:CreateTab("Home", nil) -- Title, Image
local MainSection = MaimTab:CreateSection("Main")

Rayfield:Notify({
   Title = "You executed the script",
   Content = "very good gui",
   Duration = 5,
   Image = nil,
   Actions = { -- Notification Buttons
      Ignore = {
         Name = "Okay!",
         Callback = function()
         print("The user tapped Okay!")
      end
   },
},

local Button = MainTab:CreateButton({
   Name = "Card Farm",
   Callback = function()
        "local playerGui = game:GetService(\"Players\").LocalPlayer.PlayerGui\r\nlocal DalerGui = playerGui:FindFirstChild(\"DealerGui\")\r\nlocal Shop = DalerGui and DalerGui:FindFirstChild(\"ShopFrame\")\r\nlocal Card = Shop:FindFirstChild(\"Blank Card\")\r\nlocal top = Shop:FindFirstChild(\"laptop\")\r\nlocal VirtualInputManager = game:GetService(\"VirtualInputManager\")\r\nlocal wallet = game:GetService(\"Players\").LocalPlayer.leaderstats.Wallet.Value\r\nlocal estimatedamount = math.round((wallet - 6000) / 3000)\r\nprint(\"\\n will run ~\"..estimatedamount..\" times,\\n costing ~$\".. (estimatedamount*3000)+2000 .. \",\\n final wallet ~$\"..(500*estimatedamount)+wallet..\",\\n Profiting ~$\"..((500*estimatedamount)+wallet)-((estimatedamount*3000)+2000)..\"\\n will take ~\"..(estimatedamount*0.2)..\" seconds\")\r\nif (650*estimatedamount)+wallet > 1000000 then\r\n\terror(\"ESTIMATED FINAL AMOUNT EXEEDED SAFETY THRESHHOLD OF 1 MIL, PLEASE DUPE LESS MONEY\")\r\n\treturn\r\nend\r\nif wallet \u003C 7000 then\r\n\terror(\"NOT ENOUGH MONEY, MUST HAVE 7K OR MORE\")\r\nreturn\r\nend\r\n\r\nfor i=1,estimatedamount do\r\nwarn(\"doing \"..i..\"/\"..estimatedamount)\r\ntask.wait(.1)\r\n--mousemoveabs(Card.AbsolutePosition.X, Card.AbsolutePosition.Y)\r\n--mousemoveabs(Card.AbsolutePosition.X + 150, Card.AbsolutePosition.Y + 65)\r\nVirtualInputManager:SendMouseButtonEvent(Card.AbsolutePosition.X + 150, Card.AbsolutePosition.Y + 65, 0, true, game, 1)\r\ntask.wait()\r\nVirtualInputManager:SendMouseButtonEvent(Card.AbsolutePosition.X + 150, Card.AbsolutePosition.Y + 65, 0, false, game, 1)\r\n\r\n--mousemoveabs(top.AbsolutePosition.X, top.AbsolutePosition.Y)\r\n--mousemoveabs(top.AbsolutePosition.X + 150, top.AbsolutePosition.Y + 65)\r\nrepeat\r\nVirtualInputManager:SendMouseButtonEvent(top.AbsolutePosition.X + 150, top.AbsolutePosition.Y + 65, 0, true, game, 1)\r\ntask.wait()\r\nVirtualInputManager:SendMouseButtonEvent(top.AbsolutePosition.X + 150, top.AbsolutePosition.Y + 65, 0, false, game, 1)\r\nuntil game.Players.LocalPlayer.Backpack:FindFirstChild(\"Laptop\")\r\ntask.spawn(function()\r\nlocal args = {\r\n    [1] = true,\r\n    [2] = \"NEW123\"\r\n}\r\n\r\ngame:GetService(\"ReplicatedStorage\").Assets.Other.GiverPunchmade:InvokeServer(unpack(args))\r\n\r\nlocal args = {\r\n    [1] = false,\r\n    [2] = \"NEW123\"\r\n}\r\n\r\ngame:GetService(\"ReplicatedStorage\").Assets.Other.GiverPunchmade:InvokeServer(unpack(args))\r\nend)\r\n\r\n\r\nend\r\ntask.wait(1)\r\nprint(\"done buffering cards\")\r\n\r\n\r\nrepeat \r\nVirtualInputManager:SendMouseButtonEvent(top.AbsolutePosition.X + 150, top.AbsolutePosition.Y + 65, 0, true, game, 1)\r\ntask.wait()\r\nVirtualInputManager:SendMouseButtonEvent(top.AbsolutePosition.X + 150, top.AbsolutePosition.Y + 65, 0, false, game, 1)\r\nuntil game.Players.LocalPlayer.Backpack:FindFirstChild(\"Laptop\")\r\n--task.wait(1)\r\n--game.Players.LocalPlayer.Character.Humanoid:EquipTool(game.Players.LocalPlayer.Backpack.Laptop) -- doesnt work with celery for now, not supported.\r\nrepeat\r\ntask.spawn(function()\r\n    \r\n\r\nwarn(\"still loading cards\")\r\nlocal args = {\r\n    [1] = false,\r\n    [2] = \"NEW123\"\r\n}\r\n\r\ngame:GetService(\"ReplicatedStorage\").Assets.Other.GiverPunchmade:InvokeServer(unpack(args))\r\nend)\r\ntask.wait()\r\n\r\nuntil not game.Players.LocalPlayer:FindFirstChild(\"Loaded Card\")\r\nprint(\"done\")"
   end,
})
