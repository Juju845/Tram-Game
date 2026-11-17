-- RNV MANNHEIM TRAM SIMULATOR | MAP V2
-- Einmalig in Roblox Studio in der Befehlsleiste ausfuehren.
-- Ersetzt NUR Workspace.RNV_Mannheim_Map durch eine deutlich detailliertere,
-- dauerhaft bearbeitbare Stadtkarte. Andere Workspace-Objekte bleiben erhalten.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local oldMap = Workspace:FindFirstChild("RNV_Mannheim_Map")
if oldMap then
    oldMap:Destroy()
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local rng = Random.new(845)
local function color(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local C = {
    grass = color(92, 125, 77),
    grassDark = color(73, 105, 66),
    asphalt = color(43, 46, 50),
    asphaltSide = color(54, 57, 60),
    concrete = color(164, 162, 151),
    curb = color(194, 190, 177),
    rail = color(142, 148, 151),
    track = color(75, 76, 74),
    metal = color(52, 63, 69),
    glass = color(93, 139, 158),
    windowFrame = color(54, 61, 65),
    yellow = color(244, 190, 45),
    white = color(235, 232, 220),
    red = color(179, 57, 48),
    rnvBlue = color(0, 105, 160),
}

local function part(parent, name, size, pos, material, tint, options)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.Position = pos
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = tint or color(200, 200, 200)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p.CanCollide = not (options and options.noCollision)
    p.CanTouch = false
    p.Parent = parent or map
    if options then
        if options.transparency then p.Transparency = options.transparency end
        if options.reflectance then p.Reflectance = options.reflectance end
        if options.shape then p.Shape = options.shape end
        if options.shadow == false then p.CastShadow = false end
        if options.rotation then p.Orientation = options.rotation end
    end
    return p
end

local function signText(signPart, face, text, background, textColor, fontSize)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Beschriftung"
    gui.Face = face
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 45
    gui.LightInfluence = 0
    gui.Parent = signPart

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = background or color(27, 43, 52)
    label.BackgroundTransparency = 0
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    return gui
end

local function makeBall(parent, name, diameter, pos, tint, material)
    return part(parent, name, Vector3.new(diameter, diameter, diameter), pos,
        material or Enum.Material.Grass, tint, {shape = Enum.PartType.Ball, noCollision = true})
end

-- LICHT UND HIMMEL
Lighting.ClockTime = 15.5
Lighting.Brightness = 2.3
Lighting.GlobalShadows = true
Lighting.Ambient = color(115, 119, 126)
Lighting.OutdoorAmbient = color(145, 150, 158)
Lighting.EnvironmentDiffuseScale = 0.45
Lighting.EnvironmentSpecularScale = 0.35
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
end
atmosphere.Density = 0.22
atmosphere.Offset = 0.15
atmosphere.Color = color(202, 217, 232)
atmosphere.Decay = color(102, 119, 139)
atmosphere.Glare = 0.12
atmosphere.Haze = 1.2

-- STADTGRUND UND PARKFLAECHEN
part(map, "Stadtgebiet_Grund", Vector3.new(720, 2, 720), Vector3.new(0, -1.15, 0),
    Enum.Material.Grass, C.grass)
part(map, "Gruenstreifen_West", Vector3.new(20, 0.18, 590), Vector3.new(-155, 0.02, 0),
    Enum.Material.LeafyGrass, C.grassDark)
part(map, "Gruenstreifen_Ost", Vector3.new(20, 0.18, 590), Vector3.new(155, 0.02, 0),
    Enum.Material.LeafyGrass, C.grassDark)

-- HAUPTALLEE: ASPHALT, BORDSTEINE UND GEHWEGE
part(map, "Hauptstrasse_Asphalt", Vector3.new(70, 0.22, 590), Vector3.new(0, 0.04, 0),
    Enum.Material.Asphalt, C.asphalt)
part(map, "Gehweg_West", Vector3.new(10, 0.38, 590), Vector3.new(-40, 0.22, 0),
    Enum.Material.Concrete, C.concrete)
part(map, "Gehweg_Ost", Vector3.new(10, 0.38, 590), Vector3.new(40, 0.22, 0),
    Enum.Material.Concrete, C.concrete)

for _, side in ipairs({-1, 1}) do
    part(map, "Bordstein", Vector3.new(0.65, 0.48, 590), Vector3.new(side * 35.1, 0.24, 0),
        Enum.Material.Concrete, C.curb)
    part(map, "Radweg", Vector3.new(2.2, 0.08, 570), Vector3.new(side * 43.1, 0.08, 0),
        Enum.Material.Asphalt, color(91, 117, 99))
    for z = -270, 270, 10 do
        part(map, "Gehweg_Fuge", Vector3.new(9.7, 0.025, 0.07),
            Vector3.new(side * 40, 0.425, z), Enum.Material.SmoothPlastic,
            color(135, 135, 128), {noCollision = true})
    end
    for z = -270, 270, 30 do
        part(map, "Radweg_Markierung", Vector3.new(0.12, 0.035, 5),
            Vector3.new(side * 43.1, 0.135, z), Enum.Material.SmoothPlastic, C.white,
            {noCollision = true})
    end
end

-- FAHRBAHNMARKIERUNGEN
for _, x in ipairs({-22, 22}) do
    for z = -275, 265, 18 do
        part(map, "Spurtrennlinie", Vector3.new(0.16, 0.035, 7),
            Vector3.new(x, 0.17, z), Enum.Material.SmoothPlastic, C.white,
            {noCollision = true})
    end
end
for _, x in ipairs({-33, 33}) do
    part(map, "Fahrbahnrandlinie", Vector3.new(0.18, 0.035, 580),
        Vector3.new(x, 0.17, 0), Enum.Material.SmoothPlastic, C.white,
        {noCollision = true})
end
for z = -280, 280, 35 do
    part(map, "Strassenablauf", Vector3.new(1.2, 0.045, 0.35),
        Vector3.new(-34.1, 0.17, z), Enum.Material.Metal, color(67, 72, 75),
        {noCollision = true})
end

-- DREI QUERSTRASSEN UND KREUZUNGEN
for _, z in ipairs({-180, 0, 180}) do
    part(map, "Querstrasse", Vector3.new(620, 0.2, 18), Vector3.new(0, 0.055, z),
        Enum.Material.Asphalt, C.asphaltSide)
    for _, x in ipairs({-300, 300}) do
        part(map, "Querstrasse_Randlinie", Vector3.new(35, 0.035, 0.16),
            Vector3.new(x, 0.17, z), Enum.Material.SmoothPlastic, C.white, {noCollision = true})
    end
    -- Zebrastreifen ueber die Hauptallee
    for stripeZ = -5.5, 5.5, 2.2 do
        part(map, "Zebrastreifen", Vector3.new(58, 0.035, 1.05),
            Vector3.new(0, 0.18, z + stripeZ), Enum.Material.SmoothPlastic, C.white,
            {noCollision = true})
    end
    -- Haltelinien
    for _, side in ipairs({-1, 1}) do
        part(map, "Haltelinie", Vector3.new(28, 0.035, 0.28),
            Vector3.new(side * 20, 0.18, z + side * 12), Enum.Material.SmoothPlastic,
            C.white, {noCollision = true})
    end
end

-- DOPPELTES STRASSENBAHNGLEIS
for trackCenter = -3, 3, 6 do
    part(map, "Gleis_Bett", Vector3.new(3.2, 0.2, 585),
        Vector3.new(trackCenter, 0.19, 0), Enum.Material.Concrete, C.track)
    -- Betonplatten zwischen und neben den Schienen
    for z = -280, 270, 10 do
        part(map, "Gleis_Betonplatte", Vector3.new(2.8, 0.09, 8.8),
            Vector3.new(trackCenter, 0.31, z), Enum.Material.Concrete,
            color(105, 108, 106), {noCollision = true})
    end
    for _, offset in ipairs({-0.72, 0.72}) do
        part(map, "Stahlschiene", Vector3.new(0.22, 0.25, 590),
            Vector3.new(trackCenter + offset, 0.39, 0), Enum.Material.Metal,
            C.rail)
    end
end
-- Kleine Schienenverbinder in regelmaessigen Abstaenden
for z = -275, 275, 24 do
    for _, x in ipairs({-3.72, -2.28, 2.28, 3.72}) do
        part(map, "Schienenverbinder", Vector3.new(0.32, 0.12, 0.28),
            Vector3.new(x, 0.53, z), Enum.Material.Metal, color(83, 88, 92),
            {noCollision = true})
    end
end

-- OBERLEITUNG: MASTEN, AUSLEGER UND ZWEI KONTAKTLEITUNGEN
for z = -260, 260, 40 do
    local x = -10.5
    part(map, "Oberleitungsmast_Fuss", Vector3.new(1.1, 0.5, 1.1),
        Vector3.new(x, 0.48, z), Enum.Material.Metal, color(76, 82, 85))
    part(map, "Oberleitungsmast", Vector3.new(0.38, 13.5, 0.38),
        Vector3.new(x, 7.2, z), Enum.Material.Metal, C.metal)
    part(map, "Oberleitung_Ausleger", Vector3.new(14, 0.2, 0.2),
        Vector3.new(-3.4, 12.6, z), Enum.Material.Metal, C.metal)
    part(map, "Isolator", Vector3.new(0.34, 0.65, 0.34),
        Vector3.new(-3, 12.15, z), Enum.Material.SmoothPlastic, color(190, 195, 184))
end
for _, x in ipairs({-3, 3}) do
    part(map, "Fahrdraht", Vector3.new(0.075, 0.075, 590),
        Vector3.new(x, 12.05, 0), Enum.Material.Metal, color(183, 157, 95),
        {noCollision = true})
end

-- HALTESTELLE: ERHOEHTE INSEL MIT TASTSTREIFEN UND WARTEDACH
local platform = Instance.new("Model")
platform.Name = "Haltestelle_Marktplatz"
platform.Parent = map
part(platform, "Bahnsteig", Vector3.new(6.3, 0.72, 52),
    Vector3.new(8.1, 0.48, -35), Enum.Material.Concrete, color(180, 178, 166))
part(platform, "Bahnsteigkante", Vector3.new(0.22, 0.18, 52),
    Vector3.new(5.0, 0.91, -35), Enum.Material.Concrete, C.yellow)
part(platform, "Blindenleitstreifen", Vector3.new(0.8, 0.06, 48),
    Vector3.new(5.55, 0.88, -35), Enum.Material.SmoothPlastic, C.yellow,
    {noCollision = true})
for z = -58, -12, 2 do
    part(platform, "Tastfeld_Noppen", Vector3.new(0.12, 0.09, 0.12),
        Vector3.new(5.55, 0.96, z), Enum.Material.SmoothPlastic, color(255, 213, 88),
        {shape = Enum.PartType.Ball, noCollision = true})
end
-- Wartehalle aus Glas und Stahl
part(platform, "Wartehalle_Dach", Vector3.new(5.7, 0.35, 14),
    Vector3.new(8.7, 4.55, -35), Enum.Material.Metal, C.metal)
part(platform, "Wartehalle_Dachkante", Vector3.new(5.9, 0.16, 0.25),
    Vector3.new(8.7, 4.32, -42), Enum.Material.Metal, color(0, 110, 165))
for _, z in ipairs({-41, -29}) do
    part(platform, "Wartehalle_Stuetze", Vector3.new(0.2, 4.0, 0.2),
        Vector3.new(10.9, 2.45, z), Enum.Material.Metal, C.metal)
    part(platform, "Wartehalle_Glaswand", Vector3.new(0.12, 3.4, 0.12),
        Vector3.new(6.9, 2.5, z), Enum.Material.Glass, C.glass,
        {transparency = 0.35, noCollision = true})
end
part(platform, "Wartehalle_Rueckglas", Vector3.new(4.0, 3.35, 0.12),
    Vector3.new(8.9, 2.5, -41), Enum.Material.Glass, C.glass,
    {transparency = 0.38, noCollision = true})
part(platform, "Bank_Sitzflaeche", Vector3.new(3.3, 0.22, 0.65),
    Vector3.new(8.8, 1.55, -36), Enum.Material.Wood, color(116, 78, 49))
for _, x in ipairs({7.4, 10.2}) do
    part(platform, "Bank_Fuss", Vector3.new(0.16, 1.1, 0.16),
        Vector3.new(x, 1.0, -36), Enum.Material.Metal, C.metal)
end
local stopSign = part(platform, "Haltestellen_Schild", Vector3.new(0.22, 2.6, 0.22),
    Vector3.new(10.5, 2.0, -25), Enum.Material.Metal, C.metal)
local stopBoard = part(platform, "Haltestellen_Anzeige", Vector3.new(0.22, 1.5, 3.0),
    Vector3.new(10.35, 3.2, -25), Enum.Material.SmoothPlastic, color(24, 43, 53))
signText(stopBoard, Enum.NormalId.Left, "RNV  |  MANNHEIM\nMARKTPLATZ", color(24, 43, 53), color(245, 245, 235), 30)
local shelterInfo = part(platform, "Haltestellen_Fahrplan", Vector3.new(0.16, 2.1, 1.1),
    Vector3.new(6.6, 2.2, -29), Enum.Material.SmoothPlastic, color(26, 42, 49))
signText(shelterInfo, Enum.NormalId.Right, "FAHRPLAN\nLINIE 1  |  5  |  6", color(26, 42, 49), C.white, 24)
local routePole = part(platform, "Haltestellen_Mast", Vector3.new(0.25, 3.7, 0.25),
    Vector3.new(5.8, 2.0, -53), Enum.Material.Metal, C.metal)
local routePanel = part(platform, "Haltestellen_Routenanzeige", Vector3.new(0.2, 1.4, 1.6),
    Vector3.new(5.8, 3.8, -53), Enum.Material.SmoothPlastic, C.rnvBlue)
signText(routePanel, Enum.NormalId.Right, "RNV\nHALT", C.rnvBlue, C.white, 35)
part(platform, "Bahnsteig_Licht", Vector3.new(3.8, 0.08, 0.12),
    Vector3.new(8.8, 4.34, -35), Enum.Material.Neon, color(255, 231, 178),
    {noCollision = true})

-- GEBaeUDE: MANNHEIMER INNENSTADT MIT ALTBAU- UND GESCHAEFTSFASSADEN
local facadeColors = {
    color(211, 194, 164), color(183, 184, 177), color(202, 177, 157),
    color(173, 188, 190), color(220, 210, 187), color(166, 174, 163),
    color(194, 183, 166), color(185, 166, 151)
}
local shopNames = {"CAFÉ", "BÄCKEREI", "MARKT", "APOTHEKE", "BUCHHANDLUNG",
    "BLUMEN", "KIOSK", "EISCAFÉ", "STADTTEIL-LADEN", "RESTAURANT"}

local function createBuilding(side, index, z)
    local model = Instance.new("Model")
    model.Name = "Stadthaus_" .. (side < 0 and "West_" or "Ost_") .. index
    model.Parent = map

    local depth = rng:NextNumber(25, 32)
    local width = rng:NextNumber(37, 46)
    local height = rng:NextInteger(24, 38)
    local centerX = side * 82
    local frontX = side * (82 - depth / 2)
    local facade = facadeColors[(index + (side < 0 and 0 or 3) - 1) % #facadeColors + 1]

    part(model, "Gebaeude_Korpus", Vector3.new(depth, height, width),
        Vector3.new(centerX, height / 2, z), Enum.Material.Concrete, facade)
    part(model, "Sockelzone", Vector3.new(depth + 0.35, 1.2, width + 0.3),
        Vector3.new(centerX, 0.7, z), Enum.Material.Concrete, color(119, 119, 111))
    part(model, "Dachabschluss", Vector3.new(depth + 1.0, 0.7, width + 1.0),
        Vector3.new(centerX, height + 0.28, z), Enum.Material.Concrete, color(91, 95, 97))
    part(model, "Dachflaeche", Vector3.new(depth - 1, 0.25, width - 1),
        Vector3.new(centerX, height + 0.68, z), Enum.Material.Slate, color(69, 73, 76))

    -- Ecklisenen und horizontale Gesimse
    for _, zOffset in ipairs({-width / 2 + 0.7, width / 2 - 0.7}) do
        part(model, "Fassaden_Lisene", Vector3.new(0.45, height - 1.5, 0.55),
            Vector3.new(frontX - side * 0.18, height / 2 + 0.5, z + zOffset),
            Enum.Material.Concrete, color(226, 216, 195))
    end
    for floor = 1, math.floor((height - 5) / 5) do
        part(model, "Fassaden_Gesims", Vector3.new(0.34, 0.18, width - 1.5),
            Vector3.new(frontX - side * 0.2, 3.6 + floor * 5, z),
            Enum.Material.Concrete, color(226, 216, 195))
    end

    -- Erdgeschoss mit Schaufenstern und Ladentuer
    for column = 1, 3 do
        local wz = z + (column - 2) * (width / 3)
        local pane = part(model, "Schaufenster", Vector3.new(0.16, 3.7, 7.2),
            Vector3.new(frontX - side * 0.17, 2.55, wz), Enum.Material.Glass, C.glass,
            {transparency = 0.18, reflectance = 0.08, noCollision = true})
        part(model, "Schaufenster_Sims", Vector3.new(0.35, 0.2, 7.45),
            Vector3.new(frontX - side * 0.24, 0.62, wz), Enum.Material.Concrete,
            color(227, 219, 202))
        part(model, "Schaufenster_Sturz", Vector3.new(0.32, 0.22, 7.45),
            Vector3.new(frontX - side * 0.24, 4.47, wz), Enum.Material.Concrete,
            color(227, 219, 202))
    end
    local door = part(model, "Ladeneingang", Vector3.new(0.18, 3.9, 2.0),
        Vector3.new(frontX - side * 0.22, 2.0, z), Enum.Material.Glass,
        color(48, 73, 82), {transparency = 0.08, noCollision = true})
    part(model, "Ladentuer_Griff", Vector3.new(0.08, 0.8, 0.08),
        Vector3.new(frontX - side * 0.34, 2.0, z - 0.65), Enum.Material.Metal,
        color(205, 198, 177), {noCollision = true})

    local sign = part(model, "Ladenschild", Vector3.new(0.22, 1.55, 11),
        Vector3.new(frontX - side * 0.3, 5.55, z), Enum.Material.SmoothPlastic,
        index % 2 == 0 and C.rnvBlue or color(70, 91, 78))
    local face = side < 0 and Enum.NormalId.Right or Enum.NormalId.Left
    signText(sign, face, shopNames[(index + (side < 0 and 0 or 4) - 1) % #shopNames + 1],
        sign.Color, C.white, 32)

    -- Markisen ueber den Schaufenstern
    local awningColor = index % 2 == 0 and color(170, 65, 52) or color(48, 112, 143)
    part(model, "Markise", Vector3.new(1.15, 0.18, width - 4),
        Vector3.new(frontX - side * 0.65, 4.85, z), Enum.Material.Fabric, awningColor)

    -- Obere Stockwerke mit Fenstern und Fensterbaenken
    local floors = math.floor((height - 7) / 5)
    for floor = 1, floors do
        local y = 5.8 + floor * 5
        for column = 1, 3 do
            local wz = z + (column - 2) * (width / 3)
            part(model, "Fensterglas", Vector3.new(0.16, 3.0, 3.7),
                Vector3.new(frontX - side * 0.18, y, wz), Enum.Material.Glass, C.glass,
                {transparency = 0.2, reflectance = 0.06, noCollision = true})
            part(model, "Fensterbank", Vector3.new(0.36, 0.18, 4.05),
                Vector3.new(frontX - side * 0.28, y - 1.62, wz), Enum.Material.Concrete,
                color(225, 216, 197))
            part(model, "Fenstersturz", Vector3.new(0.28, 0.18, 4.05),
                Vector3.new(frontX - side * 0.26, y + 1.62, wz), Enum.Material.Concrete,
                color(225, 216, 197))
        end
    end

    -- Dachaufbauten und Lueftung
    for _, offset in ipairs({-width / 4, width / 4}) do
        part(model, "Dachaufbau", Vector3.new(3.2, 1.2, 3.0),
            Vector3.new(centerX, height + 1.35, z + offset), Enum.Material.Metal,
            color(105, 110, 111))
    end
    return model
end

local buildingZ = {-235, -105, 105, 235}
for sideIndex, side in ipairs({-1, 1}) do
    for i, z in ipairs(buildingZ) do
        createBuilding(side, i, z)
    end
end

-- BAeUME, BAeNKE UND STRASSENBELEUCHTUNG
local function createTree(x, z, scale)
    local model = Instance.new("Model")
    model.Name = "Strassenbaum"
    model.Parent = map
    local trunkHeight = 4.8 * scale
    part(model, "Baumstamm", Vector3.new(0.75 * scale, trunkHeight, 0.75 * scale),
        Vector3.new(x, 0.5 + trunkHeight / 2, z), Enum.Material.Wood, color(101, 73, 48))
    makeBall(model, "Baumkrone_Mitte", 5.8 * scale,
        Vector3.new(x, trunkHeight + 3.0 * scale, z), color(66, 117, 67))
    makeBall(model, "Baumkrone_Links", 4.2 * scale,
        Vector3.new(x - 1.7 * scale, trunkHeight + 2.7 * scale, z + 0.9 * scale),
        color(76, 130, 73))
    makeBall(model, "Baumkrone_Rechts", 4.1 * scale,
        Vector3.new(x + 1.6 * scale, trunkHeight + 3.4 * scale, z - 0.9 * scale),
        color(57, 108, 63))
end

for _, side in ipairs({-1, 1}) do
    for z = -260, 260, 32 do
        createTree(side * 47, z, rng:NextNumber(0.85, 1.15))
    end
    -- Sitzbaenke auf den verbreiterten Gehwegen
    for z = -220, 220, 110 do
        local bench = Instance.new("Model")
        bench.Name = "Strassenbank"
        bench.Parent = map
        part(bench, "Sitzflaeche", Vector3.new(1.1, 0.22, 3.2),
            Vector3.new(side * 39.5, 1.0, z), Enum.Material.Wood, color(118, 79, 50))
        part(bench, "Rueckenlehne", Vector3.new(0.2, 1.0, 3.2),
            Vector3.new(side * 39.0, 1.5, z), Enum.Material.Wood, color(118, 79, 50))
        for _, dz in ipairs({-1.1, 1.1}) do
            part(bench, "Bankfuss", Vector3.new(0.18, 0.9, 0.18),
                Vector3.new(side * 39.5, 0.5, z + dz), Enum.Material.Metal, C.metal)
        end
    end
end

local function createStreetLight(side, z)
    local model = Instance.new("Model")
    model.Name = "Strassenlaterne"
    model.Parent = map
    local x = side * 37.5
    part(model, "Laternenmast", Vector3.new(0.28, 8.5, 0.28),
        Vector3.new(x, 4.7, z), Enum.Material.Metal, C.metal)
    part(model, "Laternenarm", Vector3.new(2.2, 0.18, 0.18),
        Vector3.new(x - side * 0.9, 8.8, z), Enum.Material.Metal, C.metal)
    local head = part(model, "Leuchtenkopf", Vector3.new(1.3, 0.25, 0.65),
        Vector3.new(x - side * 1.7, 8.72, z), Enum.Material.Metal, color(55, 62, 65))
    part(model, "Leuchtflaeche", Vector3.new(1.05, 0.07, 0.48),
        Vector3.new(x - side * 1.7, 8.56, z), Enum.Material.Neon, color(255, 236, 190),
        {noCollision = true})
    local light = Instance.new("PointLight")
    light.Color = color(255, 226, 180)
    light.Brightness = 1.1
    light.Range = 22
    light.Enabled = true
    light.Parent = head
end

for _, side in ipairs({-1, 1}) do
    for z = -250, 250, 55 do
        createStreetLight(side, z)
    end
end

-- VERKEHRSSIGNALE AN DEN KREUZUNGEN
for _, z in ipairs({-180, 0, 180}) do
    for _, side in ipairs({-1, 1}) do
        local x = side * 31
        local pole = part(map, "Ampelmast", Vector3.new(0.28, 4.6, 0.28),
            Vector3.new(x, 2.55, z + side * 13), Enum.Material.Metal, C.metal)
        local housing = part(map, "Ampel_Gehaeuse", Vector3.new(0.65, 1.9, 0.65),
            Vector3.new(x, 4.8, z + side * 13), Enum.Material.Metal, color(35, 39, 42))
        for i, tint in ipairs({color(220, 55, 48), color(239, 183, 48), color(60, 183, 92)}) do
            makeBall(map, "Ampel_Licht", 0.38,
                Vector3.new(x, 5.45 - (i - 1) * 0.62, z + side * 13),
                tint, Enum.Material.Neon)
        end
    end
end

-- KLEINE STADTTEIL-PLaTZE HINTER DEN HaeUSERN
for _, side in ipairs({-1, 1}) do
    for _, z in ipairs({-165, 165}) do
        local plaza = Instance.new("Model")
        plaza.Name = "Stadtteilplatz"
        plaza.Parent = map
        part(plaza, "Platzflaeche", Vector3.new(30, 0.16, 34),
            Vector3.new(side * 125, 0.06, z), Enum.Material.Cobblestone, color(148, 145, 133))
        part(plaza, "Pflanzbeet", Vector3.new(7, 0.55, 7),
            Vector3.new(side * 125, 0.36, z), Enum.Material.Ground, color(91, 111, 71))
        createTree(side * 125, z, 0.9)
        local seat = part(plaza, "Platzbank", Vector3.new(3.4, 0.25, 0.75),
            Vector3.new(side * 116, 0.8, z + 8), Enum.Material.Wood, color(120, 82, 53))
        part(plaza, "Platzbank_Fuss", Vector3.new(0.18, 0.7, 0.18),
            Vector3.new(side * 117, 0.45, z + 8), Enum.Material.Metal, C.metal)
        part(plaza, "Platzbank_Fuss", Vector3.new(0.18, 0.7, 0.18),
            Vector3.new(side * 115, 0.45, z + 8), Enum.Material.Metal, C.metal)
    end
end

-- PARKPLAETZE IN EINER SEITENSTRASSE ALS STADTRAUM-DETAIL
for _, side in ipairs({-1, 1}) do
    for z = -125, 125, 50 do
        part(map, "Parkbucht", Vector3.new(2.7, 0.04, 9),
            Vector3.new(side * 28.5, 0.17, z), Enum.Material.Asphalt, color(62, 65, 66),
            {noCollision = true})
        part(map, "Parkbucht_Markierung", Vector3.new(0.12, 0.035, 9),
            Vector3.new(side * 30.0, 0.2, z), Enum.Material.SmoothPlastic, C.white,
            {noCollision = true})
    end
end

print("[RNV Mannheim] MAP V2 fertig: Strassen, Doppelgleis, Haltestelle, Oberleitung, Geschaeftshaeuser, Baeume, Plaetze und Beleuchtung wurden erstellt.")
print("[RNV Mannheim] Alle Kartenobjekte sind in Workspace > RNV_Mannheim_Map einzeln bearbeitbar.")