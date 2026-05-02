local function getService(serviceName)
    return cloneref(game:GetService(serviceName))
end

local Players = getService("Players")
local RunService = getService("RunService")
local Teams = getService("Teams")

local LocalPlayer = Players.LocalPlayer

local triggerBot = {
    Settings = {
        Enabled = false,
        TeamCheck = true,
        BlacklistTeam = {}
    },

    Connection = nil,
    CurrentTarget = nil
}

local function isDead(player)
    local Character = player.Character or player.CharacterAdded:Wait()
    if not Character then
        return true
    end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if Humanoid then
        return true
    end

    if Humanoid.Health <= 0 then
        return true
    else
        return false
    end
end

local function teamCheck(player)
    if player.Team == LocalPlayer.Team then
        return true
    end

    if triggerBot.Settings.BlacklistTeam[player.Team] then
        return true
    end

    return false
end

local function getPlayerUnderMouse()
    local mouse = LocalPlayer:GetMouse()
    local unitRay = mouse.UnitRay

    local character = LocalPlayer.Character
    if not character then
        return nil
    end

    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {character}
    rayParams.IgnoreWater = true

    local rayDistance = 1000
    local result = workspace:Raycast(
        unitRay.Origin,
        unitRay.Direction * rayDistance,
        rayParams
    )

    if not result then
        return nil
    end

    local hitPart = result.Instance
    local hitCharacter = hitPart:FindFirstAncestorWhichIsA("Model")

    if not hitCharacter then
        return nil
    end

    local player = Players:GetPlayerFromCharacter(hitCharacter)

    if player and player ~= LocalPlayer then
        if triggerBot.Settings.TeamCheck == true then
            local isTeam = teamCheck(player)
            local isDead = isDead(player)
            if isTeam == true and isDead == false then
                return nil
            end
        end

        return player
    end

    return nil
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

        if target and target ~= LocalPlayer then
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

function triggerBot:Blacklist(team)
    if not team then
        return
    end

    local teamInstance = Teams:FindFirstChild(team)
    if not teamInstance then
        return
    end

    triggerBot.Settings.BlacklistTeam[teamInstance] = true
    return
end

function triggerBot:Unblacklist(team)
    if not team then
        return
    end

    local teamInstance = Teams:FindFirstChild(team)
    if not teamInstance then
        return
    end

    triggerBot.Settings.BlacklistTeam[teamInstance] = nil
    return
end

return triggerBot
