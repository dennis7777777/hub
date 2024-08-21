-- Create a LocalScript in StarterScripts or StarterPlayerScripts
local player = game.Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "MyUI"

-- Create a frame and other UI elements
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.Parent = gui

-- Create a close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 20)
closeButton.Position = UDim2.new(1, -60, 0, 10)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSans
closeButton.FontSize = Enum.FontSize.Size14
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.BackgroundColor3 = Color3.new(0, 0, 0)
closeButton.BorderSizePixel = 2
closeButton.BorderColor3 = Color3.new(1, 1, 1)
closeButton.Parent = frame

-- Create a function to close the UI when the close button is clicked
local function onCloseButtonClick()
    gui:Destroy()
end

closeButton.MouseButton1Click:Connect(onCloseButtonClick)

-- Parent the gui to the player's PlayerGui
gui.Parent = player.PlayerGui
