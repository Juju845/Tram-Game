-- RNV MANNHEIM TRAM SIMULATOR | MAP V3
-- Einmalig in Roblox Studio in der Befehlsleiste ausfuehren.
-- Ersetzt NUR Workspace.RNV_Mannheim_Map. Andere Objekte bleiben erhalten.
-- Die Karte besteht aus normalen, verankerten und in Studio bearbeitbaren Parts.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local oldMap = Workspace:FindFirstChild("RNV_Mannheim_Map")
if oldMap then oldMap:Destroy() end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local rng = Random.new(845)
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end

local C = {
    grass = rgb(91,126,76), grassDark = rgb(67,103,62),
    asphalt = rgb(42,45,49), asphalt2 = rgb(54,57,60),
    concrete = rgb(166,164,153), curb = rgb(197,192,178),
    rail = rgb(143,151,155), ballast = rgb(89,88,82),
    metal = rgb(51,63,70), glass = rgb(105,151,170),
    white = rgb(235,232,218), yellow = rgb(245,190,42),
    blue = rgb(0,103,153), roof = rgb(75,78,79),
    tree1 = rgb(58,113,64), tree2 = rgb(74,131,74),
    tree3 = rgb(84,139,76)
}

local function makePart(parent, name, size, cf, material, tint, transparency)
    local p = Instance.new("Part")
    p.Name = name
    p.Anchored = true
    p.Size = size
    p.CFrame = cf
    p.Material = material or Enum.Material.SmoothPlastic
    p.Color = tint or rgb(190,190,190)
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.CastShadow = true
    p.CanTouch = false
    p.Parent = parent or map
    if transparency then p.Transparency = transparency end
    return p
end

local function frameAt(pos, dir)
    dir = Vector3.new(dir.X, 0, dir.Z).Unit
    local right = Vector3.new(-dir.Z, 0, dir.X)
    return CFrame.fromMatrix(pos, right, Vector3.yAxis, -dir), right
end

local function localPart(parent, name, size, baseCF, offset, material, tint, transparency)
    return makePart(parent, name, size, baseCF * CFrame.new(offset), material, tint, transparency)
end

local function attachSign(board, text, bg)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Anzeige"
    gui.Face = Enum.NormalId.Front
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 38
    gui.LightInfluence = 0
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundColor3 = bg or rgb(25,43,53)
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = C.white
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

-- LICHT: heller, gut lesbarer Nachmittag
Lighting.ClockTime = 14.8
Lighting.Brightness = 2.2
Lighting.GlobalShadows = true
Lighting.Ambient = rgb(125,128,132)
Lighting.OutdoorAmbient = rgb(155,160,165)
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
end
atmosphere.Density = 0.18
atmosphere.Offset = 0.1
atmosphere.Color = rgb(207,221,234)
atmosphere.Decay = rgb(110,127,145)
atmosphere.Glare = 0.08
atmosphere.Haze = 0.8

-- GROSSER STADTGRUND
makePart(map, "Stadtgebiet_Grund", Vector3.new(1500,3,1500),
    CFrame.new(110,-1.8,0), Enum.Material.Grass, C.grass)

-- ROUTENMITTE: GESCHLOSSENER RUNDKURS MIT VIER GROSSEN GLEISBOEGEN
-- Die Kurven werden aus vielen kurzen, sauber ausgerichteten Segmenten gebaut.
local path = {}
local function pushPoint(p)
    if #path == 0 or (path[#path]-p).Magnitude > 0.1 then
        table.insert(path,p)
    end
end
local function addLine(a,b)
    local len = (b-a).Magnitude
    local steps = math.max(1, math.ceil(len/13))
    for i=1,steps do pushPoint(a:Lerp(b,i/steps)) end
end
local function addArc(center,radius,startAngle,endAngle)
    local arcLen = math.abs(endAngle-startAngle)*radius
    local steps = math.max(2, math.ceil(arcLen/13))
    for i=1,steps do
        local a = startAngle + (endAngle-startAngle)*i/steps
        pushPoint(Vector3.new(center.X+math.cos(a)*radius,0,center.Z+math.sin(a)*radius))
    end
end

local A = Vector3.new(-180,0,-300)
pushPoint(A)
addLine(A,Vector3.new(-180,0,300))
addArc(Vector3.new(-60,0,300),120,math.pi,math.pi/2)
addLine(Vector3.new(-60,0,420),Vector3.new(300,0,420))
addArc(Vector3.new(300,0,300),120,math.pi/2,0)
addLine(Vector3.new(420,0,300),Vector3.new(420,0,-300))
addArc(Vector3.new(300,0,-300),120,0,-math.pi/2)
addLine(Vector3.new(300,0,-420),Vector3.new(-60,0,-420))
addArc(Vector3.new(-60,0,-300),120,-math.pi/2,-math.pi)

-- Weglaengen fuer Haltestellen und Ausstattungen
local cumulative = {0}
for i=1,#path-1 do
    cumulative[i+1] = cumulative[i] + (path[i+1]-path[i]).Magnitude
end
local routeLength = cumulative[#cumulative]

local function routeAt(distance)
    distance = math.clamp(distance,0,routeLength-0.01)
    for i=1,#path-1 do
        if cumulative[i+1] >= distance then
            local segLen = cumulative[i+1]-cumulative[i]
            local alpha = (distance-cumulative[i])/segLen
            local pos = path[i]:Lerp(path[i+1],alpha)
            local dir = (path[i+1]-path[i]).Unit
            local cf,right = frameAt(pos,dir)
            return pos,dir,right,cf,i
        end
    end
    local i = #path-1
    local dir = (path[i+1]-path[i]).Unit
    local cf,right = frameAt(path[i+1],dir)
    return path[i+1],dir,right,cf,i
end

-- STRASSEN, GEHWEGE, BORDSTEINE UND DOPPELGLEIS
for i=1,#path-1 do
    local a,b = path[i],path[i+1]
    local diff = b-a
    local len = diff.Magnitude
    local dir = diff.Unit
    local mid = (a+b)/2
    local cf,right = frameAt(mid,dir)

    -- Die beiden Fahrbahnen neben dem Gleis
    for _,side in ipairs({-1,1}) do
        local roadCF = cf * CFrame.new(side*39,0.08,0)
        makePart(map,"Fahrbahn_Asphalt",Vector3.new(24,0.24,len+0.5),
            roadCF,Enum.Material.Asphalt,C.asphalt)
        local sidewalkCF = cf * CFrame.new(side*59,0.20,0)
        makePart(map,"Gehweg_Gross",Vector3.new(13,0.42,len+0.5),
            sidewalkCF,Enum.Material.Concrete,C.concrete)
        local curbCF = cf * CFrame.new(side*52,0.25,0)
        makePart(map,"Bordstein",Vector3.new(0.9,0.55,len+0.5),
            curbCF,Enum.Material.Concrete,C.curb)
        for _,edge in ipairs({-10.8,10.8}) do
            makePart(map,"Fahrbahn_Randmarkierung",
                Vector3.new(0.16,0.035,len),
                roadCF*CFrame.new(edge,0.14,0),
                Enum.Material.SmoothPlastic,C.white)
        end
    end

    -- Zwei getrennte Gleise mit breiteren Schienen und Betonschwellen
    for _,lane in ipairs({-1,1}) do
        local laneCF = cf*CFrame.new(lane*4.8,0.38,0)
        makePart(map,"Gleis_Bett",Vector3.new(7.4,0.48,len+0.6),
            laneCF,Enum.Material.Concrete,C.ballast)
        for _,railOffset in ipairs({-1.5,1.5}) do
            makePart(map,"Stahlschiene",Vector3.new(0.34,0.42,len+0.5),
                laneCF*CFrame.new(railOffset,0.34,0),
                Enum.Material.Metal,C.rail)
        end
        -- Eine grosse, gut erkennbare Betonschwelle je Streckenabschnitt
        for _,zOffset in ipairs({-len*0.25,len*0.25}) do
            makePart(map,"Betonschwelle",Vector3.new(6.4,0.22,1.25),
                laneCF*CFrame.new(0,-0.06,zOffset),
                Enum.Material.Concrete,rgb(108,110,108))
        end
    end

    -- Oberleitungsdraht ueber beiden Gleisen
    for _,lane in ipairs({-1,1}) do
        makePart(map,"Oberleitungsdraht",Vector3.new(0.1,0.1,len+0.5),
            cf*CFrame.new(lane*4.8,18,0),
            Enum.Material.Metal,rgb(184,158,100))
    end
end

-- OBERLEITUNGSMASTEN MIT AUSLEGERN
for distance=0,routeLength,58 do
    local pos,dir,right,cf = routeAt(distance)
    local side = (math.floor(distance/58)%2==0) and -1 or 1
    local poleCF = cf*CFrame.new(side*17,0,0)
    makePart(map,"Oberleitungsmast_Fuss",Vector3.new(1.4,0.55,1.4),
        poleCF*CFrame.new(0,0.28,0),Enum.Material.Metal,C.metal)
    makePart(map,"Oberleitungsmast",Vector3.new(0.48,19,0.48),
        poleCF*CFrame.new(0,9.8,0),Enum.Material.Metal,C.metal)
    makePart(map,"Oberleitung_Ausleger",Vector3.new(24,0.25,0.25),
        poleCF*CFrame.new(-side*5.0,18.4,0),Enum.Material.Metal,C.metal)
    makePart(map,"Oberleitung_Isolator",Vector3.new(0.42,0.8,0.42),
        poleCF*CFrame.new(-side*9.0,17.9,0),Enum.Material.SmoothPlastic,rgb(205,205,189))
end

-- FUENF DEUTLICH GROESSERE HALTESTELLEN
local stopNames = {
    "Hauptbahnhof","Wasserturm","Paradeplatz","Neckarstadt","Marktplatz"
}
local stopDistances = {300,850,1360,1900,2390}

for stopIndex,distance in ipairs(stopDistances) do
    local pos,dir,right,routeCF = routeAt(distance)
    local side = (stopIndex%2==1) and 1 or -1
    local stationCenter = pos + right*(side*19) + Vector3.new(0,0.15,0)
    local stationCF = frameAt(stationCenter,dir)
    local station = Instance.new("Model")
    station.Name = "Haltestelle_"..stopNames[stopIndex]
    station.Parent = map

    makePart(station,"Bahnsteig",Vector3.new(18,1.5,116),
        stationCF,Enum.Material.Concrete,rgb(177,176,165))
    local innerEdgeX = -side*8.1
    makePart(station,"Bahnsteigkante",Vector3.new(0.42,0.18,116),
        stationCF*CFrame.new(innerEdgeX,0.83,0),
        Enum.Material.Concrete,C.yellow)
    makePart(station,"Blindenleitstreifen",Vector3.new(1.3,0.07,110),
        stationCF*CFrame.new(innerEdgeX+side*0.95,0.83,0),
        Enum.Material.SmoothPlastic,rgb(244,200,71))
    for z=-50,50,5 do
        makePart(station,"Tastfeld",Vector3.new(0.16,0.1,0.16),
            stationCF*CFrame.new(innerEdgeX+side*0.95,0.91,z),
            Enum.Material.Neon,C.yellow)
    end

    -- Grosse, moderne Wartehalle
    local shelterX = side*1.0
    makePart(station,"Wartehalle_Dach",Vector3.new(15,0.7,42),
        stationCF*CFrame.new(shelterX,9.2,0),
        Enum.Material.Metal,C.metal)
    makePart(station,"Wartehalle_Dachkante",Vector3.new(15.4,0.2,0.55),
        stationCF*CFrame.new(shelterX,8.75,-21),
        Enum.Material.Metal,C.blue)
    makePart(station,"Wartehalle_Rueckwand",Vector3.new(0.25,7.2,40),
        stationCF*CFrame.new(shelterX+side*6.7,4.7,0),
        Enum.Material.Glass,C.glass,0.28)
    for _,z in ipairs({-19,0,19}) do
        makePart(station,"Wartehalle_Stuetzpfosten",Vector3.new(0.42,8.5,0.42),
            stationCF*CFrame.new(shelterX-side*6.6,4.7,z),
            Enum.Material.Metal,C.metal)
        makePart(station,"Wartehalle_Glasfeld",Vector3.new(0.18,6.8,0.18),
            stationCF*CFrame.new(shelterX-side*6.6,4.7,z+8),
            Enum.Material.Glass,C.glass,0.38)
    end
    for _,z in ipairs({-13,13}) do
        makePart(station,"Bank_Sitzflaeche",Vector3.new(3.6,0.32,1.0),
            stationCF*CFrame.new(shelterX,2.0,z),
            Enum.Material.Wood,rgb(119,80,51))
        makePart(station,"Bank_Rueckenlehne",Vector3.new(0.22,1.5,3.6),
            stationCF*CFrame.new(shelterX+side*1.8,2.7,z),
            Enum.Material.Wood,rgb(119,80,51))
    end

    -- Haltestellenschild und digitale Anzeige
    local board = makePart(station,"Haltestellen_Anzeiger",Vector3.new(0.35,5.6,9.5),
        stationCF*CFrame.new(-side*6.0,4.0,-30),
        Enum.Material.SmoothPlastic,C.blue)
    attachSign(board,"RNV MANNHEIM\n"..string.upper(stopNames[stopIndex]),C.blue)
    local routeBoard = makePart(station,"Linienanzeige",Vector3.new(0.3,4.2,5.8),
        stationCF*CFrame.new(-side*6.0,3.2,31),
        Enum.Material.SmoothPlastic,rgb(27,43,52))
    attachSign(routeBoard,"LINIE 1  |  5  |  6\nBITTE EINSTEIGEN",rgb(27,43,52))
    makePart(station,"Fahrkartenautomat",Vector3.new(1.2,5.0,1.5),
        stationCF*CFrame.new(side*6.2,3.4,28),
        Enum.Material.Metal,rgb(72,83,86))
    makePart(station,"Automat_Bildschirm",Vector3.new(0.12,2.0,0.95),
        stationCF*CFrame.new(side*6.85,4.1,28),
        Enum.Material.Neon,rgb(94,177,199))
    makePart(station,"Haltestellen_Licht",Vector3.new(0.3,0.14,32),
        stationCF*CFrame.new(shelterX,8.78,0),
        Enum.Material.Neon,rgb(255,235,194))
end

-- GESCHAEFTSHAeUSER ENTLANG DES RUNDKURSES
local facadeColors = {
    rgb(211,195,169),rgb(184,190,187),rgb(201,177,160),
    rgb(171,188,192),rgb(220,211,190),rgb(172,180,168),
    rgb(194,182,164),rgb(185,168,154)
}
local shopNames = {"CAFÉ","BÄCKEREI","MARKT","APOTHEKE","BUCHLADEN","BLUMEN","KIOSK","RESTAURANT"}

local function createBuilding(distance,side,index)
    local pos,dir,right,routeCF = routeAt(distance)
    local height = rng:NextInteger(48,68)
    local depth = rng:NextInteger(38,46)
    local width = rng:NextInteger(48,60)
    local center = pos + right*(side*101) + Vector3.new(0,height/2,0)
    local cf = frameAt(center,dir)
    local model = Instance.new("Model")
    model.Name = "Stadthaus_"..index.."_"..(side==1 and "Ost" or "West")
    model.Parent = map

    makePart(model,"Gebaeude_Korpus",Vector3.new(depth,height,width),
        cf,Enum.Material.Concrete,facadeColors[(index-1)%#facadeColors+1])
    makePart(model,"Sockelzone",Vector3.new(depth+0.8,2,width+0.8),
        cf*CFrame.new(0,-height/2+1,0),
        Enum.Material.Concrete,rgb(119,120,116))
    makePart(model,"Dachabschluss",Vector3.new(depth+1.5,1.2,width+1.5),
        cf*CFrame.new(0,height/2+0.3,0),
        Enum.Material.Concrete,rgb(226,216,197))
    makePart(model,"Dachflaeche",Vector3.new(depth-2,0.35,width-2),
        cf*CFrame.new(0,height/2+1.0,0),
        Enum.Material.Slate,C.roof)

    -- Ladenfront und Fenster zeigen zur Strasse
    local inwardX = -side*(depth/2+0.22)
    makePart(model,"Ladeneingang",Vector3.new(0.22,7,3.4),
        cf*CFrame.new(inwardX, -height/2+4.5,0),
        Enum.Material.Glass,rgb(48,78,88),0.12)
    local shopSign = makePart(model,"Ladenschild",Vector3.new(0.25,2.2,13),
        cf*CFrame.new(inwardX-side*0.15,-height/2+9.2,0),
        Enum.Material.SmoothPlastic,index%2==0 and C.blue or rgb(71,103,77))
    attachSign(shopSign,shopNames[(index-1)%#shopNames+1],shopSign.Color)

    local floors = math.floor((height-13)/8)
    for floor=1,floors do
        local y = -height/2+12+floor*7.2
        for col=-1,1 do
            local z=col*(width/3)
            makePart(model,"Fensterglas",Vector3.new(0.22,4.4,6.2),
                cf*CFrame.new(inwardX,y,z),
                Enum.Material.Glass,C.glass,0.18)
            makePart(model,"Fensterbank",Vector3.new(0.65,0.25,6.8),
                cf*CFrame.new(inwardX-side*0.2,y-2.35,z),
                Enum.Material.Concrete,rgb(225,216,198))
            makePart(model,"Fenstersturz",Vector3.new(0.48,0.22,6.8),
                cf*CFrame.new(inwardX-side*0.18,y+2.35,z),
                Enum.Material.Concrete,rgb(225,216,198))
        end
    end
    for _,z in ipairs({-width/2+1,width/2-1}) do
        makePart(model,"Fassaden_Lisene",Vector3.new(0.7,height-3,0.8),
            cf*CFrame.new(inwardX,height*0.02,z),
            Enum.Material.Concrete,rgb(229,220,200))
    end
end

local buildingDistances = {}
for d=100,routeLength-100,190 do table.insert(buildingDistances,d) end
for index,d in ipairs(buildingDistances) do
    createBuilding(d,-1,index)
    createBuilding(d,1,index)
end

-- STRASSENBAeUME UND LAMPEN: GROESSERE PROPORTIONEN
local function createTree(pos,scale)
    local model=Instance.new("Model")
    model.Name="Strassenbaum"
    model.Parent=map
    local trunk=5.5*scale
    makePart(model,"Baumstamm",Vector3.new(0.9*scale,trunk,0.9*scale),
        CFrame.new(pos.X,pos.Y+trunk/2,pos.Z),
        Enum.Material.Wood,rgb(101,73,48))
    local crownPos=Vector3.new(pos.X,pos.Y+trunk+3.2*scale,pos.Z)
    for _,info in ipairs({
        {6.6*scale,Vector3.new(0,0,0),C.tree1},
        {4.8*scale,Vector3.new(-1.8*scale,0.8*scale,1.0*scale),C.tree2},
        {4.8*scale,Vector3.new(1.8*scale,0.9*scale,-0.8*scale),C.tree3}
    }) do
        local diameter,offset,tint=info[1],info[2],info[3]
        local crown = makePart(model,"Baumkrone",Vector3.new(diameter,diameter,diameter),
            CFrame.new(crownPos+offset),Enum.Material.Grass,tint)
        crown.Shape=Enum.PartType.Ball
    end
end

for distance=45,routeLength-45,52 do
    local pos,dir,right,cf=routeAt(distance)
    for _,side in ipairs({-1,1}) do
        if math.floor(distance/52)%3~=0 then
            createTree(pos+right*(side*68)+Vector3.new(0,0,0),rng:NextNumber(0.95,1.25))
        end
    end
end

local function createStreetLight(pos,dir)
    local cf,right=frameAt(pos,dir)
    local model=Instance.new("Model")
    model.Name="Strassenlaterne"
    model.Parent=map
    makePart(model,"Laternenmast",Vector3.new(0.38,11,0.38),
        cf*CFrame.new(0,5.5,0),Enum.Material.Metal,C.metal)
    makePart(model,"Laternenarm",Vector3.new(3.0,0.22,0.22),
        cf*CFrame.new(-1.3,10.8,0),Enum.Material.Metal,C.metal)
    local head=makePart(model,"Leuchtenkopf",Vector3.new(1.7,0.4,0.9),
        cf*CFrame.new(-2.5,10.65,0),Enum.Material.Metal,rgb(55,62,65))
    makePart(model,"Leuchtflaeche",Vector3.new(1.35,0.1,0.7),
        cf*CFrame.new(-2.5,10.38,0),Enum.Material.Neon,rgb(255,235,192))
    local light=Instance.new("PointLight")
    light.Color=rgb(255,225,180)
    light.Brightness=0.8
    light.Range=25
    light.Enabled=false
    light.Parent=head
end

for distance=25,routeLength-25,112 do
    local pos,dir,right,cf=routeAt(distance)
    local side=(math.floor(distance/112)%2==0) and -1 or 1
    createStreetLight(pos+right*(side*53),dir)
end

-- PARK IM INNENBEREICH DER STADT, MIT WEGEN, BAeNKEN UND BAeUMEN
local park=Instance.new("Model")
park.Name="Innenstadtpark"
park.Parent=map
makePart(park,"Parkwiese",Vector3.new(290,0.24,285),
    CFrame.new(120,0.02,0),Enum.Material.LeafyGrass,C.grassDark)
makePart(park,"Parkweg_Laengs",Vector3.new(9,0.16,270),
    CFrame.new(120,0.20,0),Enum.Material.Concrete,rgb(177,172,155))
makePart(park,"Parkweg_Quer",Vector3.new(275,0.16,9),
    CFrame.new(120,0.21,0),Enum.Material.Concrete,rgb(177,172,155))
makePart(park,"Parkplatz_Rund",Vector3.new(82,0.18,82),
    CFrame.new(120,0.23,0),Enum.Material.Cobblestone,rgb(151,148,136))
for x=-5,245,42 do
    for z=-112,112,56 do
        local px=120+x-120
        if math.abs(px-120)>54 and math.abs(z)>22 then
            createTree(Vector3.new(px,0.25,z),0.9)
        end
    end
end
for _,offset in ipairs({-35,35}) do
    local bench=Instance.new("Model")
    bench.Name="Parkbank"
    bench.Parent=park
    makePart(bench,"Sitzflaeche",Vector3.new(4.6,0.35,1.1),
        CFrame.new(120+offset,1.2,52),Enum.Material.Wood,rgb(119,80,51))
    makePart(bench,"Rueckenlehne",Vector3.new(0.25,1.7,4.6),
        CFrame.new(120+offset,1.8,52.5),Enum.Material.Wood,rgb(119,80,51))
end

-- KLEINE STADTTEILPLAeTZE AN VIER ECKEN
for _,pos in ipairs({
    Vector3.new(-290,0,290),Vector3.new(520,0,290),
    Vector3.new(-290,0,-290),Vector3.new(520,0,-290)
}) do
    local plaza=Instance.new("Model")
    plaza.Name="Stadtteilplatz"
    plaza.Parent=map
    makePart(plaza,"Platzpflaster",Vector3.new(70,0.24,65),
        CFrame.new(pos.X,0.02,pos.Z),Enum.Material.Cobblestone,rgb(150,147,136))
    makePart(plaza,"Pflanzbeet",Vector3.new(14,0.6,14),
        CFrame.new(pos.X,0.35,pos.Z),Enum.Material.Ground,rgb(92,115,71))
    createTree(Vector3.new(pos.X,0.65,pos.Z),1.0)
    makePart(plaza,"Platzbank",Vector3.new(5,0.35,1.2),
        CFrame.new(pos.X+18,1.0,pos.Z+13),Enum.Material.Wood,rgb(119,80,51))
end

print("[RNV Mannheim] MAP V3 erstellt: grosser Rundkurs, vier Gleisboegen, Doppelgleis, fuenf Haltestellen, groessere Gebaeude und Stadtumgebung.")
print("[RNV Mannheim] Alle Objekte sind in Workspace > RNV_Mannheim_Map einzeln bearbeitbar.")