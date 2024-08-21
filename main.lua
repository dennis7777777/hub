-- Create a frame to hold the UI
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 200) -- adjust the size to fit your needs
frame.Position = UDim2.new(0, 10, 0, 10) -- adjust the position to fit your needs
frame.BackgroundColor3 = Color3.new(1, 1, 1) -- white background
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(0, 0, 0) -- black border

-- Create a close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 50, 0, 20)
closeButton.Position = UDim2.new(1, -60, 0, 10) -- position at top-right corner
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSans
closeButton.FontSize = Enum.FontSize.Size14
closeButton.TextColor3 = Color3.new(1, 1, 1) -- white text
closeButton.BackgroundColor3 = Color3.new(0, 0, 0) -- black background
closeButton.BorderSizePixel = 2
closeButton.BorderColor3 = Color3.new(1, 1, 1) -- white border

-- Create a function to close the UI when the close button is clicked
local function onCloseButtonClick()
    frame:Destroy()
end

closeButton.MouseButton1Click:Connect(onCloseButtonClick)

-- Parent the close button to the frame
closeButton.Parent = frame

-- Parent the frame to the screen
frame.Parent = game.StarterGui
