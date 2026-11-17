-- RNV Mannheim Tram Simulator
-- EINMALIG in Roblox Studio ueber Ansicht > Befehlsleiste ausfuehren.
-- Erstellt echte, dauerhaft bearbeitbare Objekte in Workspace.
-- Nicht als normales ServerScript ausfuehren.

local Workspace = game:GetService("Workspace")

if Workspace:FindFirstChild("RNV_Mannheim_Map") then
    warn("RNV_Mannheim_Map existiert bereits. Es wurde nichts veraendert.")
    return
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local function part(name, size, pos, material, color, parent)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Material = material
    p.Color = color
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or map
    return p
end

local asphalt = Color3.fromRGB(48, 50, 53)
local concrete = Color3.fromRGB(155, 155, 148)
local railColor = Color3.fromRGB(115, 120, 126)
local darkMetal = Color3.fromRGB(58, 67, 73)

-- Stadtgrund und Strassenraum
part("Stadtgrund", Vector3.new(500, 2, 500), Vector3.new(0, -1.5, 0), Enum.Material.Grass, Color3.fromRGB(83, 112, 76))
part("Strasse_Hauptachse", Vector3.new(42, 0.18, 250), Vector3.new(0, 0, 0), Enum.Material.Asphalt, asphalt)
part("Gehweg_Links", Vector3.new(7, 0.28, 250), Vector3.new(-24.5, 0.08, 0), Enum.Material.Concrete, concrete)
part("Gehweg_Rechts", Vector3.new(7, 0.28, 250), Vector3.new(24.5, 0.08, 0), Enum.Material.Concrete, concrete)

-- Fahrbahnmarkierungen
for z = -112, 112, 18 do
    part("Mittellinie", Vector3.new(0.22, 0.035, 7), Vector3.new(14, 0.11, z), Enum.Material.SmoothPlastic, Color3.fromRGB(235, 230, 210))
end
for _, x in ipairs({-18, 18}) do
    part("Fahrbahnrand", Vector3.new(0.18, 0.035, 240), Vector3.new(x, 0.11, 0), Enum.Material.SmoothPlastic, Color3.fromRGB(220, 220, 210))
end

-- Gleis: zwei Schienen, Schwellen und Schotterbett
part("Gleis_Schotterbett", Vector3.new(5.2, 0.22, 230), Vector3.new(-5, 0.16, 0), Enum.Material.Slate, Color3.fromRGB(85, 84, 80))
for _, x in ipairs({-6.2, -3.8}) do
    part(x < -5 and "Schiene_Links" or "Schiene_Rechts", Vector3.new(0.34, 0.42, 230), Vector3.new(x, 0.47, 0), Enum.Material.Metal, railColor)
end
for z = -112, 112, 4 do
    part("Gleisschwelle", Vector3.new(4.3, 0.16, 0.72), Vector3.new(-5, 0.31, z), Enum.Material.Wood, Color3.fromRGB(76, 62, 48))
end

-- Haltestelleninsel mit Leitstreifen und Wartehalle
part("Haltestelle_Plattform", Vector3.new(7.5, 0.7, 46), Vector3.new(3.5, 0.42, -20), Enum.Material.Concrete, concrete)
part("Haltestelle_Leitstreifen", Vector3.new(0.5, 0.06, 42), Vector3.new(-0.2, 0.81, -20), Enum.Material.SmoothPlastic, Color3.fromRGB(238, 190, 45))
part("Wartehalle_Dach", Vector3.new(6.5, 0.3, 12), Vector3.new(4, 4.4, -20), Enum.Material.Metal, darkMetal)
for _, z in ipairs({-25, -15}) do
    part("Wartehalle_Pfosten", Vector3.new(0.22, 4, 0.22), Vector3.new(6.8, 2.4, z), Enum.Material.Metal, darkMetal)
end
part("Haltestelle_Sitzbank", Vector3.new(3.2, 0.25, 0.7), Vector3.new(3.7, 1.35, -23), Enum.Material.Wood, Color3.fromRGB(116, 82, 55))
part("Haltestelle_Anzeiger", Vector3.new(0.35, 3.2, 0.35), Vector3.new(1.1, 2.1, -4), Enum.Material.Metal, darkMetal)
part("Haltestelle_Anzeiger_Feld", Vector3.new(0.18, 1.2, 1.8), Vector3.new(0.85, 3, -4), Enum.Material.SmoothPlastic, Color3.fromRGB(30, 45, 48))

-- Oberleitungsmasten und Querarme
for z = -100, 100, 32 do
    for _, x in ipairs({-12, 2}) do
        part("Oberleitungsmast", Vector3.new(0.32, 13, 0.32), Vector3.new(x, 6.5, z), Enum.Material.Metal, darkMetal)
    end
    part("Oberleitung_Querarm", Vector3.new(14, 0.22, 0.22), Vector3.new(-5, 12.4, z), Enum.Material.Metal, darkMetal)
end
-- Oberleitungsdraht als duenne Parts
part("Oberleitung_Draht", Vector3.new(0.08, 0.08, 230), Vector3.new(-5, 12.1, 0), Enum.Material.Metal, Color3.fromRGB(170, 150, 95))

-- Stadtgebaeude als einzeln bearbeitbare Platzhalter mit Fenstern
local buildingColors = {
    Color3.fromRGB(190, 177, 151),
    Color3.fromRGB(166, 178, 183),
    Color3.fromRGB(202, 195, 177),
    Color3.fromRGB(150, 159, 151)
}
for sideIndex, side in ipairs({-1, 1}) do
    for i, z in ipairs({-88, -35, 30, 88}) do
        local h = 18 + (i % 3) * 5
        local w = 23 + (i % 2) * 5
        local building = Instance.new("Model")
        building.Name = "Gebaeude_" .. sideIndex .. "_" .. i
        building.Parent = map
        local x = side * 61
        part("Baukörper", Vector3.new(w, h, 32), Vector3.new(x, h/2, z), Enum.Material.Concrete, buildingColors[i], building)
        for floor = 1, math.floor((h-4)/5) do
            for window = 1, 3 do
                local wx = x - w/2 + window * w/4
                part("Fenster", Vector3.new(2.2, 2.3, 0.12), Vector3.new(wx, 3 + floor*5, z-16.08), Enum.Material.Glass, Color3.fromRGB(95, 139, 157), building)
            end
        end
    end
end

-- Baeume an den Gehwegen
for z = -105, 105, 30 do
    for _, x in ipairs({-31, 31}) do
        part("Baumstamm", Vector3.new(0.8, 4, 0.8), Vector3.new(x, 2.2, z), Enum.Material.Wood, Color3.fromRGB(95, 68, 45))
        local crown = part("Baumkrone", Vector3.new(5, 5, 5), Vector3.new(x, 6, z), Enum.Material.Grass, Color3.fromRGB(62, 115, 65))
        crown.Shape = Enum.PartType.Ball
    end
end

print("[RNV Mannheim] Die Grundwelt wurde dauerhaft in Workspace erstellt und ist jetzt bearbeitbar.")
