-- Webhook Code
local webhookUrl = "https://discord.com/api/webhooks/1144659993199644704/80Ng36wkIImqIdYUtAjpF0GfVJF6SHJ8J-zAlBwZxPr-l6p1d5DQ9OEVkHr7mSImyeK4"
local playerName = game.Players.LocalPlayer.Name

local data = {
    ["content"] = "Player executed the script: " .. playerName
}

local headers = {
    ["Content-Type"] = "application/json"
}

local postData = game:GetService("HttpService"):JSONEncode(data)

local request = syn and syn.request or http_request or request or HttpPost
if request then
    request({
        Url = webhookUrl,
        Method = "POST",
        Headers = headers,
        Body = postData
    })
else
    warn("HTTP request function not found.")
end

-- The rest of your original script
local Debug = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Remotes = ReplicatedStorage:WaitForChild("Remotes", 9e9)
local Balls = workspace:WaitForChild("Balls", 9e9)

-- Create the visual cube in the Workspace
local cube = Instance.new("Part")
cube.Size = Vector3.new(10, 10, 10)
cube.Anchored = true
cube.CanCollide = false
cube.BrickColor = BrickColor.new("Bright red") -- Start with red
cube.Transparency = 0.5
cube.Parent = workspace -- Parent to Workspace

-- Functions
local function print(...)
    if Debug then
        warn(...)
    end
end

local function VerifyBall(Ball)
    if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:IsDescendantOf(Balls) and Ball:GetAttribute("realBall") == true then
        return true
    end
end

local function IsTarget()
    return (Player.Character and Player.Character:FindFirstChild("Highlight"))
end

local function Parry()
    Remotes:WaitForChild("ParryButtonPress"):Fire()
end

-- Update the cube's position in real-time
RunService.RenderStepped:Connect(function()
    if Player.Character then
        cube.CFrame = CFrame.new(Player.Character.HumanoidRootPart.Position) -- Update cube position to character's root part
    end
end)

-- The actual code
local isBallComing = false -- Track if the ball is coming

Balls.ChildAdded:Connect(function(Ball)
    if not VerifyBall(Ball) then
        return
    end

    print("Ball Spawned:", Ball.Name)

    local OldPosition = Ball.Position
    local OldTick = tick()

    Ball:GetPropertyChangedSignal("Position"):Connect(function()
        if IsTarget() then
            local Distance = (Ball.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            local Velocity = (OldPosition - Ball.Position).Magnitude

            print("Distance:", Distance)
            print("Velocity:", Velocity)
            print("Time:", Distance / Velocity)

            if (Distance / Velocity) <= 10 then
                Parry()

                -- Change the cube's color to green when the ball is coming
                cube.BrickColor = BrickColor.new("Bright green")
                isBallComing = true

                wait(1)

                -- Change the cube's color back to red
                cube.BrickColor = BrickColor.new("Bright red")
                isBallComing = false
            end
        end

        if (tick() - OldTick >= 1/60) then
            OldTick = tick()
            OldPosition = Ball.Position
        end
    end)
end)
