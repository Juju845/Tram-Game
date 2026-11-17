local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local oldMap = Workspace:FindFirstChild("RNV_Mannheim_Map")
if oldMap then
    oldMap:Destroy()
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local function makePart(name, size, position, material, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.Material = material
    part.Color = color
    part.TopSurface = Enum.SurfaceType.Smooth
    part.BottomSurface = Enum.SurfaceType.Smooth
    part.Parent = parent or map
    return part
end

-- Use the existing baseplate as the city ground when available.
local ground = Workspace:FindFirstChild("Boden") or Workspace:FindFirstChild("Baseplate")
if ground and ground:IsA("BasePart") then
    ground.Name = "Mannheim_Boden"
    ground.Size = Config.Map.GroundSize
    ground.Position = Vector3.new(0, -0.5, 0)
    ground.Material = Enum.Material.Asphalt
    ground.Color = Color3.fromRGB(65, 67, 70)
else
    makePart(
        "Mannheim_Boden",
        Config.Map.GroundSize,
        Vector3.new(0, -0.5, 0),
        Enum.Material.Asphalt,
        Color3.fromRGB(65, 67, 70)
    )
end

-- Main street running along the Z axis.
makePart(
    "Strasse",
    Vector3.new(Config.Map.RoadWidth, 0.12, Config.Map.RoadLength),
    Vector3.new(0, 0.08, 0),
    Enum.Material.Asphalt,
    Color3.fromRGB(42, 44, 47)
)

-- Road markings.
for z = -108, 108, 18 do
    makePart(
        "Fahrbahnmarkierung",
        Vector3.new(0.22, 0.035, 7),
        Vector3.new(15, 0.17, z),
        Enum.Material.SmoothPlastic,
        Color3.fromRGB(235, 230, 210)
    )
end

-- Two rails with a standard-gauge-inspired spacing.
local halfGauge = Config.Map.TrackGauge / 2
for _, x in ipairs({-halfGauge, halfGauge}) do
    makePart(
        x < 0 and "Schiene_Links" or "Schiene_Rechts",
        Vector3.new(0.38, 0.42, Config.Map.TrackLength),
        Vector3.new(x, 0.35, 0),
        Enum.Material.Metal,
        Color3.fromRGB(115, 120, 126)
    )
end

-- Sleepers under the rails.
for z = -108, 108, 5 do
    makePart(
        "Schwelle",
        Vector3.new(4.2, 0.18, 0.8),
        Vector3.new(0, 0.13, z),
        Enum.Material.Wood,
        Color3.fromRGB(76, 62, 48)
    )
end

-- Simple raised stop platform on the right side of the track.
makePart(
    "Haltestellen_Plattform",
    Vector3.new(7, 0.65, 42),
    Vector3.new(8, 0.32, -12),
    Enum.Material.Concrete,
    Color3.fromRGB(155, 155, 148)
)

makePart(
    "Leitstreifen",
    Vector3.new(0.45, 0.04, 38),
    Vector3.new(5.0, 0.67, -12),
    Enum.Material.SmoothPlastic,
    Color3.fromRGB(230, 190, 45)
)

-- A simple stop shelter placeholder.
makePart(
    "Haltestellen_Dach",
    Vector3.new(6, 0.35, 10),
    Vector3.new(8, 4.2, -12),
    Enum.Material.Metal,
    Color3.fromRGB(55, 65, 72)
)
for _, z in ipairs({-16, -8}) do
    makePart(
        "Haltestellen_Pfosten",
        Vector3.new(0.22, 4, 0.22),
        Vector3.new(8, 2.1, z),
        Enum.Material.Metal,
        Color3.fromRGB(55, 65, 72)
    )
end

-- Placeholder city blocks, kept away from the road and track.
for _, side in ipairs({-1, 1}) do
    for index, z in ipairs({-82, -28, 34, 88}) do
        local height = 18 + (index % 3) * 7
        local width = 22 + (index % 2) * 5
        makePart(
            "Gebaeude_Block",
            Vector3.new(width, height, 30),
            Vector3.new(side * 58, height / 2, z),
            Enum.Material.Concrete,
            side < 0 and Color3.fromRGB(174, 166, 151) or Color3.fromRGB(154, 164, 170)
        )
    end
end

-- Overhead-line poles; wires and detailed equipment will be added later.
for z = -96, 96, 32 do
    for _, x in ipairs({-7, 7}) do
        makePart(
            "Oberleitungsmast",
            Vector3.new(0.35, 13, 0.35),
            Vector3.new(x, 6.5, z),
            Enum.Material.Metal,
            Color3.fromRGB(75, 80, 85)
        )
    end
end

print("[RNV Mannheim] Grundkarte wurde erstellt. Naechster Schritt: M8C-Fahrzeug und Steuerung.")
