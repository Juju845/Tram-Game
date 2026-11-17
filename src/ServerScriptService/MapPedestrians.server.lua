-- RNV Mannheim map pedestrians
-- Runs in Play mode and moves the editable pedestrian models along the outer sidewalks.

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local function findMap()
    local existing = Workspace:FindFirstChild("RNV_Mannheim_Map")
    if existing then
        return existing
    end
    return Workspace:WaitForChild("RNV_Mannheim_Map", 120)
end

local map = findMap()
if not map then
    warn("[RNV pedestrians] RNV_Mannheim_Map was not found.")
    return
end

local people = map:WaitForChild("Passanten", 30)
if not people then
    warn("[RNV pedestrians] Passanten folder was not found.")
    return
end

local running = {}

local function animatePedestrian(npc)
    if not npc:IsA("Model") or running[npc] then
        return
    end

    local root = npc.PrimaryPart or npc:FindFirstChild("Koerper")
    if not root or not root:IsA("BasePart") then
        return
    end

    npc.PrimaryPart = root
    running[npc] = true

    task.spawn(function()
        local id = tonumber(npc.Name:match("%d+$")) or 1
        local direction = (id % 2 == 0) and 1 or -1

        while npc.Parent == people and map.Parent == Workspace do
            local start = npc:GetPivot()
            local destination = start * CFrame.new(0, 0, direction * 46)

            local value = Instance.new("CFrameValue")
            value.Value = start

            local connection = value:GetPropertyChangedSignal("Value"):Connect(function()
                if npc.Parent then
                    npc:PivotTo(value.Value)
                end
            end)

            local tween = TweenService:Create(
                value,
                TweenInfo.new(18, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                { Value = destination }
            )
            tween:Play()
            tween.Completed:Wait()

            connection:Disconnect()
            value:Destroy()
            direction = -direction
            task.wait(0.6)
        end

        running[npc] = nil
    end)
end

for _, npc in ipairs(people:GetChildren()) do
    animatePedestrian(npc)
end

people.ChildAdded:Connect(animatePedestrian)

print("[RNV pedestrians] Passanten-Bewegung gestartet.")
