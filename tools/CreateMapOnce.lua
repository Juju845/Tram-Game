-- RNV MANNHEIM TRAM SIMULATOR | MAP V11
-- Ausbau: klar getrennte Doppelgleise (4 Schienen), echte Depotanbindung,
-- groessere Betriebshofanlage, zahlreiche Gebaeude und markierte Baugrundstuecke.
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

-- Nahtlose Grundflaeche aus vier gleichfarbigen Teilflaechen.
-- Jede einzelne Part-Groesse bleibt unter dem Roblox-Limit von 2048 Studs.
for _, groundX in ipairs({-675, 675}) do
    for _, groundZ in ipairs({-675, 675}) do
        makePart(map, "Stadtgrund_Flaeche", Vector3.new(1350, 2, 1350),
            Vector3.new(groundX, -1.05, groundZ), Enum.Material.Grass, C.ground, true)
    end
end

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
    Vector3.new(-1220, 0, -820),
    Vector3.new(-1010, 0, -820),
    Vector3.new(-810, 0, -760),
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
-- Zwei getrennte Gleise mit je zwei Schienen: sichtbar vier parallele Schienen.
-- Der groessere Gleismittenabstand schafft Platz fuer zwei entgegenkommende Trams.
local trackCenters = {-4.2, 4.2}
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
        local platformCenter = center + normal * side * 12.5
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

makeStation("Betriebshof", 0.12)
makeStation("Neckarstadt", 0.24)
makeStation("Paradeplatz", 0.43)
makeStation("Wasserturm", 0.63)
makeStation("Oststadt", 0.81)
makeStation("Feudenheim", 0.96)

-- Betriebshof: zwei offene Garagenbuchten, deren Gleise direkt in die Hauptstrecke uebergehen.
-- Streckenstart liegt bei x=-1220, z=-820. Die beiden Depotgleise setzen exakt dort an.
local depot = model("Betriebshof")
local depotTrackGroup = model("Depotgleise_Direktverbindung", depot)

makePart(depot, "Betriebshof_Vorplatz", Vector3.new(330, 0.3, 230),
    CFrame.new(-1320, 0.10, -965), Enum.Material.Asphalt, C.asphalt, true)
makePart(depot, "Hallenboden", Vector3.new(238, 0.35, 78),
    CFrame.new(-1338, 0.16, -820), Enum.Material.Concrete, rgb(112, 119, 121), true)

-- Werkstatthalle mit zwei grossen Einfahrtstoren und seitlichen Werkstattfenstern.
makePart(depot, "Werkstatthalle_Rueckwand", Vector3.new(3, 28, 78),
    CFrame.new(-1456, 14, -820), Enum.Material.Concrete, rgb(160, 169, 172), true)
makePart(depot, "Werkstatthalle_Seitenwand_Nord", Vector3.new(238, 28, 3),
    CFrame.new(-1338, 14, -859), Enum.Material.Concrete, rgb(160, 169, 172), true)
makePart(depot, "Werkstatthalle_Seitenwand_Sued", Vector3.new(238, 28, 3),
    CFrame.new(-1338, 14, -781), Enum.Material.Concrete, rgb(160, 169, 172), true)
makePart(depot, "Werkstatthalle_Dach", Vector3.new(245, 3, 86),
    CFrame.new(-1338, 29.5, -820), Enum.Material.Metal, rgb(58, 72, 80), true)

-- Frontseite: zwei getrennte Tore, genau ueber den beiden Gleismitten.
-- Frontwand mit zwei exakt zu den Schienen ausgerichteten Toroeffnungen.
-- Jedes Tor ist 5 Studs breit; ein massiver Mittelpfosten trennt die Einfahrten.
for _, segment in ipairs({
    {centerZ = -843.0, length = 32.0},
    {centerZ = -820.0, length = 3.0},
    {centerZ = -797.0, length = 32.0}
}) do
    makePart(depot, "Werkstatthalle_Frontwand_Segment",
        Vector3.new(3, 23, segment.length),
        CFrame.new(-1219, 11.5, segment.centerZ),
        Enum.Material.Concrete, rgb(160, 169, 172), true)
end
makePart(depot, "Torsturz", Vector3.new(3, 2.5, 78),
    CFrame.new(-1219, 26, -820), Enum.Material.Metal, C.steel, true)
for _, z in ipairs({-824.2, -815.8}) do
    makePart(depot, "Torrahmen_Sturz", Vector3.new(3.0, 1.0, 6.0),
        CFrame.new(-1219, 23.2, z), Enum.Material.Metal, C.railDark, false)
end

-- Werkstattdetails: Arbeitsgruben-Rand, Werkzeugbereiche, Lichtbaender und Beschilderung.
for _, x in ipairs({-1400, -1340, -1280}) do
    makePart(depot, "Werkstatt_Lichtband", Vector3.new(1.2, 0.25, 54),
        CFrame.new(x, 27.7, -820), Enum.Material.Neon, rgb(231, 236, 224), false)
end
for _, z in ipairs({-844, -796}) do
    makePart(depot, "Werkbank", Vector3.new(30, 3, 5),
        CFrame.new(-1370, 1.7, z), Enum.Material.Metal, C.steel, true)
    for _, x in ipairs({-1417, -1325}) do
        makePart(depot, "Werkzeugschrank", Vector3.new(10, 7, 4),
            CFrame.new(x, 3.5, z), Enum.Material.Metal, rgb(65, 91, 103), true)
    end
end
makePart(depot, "Werkstattgrube_Rahmen_A", Vector3.new(82, 0.3, 1.2),
    CFrame.new(-1340, 0.42, -826), Enum.Material.Metal, C.yellow, false)
makePart(depot, "Werkstattgrube_Rahmen_B", Vector3.new(82, 0.3, 1.2),
    CFrame.new(-1340, 0.42, -814), Enum.Material.Metal, C.yellow, false)

-- Die Depotgleise bestehen aus den gleichen zwei Schienen je Gleis wie die Hauptstrecke.
-- Sie verlaufen aus der Halle heraus bis exakt zum Startpunkt der Hauptstrecke.
local function buildDepotTrack(laneOffset)
    local lane = model(laneOffset < 0 and "Depotgleis_A" or "Depotgleis_B", depotTrackGroup)
    local depotLine = {
        Vector3.new(-1438, 0, -820),
        Vector3.new(-1220, 0, -820)
    }
    local lanePath = offsetPath(depotLine, laneOffset)

    makeSegment(lane, "Gleisunterbau", 5.15, 0.36,
        lanePath[1], lanePath[2], 0.32, Enum.Material.Concrete, C.trackbed, true)

    for distance = 6, 215, 10.5 do
        local point = Vector3.new(-1438 + distance, 0, -820)
        local _, normal = pathBasis(depotLine, 1)
        point += normal * laneOffset
        local frame = CFrame.lookAt(Vector3.new(point.X, 0.57, point.Z),
            Vector3.new(point.X + 1, 0.57, point.Z), Vector3.yAxis)
        makePart(lane, "Betonschwelle", Vector3.new(5.0, 0.20, 1.25),
            frame, Enum.Material.Concrete, C.sleeper, true)
    end

    for _, gauge in ipairs({-0.76, 0.76}) do
        local railLine = offsetPath(depotLine, laneOffset + gauge)
        makeSegment(lane, "Schienenfuss_und_Steg", 0.34, 0.48,
            railLine[1], railLine[2], 0.82, Enum.Material.Metal, C.railDark, false)
        makeSegment(lane, "Polierter_Schienenkopf", 0.57, 0.17,
            railLine[1], railLine[2], 1.105, Enum.Material.Metal, C.rail, false)
    end

    -- Fahrdraht verlaeuft im Hallendach und ohne Unterbrechung durch das Tor.
    makeSegment(depotTrackGroup, "Depot_Kupferfahrdraht",
        0.16, 0.16, lanePath[1], lanePath[2], 15.55, Enum.Material.Metal, C.copper, false)
    makeSegment(depotTrackGroup, "Depot_Tragseil",
        0.13, 0.13, lanePath[1], lanePath[2], 17.0, Enum.Material.Metal, rgb(157, 165, 165), false)
end
buildDepotTrack(-4.2)
buildDepotTrack(4.2)

-- Zufahrt, Verwaltungsgebaeude, Waschhalle, Parkplaetze und gesicherte Einfahrt.
local accessRoad = smoothPath({
    Vector3.new(-1440, 0, -1000),
    Vector3.new(-1330, 0, -1080),
    Vector3.new(-1190, 0, -1100),
    Vector3.new(-1080, 0, -1040)
}, 8)
buildRoad(accessRoad, 22, "Betriebshof_Zufahrt", false)

makePart(depot, "Verwaltungsgebaeude", Vector3.new(64, 18, 34),
    CFrame.new(-1490, 9, -945), Enum.Material.Concrete, rgb(190, 194, 187), true)
makePart(depot, "Verwaltung_Glasfront", Vector3.new(0.6, 12, 29),
    CFrame.new(-1457.5, 9, -945), Enum.Material.Glass, C.glass, false, 0.12)
makePart(depot, "Verwaltung_Dach", Vector3.new(69, 2, 38),
    CFrame.new(-1490, 19, -945), Enum.Material.Metal, C.steel, true)

makePart(depot, "Waschhalle_Wand_Hinten", Vector3.new(76, 16, 2),
    CFrame.new(-1370, 8, -1065), Enum.Material.Concrete, rgb(172, 181, 180), true)
makePart(depot, "Waschhalle_Wand_Seite_A", Vector3.new(2, 16, 45),
    CFrame.new(-1408, 8, -1042.5), Enum.Material.Concrete, rgb(172, 181, 180), true)
makePart(depot, "Waschhalle_Wand_Seite_B", Vector3.new(2, 16, 45),
    CFrame.new(-1332, 8, -1042.5), Enum.Material.Concrete, rgb(172, 181, 180), true)
makePart(depot, "Waschhalle_Dach", Vector3.new(82, 2, 52),
    CFrame.new(-1370, 17, -1042.5), Enum.Material.Metal, C.steel, true)
for _, x in ipairs({-1390, -1370, -1350}) do
    makePart(depot, "Waschportal", Vector3.new(0.6, 13, 1.2),
        CFrame.new(x, 7, -1018), Enum.Material.Neon, rgb(79, 179, 192), false)
end

for row = 0, 3 do
    for col = 0, 5 do
        local x = -1470 + col * 18
        local z = -1105 + row * 17
        makePart(depot, "Mitarbeiterparkplatz", Vector3.new(15, 0.06, 12),
            CFrame.new(x, 0.28, z), Enum.Material.Asphalt, rgb(54, 59, 63), false)
        makePart(depot, "Parkplatzlinie", Vector3.new(0.22, 0.04, 11),
            CFrame.new(x - 7.5, 0.34, z), Enum.Material.SmoothPlastic, C.white, false)
    end
end

local depotSign = verticalPart(depot, "Betriebshof_Schild",
    Vector3.new(0.8, 5, 26), Vector3.new(-1211, 32, -820),
    Enum.Material.SmoothPlastic, C.blue, false)
makeBillboard(depotSign, "RNV BETRIEBSHOF", C.blue, 270, 60)

-- Spawn auf dem freien Betriebshof-Vorplatz, sicher ausserhalb der Gleise.
local spawn = Instance.new("SpawnLocation")
spawn.Name = "SpielerSpawn_Betriebshof"
spawn.Size = Vector3.new(9, 1, 9)
spawn.CFrame = CFrame.new(-1350, 0.78, -1000)
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
    {-850, 330, 82, 66, 14},
    {-350, 400, 86, 68, -12},
    {10, 100, 82, 66, 18},
    {340, 500, 84, 70, -15},
    {880, 350, 88, 72, 22},
    {1080, -680, 84, 68, -16},
    {430, -1090, 88, 72, -20},
    {-1220, -300, 86, 72, -24},
    {-1250, 500, 80, 66, 9},
    {-520, -700, 84, 68, 16},
    {120, -700, 82, 66, -13},
    {1150, -450, 82, 68, 18},
    {500, 1200, 86, 70, -12},
    {-1200, 0, 78, 64, 12}
}
for index, values in ipairs(plotData) do
    makePlot(index, values[1], values[2], values[3], values[4], values[5])
end

-- Ein markanter Mannheimer Orientierungspunkt: Wasserturm in einer Parkanlage.
local park = model("Friedrichsplatz_Wasserturm")
makePart(park, "Parkflaeche", Vector3.new(230, 0.18, 210),
    CFrame.new(930, 0.08, 70), Enum.Material.Grass, C.grass, false)

local fountain = makePart(park, "Brunnenbecken", Vector3.new(2.5, 94, 94),
    CFrame.new(930, 1.25, 70) * CFrame.Angles(0, 0, math.rad(90)),
    Enum.Material.Concrete, rgb(205, 203, 190), true)
fountain.Shape = Enum.PartType.Cylinder

local water = makePart(park, "Brunnenwasser", Vector3.new(1.0, 78, 78),
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

-- Ausgebaute Stadtviertel: viele eigenstaendige, editierbare Gebaeude.
-- Die Standorte sind bewusst in lockeren Strassenzuegen gruppiert, nicht in einem Raster.
local buildingsFolder = model("Stadtbebauung")
local buildingRng = Random.new(241119)

local facadeColors = {
    rgb(220, 207, 183), rgb(201, 190, 174), rgb(185, 191, 190),
    rgb(213, 198, 174), rgb(195, 180, 163), rgb(224, 218, 203),
    rgb(176, 188, 187), rgb(205, 203, 191)
}
local roofColors = {
    rgb(67, 67, 66), rgb(86, 68, 59), rgb(105, 75, 63),
    rgb(73, 82, 84), rgb(95, 89, 79)
}

local function makeCityBuilding(name, x, z, width, depth, floors, rotation, style)
    local building = model(name, buildingsFolder)
    local frame = CFrame.new(x, 0, z) * CFrame.Angles(0, math.rad(rotation), 0)
    local height = floors * 9
    local facade = facadeColors[buildingRng:NextInteger(1, #facadeColors)]
    local roofColor = roofColors[buildingRng:NextInteger(1, #roofColors)]
    local isShop = style == "shop"
    local isApartment = style == "apartment"

    makePart(building, "Gebaeudekoerper", Vector3.new(width, height, depth),
        frame * CFrame.new(0, height / 2, 0),
        isShop and Enum.Material.Concrete or Enum.Material.SmoothPlastic, facade, true)

    makePart(building, "Sockelzone", Vector3.new(width + 0.8, 1.0, depth + 0.8),
        frame * CFrame.new(0, 0.6, 0), Enum.Material.Concrete, rgb(126, 130, 127), true)
    makePart(building, "Dachabschluss", Vector3.new(width + 2, 1.3, depth + 2),
        frame * CFrame.new(0, height + 0.4, 0), Enum.Material.Concrete, roofColor, true)

    -- Vorderfassade: regelmaessige, aber pro Haus unterschiedlich breite Fenster.
    local floorHeight = 9
    for floorIndex = 1, floors do
        local windowY = 2.7 + (floorIndex - 1) * floorHeight
        local windowCount = math.max(2, math.floor(width / 12))
        for windowIndex = 1, windowCount do
            local localX = -width / 2 + (windowIndex * width / (windowCount + 1))
            local windowWidth = isShop and 7.5 or 4.4
            local windowHeight = isShop and 5.2 or 4.0
            makePart(building, "Fassadenfenster", Vector3.new(windowWidth, windowHeight, 0.32),
                frame * CFrame.new(localX, windowY, -depth / 2 - 0.12),
                Enum.Material.Glass, C.glass, false, 0.12)
            makePart(building, "Fensterrahmen_Sturz", Vector3.new(windowWidth + 0.5, 0.25, 0.5),
                frame * CFrame.new(localX, windowY + windowHeight / 2, -depth / 2 - 0.15),
                Enum.Material.Metal, C.white, false)
        end
    end

    -- Seitenfenster geben auch aus schraegem Blickwinkel eine fertige Fassade.
    for floorIndex = 1, floors do
        local windowY = 2.7 + (floorIndex - 1) * floorHeight
        for _, side in ipairs({-1, 1}) do
            for _, along in ipairs({-depth * 0.28, depth * 0.28}) do
                makePart(building, "Seitenfenster", Vector3.new(0.32, 4.0, 4.2),
                    frame * CFrame.new(side * (width / 2 + 0.12), windowY, along),
                    Enum.Material.Glass, C.glass, false, 0.12)
            end
        end
    end

    -- Eingang mit Vordach, Stufen und einem gut sichtbaren Rahmen.
    makePart(building, "Hauseingang", Vector3.new(4.8, 7.0, 0.55),
        frame * CFrame.new(0, 3.5, -depth / 2 - 0.24),
        Enum.Material.Wood, C.wood, false)
    makePart(building, "Eingangsvordach", Vector3.new(9.0, 0.65, 4.2),
        frame * CFrame.new(0, 7.5, -depth / 2 - 2.0),
        Enum.Material.Metal, C.steel, true)
    makePart(building, "Eingangsstufe", Vector3.new(7.0, 0.35, 2.4),
        frame * CFrame.new(0, 0.25, -depth / 2 - 1.7),
        Enum.Material.Concrete, C.curb, true)

    -- Dachgauben/Schornstein und leicht variierte Dachaufbauten.
    if buildingRng:NextNumber() > 0.35 then
        makePart(building, "Schornstein", Vector3.new(3.2, 5.0, 3.2),
            frame * CFrame.new(width * 0.28, height + 3.0, depth * 0.2),
            Enum.Material.Brick, rgb(145, 91, 72), true)
    end
    if isApartment then
        for floorIndex = 1, floors - 1 do
            local balconyY = 4.5 + (floorIndex - 1) * floorHeight
            makePart(building, "Balkonplatte", Vector3.new(7.0, 0.35, 2.0),
                frame * CFrame.new(-width * 0.25, balconyY, -depth / 2 - 1.0),
                Enum.Material.Concrete, C.concrete, true)
            makePart(building, "Balkongelaender", Vector3.new(7.0, 1.15, 0.18),
                frame * CFrame.new(-width * 0.25, balconyY + 0.7, -depth / 2 - 1.9),
                Enum.Material.Metal, C.white, false)
        end
    end

    if isShop then
        local shopSign = makePart(building, "Geschaeftsschild", Vector3.new(width * 0.72, 2.4, 0.5),
            frame * CFrame.new(0, 8.0, -depth / 2 - 0.42),
            Enum.Material.SmoothPlastic, C.blue, false)
        makeBillboard(shopSign, "GESCHAEFT", C.blue, 170, 40)
        makePart(building, "Markise", Vector3.new(width * 0.72, 0.45, 3.4),
            frame * CFrame.new(0, 5.9, -depth / 2 - 1.9),
            Enum.Material.Fabric, C.red, false)
    end

    return building
end

-- Wohnquartiere mit wechselnden Hausgroessen und Fassaden.
local buildingLots = {
    -- Neckarstadt / westliches Wohngebiet
    {-1120, 720, 54, 44, 3, 12, "apartment"},
    {-980, 760, 48, 42, 2, -8, "house"},
    {-835, 710, 58, 46, 3, 16, "apartment"},
    {-690, 770, 50, 43, 2, -12, "house"},
    {-1120, 900, 58, 45, 3, -14, "apartment"},
    {-970, 930, 47, 42, 2, 9, "house"},
    {-820, 900, 54, 44, 3, 7, "apartment"},
    {-675, 940, 48, 42, 2, -10, "house"},

    -- Nordviertel
    {-420, 1010, 52, 44, 3, 8, "apartment"},
    {-275, 1040, 48, 42, 2, -8, "house"},
    {-125, 1000, 58, 46, 4, 13, "apartment"},
    {35, 1035, 50, 42, 2, -12, "house"},
    {195, 990, 55, 45, 3, 9, "apartment"},
    {355, 1015, 48, 42, 2, -7, "house"},

    -- Oststadt und Feudenheim
    {680, 470, 56, 45, 3, 11, "apartment"},
    {835, 470, 48, 42, 2, -8, "house"},
    {990, 470, 58, 46, 4, 14, "apartment"},
    {1145, 470, 48, 42, 2, -10, "house"},
    {670, 1010, 50, 43, 2, -12, "house"},
    {825, 1030, 58, 46, 3, 8, "apartment"},
    {985, 1000, 49, 42, 2, -8, "house"},
    {1140, 1040, 56, 45, 3, 12, "apartment"},

    -- Suedliche Wohngebiete
    {-1120, -320, 56, 45, 3, 10, "apartment"},
    {-970, -350, 49, 42, 2, -12, "house"},
    {-820, -315, 58, 46, 3, 8, "apartment"},
    {-670, -355, 48, 42, 2, -9, "house"},
    {-1120, -1220, 50, 43, 2, -8, "house"},
    {-970, -1210, 58, 45, 3, 13, "apartment"},
    {-815, -1230, 49, 42, 2, -12, "house"},
    {-660, -1200, 56, 46, 3, 10, "apartment"},
    {-430, -1215, 48, 42, 2, -9, "house"},
    {-275, -1200, 58, 46, 3, 13, "apartment"},
    {-115, -1220, 50, 43, 2, -8, "house"},
    {45, -1200, 56, 45, 3, 10, "apartment"},
    {205, -1220, 48, 42, 2, -10, "house"},

    -- Suedoestliche Reihen mit Geschosswohnbauten
    {820, -1110, 62, 48, 4, 10, "apartment"},
    {995, -1080, 52, 44, 3, -12, "apartment"},
    {1160, -1110, 48, 42, 2, 8, "house"},
    {820, -930, 50, 42, 2, -9, "house"},
    {980, -900, 60, 48, 3, 13, "apartment"},
    {1150, -930, 54, 44, 3, -10, "apartment"},

    -- Gewerbe und gemischte Innenstadt
    {-1130, 170, 66, 48, 3, 12, "shop"},
    {-970, 205, 58, 45, 3, -9, "shop"},
    {-810, 165, 64, 48, 4, 10, "apartment"},
    {-650, 220, 54, 44, 3, -12, "apartment"},
    {1040, 350, 70, 52, 3, 14, "shop"},
    {1180, 350, 60, 46, 3, -10, "shop"}
}

for index, lot in ipairs(buildingLots) do
    makeCityBuilding("Stadthaus_" .. string.format("%02d", index),
        lot[1], lot[2], lot[3], lot[4], lot[5], lot[6], lot[7])
end

-- Zusaetzliche markante Einrichtungen fuer eine belebte Stadt.
local function makePublicBuilding(name, x, z, width, depth, height, facade, signText)
    local public = model(name, buildingsFolder)
    makePart(public, "Hauptgebaeude", Vector3.new(width, height, depth),
        CFrame.new(x, height / 2, z), Enum.Material.Concrete, facade, true)
    makePart(public, "Flachdach", Vector3.new(width + 4, 2, depth + 4),
        CFrame.new(x, height + 1, z), Enum.Material.Metal, C.steel, true)
    makePart(public, "Glasfront", Vector3.new(width * 0.72, height * 0.62, 0.5),
        CFrame.new(x, height * 0.52, z - depth / 2 - 0.28),
        Enum.Material.Glass, C.glass, false, 0.1)
    local sign = makePart(public, "Gebaeudeschild", Vector3.new(width * 0.55, 3.5, 0.7),
        CFrame.new(x, height - 4, z - depth / 2 - 0.5),
        Enum.Material.SmoothPlastic, C.blue, false)
    makeBillboard(sign, signText, C.blue, 220, 48)
    return public
end

makePublicBuilding("Stadtbibliothek", -510, 500, 92, 66, 28, rgb(193, 199, 196), "STADTBIBLIOTHEK")
makePublicBuilding("Schule", -350, -650, 112, 72, 24, rgb(211, 204, 186), "SCHULE")
makePublicBuilding("Einkaufszentrum", 1100, 570, 120, 76, 28, rgb(181, 190, 190), "EINKAUFSZENTRUM")
makePublicBuilding("Feuerwache", -1070, 430, 86, 62, 22, rgb(190, 190, 185), "FEUERWACHE")

-- Stadtmoebel: Bushaltestellen, Fahrradstaender, Muelleimer und kleine Beete.
for index, position in ipairs({
    {-1040, 620}, {-740, 610}, {-350, 930}, {280, 930},
    {720, 790}, {1080, 760}, {-1080, -470}, {-760, -470},
    {900, -790}, {1110, -790}, {-380, -990}, {210, -990}
}) do
    local streetFurniture = model("Stadtmobiliar_" .. index, buildingsFolder)
    makePart(streetFurniture, "Pflanzkuebel", Vector3.new(5, 1.1, 5),
        CFrame.new(position[1], 0.55, position[2]), Enum.Material.Concrete, C.concrete, true)
    makeBall(streetFurniture, "Strauch", Vector3.new(4.5, 4.5, 4.5),
        Vector3.new(position[1], 3.2, position[2]), Enum.Material.Grass, C.green)
    makePart(streetFurniture, "Muelleimer", Vector3.new(1.3, 1.8, 1.3),
        CFrame.new(position[1] + 7, 0.9, position[2]), Enum.Material.Metal, C.steel, true)
end

print("[RNV MAP V11] Neue geschwungene Mannheim-Karte wurde erstellt.")
print("[RNV MAP V11] Zwei getrennte Gleise mit jeweils zwei Schienen = vier durchgehende Hauptschienen.")
print("[RNV MAP V11] Zwei Depotgleise laufen aus zwei Hallentoren bis direkt zur Hauptstrecke.")
print("[RNV MAP V11] Betriebshof-Spawn, Werkstatt, Waschhalle, Verwaltung und Parkplatz angelegt.")
print("[RNV MAP V11] 47 Stadthaeuser, Geschaefte, oeffentliche Gebaeude und Baugrundstuecke angelegt.")
print("[RNV MAP V11] Fertig. Im Explorer liegt alles unter Workspace > RNV_Mannheim_Map.")
