-- sorry if it's bunyuns

local function getService(serviceName)
    return cloneref(game:GetService(serviceName))
end

local Players = getService("Players")
local RunService = getService("RunService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local triggerBot = {
    Settings = {
        Enabled = false,
        Radius = 20,
        TargetPart = "Head"
    },

    Connection = nil,
    CurrentTarget = nil
}

local function getMousePosition()
    local mouse = LocalPlayer:GetMouse()
    return Vector2.new(mouse.X, mouse.Y)
end

local function getTargetPart(character, partName)
    return character:FindFirstChild(partName)
        or character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
end

local function getPlayerUnderMouse()
    local mousePos = getMousePosition()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = getTargetPart(
                player.Character,
                triggerBot.Settings.TargetPart
            )

            if part then
                local screenPos, visible =
                    Camera:WorldToViewportPoint(part.Position)

                if visible then
                    local distance = (
                        Vector2.new(screenPos.X, screenPos.Y) - mousePos
                    ).Magnitude

                    if distance <= triggerBot.Settings.Radius
                        and distance < closestDistance then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end

    return closestPlayer
end

function triggerBot:Start(callback)
    if self.Connection then
        return
    end

    self.Settings.Enabled = true

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Settings.Enabled then
            return
        end

        local target = getPlayerUnderMouse()

        if target then
            self.CurrentTarget = target

            if callback then
                callback(target)
            end
        elseif not target then
            self.CurrentTarget = nil
        end
    end)
end

function triggerBot:Stop()
    self.Settings.Enabled = false
    self.CurrentTarget = nil

    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
end

return triggerBot
