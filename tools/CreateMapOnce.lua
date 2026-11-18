-- RNV MANNHEIM TRAM SIMULATOR | MAP V10
-- Neue organische Stadtkarte mit geschwungener Doppelgleisstrecke,
-- ausgebauten Haltestellen, Betriebshof-Spawn und markierten Bauflächen.
-- Einmalig in Roblox Studio Command Bar ausfuehren (nicht im Play-Modus).
-- Alle Weltobjekte sind normale, einzeln editierbare Studio-Parts.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local oldMap = Workspace:FindFirstChild("RNV_Mannheim_Map")
if oldMap then oldMap:Destroy() end

local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then baseplate:Destroy() end

for _, object in ipairs(Workspace:GetDescendants()) do
    if object:IsA("SpawnLocation") then
        object:Destroy()
    end
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local function rgb(r, g, b)
    return Color3.fromRGB(r, g, b)
end

local C = {
    ground = rgb(91, 119, 82),
    grass = rgb(77, 128, 73),
    grassLight = rgb(103, 145, 87),
    asphalt = rgb(43, 48, 53),
    pavement = rgb(177, 176, 168),
    curb = rgb(211, 207, 192),
    concrete = rgb(133, 139, 139),
    trackbed = rgb(69, 75, 78),
    sleeper = rgb(119, 126, 126),
    rail = rgb(187, 198, 203),
    railDark = rgb(69, 79, 84),
    steel = rgb(48, 61, 70),
    copper = rgb(191, 160, 105),
    glass = rgb(113, 176, 194),
    blue = rgb(0, 91, 151),
    white = rgb(242, 240, 229),
    yellow = rgb(239, 191, 75),
    wood = rgb(117, 82, 56),
    red = rgb(164, 55, 48),
    green = rgb(48, 115, 66),
    water = rgb(54, 125, 151)
}

local function folder(name, parent)
    local object = Instance.new("Folder")
    object.Name = name
    object.Parent = parent or map
    return object
end

local function model(name, parent)
    local object = Instance.new("Model")
    object.Name = name
    object.Parent = parent or map
    return object
end

local function makePart(parent, name, size, cf, material, color, canCollide, transparency)
    local object = Instance.new("Part")
    object.Name = name
    object.Size = size
    object.CFrame = typeof(cf) == "CFrame" and cf or CFrame.new(cf)
    object.Anchored = true
    object.Material = material or Enum.Material.SmoothPlastic
    object.Color = color or C.white
    object.TopSurface = Enum.SurfaceType.Smooth
    object.BottomSurface = Enum.SurfaceType.Smooth
    object.CastShadow = true
    object.CanTouch = false
    if canCollide ~= nil then object.CanCollide = canCollide end
    if transparency ~= nil then object.Transparency = transparency end
    object.Parent = parent or map
    return object
end

local function makeBall(parent, name, size, position, material, color)
    local object = makePart(parent, name, size, CFrame.new(position), material, color, false)
    object.Shape = Enum.PartType.Ball
    return object
end

local function makeBillboard(adornee, text, background, width, height)
    local gui = Instance.new("BillboardGui")
    gui.Name = "Beschriftung"
    gui.Adornee = adornee
    gui.Size = UDim2.fromOffset(width or 210, height or 54)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
    gui.Parent = adornee

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = background or C.blue
    label.BackgroundTransparency = 0.05
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = C.white
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
    return gui
end

local function verticalPart(parent, name, size, position, material, color, collide)
    return makePart(parent, name, size, CFrame.new(position), material, color, collide)
end

-- Beleuchtung: klares Tageslicht, ohne ueberstrahlte Effekte.
Lighting.ClockTime = 14.4
Lighting.Brightness = 2.1
Lighting.GlobalShadows = true
Lighting.ShadowSoftness = 0.32
Lighting.Ambient = rgb(113, 121, 127)
Lighting.OutdoorAmbient = rgb(157, 166, 174)
Lighting.EnvironmentDiffuseScale = 0.65
Lighting.EnvironmentSpecularScale = 0.48

for _, effectName in ipairs({"RNV_Atmosphere", "RNV_Color", "RNV_Bloom", "RNV_Sun"}) do
    local effect = Lighting:FindFirstChild(effectName)
    if effect then effect:Destroy() end
end

local atmosphere = Instance.new("Atmosphere")
atmosphere.Name = "RNV_Atmosphere"
atmosphere.Density = 0.22
atmosphere.Offset = 0.1
atmosphere.Color = rgb(199, 217, 231)
atmosphere.Decay = rgb(112, 127, 143)
atmosphere.Haze = 0.8
atmosphere.Glare = 0.08
atmosphere.Parent = Lighting

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Name = "RNV_Color"
colorCorrection.Brightness = 0.015
colorCorrection.Contrast = 0.08
colorCorrection.Saturation = 0.06
colorCorrection.TintColor = rgb(255, 250, 241)
colorCorrection.Parent = Lighting

-- Grundflaeche ohne sichtbare quadratische Rasterfelder.
makePart(map, "Stadtgrund", Vector3.new(2700, 2, 2700), Vector3.new(0, -1.05, 0),
    Enum.Material.Grass, C.ground, true)

-- Catmull-Rom erzeugt weiche Kurven zwischen den gesetzten Streckenpunkten.
local function catmullRom(p0, p1, p2, p3, t)
    local t2 = t * t
    local t3 = t2 * t
    return (p1 * 2
        + (p2 - p0) * t
        + (p0 * 2 - p1 * 5 + p2 * 4 - p3) * t2
        + (-p0 + p1 * 3 - p2 * 3 + p3) * t3) * 0.5
end

local function smoothPath(nodes, stepsPerSpan)
    local points = {}
    for index = 1, #nodes - 1 do
        local p0 = nodes[math.max(1, index - 1)]
        local p1 = nodes[index]
        local p2 = nodes[index + 1]
        local p3 = nodes[math.min(#nodes, index + 2)]
        for step = 0, stepsPerSpan - 1 do
            local t = step / stepsPerSpan
            points[#points + 1] = catmullRom(p0, p1, p2, p3, t)
        end
    end
    points[#points + 1] = nodes[#nodes]
    return points
end

local function pathBasis(points, index)
    local previous = points[math.max(1, index - 1)]
    local following = points[math.min(#points, index + 1)]
    local direction = following - previous
    if direction.Magnitude < 0.001 then
        direction = Vector3.new(0, 0, -1)
    end
    local tangent = direction.Unit
    local normal = Vector3.new(-tangent.Z, 0, tangent.X)
    return tangent, normal
end

local function offsetPath(points, offset)
    local result = {}
    for index, point in ipairs(points) do
        local _, normal = pathBasis(points, index)
        result[index] = point + normal * offset
    end
    return result
end

local function orientedFrame(position, tangent, y)
    local origin = Vector3.new(position.X, y, position.Z)
    return CFrame.lookAt(origin, origin + tangent, Vector3.yAxis)
end

local function makeSegment(parent, name, width, height, a, b, centerY, material, color, collide)
    local delta = b - a
    local flatDelta = Vector3.new(delta.X, 0, delta.Z)
    if flatDelta.Magnitude < 0.05 then return nil end
    local midpoint = (a + b) * 0.5
    local position = Vector3.new(midpoint.X, centerY, midpoint.Z)
    local frame = CFrame.lookAt(position, position + flatDelta.Unit, Vector3.yAxis)
    return makePart(parent, name, Vector3.new(width, height, flatDelta.Magnitude + 0.45),
        frame, material, color, collide)
end

local function pathLength(points)
    local length = 0
    for index = 1, #points - 1 do
        length += (points[index + 1] - points[index]).Magnitude
    end
    return length
end

local function pointAtDistance(points, distance)
    local remaining = math.max(0, distance)
    for index = 1, #points - 1 do
        local a = points[index]
        local b = points[index + 1]
        local segmentLength = (b - a).Magnitude
        if remaining <= segmentLength or index == #points - 1 then
            local alpha = segmentLength > 0 and math.clamp(remaining / segmentLength, 0, 1) or 0
            local position = a:Lerp(b, alpha)
            local direction = b - a
            if direction.Magnitude < 0.001 then direction = Vector3.new(0, 0, -1) end
            local tangent = direction.Unit
            local normal = Vector3.new(-tangent.Z, 0, tangent.X)
            return position, tangent, normal
        end
        remaining -= segmentLength
    end
    local tangent, normal = pathBasis(points, #points)
    return points[#points], tangent, normal
end

local function pointAtFraction(points, fraction)
    return pointAtDistance(points, pathLength(points) * math.clamp(fraction, 0, 1))
end

-- Zentrale Strasse: gekruemmt, mit Gehwegen, Bordsteinen und Markierungen.
local roadsFolder = folder("Strassen")
local function buildRoad(points, width, name, withLights)
    local road = model(name, roadsFolder)
    local leftCurb = offsetPath(points, -(width / 2 + 0.8))
    local rightCurb = offsetPath(points, width / 2 + 0.8)
    local leftWalk = offsetPath(points, -(width / 2 + 5.5))
    local rightWalk = offsetPath(points, width / 2 + 5.5)

    for index = 1, #points - 1 do
        makeSegment(road, "Fahrbahn", width, 0.28, points[index], points[index + 1],
            0.04, Enum.Material.Asphalt, C.asphalt, true)
        makeSegment(road, "Bordstein_links", 1.1, 0.32, leftCurb[index], leftCurb[index + 1],
            0.19, Enum.Material.Concrete, C.curb, true)
        makeSegment(road, "Bordstein_rechts", 1.1, 0.32, rightCurb[index], rightCurb[index + 1],
            0.19, Enum.Material.Concrete, C.curb, true)
        makeSegment(road, "Gehweg_links", 8.4, 0.22, leftWalk[index], leftWalk[index + 1],
            0.12, Enum.Material.Concrete, C.pavement, true)
        makeSegment(road, "Gehweg_rechts", 8.4, 0.22, rightWalk[index], rightWalk[index + 1],
            0.12, Enum.Material.Concrete, C.pavement, true)

        if index % 4 == 0 then
            local _, normalA = pathBasis(points, index)
            local _, normalB = pathBasis(points, index + 1)
            for _, side in ipairs({-1, 1}) do
                local a = points[index] + normalA * (side * 18)
                local b = points[index + 1] + normalB * (side * 18)
                makeSegment(road, "Fahrbahnmarkierung", 0.22, 0.035, a, b,
                    0.205, Enum.Material.SmoothPlastic, C.white, false)
            end
        end

        if withLights and index % 10 == 0 then
            local position = points[index]
            local _, normal = pathBasis(points, index)
            local side = (math.floor(index / 10) % 2 == 0) and 1 or -1
            local lampPosition = position + normal * side * (width / 2 + 4.5)
            local lamp = model("Strassenlaterne", road)
            verticalPart(lamp, "Laternenmast", Vector3.new(0.45, 10.5, 0.45),
                Vector3.new(lampPosition.X, 5.25, lampPosition.Z), Enum.Material.Metal, C.steel)
            local head = verticalPart(lamp, "Leuchtenkopf", Vector3.new(2.6, 0.45, 0.8),
                Vector3.new(lampPosition.X, 10.5, lampPosition.Z), Enum.Material.Metal, C.white)
            local light = Instance.new("PointLight")
            light.Color = rgb(255, 232, 190)
            light.Brightness = 0.35
            light.Range = 16
            light.Parent = head
        end
    end
    return road
end

-- Die neue Hauptstrecke ist eine lange S-/Bogenfuehrung statt eines Schienenkreuzes.
local routeNodes = {
    Vector3.new(-930, 0, -690),
    Vector3.new(-770, 0, -520),
    Vector3.new(-570, 0, -390),
    Vector3.new(-330, 0, -320),
    Vector3.new(-80, 0, -340),
    Vector3.new(180, 0, -300),
    Vector3.new(390, 0, -170),
    Vector3.new(540, 0, 40),
    Vector3.new(590, 0, 300),
    Vector3.new(520, 0, 550),
    Vector3.new(320, 0, 740),
    Vector3.new(60, 0, 820),
    Vector3.new(-220, 0, 780),
    Vector3.new(-450, 0, 620),
    Vector3.new(-590, 0, 390),
    Vector3.new(-630, 0, 140)
}
local route = smoothPath(routeNodes, 12)

-- Drei weitere Strassen folgen eigenen weichen Linien und bilden keine Quadrate.
local roadA = smoothPath({
    Vector3.new(-1080, 0, -180),
    Vector3.new(-850, 0, -40),
    Vector3.new(-600, 0, 110),
    Vector3.new(-330, 0, 190),
    Vector3.new(-40, 0, 245),
    Vector3.new(260, 0, 350),
    Vector3.new(560, 0, 540),
    Vector3.new(880, 0, 760)
}, 10)

local roadB = smoothPath({
    Vector3.new(-850, 0, -1030),
    Vector3.new(-560, 0, -930),
    Vector3.new(-250, 0, -900),
    Vector3.new(80, 0, -840),
    Vector3.new(390, 0, -700),
    Vector3.new(690, 0, -510),
    Vector3.new(920, 0, -260),
    Vector3.new(1090, 0, 0)
}, 10)

local roadC = smoothPath({
    Vector3.new(-1080, 0, 470),
    Vector3.new(-830, 0, 560),
    Vector3.new(-590, 0, 690),
    Vector3.new(-330, 0, 790),
    Vector3.new(-30, 0, 850),
    Vector3.new(280, 0, 930),
    Vector3.new(590, 0, 1040),
    Vector3.new(900, 0, 1160)
}, 10)

buildRoad(route, 62, "Hauptstrasse_mit_Strassenbahn", true)
buildRoad(roadA, 27, "Verbindungsstrasse_West_Ost", false)
buildRoad(roadB, 25, "Suedliche_Stadtstrasse", false)
buildRoad(roadC, 25, "Nordbogen_Stadtstrasse", false)

-- Gekruemmter Fluss am noerdlichen Kartenrand.
local riverPath = smoothPath({
    Vector3.new(-1180, 0, 1180),
    Vector3.new(-850, 0, 1260),
    Vector3.new(-480, 0, 1280),
    Vector3.new(-100, 0, 1230),
    Vector3.new(300, 0, 1110),
    Vector3.new(690, 0, 930),
    Vector3.new(1120, 0, 710)
}, 12)
local riverFolder = model("Neckar_Uferbereich")
local leftBank = offsetPath(riverPath, -51)
local rightBank = offsetPath(riverPath, 51)
for index = 1, #riverPath - 1 do
    makeSegment(riverFolder, "Neckar_Wasser", 100, 0.35, riverPath[index], riverPath[index + 1],
        0.02, Enum.Material.Glass, C.water, false)
    makeSegment(riverFolder, "Uferweg_links", 5, 0.36, leftBank[index], leftBank[index + 1],
        0.12, Enum.Material.Concrete, C.curb, true)
    makeSegment(riverFolder, "Uferweg_rechts", 5, 0.36, rightBank[index], rightBank[index + 1],
        0.12, Enum.Material.Concrete, C.curb, true)
end

-- Doppelgleis: getrennte Gleisbetten, Schwellen und sichtbare Schienenprofile.
local trackFolder = model("Zweigleisige_Tramstrecke")
local trackCenters = {-2.75, 2.75}
local routeMeters = pathLength(route)

for trackIndex, laneOffset in ipairs(trackCenters) do
    local lane = model(trackIndex == 1 and "Gleis_Richtung_A" or "Gleis_Richtung_B", trackFolder)
    local lanePath = offsetPath(route, laneOffset)

    for index = 1, #lanePath - 1 do
        makeSegment(lane, "Gleisunterbau", 5.15, 0.36, lanePath[index], lanePath[index + 1],
            0.32, Enum.Material.Concrete, C.trackbed, true)
    end

    -- Betonschwellen in gleichmaessigem Abstand entlang der Kurven.
    for distance = 0, routeMeters, 10.5 do
        local position, tangent, normal = pointAtDistance(route, distance)
        position = position + normal * laneOffset
        local frame = orientedFrame(position, tangent, 0.57)
        makePart(lane, "Betonschwelle", Vector3.new(5.0, 0.20, 1.25), frame,
            Enum.Material.Concrete, C.sleeper, true)
    end

    -- Je Schiene ein dunkler Fuss/Steg und ein heller, breiter Schienenkopf.
    for _, gauge in ipairs({-0.76, 0.76}) do
        local railPath = offsetPath(route, laneOffset + gauge)
        for index = 1, #railPath - 1 do
            makeSegment(lane, "Schienenfuss_und_Steg", 0.34, 0.48,
                railPath[index], railPath[index + 1], 0.82,
                Enum.Material.Metal, C.railDark, false)
            makeSegment(lane, "Polierter_Schienenkopf", 0.57, 0.17,
                railPath[index], railPath[index + 1], 1.105,
                Enum.Material.Metal, C.rail, false)
        end
    end
end

-- Oberleitung: staerkere Masten, Quertragwerke, Isolatoren, Tragseile und Fahrdraehte.
local overhead = model("Oberleitung")
for index = 6, #route - 5, 7 do
    local position = route[index]
    local tangent, normal = pathBasis(route, index)
    local left = position - normal * 14
    local right = position + normal * 14

    for _, mastPosition in ipairs({left, right}) do
        makePart(overhead, "Mastfundament", Vector3.new(2.2, 0.65, 2.2),
            CFrame.new(mastPosition.X, 0.32, mastPosition.Z),
            Enum.Material.Concrete, C.concrete, true)
        makePart(overhead, "Oberleitungsmast", Vector3.new(0.78, 18.2, 0.78),
            CFrame.new(mastPosition.X, 9.35, mastPosition.Z),
            Enum.Material.Metal, C.steel, true)
        makePart(overhead, "Mastkopf", Vector3.new(1.15, 0.55, 1.15),
            CFrame.new(mastPosition.X, 18.55, mastPosition.Z),
            Enum.Material.Metal, C.railDark, false)
    end

    makeSegment(overhead, "Quertragwerk", 0.5, 0.48, left, right,
        17.6, Enum.Material.Metal, C.steel, false)

    for _, laneOffset in ipairs(trackCenters) do
        local wirePosition = position + normal * laneOffset
        makePart(overhead, "Keramikisolator", Vector3.new(0.7, 0.55, 0.7),
            CFrame.new(wirePosition.X, 17.05, wirePosition.Z),
            Enum.Material.SmoothPlastic, rgb(218, 213, 190), false)
    end
end

for _, laneOffset in ipairs(trackCenters) do
    local wirePath = offsetPath(route, laneOffset)
    for index = 1, #wirePath - 1 do
        makeSegment(overhead, "Kupferfahrdraht", 0.16, 0.16,
            wirePath[index], wirePath[index + 1], 15.55,
            Enum.Material.Metal, C.copper, false)
        makeSegment(overhead, "Tragseil", 0.13, 0.13,
            wirePath[index], wirePath[index + 1], 17.0,
            Enum.Material.Metal, rgb(157, 165, 165), false)
    end

    for index = 4, #wirePath - 4, 5 do
        local position = wirePath[index]
        makePart(overhead, "Fahrdraht_Haenger", Vector3.new(0.09, 1.35, 0.09),
            CFrame.new(position.X, 16.28, position.Z),
            Enum.Material.Metal, C.copper, false)
    end
end

-- Grosse Haltestellen mit zwei getrennten Bahnsteigen und vollstaendiger Ausstattung.
local stationsFolder = model("Haltestellen")
local function orientedPart(parent, name, size, position, tangent, y, material, color, collide, transparency)
    return makePart(parent, name, size, orientedFrame(position, tangent, y),
        material, color, collide, transparency)
end

local function makeStation(name, fraction)
    local center, tangent, normal = pointAtFraction(route, fraction)
    local stop = model("Haltestelle_" .. name, stationsFolder)

    for _, side in ipairs({-1, 1}) do
        local platformCenter = center + normal * side * 10.6
        local platform = model(side < 0 and "Bahnsteig_Richtung_A" or "Bahnsteig_Richtung_B", stop)

        orientedPart(platform, "Bahnsteigplatte", Vector3.new(9.4, 1.08, 150),
            platformCenter, tangent, 0.61, Enum.Material.Concrete, rgb(181, 181, 174), true)

        local innerEdge = platformCenter - normal * side * 4.45
        orientedPart(platform, "Bahnsteigkante", Vector3.new(0.42, 0.22, 142),
            innerEdge, tangent, 1.18, Enum.Material.Concrete, C.yellow, true)
        orientedPart(platform, "Taktiler_Streifen", Vector3.new(1.05, 0.09, 136),
            platformCenter - normal * side * 3.65, tangent, 1.2,
            Enum.Material.Concrete, rgb(226, 193, 121), false)
        orientedPart(platform, "Sicherheitslinie", Vector3.new(0.16, 0.045, 136),
            platformCenter - normal * side * 2.55, tangent, 1.18,
            Enum.Material.SmoothPlastic, C.white, false)

        -- Lange Wartehalle mit Stahlrahmen, Glas und grossem Dach.
        local shelterCenter = platformCenter + normal * side * 0.55 + tangent * -13
        orientedPart(platform, "Wartehalle_Dach", Vector3.new(8.0, 0.48, 31),
            shelterCenter, tangent, 6.2, Enum.Material.Metal, C.steel, true)
        orientedPart(platform, "Wartehalle_Dachkante", Vector3.new(8.3, 0.18, 31.3),
            shelterCenter, tangent, 5.94, Enum.Material.Metal, C.railDark, false)

        for _, across in ipairs({-3.65, 3.65}) do
            for _, along in ipairs({-14, 14}) do
                local postPosition = shelterCenter + normal * across + tangent * along
                verticalPart(platform, "Wartehalle_Stuetzpfosten",
                    Vector3.new(0.28, 5.1, 0.28),
                    Vector3.new(postPosition.X, 3.5, postPosition.Z),
                    Enum.Material.Metal, C.steel)
            end
        end

        for _, across in ipairs({-3.45, 3.45}) do
            orientedPart(platform, "Wartehalle_Glaswand", Vector3.new(0.14, 4.1, 27),
                shelterCenter + normal * across, tangent, 3.45,
                Enum.Material.Glass, C.glass, false, 0.18)
        end
        for _, along in ipairs({-13.6, 13.6}) do
            orientedPart(platform, "Wartehalle_Glaswand_Stirnseite", Vector3.new(6.8, 4.1, 0.14),
                shelterCenter + tangent * along, tangent, 3.45,
                Enum.Material.Glass, C.glass, false, 0.18)
        end

        orientedPart(platform, "Sitzbank_Sitz", Vector3.new(4.8, 0.32, 1.0),
            shelterCenter + tangent * -2, tangent, 1.65, Enum.Material.Wood, C.wood, true)
        orientedPart(platform, "Sitzbank_Lehne", Vector3.new(4.8, 1.05, 0.22),
            shelterCenter + tangent * -2 - normal * 0.45, tangent, 2.25,
            Enum.Material.Wood, C.wood, true)

        -- Fahrkartenautomat und digitale Abfahrtsanzeige.
        local machinePosition = platformCenter + normal * side * 2.6 + tangent * 34
        verticalPart(platform, "Fahrkartenautomat", Vector3.new(1.1, 2.8, 0.9),
            Vector3.new(machinePosition.X, 1.85, machinePosition.Z),
            Enum.Material.Metal, C.steel)
        local displayPosition = platformCenter + normal * side * 2.6 + tangent * 20
        local display = verticalPart(platform, "LED_Abfahrtsanzeige",
            Vector3.new(0.65, 3.0, 3.8),
            Vector3.new(displayPosition.X, 3.0, displayPosition.Z),
            Enum.Material.Metal, C.steel)
        makeBillboard(display, "RNV  |  ABFAHRT", C.blue, 170, 44)

        -- Haltestellenmast mit eigenem, gut lesbarem Schild.
        local signPosition = platformCenter + normal * side * 3.0 + tangent * 59
        verticalPart(platform, "Haltestellenmast", Vector3.new(0.35, 5.8, 0.35),
            Vector3.new(signPosition.X, 2.9, signPosition.Z),
            Enum.Material.Metal, C.steel)
        local signBoard = verticalPart(platform, "Haltestellenschild",
            Vector3.new(0.55, 2.4, 2.4),
            Vector3.new(signPosition.X, 6.4, signPosition.Z),
            Enum.Material.SmoothPlastic, C.blue)
        makeBillboard(signBoard, name, C.blue, 190, 48)

        local binPosition = platformCenter + normal * side * 3.0 + tangent * -57
        verticalPart(platform, "Abfallbehaelter", Vector3.new(1.0, 1.6, 1.0),
            Vector3.new(binPosition.X, 0.9, binPosition.Z),
            Enum.Material.Metal, C.steel)
    end
end

makeStation("Betriebshof", 0.055)
makeStation("Neckarstadt", 0.24)
makeStation("Paradeplatz", 0.43)
makeStation("Wasserturm", 0.63)
makeStation("Oststadt", 0.81)
makeStation("Feudenheim", 0.96)

-- Betriebshof mit Werkstatthalle, Vorplatz, Toren und festem Spieler-Spawn.
local depot = model("Betriebshof")
makePart(depot, "Betriebshof_Vorplatz", Vector3.new(270, 0.28, 205),
    CFrame.new(-1000, 0.12, -760), Enum.Material.Asphalt, C.asphalt, true)

-- Werkstatthalle: offene Einfahrt mit seitlichen Waenden und Dach.
makePart(depot, "Werkstatthalle_Rueckwand", Vector3.new(112, 28, 3),
    CFrame.new(-1110, 14, -815), Enum.Material.Concrete, rgb(166, 174, 176), true)
makePart(depot, "Werkstatthalle_Seitenwand_L", Vector3.new(3, 28, 92),
    CFrame.new(-1164, 14, -770), Enum.Material.Concrete, rgb(166, 174, 176), true)
makePart(depot, "Werkstatthalle_Seitenwand_R", Vector3.new(3, 28, 92),
    CFrame.new(-1056, 14, -770), Enum.Material.Concrete, rgb(166, 174, 176), true)
makePart(depot, "Werkstatthalle_Dach", Vector3.new(120, 3, 102),
    CFrame.new(-1110, 29.5, -770), Enum.Material.Metal, rgb(62, 75, 82), true)

for _, x in ipairs({-1140, -1080}) do
    makePart(depot, "Torpfosten", Vector3.new(2.2, 25, 2.2),
        CFrame.new(x, 12.5, -724), Enum.Material.Metal, C.steel, true)
end
makePart(depot, "Torsturz", Vector3.new(64, 2.5, 2.2),
    CFrame.new(-1110, 25, -724), Enum.Material.Metal, C.steel, true)

for _, x in ipairs({-1150, -1110, -1070}) do
    makePart(depot, "Werkstattfenster", Vector3.new(1.0, 5, 15),
        CFrame.new(x, 17, -817), Enum.Material.Glass, C.glass, false, 0.15)
end

local depotSign = verticalPart(depot, "Betriebshof_Schild",
    Vector3.new(1, 5, 25), Vector3.new(-1110, 32, -721),
    Enum.Material.SmoothPlastic, C.blue, false)
makeBillboard(depotSign, "RNV BETRIEBSHOF", C.blue, 260, 60)

-- Der Spawn liegt sichtbar auf dem Betriebshof-Vorplatz, nicht auf einem Dach.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpielerSpawn_Betriebshof"
spawn.Size = Vector3.new(9, 1, 9)
spawn.CFrame = CFrame.new(-980, 0.78, -820)
spawn.Anchored = true
spawn.Neutral = true
spawn.AllowTeamChangeOnTouch = false
spawn.Duration = 0
spawn.Material = Enum.Material.Neon
spawn.Color = rgb(54, 153, 118)
spawn.Transparency = 0.18
spawn.CanCollide = true
spawn.Parent = depot
makeBillboard(spawn, "START  |  BETRIEBSHOF", rgb(33, 111, 82), 240, 54)

-- Markierte, freie Baugrundstuecke. Hier kannst du spaeter selbst Haeuser einsetzen.
local plotsFolder = model("Bauflaechen_Hier_Haeuser_Platzieren")
local function makePlot(plotNumber, x, z, width, depth, rotation)
    local plot = model(string.format("Bauflaeche_%02d", plotNumber), plotsFolder)
    plot:SetAttribute("Buildable", true)
    plot:SetAttribute("PlotNumber", plotNumber)

    local baseFrame = CFrame.new(x, 0.11, z) * CFrame.Angles(0, math.rad(rotation), 0)
    makePart(plot, "Freie_Bauflaeche", Vector3.new(width, 0.18, depth),
        baseFrame, Enum.Material.Grass, C.grassLight, true)

    local borderColor = rgb(232, 187, 70)
    local borderY = 0.28
    makePart(plot, "Markierung_vorne", Vector3.new(width, 0.28, 1.0),
        baseFrame * CFrame.new(0, borderY, -depth / 2), Enum.Material.Neon, borderColor, false)
    makePart(plot, "Markierung_hinten", Vector3.new(width, 0.28, 1.0),
        baseFrame * CFrame.new(0, borderY, depth / 2), Enum.Material.Neon, borderColor, false)
    makePart(plot, "Markierung_links", Vector3.new(1.0, 0.28, depth),
        baseFrame * CFrame.new(-width / 2, borderY, 0), Enum.Material.Neon, borderColor, false)
    makePart(plot, "Markierung_rechts", Vector3.new(1.0, 0.28, depth),
        baseFrame * CFrame.new(width / 2, borderY, 0), Enum.Material.Neon, borderColor, false)

    local signFrame = baseFrame * CFrame.new(width / 2 - 5, 3.2, -depth / 2 + 5)
    makePart(plot, "Bauflaechen_Schild", Vector3.new(1.0, 6.0, 1.0),
        signFrame, Enum.Material.Metal, C.steel, true)
    local sign = makePart(plot, "Bauflaechen_Beschriftung", Vector3.new(0.7, 2.5, 9),
        signFrame * CFrame.new(0, 3.4, 0), Enum.Material.SmoothPlastic, C.blue, false)
    makeBillboard(sign, string.format("BAUFLAECHE %02d  |  HIER BAUEN", plotNumber),
        C.blue, 250, 48)
end

local plotData = {
    {-1070, 170, 78, 62, -18},
    {-850, 330, 82, 66, 14},
    {-350, 400, 86, 68, -12},
    {10, 100, 82, 66, 18},
    {340, 500, 84, 70, -15},
    {880, 350, 88, 72, 22},
    {1080, -680, 84, 68, -16},
    {960, -1050, 82, 68, 12},
    {430, -1090, 88, 72, -20},
    {-20, -1070, 84, 70, 17},
    {-1220, -300, 86, 72, -24},
    {-1120, 760, 82, 66, 13},
    {-500, 1040, 86, 70, -18},
    {1110, 390, 82, 68, 20}
}
for index, values in ipairs(plotData) do
    makePlot(index, values[1], values[2], values[3], values[4], values[5])
end

-- Ein markanter Mannheimer Orientierungspunkt: Wasserturm in einer Parkanlage.
local park = model("Friedrichsplatz_Wasserturm")
makePart(park, "Parkflaeche", Vector3.new(230, 0.18, 210),
    CFrame.new(930, 0.08, 70), Enum.Material.Grass, C.grass, false)

local fountain = makePart(park, "Brunnenbecken", Vector3.new(94, 2.5, 94),
    CFrame.new(930, 1.25, 70) * CFrame.Angles(0, 0, math.rad(90)),
    Enum.Material.Concrete, rgb(205, 203, 190), true)
fountain.Shape = Enum.PartType.Cylinder

local water = makePart(park, "Brunnenwasser", Vector3.new(78, 1.0, 78),
    CFrame.new(930, 2.35, 70) * CFrame.Angles(0, 0, math.rad(90)),
    Enum.Material.Glass, C.water, false, 0.18)
water.Shape = Enum.PartType.Cylinder

local towerBase = makePart(park, "Wasserturm_Sockel", Vector3.new(34, 29, 29),
    CFrame.new(930, 16, 70) * CFrame.Angles(0, 0, math.rad(90)),
    Enum.Material.Sandstone, rgb(193, 156, 112), true)
towerBase.Shape = Enum.PartType.Cylinder

local tower = makePart(park, "Wasserturm_Schaft", Vector3.new(58, 21, 21),
    CFrame.new(930, 58, 70) * CFrame.Angles(0, 0, math.rad(90)),
    Enum.Material.Sandstone, rgb(211, 177, 134), true)
tower.Shape = Enum.PartType.Cylinder

local towerRoof = makePart(park, "Wasserturm_Dach", Vector3.new(18, 30, 30),
    CFrame.new(930, 96, 70) * CFrame.Angles(0, 0, math.rad(90)),
    Enum.Material.Slate, rgb(65, 83, 82), true)
towerRoof.Shape = Enum.PartType.Cylinder
makeBillboard(tower, "WASSERTURM", C.blue, 190, 50)

-- Baeume als lockere Gruppen, nicht als starres Raster.
local function makeTree(x, z, scale)
    local tree = model("Stadtbaum")
    verticalPart(tree, "Stamm", Vector3.new(1.5 * scale, 7 * scale, 1.5 * scale),
        Vector3.new(x, 3.5 * scale, z), Enum.Material.Wood, C.wood)
    makeBall(tree, "Baumkrone", Vector3.new(8 * scale, 9 * scale, 8 * scale),
        Vector3.new(x, 9 * scale, z), Enum.Material.Grass, C.green)
end

for _, position in ipairs({
    {-960, 110}, {-870, 250}, {-640, 400}, {-300, 430},
    {40, 500}, {280, 540}, {720, 120}, {850, -30},
    {1040, 30}, {1060, 90}, {840, 170}, {680, 760},
    {380, 1110}, {-80, 1160}, {-520, 1080}, {-900, 880}
}) do
    makeTree(position[1], position[2], 1.0)
end

print("[RNV MAP V10] Neue geschwungene Mannheim-Karte wurde erstellt.")
print("[RNV MAP V10] Doppelgleis, Kurven, groessere Haltestellen und verbesserte Oberleitung angelegt.")
print("[RNV MAP V10] Spieler-Spawn liegt auf dem Betriebshof-Vorplatz.")
print("[RNV MAP V10] 14 nummerierte, freie Bauflaechen sind im Workspace editierbar.")
print("[RNV MAP V10] Fertig. Im Explorer liegt alles unter Workspace > RNV_Mannheim_Map.")
