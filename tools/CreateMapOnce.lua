-- RNV MANNHEIM TRAM SIMULATOR | MAP V4
-- Mannheimer Quadrate-Stadt statt Rundkurs.
-- Einmalig in Roblox Studio in die Befehlsleiste einfuegen und ausfuehren.
-- Ersetzt ausschliesslich Workspace.RNV_Mannheim_Map. Alle Teile bleiben editierbar.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local oldMap = Workspace:FindFirstChild("RNV_Mannheim_Map")
if oldMap then oldMap:Destroy() end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace
local rng = Random.new(4517)
local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end

local C = {
    floor=rgb(174,171,161), road=rgb(43,46,49), sidewalk=rgb(184,181,169),
    curb=rgb(207,202,188), track=rgb(78,81,80), sleeper=rgb(105,108,105),
    rail=rgb(151,159,162), metal=rgb(51,63,70), glass=rgb(98,146,166),
    white=rgb(238,235,223), yellow=rgb(244,190,47), blue=rgb(0,103,154),
    green=rgb(71,119,70), darkGreen=rgb(49,91,57), sandstone=rgb(198,176,143),
    cream=rgb(224,209,183), roof=rgb(74,78,81)
}

local function makePart(parent,name,size,cf,material,tint,transparency)
    local p=Instance.new("Part")
    p.Name=name
    p.Anchored=true
    p.Size=size
    p.CFrame=cf
    p.Material=material or Enum.Material.SmoothPlastic
    p.Color=tint or rgb(190,190,190)
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.CastShadow=true
    p.CanTouch=false
    p.Parent=parent or map
    if transparency then p.Transparency=transparency end
    return p
end

local function frameAt(pos,dir)
    dir=Vector3.new(dir.X,0,dir.Z).Unit
    local right=Vector3.new(-dir.Z,0,dir.X)
    return CFrame.fromMatrix(pos,right,Vector3.yAxis,-dir),right
end

local function makeCylinder(parent,name,diameter,height,pos,material,tint)
    local p=Instance.new("Part")
    p.Name=name
    p.Shape=Enum.PartType.Cylinder
    p.Size=Vector3.new(height,diameter,diameter)
    p.CFrame=CFrame.new(pos)*CFrame.Angles(0,0,math.rad(90))
    p.Anchored=true
    p.Material=material
    p.Color=tint
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or map
    return p
end

local function addBillboard(adornee,text,width,height,offset,bg)
    local gui=Instance.new("BillboardGui")
    gui.Name="Beschriftung"
    gui.Adornee=adornee
    gui.Size=UDim2.fromOffset(width,height)
    gui.StudsOffset=offset or Vector3.new(0,4,0)
    gui.AlwaysOnTop=true
    gui.MaxDistance=500
    gui.Parent=adornee
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bg or rgb(26,44,54)
    label.BackgroundTransparency=0.06
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=C.white
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
    local corner=Instance.new("UICorner")
    corner.CornerRadius=UDim.new(0,7)
    corner.Parent=label
end

local function addSideSign(board,text,face,bg)
    local gui=Instance.new("SurfaceGui")
    gui.Name="Schrift"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=34
    gui.LightInfluence=0
    gui.Parent=board
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bg
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=C.white
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
end

local function createTree(pos,scale,parent)
    local model=Instance.new("Model")
    model.Name="Stadtbaum"
    model.Parent=parent or map
    local trunk=5.5*scale
    makePart(model,"Baumstamm",Vector3.new(0.9*scale,trunk,0.9*scale),
        CFrame.new(pos.X,pos.Y+trunk/2,pos.Z),Enum.Material.Wood,rgb(101,73,48))
    local crownPos=Vector3.new(pos.X,pos.Y+trunk+3.1*scale,pos.Z)
    local crowns={
        {6.5*scale,Vector3.new(0,0,0),rgb(58,111,63)},
        {4.7*scale,Vector3.new(-1.7*scale,0.8*scale,0.9*scale),rgb(76,130,73)},
        {4.6*scale,Vector3.new(1.7*scale,0.8*scale,-0.9*scale),rgb(65,120,68)}
    }
    for _,item in ipairs(crowns) do
        local leaf=makePart(model,"Baumkrone",Vector3.new(item[1],item[1],item[1]),
            CFrame.new(crownPos+item[2]),Enum.Material.Grass,item[3])
        leaf.Shape=Enum.PartType.Ball
    end
    return model
end

-- LICHT UND HIMMEL
Lighting.ClockTime=15
Lighting.Brightness=2.2
Lighting.GlobalShadows=true
Lighting.Ambient=rgb(126,129,134)
Lighting.OutdoorAmbient=rgb(156,161,167)
Lighting.EnvironmentDiffuseScale=0.45
Lighting.EnvironmentSpecularScale=0.35
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere=Instance.new("Atmosphere")
    atmosphere.Parent=Lighting
end
atmosphere.Density=0.19
atmosphere.Offset=0.12
atmosphere.Color=rgb(205,219,232)
atmosphere.Decay=rgb(109,126,144)
atmosphere.Glare=0.08
atmosphere.Haze=0.8

-- EIN DURCHGEHENDER, GEPFLASTERTER STADTBODEN.
-- Gruenflaechen entstehen spaeter nur gezielt in Parks und Pflanzbeeten.
makePart(map,"Mannheim_Stadtboden",Vector3.new(1600,4,1600),
    CFrame.new(0,-2,0),Enum.Material.Concrete,C.floor)

-- DAS MANNHEIMER QUADRATERASTER: GERADE STRASSEN UND RECHTECKIGE BLOCKS
local grid={-600,-400,-200,0,200,400,600}
local roadWidth=48
local sidewalkOffset=39
local sidewalkWidth=16

for _,x in ipairs(grid) do
    makePart(map,"NordSuedstrasse",Vector3.new(roadWidth,0.32,1500),
        CFrame.new(x,0.16,0),Enum.Material.Asphalt,C.road)
    for _,side in ipairs({-1,1}) do
        makePart(map,"Gehweg",Vector3.new(sidewalkWidth,0.5,1500),
            CFrame.new(x+side*sidewalkOffset,0.25,0),Enum.Material.Concrete,C.sidewalk)
        makePart(map,"Bordstein",Vector3.new(0.9,0.48,1500),
            CFrame.new(x+side*25,0.24,0),Enum.Material.Concrete,C.curb)
    end
end
for _,z in ipairs(grid) do
    makePart(map,"OstWeststrasse",Vector3.new(1500,0.32,roadWidth),
        CFrame.new(0,0.16,z),Enum.Material.Asphalt,C.road)
    for _,side in ipairs({-1,1}) do
        makePart(map,"Gehweg",Vector3.new(1500,0.5,sidewalkWidth),
            CFrame.new(0,0.25,z+side*sidewalkOffset),Enum.Material.Concrete,C.sidewalk)
        makePart(map,"Bordstein",Vector3.new(1500,0.48,0.9),
            CFrame.new(0,0.24,z+side*25),Enum.Material.Concrete,C.curb)
    end
end

-- STRASSENMARKIERUNGEN
for _,x in ipairs(grid) do
    if x~=0 then
        for z=-690,690,34 do
            makePart(map,"Mittellinie",Vector3.new(0.18,0.035,10),
                CFrame.new(x,0.34,z),Enum.Material.SmoothPlastic,C.white)
        end
    end
end
for _,z in ipairs(grid) do
    if z~=0 then
        for x=-690,690,34 do
            makePart(map,"Mittellinie",Vector3.new(10,0.035,0.18),
                CFrame.new(x,0.34,z),Enum.Material.SmoothPlastic,C.white)
        end
    end
end
local function crossX(x,z)
    for dx=-20,20,4 do
        makePart(map,"Zebrastreifen",Vector3.new(2.2,0.045,15),
            CFrame.new(x+dx,0.36,z),Enum.Material.SmoothPlastic,C.white)
    end
end
local function crossZ(x,z)
    for dz=-20,20,4 do
        makePart(map,"Zebrastreifen",Vector3.new(15,0.045,2.2),
            CFrame.new(x,0.36,z+dz),Enum.Material.SmoothPlastic,C.white)
    end
end
for _,x in ipairs({-400,0,400}) do
    for _,z in ipairs({-400,0,400}) do
        crossX(x,z-34)
        crossX(x,z+34)
        crossZ(x-34,z)
        crossZ(x+34,z)
    end
end

-- GLEISBAU: DOPPELGLEIS MIT BETTUNG, BETONSCHWELLEN UND SCHIENENPROFIL
local function buildTrackSegment(a,b,lineName)
    local diff=b-a
    local totalLen=diff.Magnitude
    if totalLen<0.2 then return end
    local sections=math.ceil(totalLen/22)
    for section=1,sections do
        local p0=a:Lerp(b,(section-1)/sections)
        local p1=a:Lerp(b,section/sections)
        local delta=p1-p0
        local len=delta.Magnitude
        local cf=frameAt((p0+p1)/2,delta.Unit)
        makePart(map,lineName.."_Gleisunterbau",Vector3.new(14.6,0.38,len+0.4),
            cf*CFrame.new(0,0.21,0),Enum.Material.Slate,C.track)

        for _,lane in ipairs({-1,1}) do
            local laneX=lane*4.55
            for d=2.5,len-1,5 do
                makePart(map,lineName.."_Betonschwelle",Vector3.new(4.2,0.2,1.15),
                    cf*CFrame.new(laneX,0.48,d-len/2),
                    Enum.Material.Concrete,C.sleeper)
            end
            for _,railOffset in ipairs({-1.42,1.42}) do
                local railX=laneX+railOffset
                makePart(map,lineName.."_Schienenfuss",Vector3.new(0.72,0.14,len+0.35),
                    cf*CFrame.new(railX,0.64,0),Enum.Material.Metal,C.rail)
                makePart(map,lineName.."_Schienensteg",Vector3.new(0.24,0.36,len+0.35),
                    cf*CFrame.new(railX,0.86,0),Enum.Material.Metal,C.rail)
                makePart(map,lineName.."_Schienenkopf",Vector3.new(0.5,0.16,len+0.35),
                    cf*CFrame.new(railX,1.12,0),Enum.Material.Metal,rgb(176,183,185))
                for d=5,len-1,10 do
                    makePart(map,lineName.."_Schienenbefestigung",Vector3.new(0.72,0.13,0.42),
                        cf*CFrame.new(railX,0.75,d-len/2),
                        Enum.Material.Metal,rgb(65,72,76))
                end
            end
        end
        for _,lane in ipairs({-1,1}) do
            makePart(map,lineName.."_Fahrdraht",Vector3.new(0.09,0.09,len+0.5),
                cf*CFrame.new(lane*4.55,18,0),Enum.Material.Metal,rgb(184,158,101))
        end
    end
end

local function buildTrackLine(points,lineName)
    for i=1,#points-1 do
        buildTrackSegment(points[i],points[i+1],lineName)
    end
end

local function bezierPoints(p0,p1,p2,p3,steps)
    local result={}
    for i=0,steps do
        local t=i/steps
        local u=1-t
        table.insert(result,p0*(u*u*u)+p1*(3*u*u*t)+p2*(3*u*t*t)+p3*(t*t*t))
    end
    return result
end

local lineNorthSouth={Vector3.new(0,0,-760),Vector3.new(0,0,760)}
local lineEastWest={Vector3.new(-760,0,0),Vector3.new(760,0,0)}
local curveSouthEast=bezierPoints(
    Vector3.new(0,0,150),Vector3.new(0,0,275),
    Vector3.new(130,0,400),Vector3.new(260,0,400),18)
table.insert(curveSouthEast,Vector3.new(760,0,400))
local curveNorthWest=bezierPoints(
    Vector3.new(0,0,-150),Vector3.new(0,0,-275),
    Vector3.new(-130,0,-400),Vector3.new(-260,0,-400),18)
table.insert(curveNorthWest,Vector3.new(-760,0,-400))

-- ASPHALTSTRASSEN UNTER DEN KURVEN
local function buildCurvedRoad(points,name)
    for i=1,#points-1 do
        local a,b=points[i],points[i+1]
        local delta=b-a
        local cf,right=frameAt((a+b)/2,delta.Unit)
        local len=delta.Magnitude+1
        makePart(map,name.."_Asphalt",Vector3.new(78,0.28,len),
            cf*CFrame.new(0,0.14,0),Enum.Material.Asphalt,C.road)
        for _,side in ipairs({-1,1}) do
            makePart(map,name.."_Gehweg",Vector3.new(13,0.46,len),
                cf*CFrame.new(side*47,0.23,0),Enum.Material.Concrete,C.sidewalk)
            makePart(map,name.."_Bordstein",Vector3.new(0.8,0.44,len),
                cf*CFrame.new(side*40,0.22,0),Enum.Material.Concrete,C.curb)
        end
    end
end
buildCurvedRoad(curveSouthEast,"Kurvenallee_Suedost")
buildCurvedRoad(curveNorthWest,"Kurvenallee_Nordwest")

-- FAHRLEITUNG UND MASTEN
local function buildMasts(points,lineName)
    local since=0
    for i=1,#points-1 do
        local a,b=points[i],points[i+1]
        local delta=b-a
        local len=delta.Magnitude
        local dir=delta.Unit
        local remaining=48-since
        while remaining<=len do
            local pos=a+dir*remaining
            local cf=frameAt(pos,dir)
            local side=(math.floor((remaining+since)/48)%2==0) and -1 or 1
            local mastCF=cf*CFrame.new(side*18,0,0)
            makePart(map,lineName.."_Mastfuss",Vector3.new(1.4,0.5,1.4),
                mastCF*CFrame.new(0,0.25,0),Enum.Material.Metal,C.metal)
            makePart(map,lineName.."_Oberleitungsmast",Vector3.new(0.48,18.5,0.48),
                mastCF*CFrame.new(0,9.5,0),Enum.Material.Metal,C.metal)
            makePart(map,lineName.."_Quertragwerk",Vector3.new(28,0.28,0.28),
                mastCF*CFrame.new(-side*5.5,17.9,0),Enum.Material.Metal,C.metal)
            makePart(map,lineName.."_Isolator",Vector3.new(0.42,0.8,0.42),
                mastCF*CFrame.new(-side*10,17.35,0),Enum.Material.SmoothPlastic,rgb(209,205,187))
            remaining=remaining+48
        end
        since=(since+len)%48
    end
end

-- STRECKENNETZ: ZWEI HAUPTACHSEN UND ZWEI ABZWEIGE MIT KURVEN
local lines={
    {name="Linie_NordSued",points=lineNorthSouth},
    {name="Linie_OstWest",points=lineEastWest},
    {name="Abzweig_Suedost",points=curveSouthEast},
    {name="Abzweig_Nordwest",points=curveNorthWest}
}
for _,line in ipairs(lines) do
    buildTrackLine(line.points,line.name)
    buildMasts(line.points,line.name)
end

-- HALTESTELLEN MIT ZWEI BAHNSTEIGEN: JE EINER PRO FAHRTRICHTUNG
local function makeStopSide(station,name,baseCF,side)
    local platform=Instance.new("Model")
    platform.Name="Bahnsteig_"..(side<0 and "West" or "Ost")
    platform.Parent=station
    local platformCF=baseCF*CFrame.new(side*18,0.82,0)
    makePart(platform,"Bahnsteigplatte",Vector3.new(17,1.64,142),
        platformCF,Enum.Material.Concrete,rgb(177,176,166))
    makePart(platform,"Bahnsteigkante",Vector3.new(0.42,0.22,142),
        platformCF*CFrame.new(-side*8.25,0.91,0),
        Enum.Material.Concrete,C.yellow)
    makePart(platform,"Blindenleitstreifen",Vector3.new(1.15,0.09,136),
        platformCF*CFrame.new(-side*7.35,0.91,0),
        Enum.Material.SmoothPlastic,rgb(247,204,72))
    for z=-64,64,8 do
        makePart(platform,"Tastfeld",Vector3.new(0.22,0.1,0.22),
            platformCF*CFrame.new(-side*7.35,1.02,z),
            Enum.Material.Neon,C.yellow)
    end

    local shelterX=side*1.4
    makePart(platform,"Wartehalle_Dach",Vector3.new(13,0.72,42),
        platformCF*CFrame.new(shelterX,8.8,0),Enum.Material.Metal,C.metal)
    makePart(platform,"Wartehalle_Dachblende",Vector3.new(13.4,0.24,0.55),
        platformCF*CFrame.new(shelterX,8.35,-21),
        Enum.Material.Metal,C.blue)
    for _,z in ipairs({-19,0,19}) do
        makePart(platform,"Wartehalle_Pfosten",Vector3.new(0.42,8,0.42),
            platformCF*CFrame.new(shelterX-side*5.8,4.7,z),
            Enum.Material.Metal,C.metal)
        makePart(platform,"Wartehalle_Glaswand",Vector3.new(0.16,6.5,17),
            platformCF*CFrame.new(shelterX+side*5.8,4.5,z),
            Enum.Material.Glass,C.glass,0.3)
    end
    makePart(platform,"Wartehalle_Rueckwand",Vector3.new(10.8,6.5,0.16),
        platformCF*CFrame.new(shelterX,4.5,-20.8),
        Enum.Material.Glass,C.glass,0.34)
    for _,z in ipairs({-12,12}) do
        makePart(platform,"Bank_Sitz",Vector3.new(3.6,0.3,1.1),
            platformCF*CFrame.new(shelterX,2.1,z),Enum.Material.Wood,rgb(116,79,52))
        makePart(platform,"Bank_Lehne",Vector3.new(0.2,1.35,3.6),
            platformCF*CFrame.new(shelterX+side*1.8,2.75,z),
            Enum.Material.Wood,rgb(116,79,52))
    end

    local face=side>0 and Enum.NormalId.Left or Enum.NormalId.Right
    local pole=makePart(platform,"Haltestellenmast",Vector3.new(0.42,6.5,0.42),
        platformCF*CFrame.new(side*5.5,3.8,-52),Enum.Material.Metal,C.metal)
    addBillboard(pole,name,190,38,Vector3.new(0,5,0),C.blue)
    local sign=makePart(platform,"RNV_Haltestellenschild",Vector3.new(0.35,4.2,5.8),
        platformCF*CFrame.new(side*5.5,5.3,-52),Enum.Material.SmoothPlastic,C.blue)
    addSideSign(sign,name,face,C.blue)
    local display=makePart(platform,"Abfahrtsanzeige",Vector3.new(0.35,3.0,4.8),
        platformCF*CFrame.new(-side*5.5,4.2,40),
        Enum.Material.SmoothPlastic,rgb(22,39,48))
    addSideSign(display,"RNV  |  LINIE 1 / 5 / 6",face,rgb(22,39,48))
    makePart(platform,"Fahrkartenautomat",Vector3.new(1.5,4.8,1.5),
        platformCF*CFrame.new(side*5.2,3.2,35),Enum.Material.Metal,rgb(72,82,85))
    makePart(platform,"Automat_Display",Vector3.new(0.16,1.7,0.95),
        platformCF*CFrame.new(side*6.05,4.0,35),Enum.Material.Neon,rgb(91,177,202))
    makePart(platform,"Dachbeleuchtung",Vector3.new(0.35,0.16,32),
        platformCF*CFrame.new(shelterX,8.39,0),Enum.Material.Neon,rgb(255,232,188))
end

local function makeStopPair(name,pos,dir)
    local station=Instance.new("Model")
    station.Name="Haltestelle_"..name
    station.Parent=map
    local cf=frameAt(pos,dir)
    makeStopSide(station,name.."  |  Richtung 1",cf,-1)
    makeStopSide(station,name.."  |  Richtung 2",cf,1)
end

makeStopPair("Wasserturm",Vector3.new(0,0,-510),Vector3.new(0,0,1))
makeStopPair("Planken",Vector3.new(0,0,-265),Vector3.new(0,0,1))
makeStopPair("Paradeplatz",Vector3.new(0,0,155),Vector3.new(0,0,1))
makeStopPair("Hauptbahnhof",Vector3.new(0,0,510),Vector3.new(0,0,1))
makeStopPair("Schloss",Vector3.new(-485,0,0),Vector3.new(1,0,0))
makeStopPair("Neckarstadt",Vector3.new(485,0,0),Vector3.new(1,0,0))
makeStopPair("Jungbusch",Vector3.new(-485,0,-400),Vector3.new(1,0,0))
makeStopPair("Schwetzingerstadt",Vector3.new(485,0,400),Vector3.new(1,0,0))

-- HAeUSER MIT ALTBAU-FASSADEN, LADENFRONTEN, FENSTERN UND GESIMSEN
local facadeColors={
    rgb(210,192,164),rgb(190,190,183),rgb(199,177,158),
    rgb(176,190,190),rgb(222,211,190),rgb(171,178,166),
    rgb(193,181,162),rgb(188,168,151),rgb(205,199,186)
}
local shopNames={"CAFÉ","BÄCKEREI","MARKT","APOTHEKE","BUCHHANDLUNG",
    "BLUMEN","KIOSK","RESTAURANT","MODE","STADTTEIL-LADEN"}

local function createCityBuilding(name,groundPos,dir,streetSide,index)
    local height=rng:NextInteger(48,72)
    local depth=rng:NextInteger(34,42)
    local width=rng:NextInteger(52,66)
    local cf=frameAt(Vector3.new(groundPos.X,height/2,groundPos.Z),dir)
    local model=Instance.new("Model")
    model.Name="Haus_"..name
    model.Parent=map
    local facade=facadeColors[(index-1)%#facadeColors+1]
    makePart(model,"Gebaeude_Korpus",Vector3.new(depth,height,width),
        cf,Enum.Material.Concrete,facade)
    makePart(model,"Sockel",Vector3.new(depth+0.7,2,width+0.8),
        cf*CFrame.new(0,-height/2+1,0),Enum.Material.Concrete,rgb(127,126,119))
    makePart(model,"Dachgesims",Vector3.new(depth+1.8,1,width+1.8),
        cf*CFrame.new(0,height/2-0.2,0),Enum.Material.Concrete,C.cream)
    makePart(model,"Flachdach",Vector3.new(depth-2,0.35,width-2),
        cf*CFrame.new(0,height/2+0.45,0),Enum.Material.Slate,C.roof)

    local frontX=-streetSide*(depth/2+0.18)
    local face=streetSide>0 and Enum.NormalId.Left or Enum.NormalId.Right
    -- Ladenfront
    for col=-1,1 do
        local z=col*(width/3)
        makePart(model,"Schaufenster",Vector3.new(0.2,5.0,7.8),
            cf*CFrame.new(frontX,-height/2+4.3,z),
            Enum.Material.Glass,C.glass,0.16)
        makePart(model,"Schaufensterbank",Vector3.new(0.55,0.22,8.2),
            cf*CFrame.new(frontX-streetSide*0.2,-height/2+1.7,z),
            Enum.Material.Concrete,C.cream)
    end
    makePart(model,"Eingangstuer",Vector3.new(0.2,5.4,2.6),
        cf*CFrame.new(frontX,-height/2+4.3,0),
        Enum.Material.Glass,rgb(54,79,88),0.1)
    local shopSign=makePart(model,"Ladenschild",Vector3.new(0.32,2.2,13),
        cf*CFrame.new(frontX-streetSide*0.25,-height/2+8.2,0),
        Enum.Material.SmoothPlastic,index%2==0 and C.blue or rgb(73,103,77))
    addSideSign(shopSign,shopNames[(index-1)%#shopNames+1],face,shopSign.Color)
    makePart(model,"Markise",Vector3.new(2.4,0.25,width-4),
        cf*CFrame.new(frontX-streetSide*1.2,-height/2+9.6,0),
        Enum.Material.Fabric,index%2==0 and rgb(171,72,57) or rgb(48,105,137))

    -- Regelmaessige Altbau-Fensterreihen und helle Fassadenrahmen
    local floors=math.floor((height-16)/9)
    for floor=1,floors do
        local y=-height/2+12+floor*8.5
        for col=-1,1 do
            local z=col*(width/3)
            makePart(model,"Fensterglas",Vector3.new(0.2,4.8,5.8),
                cf*CFrame.new(frontX,y,z),Enum.Material.Glass,C.glass,0.18)
            makePart(model,"Fensterbank",Vector3.new(0.48,0.2,6.3),
                cf*CFrame.new(frontX-streetSide*0.22,y-2.55,z),
                Enum.Material.Concrete,C.cream)
            makePart(model,"Fenstersturz",Vector3.new(0.38,0.18,6.3),
                cf*CFrame.new(frontX-streetSide*0.18,y+2.55,z),
                Enum.Material.Concrete,C.cream)
        end
    end
    for _,z in ipairs({-width/2+1,width/2-1}) do
        makePart(model,"Fassadenpilaster",Vector3.new(0.6,height-3,0.7),
            cf*CFrame.new(frontX-streetSide*0.25,0,z),
            Enum.Material.Concrete,C.cream)
    end
    for _,offset in ipairs({-width/4,width/4}) do
        makePart(model,"Dachaufbau",Vector3.new(4,1.5,4),
            cf*CFrame.new(0,height/2+1.3,offset),
            Enum.Material.Metal,rgb(104,108,109))
    end
end

local buildingIndex=0
for zi=1,#grid-1 do
    for xi=1,#grid-1 do
        local x1,x2=grid[xi],grid[xi+1]
        local z1,z2=grid[zi],grid[zi+1]
        local midX=(x1+x2)/2
        local midZ=(z1+z2)/2
        local reserved=(xi==4 and zi==1) or (xi==3 and zi==3) or (xi==1 and zi==6) or (xi==6 and zi==2)
        local curveClearance=(midX> -220 and midX<360 and midZ>170 and midZ<500)
            or (midX<220 and midX> -360 and midZ< -170 and midZ> -500)
        if not reserved and not curveClearance then
            buildingIndex=buildingIndex+1
            createCityBuilding(string.char(64+zi)..xi,Vector3.new(midX-35,0,z1+68),
                Vector3.new(1,0,0),1,buildingIndex)
            buildingIndex=buildingIndex+1
            createCityBuilding(string.char(64+zi)..xi.."_E",Vector3.new(x2-68,0,midZ+30),
                Vector3.new(0,0,1),1,buildingIndex)
            if (xi+zi)%2==0 then
                buildingIndex=buildingIndex+1
                createCityBuilding(string.char(64+zi)..xi.."_S",Vector3.new(midX+35,0,z2-68),
                    Vector3.new(1,0,0),-1,buildingIndex)
            end
        end
    end
end

-- QUADRAT-SCHILDER: A1 BIS F6 ALS SPIELER-ORIENTIERUNG
for zi=1,#grid-1 do
    for xi=1,#grid-1 do
        local x=grid[xi]+18
        local z=grid[zi]+18
        local pole=makePart(map,"Quadratsschildmast",Vector3.new(0.32,5.5,0.32),
            CFrame.new(x,2.75,z),Enum.Material.Metal,C.metal)
        local plaque=makePart(map,"Quadratsschild",Vector3.new(0.35,2.1,3.5),
            CFrame.new(x,5.2,z),Enum.Material.SmoothPlastic,C.blue)
        addBillboard(plaque,string.char(64+zi)..xi,95,48,Vector3.new(0,1.8,0),C.blue)
    end
end

-- PLAZA UND WAASSERTURM AM FRIEDRICHSPLATZ
local friedrich=Instance.new("Model")
friedrich.Name="Friedrichsplatz_Wasserturm"
friedrich.Parent=map
makePart(friedrich,"Platzpflaster",Vector3.new(178,0.32,180),
    CFrame.new(150,0.18,-500),Enum.Material.Concrete,rgb(188,184,170))
for _,offset in ipairs({Vector3.new(-65,0,-65),Vector3.new(65,0,-65),Vector3.new(-65,0,65),Vector3.new(65,0,65)}) do
    makePart(friedrich,"Zierbeet",Vector3.new(34,0.45,34),
        CFrame.new(150+offset.X,0.25,-500+offset.Z),
        Enum.Material.Ground,C.green)
    createTree(Vector3.new(150+offset.X,0.5,-500+offset.Z),1.05,friedrich)
end
makeCylinder(friedrich,"Brunnenbecken",100,2,Vector3.new(150,1,-500),
    Enum.Material.Concrete,rgb(146,143,132))
makeCylinder(friedrich,"Brunnenwasser",82,0.35,Vector3.new(150,2.1,-500),
    Enum.Material.Water,rgb(95,154,174))

-- Wasserturm: Sandstein-Schaft, Rundgalerie, gruene Kupferkuppel und Spitze
makeCylinder(friedrich,"Wasserturm_Sockel",40,5,Vector3.new(150,4.8,-500),
    Enum.Material.Concrete,C.sandstone)
makeCylinder(friedrich,"Wasserturm_Schaft",30,48,Vector3.new(150,30,-500),
    Enum.Material.Concrete,C.sandstone)
makeCylinder(friedrich,"Wasserturm_Galerie",40,7,Vector3.new(150,57.5,-500),
    Enum.Material.Concrete,C.cream)
local dome=makePart(friedrich,"Wasserturm_Kuppel",Vector3.new(39,19,39),
    CFrame.new(150,69.5,-500),Enum.Material.Metal,rgb(64,103,91))
dome.Shape=Enum.PartType.Ball
makeCylinder(friedrich,"Wasserturm_Laterne",13,12,Vector3.new(150,79,-500),
    Enum.Material.Metal,rgb(65,101,87))
local cap=makePart(friedrich,"Wasserturm_Laternendach",Vector3.new(17,6,17),
    CFrame.new(150,87.5,-500),Enum.Material.Metal,rgb(55,91,78))
cap.Shape=Enum.PartType.Ball
makeCylinder(friedrich,"Wasserturm_Spitze",2.2,10,Vector3.new(150,94,-500),
    Enum.Material.Metal,rgb(58,91,78))
local tip=makePart(friedrich,"Wasserturm_Kugel",Vector3.new(3,3,3),
    CFrame.new(150,100,-500),Enum.Material.Metal,rgb(65,104,89))
tip.Shape=Enum.PartType.Ball

for levelY=21,46,18 do
    for i=0,11 do
        local angle=(math.pi*2*i)/12
        local x=150+math.cos(angle)*15.15
        local z=-500+math.sin(angle)*15.15
        local cf=CFrame.new(x,levelY,z)*CFrame.Angles(0,-angle,0)
        makePart(friedrich,"Wasserturm_Fenster",Vector3.new(0.28,5,2.2),
            cf,Enum.Material.Glass,rgb(63,91,101),0.05)
    end
end
for i=0,11 do
    local angle=(math.pi*2*i)/12
    local x=150+math.cos(angle)*20.2
    local z=-500+math.sin(angle)*20.2
    makePart(friedrich,"Galerie_Bogenpfeiler",Vector3.new(1.1,5.5,1.1),
        CFrame.new(x,57.4,z),Enum.Material.Concrete,C.sandstone)
end
addBillboard(makePart(friedrich,"Wasserturm_Name",Vector3.new(1,1,1),
    CFrame.new(150,104,-500),Enum.Material.SmoothPlastic,C.blue),
    "MANNHEIMER WASSERTURM",230,48,Vector3.new(0,4,0),C.blue)

-- PARADEPLATZ: OFFENER, GEPFLASTERTER STADTPLATZ MIT BRUNNEN
local parade=Instance.new("Model")
parade.Name="Paradeplatz"
parade.Parent=map
makePart(parade,"Platzflaeche",Vector3.new(160,0.38,150),
    CFrame.new(-100,0.2,-100),Enum.Material.Concrete,rgb(190,186,173))
makeCylinder(parade,"Brunnen_Sockel",34,2.2,Vector3.new(-100,1.2,-100),
    Enum.Material.Concrete,rgb(124,126,124))
makeCylinder(parade,"Brunnen_Wasser",27,0.45,Vector3.new(-100,2.45,-100),
    Enum.Material.Water,rgb(87,150,171))
makeCylinder(parade,"Brunnen_Saeule",5,9,Vector3.new(-100,7,-100),
    Enum.Material.Metal,rgb(119,126,127))
local statue=makePart(parade,"Brunnen_Figur",Vector3.new(5,8,5),
    CFrame.new(-100,14,-100),Enum.Material.Metal,rgb(135,128,105))
statue.Shape=Enum.PartType.Ball
for _,dx in ipairs({-58,58}) do
    for _,dz in ipairs({-52,52}) do
        createTree(Vector3.new(-100+dx,0.4,-100+dz),0.9,parade)
    end
end
addBillboard(makePart(parade,"Paradeplatz_Schild",Vector3.new(1,1,1),
    CFrame.new(-100,3,-100),Enum.Material.SmoothPlastic,C.blue),
    "PARADEPLATZ",170,38,Vector3.new(0,3,0),C.blue)

-- MANNHEIMER SCHLOSS: GROSSER BAROCKER GEBaeUDEKOMPLEX
local castle=Instance.new("Model")
castle.Name="Schloss_Mannheim"
castle.Parent=map
makePart(castle,"Schloss_Hauptbau",Vector3.new(170,54,64),
    CFrame.new(-500,27,480),Enum.Material.Concrete,C.sandstone)
makePart(castle,"Schloss_Fluegel_West",Vector3.new(58,43,58),
    CFrame.new(-615,21.5,480),Enum.Material.Concrete,C.cream)
makePart(castle,"Schloss_Fluegel_Ost",Vector3.new(58,43,58),
    CFrame.new(-385,21.5,480),Enum.Material.Concrete,C.cream)
makePart(castle,"Schloss_Gesims",Vector3.new(184,2.0,70),
    CFrame.new(-500,54,480),Enum.Material.Concrete,C.cream)
makePart(castle,"Schloss_Dach",Vector3.new(174,2.5,66),
    CFrame.new(-500,56,480),Enum.Material.Slate,C.roof)
for x=-575, -425, 25 do
    for y=12,43,14 do
        makePart(castle,"Schloss_Fenster",Vector3.new(0.22,6,5.5),
            CFrame.new(x,y,512.2),Enum.Material.Glass,C.glass,0.08)
    end
end
for x=-630,-370,26 do
    makePart(castle,"Schloss_Fenster_Fluegel",Vector3.new(5.5,5,0.22),
        CFrame.new(x,20,509.2),Enum.Material.Glass,C.glass,0.08)
end
for _,x in ipairs({-615,-385}) do
    makeCylinder(castle,"Schloss_Turm",18,46,Vector3.new(x,66,480),
        Enum.Material.Concrete,C.cream)
    local roof=makePart(castle,"Schloss_Turmdach",Vector3.new(21,9,21),
        CFrame.new(x,92,480),Enum.Material.Metal,rgb(69,91,83))
    roof.Shape=Enum.PartType.Ball
end
local castleSign=makePart(castle,"Schloss_Schild",Vector3.new(0.5,5,35),
    CFrame.new(-500,35,513),Enum.Material.SmoothPlastic,C.blue)
addBillboard(castleSign,"SCHLOSS MANNHEIM",210,42,Vector3.new(0,4,0),C.blue)

-- MARKTPLATZ MIT MARKTSTAeNDEN
local market=Instance.new("Model")
market.Name="Marktplatz"
market.Parent=map
makePart(market,"Marktplatz_Pflaster",Vector3.new(145,0.35,130),
    CFrame.new(500,0.18,-300),Enum.Material.Concrete,rgb(185,181,168))
for i=1,4 do
    local x=455+(i-1)*30
    makePart(market,"Marktstand_Dach",Vector3.new(24,0.6,18),
        CFrame.new(x,10,-300),Enum.Material.Fabric,
        i%2==0 and rgb(173,70,55) or rgb(58,111,141))
    for _,dx in ipairs({-10,10}) do
        makePart(market,"Marktstand_Pfosten",Vector3.new(0.6,9,0.6),
            CFrame.new(x+dx,4.5,-308),Enum.Material.Wood,rgb(105,76,53))
        makePart(market,"Marktstand_Pfosten",Vector3.new(0.6,9,0.6),
            CFrame.new(x+dx,4.5,-292),Enum.Material.Wood,rgb(105,76,53))
    end
    makePart(market,"Markttisch",Vector3.new(18,2,4),
        CFrame.new(x,2,-300),Enum.Material.Wood,rgb(131,95,61))
end
addBillboard(makePart(market,"Marktplatz_Schild",Vector3.new(1,1,1),
    CFrame.new(500,3,-300),Enum.Material.SmoothPlastic,C.blue),
    "MARKTPLATZ",170,38,Vector3.new(0,3,0),C.blue)

-- PARKFLAeCHEN UND BAUMREIHEN: GRUEN NUR AN GEPLANTEN ORTEN
local park=Instance.new("Model")
park.Name="Friedrichspark"
park.Parent=map
makePart(park,"Parkwiese",Vector3.new(115,0.25,95),
    CFrame.new(360,0.12,180),Enum.Material.Grass,C.green)
for _,offset in ipairs({Vector3.new(-40,0,0),Vector3.new(40,0,0),
    Vector3.new(0,0,-32),Vector3.new(0,0,32)}) do
    createTree(Vector3.new(360+offset.X,0.25,180+offset.Z),0.95,park)
end
for _,x in ipairs({-520,-320,320,520}) do
    for z=-560,560,160 do
        if math.abs(x)>280 then
            createTree(Vector3.new(x,0.45,z),0.9,park)
        end
    end
end

-- NECKAR UND BRueCKE AM NORDRAND
makePart(map,"Neckar_Wasser",Vector3.new(1600,0.25,82),
    CFrame.new(0,0.08,-710),Enum.Material.Water,rgb(83,143,164))
makePart(map,"Neckar_Ufer_West",Vector3.new(1600,0.5,8),
    CFrame.new(0,0.25,-665),Enum.Material.Concrete,rgb(144,146,139))
makePart(map,"Neckar_Ufer_Ost",Vector3.new(1600,0.5,8),
    CFrame.new(0,0.25,-755),Enum.Material.Concrete,rgb(144,146,139))
makePart(map,"Neckarbruecke_Fahrbahn",Vector3.new(112,0.42,180),
    CFrame.new(0,0.36,-710),Enum.Material.Asphalt,C.road)
for _,x in ipairs({-54,54}) do
    makePart(map,"Neckarbruecke_Gelaender",Vector3.new(1.2,4,180),
        CFrame.new(x,2.5,-710),Enum.Material.Metal,C.metal)
end
addBillboard(makePart(map,"Neckarbruecke_Schild",Vector3.new(1,1,1),
    CFrame.new(0,5,-710),Enum.Material.SmoothPlastic,C.blue),
    "NECKARBRÜCKE",180,40,Vector3.new(0,4,0),C.blue)

-- STRASSENLAMPEN AN DEN WICHTIGSTEN ACHSEN
local function createStreetLight(x,z)
    local model=Instance.new("Model")
    model.Name="Strassenlaterne"
    model.Parent=map
    makePart(model,"Laternenmast",Vector3.new(0.42,10,0.42),
        CFrame.new(x,5,z),Enum.Material.Metal,C.metal)
    makePart(model,"Laternenarm",Vector3.new(2.8,0.22,0.22),
        CFrame.new(x+1.0,9.8,z),Enum.Material.Metal,C.metal)
    local head=makePart(model,"Leuchtenkopf",Vector3.new(1.6,0.38,0.85),
        CFrame.new(x+2.1,9.65,z),Enum.Material.Metal,rgb(57,63,66))
    makePart(model,"Leuchtflaeche",Vector3.new(1.25,0.1,0.62),
        CFrame.new(x+2.1,9.4,z),Enum.Material.Neon,rgb(255,235,193))
    local light=Instance.new("PointLight")
    light.Color=rgb(255,225,180)
    light.Brightness=0.7
    light.Range=24
    light.Enabled=false
    light.Parent=head
end
for z=-560,560,112 do
    createStreetLight(48,z)
    createStreetLight(-48,z)
end
for x=-560,560,140 do
    createStreetLight(x,48)
    createStreetLight(x,-48)
end

-- KREUZUNGSAMPELN AN DEN GROSSEN PLATZBEREICHEN
for _,pos in ipairs({Vector3.new(-28,0,-28),Vector3.new(28,0,-28),
    Vector3.new(-28,0,28),Vector3.new(28,0,28),
    Vector3.new(-428,0,28),Vector3.new(428,0,-28)}) do
    local pole=makePart(map,"Ampelmast",Vector3.new(0.35,5.5,0.35),
        CFrame.new(pos.X,2.75,pos.Z),Enum.Material.Metal,C.metal)
    local housing=makePart(map,"Ampel_Gehaeuse",Vector3.new(0.8,2.2,0.8),
        CFrame.new(pos.X,5.5,pos.Z),Enum.Material.Metal,rgb(34,39,42))
    for i,tint in ipairs({rgb(220,57,48),rgb(238,185,48),rgb(61,179,91)}) do
        local lamp=makePart(map,"Ampel_Licht",Vector3.new(0.44,0.44,0.16),
            CFrame.new(pos.X,6.2-(i-1)*0.65,pos.Z-0.48),
            Enum.Material.Neon,tint)
        lamp.Shape=Enum.PartType.Ball
    end
end

print("[RNV Mannheim] MAP V4 erstellt: Mannheimer Quadrate, einheitlicher Stadtboden, zwei Hauptachsen, zwei Kurvenabzweige, acht Haltestellen mit Bahnsteigen auf beiden Seiten, Wasserturm, Paradeplatz, Schloss und Neckar.")
print("[RNV Mannheim] Alle Kartenobjekte liegen unter Workspace > RNV_Mannheim_Map und sind in Studio bearbeitbar.")