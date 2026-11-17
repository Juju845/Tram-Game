-- RNV MANNHEIM TRAM SIMULATOR | MAP V5 - SECKENHEIM RATHAUS
-- Lokaler Nachbau des Bereichs Seckenheim Rathaus / Seckenheimer Hauptstrasse.
-- Einmalig in Roblox Studio in die Befehlsleiste einfuegen und ausfuehren.
-- Ersetzt nur Workspace.RNV_Mannheim_Map und entfernt SpawnLocation-Objekte.
-- Keine Wegweiser-/Quadrat-Beschriftungen. Alle Weltobjekte sind editierbar.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- Alten Kartengenerator-Ordner entfernen und den gewuenschten Spawnpunkt beseitigen.
local oldMap = Workspace:FindFirstChild("RNV_Mannheim_Map")
if oldMap then oldMap:Destroy() end

local removedSpawns = 0
for _,obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("SpawnLocation") then
        obj:Destroy()
        removedSpawns = removedSpawns + 1
    end
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local rng = Random.new(68239)
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end

local C = {
    ground = rgb(164,161,151),
    asphalt = rgb(48,50,52),
    asphaltDark = rgb(39,42,44),
    sidewalk = rgb(180,177,165),
    cobble = rgb(143,139,128),
    curb = rgb(203,198,184),
    rail = rgb(151,158,160),
    railHead = rgb(183,188,188),
    sleeper = rgb(105,107,104),
    trackBed = rgb(83,84,80),
    metal = rgb(49,61,68),
    glass = rgb(105,151,169),
    white = rgb(239,235,222),
    yellow = rgb(244,190,49),
    rnvBlue = rgb(0,103,154),
    townHall = rgb(222,195,132),
    townHallTrim = rgb(241,224,188),
    roofRed = rgb(142,58,42),
    roofDark = rgb(75,65,57),
    leaf1 = rgb(62,116,68),
    leaf2 = rgb(77,132,73),
    leaf3 = rgb(88,140,77)
}

-- Lokales Koordinatensystem: Die Seckenheimer Hauptstrasse verlaeuft diagonal.
local MAIN = Vector3.new(1,0,-1).Unit
local SIDE = Vector3.new(1,0,1).Unit
local UP = Vector3.new(0,1,0)

local function world(t,s,y)
    return MAIN*t + SIDE*s + UP*(y or 0)
end

local function frameAt(pos,dir)
    dir = Vector3.new(dir.X,0,dir.Z).Unit
    local right = Vector3.new(-dir.Z,0,dir.X)
    return CFrame.fromMatrix(pos,right,UP,-dir),right
end

local function localFrame(t,s,y,dir)
    return frameAt(world(t,s,y),dir or MAIN)
end

local function part(parent,name,size,cf,material,tint,canCollide,transparency)
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
    if canCollide ~= nil then p.CanCollide = canCollide end
    if transparency then p.Transparency = transparency end
    p.Parent = parent or map
    return p
end

local function at(parent,name,size,t,s,y,dir,material,tint,canCollide,transparency)
    local cf = localFrame(t,s,y,dir or MAIN)
    return part(parent,name,size,cf,material,tint,canCollide,transparency)
end

local function beam(parent,name,a,b,width,height,material,tint)
    local delta = b-a
    local len = delta.Magnitude
    local mid = (a+b)/2
    local cf = CFrame.lookAt(mid,b,SIDE)
    return part(parent,name,Vector3.new(width,height,len),cf,material,tint)
end

local function cylinder(parent,name,diameter,height,cf,material,tint)
    local p = Instance.new("Part")
    p.Name = name
    p.Shape = Enum.PartType.Cylinder
    p.Size = Vector3.new(height,diameter,diameter)
    p.CFrame = cf*CFrame.Angles(0,0,math.rad(90))
    p.Anchored = true
    p.Material = material
    p.Color = tint
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent or map
    return p
end

local function surfaceText(board,text,face,bg,textColor)
    local gui = Instance.new("SurfaceGui")
    gui.Name = "Beschriftung"
    gui.Face = face
    gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud = 38
    gui.LightInfluence = 0
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundColor3 = bg
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = textColor or C.white
    label.TextScaled = true
    label.TextWrapped = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

local function billboard(board,text,width,height,bg)
    local gui = Instance.new("BillboardGui")
    gui.Name = "Ortsbeschriftung"
    gui.Adornee = board
    gui.Size = UDim2.fromOffset(width,height)
    gui.StudsOffset = Vector3.new(0,4,0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 350
    gui.Parent = board
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1)
    label.BackgroundColor3 = bg or C.rnvBlue
    label.BackgroundTransparency = 0.08
    label.BorderSizePixel = 0
    label.Text = text
    label.TextColor3 = C.white
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

-- LICHT UND HIMMEL
Lighting.ClockTime = 15.1
Lighting.Brightness = 2.15
Lighting.GlobalShadows = true
Lighting.Ambient = rgb(124,127,132)
Lighting.OutdoorAmbient = rgb(156,160,166)
Lighting.EnvironmentDiffuseScale = 0.42
Lighting.EnvironmentSpecularScale = 0.32
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere = Instance.new("Atmosphere")
    atmosphere.Parent = Lighting
end
atmosphere.Density = 0.18
atmosphere.Offset = 0.12
atmosphere.Color = rgb(207,220,232)
atmosphere.Decay = rgb(112,129,148)
atmosphere.Glare = 0.08
atmosphere.Haze = 0.75

-- EIN EINZIGER, DURCHGEHENDER BODEN. KEINE UEBEREINANDERLIEGENDEN GRUNDPLATTEN.
part(map,"Seckenheim_Gesamtboden",Vector3.new(1800,4,1800),
    CFrame.new(0,-2.05,0),Enum.Material.Concrete,C.ground)

-- SECKENHEIMER HAUPTSTRASSE: DURCHGEHENDER ASPHALT UND GETRENNTE GEHWEGE.
local mainRoadCF = localFrame(0,0,0.12,MAIN)
part(map,"Seckenheimer_Hauptstrasse",Vector3.new(82,0.24,1420),
    mainRoadCF,Enum.Material.Asphalt,C.asphalt)
for _,side in ipairs({-1,1}) do
    at(map,"Gehweg_Hauptstrasse",Vector3.new(18,0.38,1420),
        0,side*50,0.27,MAIN,Enum.Material.Concrete,C.sidewalk)
    at(map,"Bordstein_Hauptstrasse",Vector3.new(0.9,0.45,1420),
        0,side*41,0.26,MAIN,Enum.Material.Concrete,C.curb)
    at(map,"Gehweg_Pflasterband",Vector3.new(11,0.16,1380),
        0,side*66,0.12,MAIN,Enum.Material.Cobblestone,C.cobble)
end

-- GLEISE IN DIE STRASSE EINGEBETTET: SCHWELLEN, SCHIENENFUSS, STEG UND KOPF.
at(map,"Strassenbahngleis_Bettung",Vector3.new(19,0.16,1320),
    0,0,0.27,MAIN,Enum.Material.Asphalt,C.asphaltDark)

for _,trackSide in ipairs({-1,1}) do
    local trackCenter = trackSide*3.75
    for z=-650,650,5 do
        at(map,"Betonschwelle",Vector3.new(5.4,0.16,1.0),
            z,trackCenter,0.39,MAIN,Enum.Material.Concrete,C.sleeper)
    end
    for _,offset in ipairs({-1.38,1.38}) do
        local railS = trackCenter+offset
        at(map,"Schienenfuss",Vector3.new(0.72,0.14,1320),
            0,railS,0.48,MAIN,Enum.Material.Metal,C.rail)
        at(map,"Schienensteg",Vector3.new(0.24,0.34,1320),
            0,railS,0.70,MAIN,Enum.Material.Metal,C.rail)
        at(map,"Schienenkopf",Vector3.new(0.48,0.14,1320),
            0,railS,0.94,MAIN,Enum.Material.Metal,C.railHead)
        for z=-645,645,15 do
            at(map,"Schienenbefestigung",Vector3.new(0.72,0.12,0.38),
                z,railS,0.57,MAIN,Enum.Material.Metal,rgb(65,72,75))
        end
    end
end

-- OBERLEITUNG MIT MASTEN, QUERTRAEGERN UND ISOLATOREN.
for z=-640,640,52 do
    local side = (math.floor((z+640)/52)%2==0) and -1 or 1
    at(map,"Oberleitungsmast_Fuss",Vector3.new(1.5,0.48,1.5),
        z,side*18,0.3,MAIN,Enum.Material.Metal,C.metal)
    at(map,"Oberleitungsmast",Vector3.new(0.5,16,0.5),
        z,side*18,8.25,MAIN,Enum.Material.Metal,C.metal)
    at(map,"Oberleitung_Quertraeger",Vector3.new(27,0.26,0.26),
        z,side*5,15.8,MAIN,Enum.Material.Metal,C.metal)
    at(map,"Oberleitung_Isolator",Vector3.new(0.48,0.82,0.48),
        z,side*-5,15.25,MAIN,Enum.Material.SmoothPlastic,rgb(205,201,184))
end
for _,trackSide in ipairs({-1,1}) do
    at(map,"Oberleitungsdraht",Vector3.new(0.1,0.1,1320),
        0,trackSide*3.75,15.1,MAIN,Enum.Material.Metal,rgb(188,160,101))
end

-- FAHRBAHNMARKIERUNGEN, RADSTREIFEN UND PARKBUCHTEN.
for _,side in ipairs({-1,1}) do
    for z=-650,650,22 do
        at(map,"Spurmarkierung",Vector3.new(0.16,0.035,8),
            z,side*25,0.265,MAIN,Enum.Material.SmoothPlastic,C.white)
    end
    at(map,"Radweg",Vector3.new(4,0.08,1300),
        0,side*74,0.11,MAIN,Enum.Material.Asphalt,rgb(83,108,91))
    for z=-630,630,30 do
        at(map,"Radweg_Markierung",Vector3.new(0.12,0.035,5),
            z,side*74,0.17,MAIN,Enum.Material.SmoothPlastic,C.white)
    end
end

-- NEBENSTRASSEN: FREIBURGER STRASSE, KEHLER STRASSE, BRUECKENSTRASSE.
-- Sie enden sauber an der Hauptstrasse; die Flaechen werden nicht uebereinandergelegt.
local function sideStreet(name,tConst,s1,s2)
    local center=(s1+s2)/2
    local length=math.abs(s2-s1)
    local cf=frameAt(world(tConst,center,0.16),SIDE)
    part(map,name.."_Fahrbahn",Vector3.new(34,0.28,length),
        cf,Enum.Material.Asphalt,C.asphalt)
    for _,edge in ipairs({-17,17}) do
        local sideCF=cf*CFrame.new(edge,0.23,0)
        part(map,name.."_Bordstein",Vector3.new(0.75,0.44,length),
            sideCF,Enum.Material.Concrete,C.curb)
    end
    -- Kleine durchgehende Seitenwege, auf gleicher Bodenhoehe statt doppelter Strassenplatten.
    for _,edge in ipairs({-25,25}) do
        local pathCF=cf*CFrame.new(edge,0.18,0)
        part(map,name.."_Gehweg",Vector3.new(10,0.34,length),
            pathCF,Enum.Material.Concrete,C.sidewalk)
    end
end
sideStreet("Freiburger_Strasse",-300,-390,-42)
sideStreet("Kehler_Strasse",150,42,390)
sideStreet("Brueckenstrasse",360,-390,-42)
sideStreet("Heumarkt_Zufahrt",250,42,300)

-- EIN PAAR SANFTE KURVEN IN DEN ZUFAHRTEN; KEIN KREIS ODER RUNDKURS.
local function curvedStreet(name,points,width)
    for i=1,#points-1 do
        local a,b=points[i],points[i+1]
        local delta=b-a
        local cf=frameAt((a+b)/2,delta.Unit)
        local len=delta.Magnitude
        part(map,name.."_Kurvenfahrbahn",Vector3.new(width,0.25,len+0.1),
            cf*CFrame.new(0,0.14,0),Enum.Material.Asphalt,C.asphalt)
    end
end
local curve1={
    world(145,42,0),world(168,95,0),world(210,145,0),world(250,205,0)
}
local curve2={
    world(330,-42,0),world(350,-95,0),world(385,-145,0),world(425,-205,0)
}
curvedStreet("Kehler_Strassenbogen",curve1,34)
curvedStreet("Brueckenstrassenbogen",curve2,34)

-- STRASSENBAHN-HALTESTELLE SECKENHEIM RATHAUS: STEIG A UND B.
-- Ein Bahnsteig je Seite der beiden Gleise, mit Glaswartehalle und RNV-Ausstattung.
local function makeTramPlatform(steig,side)
    local model=Instance.new("Model")
    model.Name="Steig_"..steig
    model.Parent=map
    local tCenter=-15
    local sCenter=side*22
    local baseCF=localFrame(tCenter,sCenter,0.78,MAIN)

    part(model,"Bahnsteigplatte",Vector3.new(15,1.45,100),
        baseCF,Enum.Material.Concrete,rgb(174,173,164))
    part(model,"Bahnsteigkante",Vector3.new(0.38,0.18,100),
        baseCF*CFrame.new(-side*7.2,0.82,0),
        Enum.Material.Concrete,C.yellow)
    part(model,"Taststreifen",Vector3.new(1.15,0.08,96),
        baseCF*CFrame.new(-side*6.55,0.82,0),
        Enum.Material.SmoothPlastic,rgb(246,203,71))
    for z=-45,45,5 do
        part(model,"Tastnoppen",Vector3.new(0.22,0.1,0.22),
            baseCF*CFrame.new(-side*6.55,0.91,z),
            Enum.Material.Neon,C.yellow)
    end

    -- Wartehalle, groeßer und hoeher skaliert.
    local shelterS=side*1.2
    part(model,"Wartehalle_Dach",Vector3.new(13,0.65,38),
        baseCF*CFrame.new(shelterS,8.0,0),
        Enum.Material.Metal,C.metal)
    part(model,"Wartehalle_Dachblende",Vector3.new(13.3,0.24,0.55),
        baseCF*CFrame.new(shelterS,7.63,-19),
        Enum.Material.Metal,C.rnvBlue)
    for _,z in ipairs({-17,0,17}) do
        part(model,"Wartehalle_Pfosten",Vector3.new(0.4,7.5,0.4),
            baseCF*CFrame.new(shelterS-side*5.9,4.4,z),
            Enum.Material.Metal,C.metal)
        part(model,"Wartehalle_Glaswand",Vector3.new(0.16,6.2,16),
            baseCF*CFrame.new(shelterS+side*5.9,4.3,z),
            Enum.Material.Glass,C.glass,false,0.3)
    end
    part(model,"Wartehalle_Rueckglas",Vector3.new(10.8,6.2,0.16),
        baseCF*CFrame.new(shelterS,4.3,-18.8),
        Enum.Material.Glass,C.glass,false,0.34)
    for _,z in ipairs({-11,11}) do
        part(model,"Sitzbank",Vector3.new(3.6,0.3,1.0),
            baseCF*CFrame.new(shelterS,1.7,z),Enum.Material.Wood,rgb(117,80,52))
    end
    local mast=part(model,"Haltestellenmast",Vector3.new(0.4,6.0,0.4),
        baseCF*CFrame.new(side*5.6,3.7,-40),Enum.Material.Metal,C.metal)
    billboard(mast,"SECKENHEIM RATHAUS",190,34,C.rnvBlue)
    local sign=part(model,"RNV_Steigschild",Vector3.new(0.3,3.3,4.2),
        baseCF*CFrame.new(side*5.5,4.2,-40),Enum.Material.SmoothPlastic,C.rnvBlue)
    local face=side>0 and Enum.NormalId.Left or Enum.NormalId.Right
    surfaceText(sign,"RNV  |  STEIG "..steig,face,C.rnvBlue,C.white)
    local display=part(model,"Abfahrtsanzeige",Vector3.new(0.25,2.6,3.7),
        baseCF*CFrame.new(-side*5.4,3.6,38),Enum.Material.SmoothPlastic,rgb(26,42,50))
    surfaceText(display,"LINIE 5 / 40",face,rgb(26,42,50),C.white)
    part(model,"Fahrkartenautomat",Vector3.new(1.3,4.2,1.4),
        baseCF*CFrame.new(side*5.4,3.0,30),Enum.Material.Metal,rgb(76,84,85))
    part(model,"Automat_Bildschirm",Vector3.new(0.12,1.6,0.9),
        baseCF*CFrame.new(side*6.1,3.7,30),Enum.Material.Neon,rgb(93,175,202),false)
    part(model,"Dachlicht",Vector3.new(0.3,0.12,29),
        baseCF*CFrame.new(shelterS,7.62,0),Enum.Material.Neon,rgb(255,233,193),false)
end
makeTramPlatform("A",-1)
makeTramPlatform("B",1)

-- BUSSTEIGE C, D UND E AM PLATZ, WIE IM RNV-HALTESTELLENPLAN.
local function makeBusBay(letter,t,s)
    local model=Instance.new("Model")
    model.Name="Bussteig_"..letter
    model.Parent=map
    local cf=localFrame(t,s,0.35,MAIN)
    part(model,"Bussteig_Plattform",Vector3.new(12,0.75,38),
        cf,Enum.Material.Concrete,rgb(177,175,163))
    part(model,"Bussteig_Leitkante",Vector3.new(0.28,0.12,38),
        cf*CFrame.new(-5.7,0.43,0),Enum.Material.Concrete,C.yellow)
    local pole=part(model,"Bussteig_Mast",Vector3.new(0.35,4.5,0.35),
        cf*CFrame.new(4.5,2.4,-11),Enum.Material.Metal,C.metal)
    local board=part(model,"Bussteig_Schild",Vector3.new(0.25,2.5,2.2),
        cf*CFrame.new(4.5,4.0,-11),Enum.Material.SmoothPlastic,C.rnvBlue)
    surfaceText(board,"STEIG "..letter,Enum.NormalId.Left,C.rnvBlue,C.white)
    billboard(pole,"SECKENHEIM RATHAUS",160,30,C.rnvBlue)
    part(model,"Buswarte_Dach",Vector3.new(9,0.5,13),
        cf*CFrame.new(-0.5,5.0,4),Enum.Material.Metal,C.metal)
    for _,z in ipairs({-2,10}) do
        part(model,"Buswarte_Pfosten",Vector3.new(0.3,4.8,0.3),
            cf*CFrame.new(-4.5,2.5,z),Enum.Material.Metal,C.metal)
    end
    part(model,"Buswarte_Glas",Vector3.new(0.12,3.9,11),
        cf*CFrame.new(4.0,2.4,4),Enum.Material.Glass,C.glass,false,0.32)
    part(model,"Busbank",Vector3.new(2.6,0.25,0.7),
        cf*CFrame.new(0,1.25,5),Enum.Material.Wood,rgb(118,80,51))
end
makeBusBay("C",48,104)
makeBusBay("D",112,104)
makeBusBay("E",176,104)

-- SECKENHEIMER PLANKEN / RATHAUSPLATZ: PFLASTER, MARKT UND PLATANEN.
local plaza=Instance.new("Model")
plaza.Name="Seckenheimer_Planken_Rathausplatz"
plaza.Parent=map
at(plaza,"Rathausplatz_Pflaster",Vector3.new(98,0.24,248),
    65,108,0.14,MAIN,Enum.Material.Cobblestone,C.cobble)
at(plaza,"Rathausplatz_Natursteinband",Vector3.new(3,0.07,230),
    65,62,0.30,MAIN,Enum.Material.Slate,rgb(116,113,106))
at(plaza,"Heumarkt_Pflaster",Vector3.new(70,0.22,125),
    265,200,0.13,MAIN,Enum.Material.Cobblestone,C.cobble)

-- ALTES RATHAUS: GELBE FASSADE, ROTES ZIEGELDACH, ARKADEN UND UHR TURM.
local town=Instance.new("Model")
town.Name="Altes_Rathaus_Seckenheim"
town.Parent=map
local townT=70
local townS=184
local townHeight=38
local townDepth=48
local townLength=108
local townCF=localFrame(townT,townS,townHeight/2,MAIN)

part(town,"Rathaus_Hauptbau",Vector3.new(townDepth,townHeight,townLength),
    townCF,Enum.Material.Concrete,C.townHall)
part(town,"Rathaus_Sockel",Vector3.new(townDepth+1.4,2,townLength+1.8),
    townCF*CFrame.new(0,-townHeight/2+1,0),
    Enum.Material.Concrete,rgb(183,166,139))
part(town,"Rathaus_Gesims",Vector3.new(townDepth+2,1.0,townLength+2),
    townCF*CFrame.new(0,townHeight/2-0.4,0),
    Enum.Material.Concrete,C.townHallTrim)

-- Rote, geneigte Ziegeldachflaechen.
for _,side in ipairs({-1,1}) do
    local roof=part(town,"Rathaus_Dachflaeche",Vector3.new(townDepth/2+2,1.4,townLength+5),
        townCF*CFrame.new(side*townDepth/4,townHeight/2+5,0)
            *CFrame.Angles(0,0,side*math.rad(23)),
        Enum.Material.RoofShingles,C.roofRed)
end
at(town,"Rathaus_Dachfirst",Vector3.new(1.2,1.0,townLength+7),
    townT,townS,townHeight+10,MAIN,Enum.Material.Wood,C.roofDark)

-- Fenster und helle Rahmungen an der Strassenseite.
local frontX=-townDepth/2-0.22
for floor=1,2 do
    local y=(floor==1) and 10 or 25
    for z=-42,42,21 do
        part(town,"Rathaus_Fenster",Vector3.new(0.22,7,8),
            townCF*CFrame.new(frontX,y,z),
            Enum.Material.Glass,rgb(92,115,122),0.06)
        part(town,"Rathaus_Fensterrahmen",Vector3.new(0.5,7.8,8.8),
            townCF*CFrame.new(frontX-0.08,y,z),
            Enum.Material.Concrete,C.townHallTrim)
    end
end

-- Arkaden: breite Pfeiler und segmentierte Rundboegen vor dem Erdgeschoss.
for arch=-2,2 do
    local zCenter=arch*18
    for _,zSide in ipairs({-5.4,5.4}) do
        local pillarCF=townCF*CFrame.new(frontX-0.55,4.4,zCenter+zSide)
        cylinder(town,"Rathaus_Arkadenpfeiler",1.7,8.8,pillarCF,
            Enum.Material.Concrete,C.townHallTrim)
    end
    local points={}
    for step=0,8 do
        local angle=math.pi-step*math.pi/8
        local localY=8.4+4.1*math.sin(angle)
        local localZ=zCenter+5.4*math.cos(angle)
        table.insert(points,townCF:PointToWorldSpace(Vector3.new(frontX-0.6,localY,localZ)))
    end
    for i=1,#points-1 do
        beam(town,"Rathaus_Rundbogen",points[i],points[i+1],0.9,0.9,
            Enum.Material.Concrete,C.townHallTrim)
    end
end

-- Rathausportal und Eingangstuer.
part(town,"Rathaus_Haupteingang",Vector3.new(0.24,9,8),
    townCF*CFrame.new(frontX-0.3,5.2,0),
    Enum.Material.Wood,rgb(83,65,48))
part(town,"Rathaus_Eingangsstufe",Vector3.new(4,0.6,13),
    townCF*CFrame.new(frontX-2.3,0.3,0),
    Enum.Material.Concrete,C.townHallTrim)
local plaque=part(town,"Rathaus_Wappen",Vector3.new(0.22,4.5,3.8),
    townCF*CFrame.new(frontX-0.55,18,0),
    Enum.Material.Metal,rgb(176,149,88))
surfaceText(plaque,"MANNHEIM\nSECKENHEIM",Enum.NormalId.Left,rgb(176,149,88),rgb(255,245,217))

-- Uhrturm mittig ueber dem Dach.
part(town,"Uhrturm_Sockel",Vector3.new(18,9,18),
    townCF*CFrame.new(0,townHeight+10,5),Enum.Material.Concrete,C.townHallTrim)
part(town,"Uhrturm_Korpus",Vector3.new(14,19,14),
    townCF*CFrame.new(0,townHeight+23,5),Enum.Material.Wood,rgb(54,49,44))
part(town,"Uhrturm_Gesims",Vector3.new(17,1.2,17),
    townCF*CFrame.new(0,townHeight+33,5),Enum.Material.Metal,C.metal)
for _,faceX in ipairs({-7.2,7.2}) do
    local sign=part(town,"Uhrturm_Zifferblatt",Vector3.new(0.25,6,6),
        townCF*CFrame.new(faceX,townHeight+23,5)
            *CFrame.Angles(0,faceX<0 and 0 or math.pi,0),
        Enum.Material.SmoothPlastic,rgb(244,236,208))
    surfaceText(sign,"12\n—",faceX<0 and Enum.NormalId.Left or Enum.NormalId.Right,
        rgb(244,236,208),rgb(44,48,47))
end
local towerRoof=part(town,"Uhrturm_Dach",Vector3.new(18,13,18),
    townCF*CFrame.new(0,townHeight+41,5),Enum.Material.Metal,rgb(48,52,52))
towerRoof.Shape=Enum.PartType.Ball
part(town,"Uhrturm_Spitze",Vector3.new(0.8,8,0.8),
    townCF*CFrame.new(0,townHeight+50,5),Enum.Material.Metal,C.metal)
local townName=part(town,"Altes_Rathaus_Schild",Vector3.new(1,1,1),
    townCF*CFrame.new(0,townHeight+55,5),Enum.Material.SmoothPlastic,C.rnvBlue,false)
billboard(townName,"ALTES RATHAUS SECKENHEIM",250,42,C.rnvBlue)

-- HISTORISCHE GESCHAEFTSHAEUSER IN DER HAUPTSTRASSE.
local facades={
    rgb(214,194,164),rgb(196,189,174),rgb(206,177,157),
    rgb(181,191,190),rgb(224,211,187),rgb(193,178,157),
    rgb(202,202,190),rgb(187,166,151)
}
local shopNames={"BÄCKEREI","APOTHEKE","FRISEUR","CAFÉ","BLUMEN","KIOSK","GASTSTÄTTE","ARZTPRAXIS","SUPERMARKT"}
local function createHouse(name,center,dir,streetSide,index)
    local height=rng:NextInteger(27,42)
    local depth=rng:NextInteger(31,39)
    local length=rng:NextInteger(40,53)
    local cf=frameAt(center+UP*(height/2),dir)
    local model=Instance.new("Model")
    model.Name=name
    model.Parent=map
    local facade=facades[(index-1)%#facades+1]
    part(model,"Hauskoerper",Vector3.new(depth,height,length),
        cf,Enum.Material.Concrete,facade)
    part(model,"Sockel",Vector3.new(depth+0.7,1.7,length+0.8),
        cf*CFrame.new(0,-height/2+0.85,0),Enum.Material.Concrete,rgb(137,130,116))
    local front=-streetSide*(depth/2+0.15)

    -- Ladenfront, Tueren, Markisen.
    for col=-1,1 do
        local z=col*length/3
        part(model,"Schaufenster",Vector3.new(0.18,5.7,7),
            cf*CFrame.new(front,3.4-height/2+2.8,z),
            Enum.Material.Glass,C.glass,false,0.16)
        part(model,"Fenstersims_EG",Vector3.new(0.55,0.22,7.5),
            cf*CFrame.new(front-streetSide*0.18,0.75,z),
            Enum.Material.Concrete,C.townHallTrim)
    end
    part(model,"Haustuer",Vector3.new(0.2,6,3.1),
        cf*CFrame.new(front,3.1-height/2+2.8,0),
        Enum.Material.Wood,rgb(78,61,46))
    local sign=part(model,"Geschaeftsschild",Vector3.new(0.28,2.1,12),
        cf*CFrame.new(front-streetSide*0.2,5.7-height/2+5,0),
        Enum.Material.SmoothPlastic,index%2==0 and C.rnvBlue or rgb(75,103,75))
    local face=streetSide>0 and Enum.NormalId.Left or Enum.NormalId.Right
    surfaceText(sign,shopNames[(index-1)%#shopNames+1],face,sign.Color,C.white)
    part(model,"Markise",Vector3.new(2.4,0.24,length-4),
        cf*CFrame.new(front-streetSide*1.15,7.5-height/2+5,0),
        Enum.Material.Fabric,index%2==0 and rgb(174,71,57) or rgb(55,109,139))

    -- Obere Stockwerke mit Fenstern, Fensterlaeden und Blumenkasten.
    local floors=math.floor((height-10)/9)
    for floor=1,floors do
        local y=-height/2+10+floor*8.3
        for col=-1,1 do
            local z=col*length/3
            part(model,"Fensterglas",Vector3.new(0.18,4.5,4.5),
                cf*CFrame.new(front,y,z),Enum.Material.Glass,C.glass,false,0.14)
            part(model,"Fensterrahmen",Vector3.new(0.42,4.9,4.9),
                cf*CFrame.new(front-streetSide*0.1,y,z),
                Enum.Material.Concrete,C.townHallTrim)
            part(model,"Blumenkasten",Vector3.new(0.65,0.65,4.2),
                cf*CFrame.new(front-streetSide*0.35,y-2.7,z),
                Enum.Material.Wood,rgb(106,75,49))
            part(model,"Fensterladen_L",Vector3.new(0.22,4.3,0.75),
                cf*CFrame.new(front-streetSide*0.22,y,z-2.7),
                Enum.Material.Wood,rgb(85,108,91))
            part(model,"Fensterladen_R",Vector3.new(0.22,4.3,0.75),
                cf*CFrame.new(front-streetSide*0.22,y,z+2.7),
                Enum.Material.Wood,rgb(85,108,91))
        end
    end

    -- Zwei geneigte Dachhaelften und kleine Gauben.
    for _,roofSide in ipairs({-1,1}) do
        part(model,"Ziegeldach",Vector3.new(depth/2+2,1.0,length+3),
            cf*CFrame.new(roofSide*depth/4,height/2+2.8,0)
                *CFrame.Angles(0,0,roofSide*math.rad(27)),
            Enum.Material.RoofShingles,index%2==0 and C.roofRed or C.roofDark)
    end
    part(model,"Dachfirst",Vector3.new(1.0,0.9,length+4),
        cf*CFrame.new(0,height/2+5.3,0),Enum.Material.Metal,C.roofRed)
    for _,offset in ipairs({-length/4,length/4}) do
        part(model,"Dachgaube",Vector3.new(5,4,5),
            cf*CFrame.new(-streetSide*depth/4,height/2+4,offset),
            Enum.Material.Concrete,facade)
    end
    return model
end

-- Haeuserzeilen entlang der Hauptstrasse, mit freiem Rathausplatz.
local index=0
for t=-590,590,88 do
    index=index+1
    createHouse("Altstadthaus_West_"..index,world(t,-91,0),MAIN,-1,index)
    if t < -150 or t > 205 then
        index=index+1
        createHouse("Altstadthaus_Ost_"..index,world(t,91,0),MAIN,1,index)
    end
end

-- Weitere Haeuser an Freiburger, Kehler und Brueckenstrasse.
for _,side in ipairs({-1,1}) do
    for s=-300,300,105 do
        if math.abs(s)>105 then
            index=index+1
            createHouse("Nebenstrassenhaus_"..index,world(-300,s,0),SIDE,side,index)
            index=index+1
            createHouse("Nebenstrassenhaus_"..index,world(360,s,0),SIDE,side,index)
        end
    end
end

-- PLATZLEBEN: PLATANEN, BAENKE, PFLANZBEETE, PERGOLA, MARKT UND GASTRONOMIE.
local function createTreeAt(parent,t,s,scale)
    local model=Instance.new("Model")
    model.Name="Platane"
    model.Parent=parent or map
    local base=world(t,s,0.3)
    local trunk=6.2*scale
    part(model,"Baumstamm",Vector3.new(1.1*scale,trunk,1.1*scale),
        CFrame.new(base+UP*(trunk/2)),Enum.Material.Wood,rgb(102,78,54))
    local crownCenter=base+UP*(trunk+3.1*scale)
    local crownSpecs={
        {7.4*scale,Vector3.new(0,0,0),C.leaf1},
        {5.4*scale,Vector3.new(2*scale,0.8*scale,1.2*scale),C.leaf2},
        {5.1*scale,Vector3.new(-2*scale,0.7*scale,-1.3*scale),C.leaf3}
    }
    for _,spec in ipairs(crownSpecs) do
        local leaf=part(model,"Baumkrone",Vector3.new(spec[1],spec[1],spec[1]),
            CFrame.new(crownCenter+spec[2]),Enum.Material.Grass,spec[3],false)
        leaf.Shape=Enum.PartType.Ball
    end
end

for _,t in ipairs({-38,28,94,160}) do
    createTreeAt(plaza,t,145,1.0)
end
for _,t in ipairs({-35,55,145}) do
    createTreeAt(plaza,t,72,0.85)
end

local function makeBench(parent,t,s,rotation)
    local cf=localFrame(t,s,0.8,MAIN)*CFrame.Angles(0,rotation or 0,0)
    local bench=Instance.new("Model")
    bench.Name="Parkbank"
    bench.Parent=parent or map
    part(bench,"Sitzflaeche",Vector3.new(4.4,0.3,1.1),
        cf,Enum.Material.Wood,rgb(112,77,50))
    part(bench,"Rueckenlehne",Vector3.new(0.24,1.4,4.4),
        cf*CFrame.new(0.5,0.65,0),Enum.Material.Wood,rgb(112,77,50))
    for _,z in ipairs({-1.5,1.5}) do
        part(bench,"Bankfuss",Vector3.new(0.18,0.75,0.18),
            cf*CFrame.new(0,-0.3,z),Enum.Material.Metal,C.metal)
    end
end
makeBench(plaza,-45,130)
makeBench(plaza,0,130)
makeBench(plaza,125,130)

-- Pergola mit Rankgeruest am Heumarkt.
local pergola=Instance.new("Model")
pergola.Name="Pergola_Heumarkt"
pergola.Parent=plaza
for _,t in ipairs({-30,20,70}) do
    for _,s in ipairs({87,111}) do
        at(pergola,"Pergolapfosten",Vector3.new(0.55,8,0.55),
            t,s,4,MAIN,Enum.Material.Wood,rgb(112,83,54))
    end
    at(pergola,"Pergolatraeger",Vector3.new(26,0.5,0.55),
        t,99,8.1,MAIN,Enum.Material.Wood,rgb(112,83,54))
end
for t=-48,88,12 do
    at(pergola,"Pergola_Querlatte",Vector3.new(27,0.25,0.3),
        t,99,8.4,MAIN,Enum.Material.Wood,rgb(124,93,61))
end

-- MARKTSTAENDE AUF DEM RATHAUSPLATZ.
for i=1,4 do
    local t= -25+(i-1)*48
    local stall=Instance.new("Model")
    stall.Name="Wochenmarktstand_"..i
    stall.Parent=plaza
    at(stall,"Markttisch",Vector3.new(5,2,15),
        t,112,1.1,MAIN,Enum.Material.Wood,rgb(121,86,56))
    at(stall,"Marktdach",Vector3.new(8,0.55,18),
        t,112,8.4,MAIN,Enum.Material.Fabric,
        i%2==0 and rgb(170,70,54) or rgb(59,111,137))
    for _,s in ipairs({108,116}) do
        at(stall,"Marktstandpfosten",Vector3.new(0.3,8,0.3),
            t-8,s,4.2,MAIN,Enum.Material.Wood,rgb(107,76,52))
        at(stall,"Marktstandpfosten",Vector3.new(0.3,8,0.3),
            t+8,s,4.2,MAIN,Enum.Material.Wood,rgb(107,76,52))
    end
    at(stall,"Marktkisten",Vector3.new(3.2,1.3,3.2),
        t,107,2.6,MAIN,Enum.Material.Wood,rgb(153,111,62))
end

-- CAFE-TISCHE, STUEHLE, BLUMENKUEBEL UND FAHRRADSTAENDER.
for _,t in ipairs({-65,-35,5,35}) do
    local cafe=Instance.new("Model")
    cafe.Name="Cafe_Aussenbereich"
    cafe.Parent=plaza
    at(cafe,"Cafetisch",Vector3.new(2.8,0.25,2.8),
        t,83,1.15,MAIN,Enum.Material.Wood,rgb(119,83,54))
    at(cafe,"Tischfuss",Vector3.new(0.3,1.0,0.3),
        t,83,0.5,MAIN,Enum.Material.Metal,C.metal)
    for _,offset in ipairs({-3.2,3.2}) do
        at(cafe,"CafeStuhl",Vector3.new(1.4,1.4,1.4),
            t+offset,83,0.85,MAIN,Enum.Material.Wood,rgb(76,93,82))
    end
end
for _,t in ipairs({-95,0,95,190}) do
    local planter=Instance.new("Model")
    planter.Name="Blumenkuebel"
    planter.Parent=plaza
    at(planter,"Pflanzkuebel",Vector3.new(5,1.1,5),
        t,68,0.55,MAIN,Enum.Material.Concrete,rgb(137,135,125))
    createTreeAt(planter,t,68,0.45)
end
for i=1,7 do
    local t=-78+(i-1)*24
    local rack=Instance.new("Model")
    rack.Name="Fahrradstaender"
    rack.Parent=plaza
    at(rack,"Fahrradbügel",Vector3.new(0.18,1.8,2.2),
        t,151,0.9,MAIN,Enum.Material.Metal,C.metal)
end

-- STATICHE FAHRZEUGE: PARKEN AM STRASSENRAND, NIE AUF DEN GLEISEN.
local carColors={
    rgb(191,191,185),rgb(65,83,96),rgb(155,59,47),
    rgb(55,59,61),rgb(205,198,176),rgb(47,94,78)
}
local function createParkedCar(t,s,index)
    local model=Instance.new("Model")
    model.Name="Geparktes_Auto_"..index
    model.Parent=map
    local cf=localFrame(t,s,0.85,MAIN)
    local bodyColor=carColors[(index-1)%#carColors+1]
    part(model,"Karosserie",Vector3.new(5.7,1.7,11.5),
        cf,Enum.Material.Metal,bodyColor,false)
    part(model,"Fahrgastzelle",Vector3.new(4.6,1.7,5.8),
        cf*CFrame.new(0,1.45,-0.5),Enum.Material.Glass,C.glass,false,0.25)
    part(model,"Motorhaube",Vector3.new(5.4,0.65,3.0),
        cf*CFrame.new(0,1.0,-4.1),Enum.Material.Metal,bodyColor,false)
    part(model,"Heck",Vector3.new(5.4,0.65,2.1),
        cf*CFrame.new(0,1.0,4.6),Enum.Material.Metal,bodyColor,false)
    for _,x in ipairs({-2.65,2.65}) do
        for _,z in ipairs({-3.7,3.7}) do
            local wheel=Instance.new("Part")
            wheel.Name="Reifen"
            wheel.Shape=Enum.PartType.Cylinder
            wheel.Size=Vector3.new(0.75,1.65,1.65)
            wheel.CFrame=cf*CFrame.new(x,0.1,z)
            wheel.Anchored=true
            wheel.Material=Enum.Material.Rubber
            wheel.Color=rgb(31,33,34)
            wheel.CanCollide=false
            wheel.Parent=model
        end
    end
    for _,x in ipairs({-1.9,1.9}) do
        part(model,"Scheinwerfer",Vector3.new(0.18,0.38,0.8),
            cf*CFrame.new(x,0.7,-5.82),Enum.Material.Neon,rgb(255,242,202),false)
        part(model,"Ruecklicht",Vector3.new(0.18,0.5,0.8),
            cf*CFrame.new(x,0.7,5.82),Enum.Material.Neon,rgb(194,48,37),false)
    end
end
local carIndex=0
for _,t in ipairs({-555,-455,-355,-255,310,410,510}) do
    for _,side in ipairs({-1,1}) do
        carIndex=carIndex+1
        createParkedCar(t,side*30,carIndex)
    end
end

-- FAHRRAEDER ALS KLEINE SZENENDETAILS.
local function createBicycle(t,s)
    local model=Instance.new("Model")
    model.Name="Fahrrad"
    model.Parent=map
    local cf=localFrame(t,s,1.0,MAIN)
    for _,z in ipairs({-1.65,1.65}) do
        local wheel=Instance.new("Part")
        wheel.Name="Fahrradreifen"
        wheel.Shape=Enum.PartType.Cylinder
        wheel.Size=Vector3.new(0.18,2.0,2.0)
        wheel.CFrame=cf*CFrame.new(0,0,z)
        wheel.Anchored=true
        wheel.Material=Enum.Material.Rubber
        wheel.Color=rgb(35,37,38)
        wheel.Parent=model
    end
    beam(model,"Fahrradrahmen",cf:PointToWorldSpace(Vector3.new(0,1.0,-1.65)),
        cf:PointToWorldSpace(Vector3.new(0,2.0,0)),0.18,0.18,Enum.Material.Metal,C.rnvBlue)
    beam(model,"Fahrradrahmen",cf:PointToWorldSpace(Vector3.new(0,2.0,0)),
        cf:PointToWorldSpace(Vector3.new(0,1.0,1.65)),0.18,0.18,Enum.Material.Metal,C.rnvBlue)
    beam(model,"Fahrradrahmen",cf:PointToWorldSpace(Vector3.new(0,1.0,-1.65)),
        cf:PointToWorldSpace(Vector3.new(0,1.0,1.65)),0.18,0.18,Enum.Material.Metal,C.rnvBlue)
    part(model,"Fahrradsattel",Vector3.new(0.5,0.18,1.0),
        cf*CFrame.new(0,2.2,-0.5),Enum.Material.SmoothPlastic,rgb(34,37,39))
    part(model,"Lenker",Vector3.new(1.7,0.16,0.16),
        cf*CFrame.new(0,2.4,1.2),Enum.Material.Metal,C.metal)
end
createBicycle(-55,145)
createBicycle(-48,145)
createBicycle(165,66)

-- STATISCHE PASSANTEN AUF GEHWEGEN UND PLATZ.
local skinColors={rgb(212,171,137),rgb(181,132,99),rgb(231,194,163)}
local clothingColors={rgb(51,89,120),rgb(157,70,55),rgb(68,104,75),rgb(74,75,83),rgb(183,151,93)}
local function createPedestrian(t,s,index)
    local model=Instance.new("Model")
    model.Name="Passant_"..index
    model.Parent=map
    local cf=localFrame(t,s,0,MAIN)
    local clothes=clothingColors[(index-1)%#clothingColors+1]
    local skin=skinColors[(index-1)%#skinColors+1]
    local lean=(index%2==0) and 0.18 or -0.18
    part(model,"Koerper",Vector3.new(1.35,2.5,0.72),
        cf*CFrame.new(0,2.25,0),Enum.Material.Fabric,clothes,false)
    local head=part(model,"Kopf",Vector3.new(1.05,1.05,1.05),
        cf*CFrame.new(0,4.05,0),Enum.Material.SmoothPlastic,skin,false)
    head.Shape=Enum.PartType.Ball
    part(model,"Bein_L",Vector3.new(0.48,1.8,0.55),
        cf*CFrame.new(-0.38,0.9,0.08),Enum.Material.Fabric,rgb(45,49,55),false)
    part(model,"Bein_R",Vector3.new(0.48,1.8,0.55),
        cf*CFrame.new(0.38,0.9,-0.08),Enum.Material.Fabric,rgb(45,49,55),false)
    part(model,"Arm_L",Vector3.new(0.42,1.9,0.46),
        cf*CFrame.new(-0.88,2.3,lean),Enum.Material.Fabric,clothes,false)
    part(model,"Arm_R",Vector3.new(0.42,1.9,0.46),
        cf*CFrame.new(0.88,2.3,-lean),Enum.Material.Fabric,clothes,false)
end
for i=1,15 do
    local t=-65+(i-1)*17
    local side=(i%2==0) and -1 or 1
    createPedestrian(t,side*52,i)
end
for i=1,6 do
    createPedestrian(-40+i*27,82,20+i)
end

-- STRASSENLAMPEN, MASTEN UND ABFALLBEHAELTER.
local function createLamp(t,s)
    local model=Instance.new("Model")
    model.Name="Strassenlaterne"
    model.Parent=map
    at(model,"Laternenmast",Vector3.new(0.38,10,0.38),
        t,s,5.0,MAIN,Enum.Material.Metal,C.metal)
    at(model,"Laternenarm",Vector3.new(2.8,0.2,0.2),
        t,s-1.2,9.8,MAIN,Enum.Material.Metal,C.metal)
    local head=at(model,"Leuchtenkopf",Vector3.new(1.6,0.4,0.85),
        t,s-2.3,9.65,MAIN,Enum.Material.Metal,rgb(59,65,68))
    at(model,"Leuchtflaeche",Vector3.new(1.3,0.08,0.65),
        t,s-2.3,9.4,MAIN,Enum.Material.Neon,rgb(255,235,194),false)
    local light=Instance.new("PointLight")
    light.Color=rgb(255,226,184)
    light.Brightness=0.6
    light.Range=24
    light.Enabled=false
    light.Parent=head
end
for t=-600,600,95 do
    createLamp(t,-1*62)
    createLamp(t,1*62)
end

for _,t in ipairs({-90,-20,50,130,205}) do
    local bin=Instance.new("Model")
    bin.Name="Abfallbehaelter"
    bin.Parent=plaza
    at(bin,"Abfalltonne",Vector3.new(1.8,2.8,1.8),
        t,150,1.4,MAIN,Enum.Material.Metal,rgb(76,85,83))
    at(bin,"Abfalltonne_Deckel",Vector3.new(2.0,0.2,2.0),
        t,150,2.9,MAIN,Enum.Material.Metal,rgb(48,57,59))
end

-- KLEINE LIEFER- UND PARKBUCHTEN IN DEN NEBENSTRASSEN.
for _,t in ipairs({-300,150,360}) do
    for _,s in ipairs({-285,285}) do
        if not (t==150 and s==285) then
            local bay=Instance.new("Model")
            bay.Name="Parkbucht_Nebenstrasse"
            bay.Parent=map
            local cf=frameAt(world(t,s,0.12),SIDE)
            part(bay,"Parkfeld",Vector3.new(5,0.05,12),
                cf,Enum.Material.Asphalt,rgb(61,64,64))
            part(bay,"Parkfeld_Linie",Vector3.new(0.14,0.04,12),
                cf*CFrame.new(-3,0.05,0),Enum.Material.SmoothPlastic,C.white,false)
        end
    end
end

-- ABSCHLUSS: KEIN SPAWN, KEINE QUADRAT-ORIENTIERUNGSSCHILDER.
print("[RNV Mannheim] MAP V5 - Seckenheim Rathaus wurde erstellt.")
print("[RNV Mannheim] Enthalten: Seckenheimer Hauptstrasse, Rathausplatz, Altes Rathaus, Steig A/B, Bussteige C/D/E, Kehler Strasse, Freiburger Strasse, Brueckenstrasse, Heumarkt, Hauser, Autos, Passanten und Stadtmobiliar.")
print("[RNV Mannheim] Entfernte SpawnLocation-Objekte: "..removedSpawns)
print("[RNV Mannheim] Alle Kartenobjekte sind unter Workspace > RNV_Mannheim_Map bearbeitbar.")