-- RNV MANNHEIM TRAM SIMULATOR | MAP V5 - SECKENHEIM RATHAUS
-- Lokaler Nachbau des Bereichs Seckenheim Rathaus / Seckenheimer Hauptstrasse.
-- Einmalig in Roblox Studio in die Befehlsleiste einfuegen und ausfuehren.
-- Ersetzt nur Workspace.RNV_Mannheim_Map und entfernt SpawnLocation-Objekte.
-- Keine Quadrat-Wegweiser oder kuenstlichen Richtungsbeschreibungen.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
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
    ground=rgb(164,161,151), asphalt=rgb(47,49,51), asphaltDark=rgb(39,42,44),
    sidewalk=rgb(180,177,165), cobble=rgb(143,139,128), curb=rgb(203,198,184),
    rail=rgb(151,158,160), railHead=rgb(183,188,188), sleeper=rgb(105,107,104),
    metal=rgb(49,61,68), glass=rgb(105,151,169), white=rgb(239,235,222),
    yellow=rgb(244,190,49), blue=rgb(0,103,154), townHall=rgb(222,195,132),
    trim=rgb(241,224,188), roofRed=rgb(142,58,42), roofDark=rgb(75,65,57),
    leaf1=rgb(62,116,68), leaf2=rgb(77,132,73), leaf3=rgb(88,140,77)
}

-- Koordinaten drehen die Hauptstrasse diagonal, wie im Ortskern.
local MAIN = Vector3.new(1,0,-1).Unit
local SIDE = Vector3.new(1,0,1).Unit
local UP = Vector3.new(0,1,0)
local function world(t,s,y)
    return MAIN*t + SIDE*s + UP*(y or 0)
end
local function frameAt(pos,dir)
    dir=Vector3.new(dir.X,0,dir.Z).Unit
    local right=Vector3.new(-dir.Z,0,dir.X)
    return CFrame.fromMatrix(pos,right,UP,-dir)
end
local function localFrame(t,s,y,dir)
    return frameAt(world(t,s,y),dir or MAIN)
end
local function part(parent,name,size,cf,material,tint,collide,transparency)
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
    if collide~=nil then p.CanCollide=collide end
    if transparency then p.Transparency=transparency end
    p.Parent=parent or map
    return p
end
local function at(parent,name,size,t,s,y,dir,material,tint,collide,transparency)
    return part(parent,name,size,localFrame(t,s,y,dir or MAIN),material,tint,collide,transparency)
end
local function beam(parent,name,a,b,thickness,material,tint)
    local cf=CFrame.lookAt((a+b)/2,b,SIDE)
    return part(parent,name,Vector3.new(thickness,thickness,(b-a).Magnitude),
        cf,material,tint)
end
local function surfaceText(board,text,face,bg,txtColor)
    local gui=Instance.new("SurfaceGui")
    gui.Name="Beschriftung"
    gui.Face=face
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=38
    gui.LightInfluence=0
    gui.Parent=board
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bg
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=txtColor or C.white
    label.TextScaled=true
    label.TextWrapped=true
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
end
local function billboard(board,text,width,height,bg)
    local gui=Instance.new("BillboardGui")
    gui.Name="Ortsbeschriftung"
    gui.Adornee=board
    gui.Size=UDim2.fromOffset(width,height)
    gui.StudsOffset=Vector3.new(0,4,0)
    gui.AlwaysOnTop=true
    gui.MaxDistance=350
    gui.Parent=board
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bg or C.blue
    label.BackgroundTransparency=0.08
    label.BorderSizePixel=0
    label.Text=text
    label.TextColor3=C.white
    label.TextScaled=true
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
end
local function cylinder(parent,name,diameter,height,cf,material,tint)
    local p=Instance.new("Part")
    p.Name=name
    p.Shape=Enum.PartType.Cylinder
    p.Size=Vector3.new(height,diameter,diameter)
    p.CFrame=cf*CFrame.Angles(0,0,math.rad(90))
    p.Anchored=true
    p.Material=material
    p.Color=tint
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.Parent=parent or map
    return p
end

-- Licht und Himmel.
Lighting.ClockTime=15.1
Lighting.Brightness=2.15
Lighting.GlobalShadows=true
Lighting.Ambient=rgb(124,127,132)
Lighting.OutdoorAmbient=rgb(156,160,166)
Lighting.EnvironmentDiffuseScale=0.42
Lighting.EnvironmentSpecularScale=0.32
local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere")
if not atmosphere then
    atmosphere=Instance.new("Atmosphere")
    atmosphere.Parent=Lighting
end
atmosphere.Density=0.18
atmosphere.Offset=0.12
atmosphere.Color=rgb(207,220,232)
atmosphere.Decay=rgb(112,129,148)
atmosphere.Glare=0.08
atmosphere.Haze=0.75

-- Ein einziger durchgehender Untergrund.
part(map,"Seckenheim_Gesamtboden",Vector3.new(1800,4,1800),
    CFrame.new(0,-2.05,0),Enum.Material.Concrete,C.ground)

-- Seckenheimer Hauptstrasse, Gehwege und Bordsteine.
part(map,"Seckenheimer_Hauptstrasse",Vector3.new(82,0.24,1420),
    localFrame(0,0,0.12),Enum.Material.Asphalt,C.asphalt)
for _,side in ipairs({-1,1}) do
    at(map,"Gehweg_Hauptstrasse",Vector3.new(18,0.38,1420),
        0,side*50,0.27,MAIN,Enum.Material.Concrete,C.sidewalk)
    at(map,"Bordstein_Hauptstrasse",Vector3.new(0.9,0.45,1420),
        0,side*41,0.26,MAIN,Enum.Material.Concrete,C.curb)
    at(map,"Gehweg_Pflasterband",Vector3.new(11,0.16,1380),
        0,side*66,0.12,MAIN,Enum.Material.Cobblestone,C.cobble)
end

-- Strassenbahngleise: Schwellen sowie Schienenfuss, Steg und Kopf.
at(map,"Strassenbahngleis_Bettung",Vector3.new(19,0.14,1320),
    0,0,0.25,MAIN,Enum.Material.Asphalt,C.asphaltDark)
for _,trackSide in ipairs({-1,1}) do
    local center=trackSide*3.75
    for z=-650,650,5 do
        at(map,"Betonschwelle",Vector3.new(5.4,0.12,1.0),
            z,center,0.32,MAIN,Enum.Material.Concrete,C.sleeper)
    end
    for _,offset in ipairs({-1.38,1.38}) do
        local railS=center+offset
        at(map,"Schienenfuss",Vector3.new(0.72,0.10,1320),
            0,railS,0.37,MAIN,Enum.Material.Metal,C.rail)
        at(map,"Schienensteg",Vector3.new(0.24,0.20,1320),
            0,railS,0.51,MAIN,Enum.Material.Metal,C.rail)
        at(map,"Schienenkopf",Vector3.new(0.48,0.10,1320),
            0,railS,0.66,MAIN,Enum.Material.Metal,C.railHead)
        for z=-645,645,15 do
            at(map,"Schienenbefestigung",Vector3.new(0.72,0.10,0.38),
                z,railS,0.43,MAIN,Enum.Material.Metal,rgb(65,72,75))
        end
    end
end

-- Oberleitung mit Masten und Quertraegern.
for z=-640,640,52 do
    local side=(math.floor((z+640)/52)%2==0) and -1 or 1
    at(map,"Oberleitungsmast_Fuss",Vector3.new(1.5,0.48,1.5),
        z,side*18,0.3,MAIN,Enum.Material.Metal,C.metal)
    at(map,"Oberleitungsmast",Vector3.new(0.5,16,0.5),
        z,side*18,8.25,MAIN,Enum.Material.Metal,C.metal)
    at(map,"Oberleitung_Quertraeger",Vector3.new(27,0.26,0.26),
        z,side*5,15.8,MAIN,Enum.Material.Metal,C.metal)
    at(map,"Oberleitung_Isolator",Vector3.new(0.48,0.82,0.48),
        z,-side*5,15.25,MAIN,Enum.Material.SmoothPlastic,rgb(205,201,184))
end
for _,trackSide in ipairs({-1,1}) do
    at(map,"Oberleitungsdraht",Vector3.new(0.1,0.1,1320),
        0,trackSide*3.75,15.1,MAIN,Enum.Material.Metal,rgb(188,160,101))
end

-- Spur- und Radwegmarkierungen.
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

-- Nebenstrassen um den Rathausplatz.
local function sideStreet(name,tConst,s1,s2)
    local center=(s1+s2)/2
    local length=math.abs(s2-s1)
    local cf=frameAt(world(tConst,center,0.16),SIDE)
    part(map,name.."_Fahrbahn",Vector3.new(34,0.28,length),
        cf,Enum.Material.Asphalt,C.asphalt)
    for _,edge in ipairs({-17,17}) do
        part(map,name.."_Bordstein",Vector3.new(0.75,0.44,length),
            cf*CFrame.new(edge,0.23,0),Enum.Material.Concrete,C.curb)
    end
    for _,edge in ipairs({-25,25}) do
        part(map,name.."_Gehweg",Vector3.new(10,0.34,length),
            cf*CFrame.new(edge,0.18,0),Enum.Material.Concrete,C.sidewalk)
    end
end
sideStreet("Freiburger_Strasse",-300,-390,-42)
sideStreet("Kehler_Strasse",150,42,390)
sideStreet("Brueckenstrasse",360,-390,-42)
sideStreet("Heumarkt_Zufahrt",250,42,300)

-- Geschwungene Zufahrten, aber kein Rundkurs.
local function curvedStreet(name,points,width)
    for i=1,#points-1 do
        local a,b=points[i],points[i+1]
        local cf=frameAt((a+b)/2,(b-a).Unit)
        part(map,name.."_Kurvenfahrbahn",Vector3.new(width,0.24,(b-a).Magnitude+0.1),
            cf*CFrame.new(0,0.15,0),Enum.Material.Asphalt,C.asphalt)
    end
end
curvedStreet("Kehler_Strassenbogen",{
    world(145,42),world(168,95),world(210,145),world(250,205)
},34)
curvedStreet("Brueckenstrassenbogen",{
    world(330,-42),world(350,-95),world(385,-145),world(425,-205)
},34)

-- Steig A und B: Bahnsteige auf beiden Seiten der Strassenbahngleise.
local function tramPlatform(steig,side)
    local model=Instance.new("Model")
    model.Name="Steig_"..steig
    model.Parent=map
    local base=localFrame(-15,side*22,0.52)
    part(model,"Bahnsteigplatte",Vector3.new(15,0.8,100),
        base,Enum.Material.Concrete,rgb(174,173,164))
    part(model,"Bahnsteigkante",Vector3.new(0.38,0.16,100),
        base*CFrame.new(-side*7.2,0.50,0),Enum.Material.Concrete,C.yellow)
    part(model,"Taststreifen",Vector3.new(1.15,0.08,96),
        base*CFrame.new(-side*6.55,0.50,0),Enum.Material.SmoothPlastic,rgb(246,203,71))
    for z=-45,45,5 do
        part(model,"Tastnoppen",Vector3.new(0.22,0.08,0.22),
            base*CFrame.new(-side*6.55,0.59,z),Enum.Material.Neon,C.yellow,false)
    end
    local shelterS=side*1.2
    part(model,"Wartehalle_Dach",Vector3.new(13,0.65,38),
        base*CFrame.new(shelterS,7.7,0),Enum.Material.Metal,C.metal)
    part(model,"Wartehalle_Dachblende",Vector3.new(13.3,0.24,0.55),
        base*CFrame.new(shelterS,7.35,-19),Enum.Material.Metal,C.blue)
    for _,z in ipairs({-17,0,17}) do
        part(model,"Wartehalle_Pfosten",Vector3.new(0.4,7.5,0.4),
            base*CFrame.new(shelterS-side*5.9,4.2,z),Enum.Material.Metal,C.metal)
    end
    part(model,"Wartehalle_Glaswand",Vector3.new(0.16,6.2,34),
        base*CFrame.new(shelterS+side*5.9,4.1,0),Enum.Material.Glass,C.glass,false,0.3)
    part(model,"Wartehalle_Rueckglas",Vector3.new(10.8,6.2,0.16),
        base*CFrame.new(shelterS,4.1,-18.8),Enum.Material.Glass,C.glass,false,0.34)
    for _,z in ipairs({-11,11}) do
        part(model,"Sitzbank",Vector3.new(3.6,0.3,1.0),
            base*CFrame.new(shelterS,1.55,z),Enum.Material.Wood,rgb(117,80,52))
    end
    local mast=part(model,"Haltestellenmast",Vector3.new(0.4,6.0,0.4),
        base*CFrame.new(side*5.6,3.7,-40),Enum.Material.Metal,C.metal)
    billboard(mast,"SECKENHEIM RATHAUS",190,34,C.blue)
    local face=side>0 and Enum.NormalId.Left or Enum.NormalId.Right
    local sign=part(model,"RNV_Steigschild",Vector3.new(0.3,3.3,4.2),
        base*CFrame.new(side*5.5,4.2,-40),Enum.Material.SmoothPlastic,C.blue)
    surfaceText(sign,"RNV  |  STEIG "..steig,face,C.blue,C.white)
    local display=part(model,"Abfahrtsanzeige",Vector3.new(0.25,2.6,3.7),
        base*CFrame.new(-side*5.4,3.6,38),Enum.Material.SmoothPlastic,rgb(26,42,50))
    surfaceText(display,"LINIE 5 / 40",face,rgb(26,42,50),C.white)
    part(model,"Fahrkartenautomat",Vector3.new(1.3,4.2,1.4),
        base*CFrame.new(side*5.4,2.9,30),Enum.Material.Metal,rgb(76,84,85))
    part(model,"Automat_Bildschirm",Vector3.new(0.12,1.6,0.9),
        base*CFrame.new(side*6.1,3.6,30),Enum.Material.Neon,rgb(93,175,202),false)
    part(model,"Dachlicht",Vector3.new(0.3,0.12,29),
        base*CFrame.new(shelterS,7.34,0),Enum.Material.Neon,rgb(255,233,193),false)
end
tramPlatform("A",-1)
tramPlatform("B",1)

-- Bussteige C, D und E neben dem Rathausplatz.
local function busBay(letter,t,s)
    local model=Instance.new("Model")
    model.Name="Bussteig_"..letter
    model.Parent=map
    local cf=localFrame(t,s,0.38)
    part(model,"Bussteig_Plattform",Vector3.new(12,0.75,38),
        cf,Enum.Material.Concrete,rgb(177,175,163))
    part(model,"Bussteig_Leitkante",Vector3.new(0.28,0.12,38),
        cf*CFrame.new(-5.7,0.43,0),Enum.Material.Concrete,C.yellow)
    local pole=part(model,"Bussteig_Mast",Vector3.new(0.35,4.5,0.35),
        cf*CFrame.new(4.5,2.4,-11),Enum.Material.Metal,C.metal)
    local board=part(model,"Bussteig_Schild",Vector3.new(0.25,2.5,2.2),
        cf*CFrame.new(4.5,4.0,-11),Enum.Material.SmoothPlastic,C.blue)
    surfaceText(board,"STEIG "..letter,Enum.NormalId.Left,C.blue,C.white)
    billboard(pole,"SECKENHEIM RATHAUS",160,30,C.blue)
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
busBay("C",48,104)
busBay("D",112,104)
busBay("E",176,104)

-- Seckenheimer Planken und Rathausplatz.
local plaza=Instance.new("Model")
plaza.Name="Seckenheimer_Planken_Rathausplatz"
plaza.Parent=map
at(plaza,"Rathausplatz_Pflaster",Vector3.new(98,0.24,248),
    65,108,0.14,MAIN,Enum.Material.Cobblestone,C.cobble)
at(plaza,"Natursteinband",Vector3.new(3,0.07,230),
    65,62,0.30,MAIN,Enum.Material.Slate,rgb(116,113,106))
at(plaza,"Heumarkt_Pflaster",Vector3.new(70,0.22,125),
    265,200,0.13,MAIN,Enum.Material.Cobblestone,C.cobble)

-- Altes Rathaus: gelbe Fassade, rotes Dach, Arkaden und Uhrturm.
local town=Instance.new("Model")
town.Name="Altes_Rathaus_Seckenheim"
town.Parent=map
local townT,townS=70,184
local h,depth,length=38,48,108
local cf=localFrame(townT,townS,h/2)
part(town,"Rathaus_Hauptbau",Vector3.new(depth,h,length),cf,Enum.Material.Concrete,C.townHall)
part(town,"Rathaus_Sockel",Vector3.new(depth+1.4,2,length+1.8),
    cf*CFrame.new(0,-h/2+1,0),Enum.Material.Concrete,rgb(183,166,139))
part(town,"Rathaus_Gesims",Vector3.new(depth+2,1,length+2),
    cf*CFrame.new(0,h/2-0.4,0),Enum.Material.Concrete,C.trim)
for _,side in ipairs({-1,1}) do
    part(town,"Rathaus_Ziegeldach",Vector3.new(depth/2+2,1.4,length+5),
        cf*CFrame.new(side*depth/4,h/2+5,0)*CFrame.Angles(0,0,side*math.rad(23)),
        Enum.Material.Slate,C.roofRed)
end
at(town,"Rathaus_Dachfirst",Vector3.new(1.2,1,length+7),
    townT,townS,h+10,MAIN,Enum.Material.Wood,C.roofDark)

local frontX=-depth/2-0.22
for floor=1,2 do
    local y=(floor==1) and 10 or 25
    for z=-42,42,21 do
        part(town,"Rathaus_Fensterglas",Vector3.new(0.22,7,7.2),
            cf*CFrame.new(frontX,y,z),Enum.Material.Glass,rgb(92,115,122),false,0.08)
        for _,dz in ipairs({-3.7,3.7}) do
            part(town,"Rathaus_Fensterrahmen",Vector3.new(0.34,7.5,0.22),
                cf*CFrame.new(frontX-0.10,y,z+dz),Enum.Material.Concrete,C.trim)
        end
        for _,dy in ipairs({-3.65,3.65}) do
            part(town,"Rathaus_Fensterrahmen",Vector3.new(0.34,0.22,7.5),
                cf*CFrame.new(frontX-0.10,y+dy,z),Enum.Material.Concrete,C.trim)
        end
    end
end

-- Arkadenboegen und Pfeiler.
for arch=-2,2 do
    local zCenter=arch*18
    for _,zSide in ipairs({-5.4,5.4}) do
        cylinder(town,"Rathaus_Arkadenpfeiler",1.7,8.8,
            cf*CFrame.new(frontX-0.55,4.4,zCenter+zSide),Enum.Material.Concrete,C.trim)
    end
    local points={}
    for step=0,8 do
        local angle=math.pi-step*math.pi/8
        local y=8.4+4.1*math.sin(angle)
        local z=zCenter+5.4*math.cos(angle)
        table.insert(points,cf:PointToWorldSpace(Vector3.new(frontX-0.6,y,z)))
    end
    for i=1,#points-1 do
        beam(town,"Rathaus_Rundbogen",points[i],points[i+1],0.9,
            Enum.Material.Concrete,C.trim)
    end
end
part(town,"Rathaus_Haupteingang",Vector3.new(0.24,9,8),
    cf*CFrame.new(frontX-0.3,5.2,0),Enum.Material.Wood,rgb(83,65,48))
part(town,"Rathaus_Eingangsstufe",Vector3.new(4,0.6,13),
    cf*CFrame.new(frontX-2.3,0.3,0),Enum.Material.Concrete,C.trim)

-- Uhrturm.
part(town,"Uhrturm_Sockel",Vector3.new(18,9,18),
    cf*CFrame.new(0,h+10,5),Enum.Material.Concrete,C.trim)
part(town,"Uhrturm_Korpus",Vector3.new(14,19,14),
    cf*CFrame.new(0,h+23,5),Enum.Material.Wood,rgb(54,49,44))
part(town,"Uhrturm_Gesims",Vector3.new(17,1.2,17),
    cf*CFrame.new(0,h+33,5),Enum.Material.Metal,C.metal)
for _,faceX in ipairs({-7.2,7.2}) do
    local dial=part(town,"Uhrturm_Zifferblatt",Vector3.new(0.25,6,6),
        cf*CFrame.new(faceX,h+23,5),Enum.Material.SmoothPlastic,rgb(244,236,208))
    surfaceText(dial,"12\n—",faceX<0 and Enum.NormalId.Left or Enum.NormalId.Right,
        rgb(244,236,208),rgb(44,48,47))
end
local turret=part(town,"Uhrturm_Dach",Vector3.new(18,13,18),
    cf*CFrame.new(0,h+41,5),Enum.Material.Metal,rgb(48,52,52))
turret.Shape=Enum.PartType.Ball
part(town,"Uhrturm_Spitze",Vector3.new(0.8,8,0.8),
    cf*CFrame.new(0,h+50,5),Enum.Material.Metal,C.metal)
local title=part(town,"Rathaus_Name",Vector3.new(1,1,1),
    cf*CFrame.new(0,h+55,5),Enum.Material.SmoothPlastic,C.blue,false)
billboard(title,"ALTES RATHAUS SECKENHEIM",250,42,C.blue)

-- Historische Geschaefts- und Wohnhaeuser mit sichtbaren Fensterrahmen.
local facades={rgb(214,194,164),rgb(196,189,174),rgb(206,177,157),
    rgb(181,191,190),rgb(224,211,187),rgb(193,178,157),rgb(202,202,190),rgb(187,166,151)}
local shopNames={"BÄCKEREI","APOTHEKE","FRISEUR","CAFÉ","BLUMEN","KIOSK","GASTSTÄTTE","ARZTPRAXIS","SUPERMARKT"}
local function createHouse(name,center,dir,streetSide,index)
    local height=rng:NextInteger(27,42)
    local d=rng:NextInteger(31,39)
    local len=rng:NextInteger(40,53)
    local houseCF=frameAt(center+UP*(height/2),dir)
    local model=Instance.new("Model")
    model.Name=name
    model.Parent=map
    local facade=facades[(index-1)%#facades+1]
    part(model,"Hauskoerper",Vector3.new(d,height,len),houseCF,Enum.Material.Concrete,facade)
    part(model,"Sockel",Vector3.new(d+0.7,1.7,len+0.8),
        houseCF*CFrame.new(0,-height/2+0.85,0),Enum.Material.Concrete,rgb(137,130,116))
    local front=-streetSide*(d/2+0.15)
    for col=-1,1 do
        local z=col*len/3
        part(model,"Schaufenster",Vector3.new(0.18,5.7,7),
            houseCF*CFrame.new(front,3.4-height/2+2.8,z),
            Enum.Material.Glass,C.glass,false,0.16)
    end
    part(model,"Haustuer",Vector3.new(0.2,6,3.1),
        houseCF*CFrame.new(front,3.1-height/2+2.8,0),Enum.Material.Wood,rgb(78,61,46))
    local sign=part(model,"Geschaeftsschild",Vector3.new(0.28,2.1,12),
        houseCF*CFrame.new(front-streetSide*0.2,5.7-height/2+5,0),
        Enum.Material.SmoothPlastic,index%2==0 and C.blue or rgb(75,103,75))
    local face=streetSide>0 and Enum.NormalId.Left or Enum.NormalId.Right
    surfaceText(sign,shopNames[(index-1)%#shopNames+1],face,sign.Color,C.white)
    part(model,"Markise",Vector3.new(2.4,0.24,len-4),
        houseCF*CFrame.new(front-streetSide*1.15,7.5-height/2+5,0),
        Enum.Material.Fabric,index%2==0 and rgb(174,71,57) or rgb(55,109,139))
    local floors=math.min(math.floor((height-10)/9),3)
    for floor=1,floors do
        local y=-height/2+10+floor*8.3
        for col=-1,1 do
            local z=col*len/3
            part(model,"Fensterglas",Vector3.new(0.18,4.5,4.5),
                houseCF*CFrame.new(front,y,z),Enum.Material.Glass,C.glass,false,0.14)
            for _,dz in ipairs({-2.35,2.35}) do
                part(model,"Fensterrahmen",Vector3.new(0.32,4.8,0.2),
                    houseCF*CFrame.new(front-streetSide*0.1,y,z+dz),Enum.Material.Concrete,C.trim)
            end
            for _,dy in ipairs({-2.35,2.35}) do
                part(model,"Fensterrahmen",Vector3.new(0.32,0.2,4.8),
                    houseCF*CFrame.new(front-streetSide*0.1,y+dy,z),Enum.Material.Concrete,C.trim)
            end
            part(model,"Blumenkasten",Vector3.new(0.65,0.55,4.2),
                houseCF*CFrame.new(front-streetSide*0.35,y-2.7,z),Enum.Material.Wood,rgb(106,75,49))
            part(model,"Fensterladen_L",Vector3.new(0.22,4.2,0.65),
                houseCF*CFrame.new(front-streetSide*0.22,y,z-2.7),Enum.Material.Wood,rgb(85,108,91))
            part(model,"Fensterladen_R",Vector3.new(0.22,4.2,0.65),
                houseCF*CFrame.new(front-streetSide*0.22,y,z+2.7),Enum.Material.Wood,rgb(85,108,91))
        end
    end
    for _,roofSide in ipairs({-1,1}) do
        part(model,"Ziegeldach",Vector3.new(d/2+2,1.0,len+3),
            houseCF*CFrame.new(roofSide*d/4,height/2+2.8,0)
                *CFrame.Angles(0,0,roofSide*math.rad(27)),
            Enum.Material.Slate,index%2==0 and C.roofRed or C.roofDark)
    end
    part(model,"Dachfirst",Vector3.new(1.0,0.9,len+4),
        houseCF*CFrame.new(0,height/2+5.3,0),Enum.Material.Metal,C.roofRed)
    for _,offset in ipairs({-len/4,len/4}) do
        part(model,"Dachgaube",Vector3.new(5,4,5),
            houseCF*CFrame.new(-streetSide*d/4,height/2+4,offset),Enum.Material.Concrete,facade)
    end
end

local houseIndex=0
for t=-590,590,88 do
    houseIndex=houseIndex+1
    createHouse("Altstadthaus_West_"..houseIndex,world(t,-91,0),MAIN,-1,houseIndex)
    if t < -150 or t > 205 then
        houseIndex=houseIndex+1
        createHouse("Altstadthaus_Ost_"..houseIndex,world(t,91,0),MAIN,1,houseIndex)
    end
end
for _,tConst in ipairs({-300,360}) do
    for s=-300,300,105 do
        if math.abs(s)>105 then
            houseIndex=houseIndex+1
            createHouse("Nebenstrassenhaus_"..houseIndex,world(tConst,s,0),SIDE,1,houseIndex)
        end
    end
end

-- Platanen, Baenke, Marktstaende, Pergola und Aussenbereich eines Cafes.
local function tree(parent,t,s,scale)
    local model=Instance.new("Model")
    model.Name="Platane"
    model.Parent=parent or map
    local base=world(t,s,0.3)
    local trunk=6.2*scale
    part(model,"Baumstamm",Vector3.new(1.1*scale,trunk,1.1*scale),
        CFrame.new(base+UP*(trunk/2)),Enum.Material.Wood,rgb(102,78,54))
    local center=base+UP*(trunk+3.1*scale)
    local crowns={{7.4*scale,Vector3.new(0,0,0),C.leaf1},
        {5.4*scale,Vector3.new(2*scale,0.8*scale,1.2*scale),C.leaf2},
        {5.1*scale,Vector3.new(-2*scale,0.7*scale,-1.3*scale),C.leaf3}}
    for _,spec in ipairs(crowns) do
        local leaf=part(model,"Baumkrone",Vector3.new(spec[1],spec[1],spec[1]),
            CFrame.new(center+spec[2]),Enum.Material.Grass,spec[3],false)
        leaf.Shape=Enum.PartType.Ball
    end
end
for _,t in ipairs({-38,28,94,160}) do tree(plaza,t,145,1.0) end
for _,t in ipairs({-35,55,145}) do tree(plaza,t,72,0.85) end

local function bench(parent,t,s)
    local cf=localFrame(t,s,0.8)
    local model=Instance.new("Model")
    model.Name="Parkbank"
    model.Parent=parent or map
    part(model,"Sitzflaeche",Vector3.new(4.4,0.3,1.1),cf,Enum.Material.Wood,rgb(112,77,50))
    part(model,"Rueckenlehne",Vector3.new(0.24,1.4,4.4),
        cf*CFrame.new(0.5,0.65,0),Enum.Material.Wood,rgb(112,77,50))
    for _,z in ipairs({-1.5,1.5}) do
        part(model,"Bankfuss",Vector3.new(0.18,0.75,0.18),
            cf*CFrame.new(0,-0.3,z),Enum.Material.Metal,C.metal)
    end
end
bench(plaza,-45,130)
bench(plaza,0,130)
bench(plaza,125,130)

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

for i=1,4 do
    local t=-25+(i-1)*48
    local stall=Instance.new("Model")
    stall.Name="Wochenmarktstand_"..i
    stall.Parent=plaza
    at(stall,"Markttisch",Vector3.new(5,2,15),t,112,1.1,MAIN,Enum.Material.Wood,rgb(121,86,56))
    at(stall,"Marktdach",Vector3.new(8,0.55,18),t,112,8.4,MAIN,Enum.Material.Fabric,
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
for _,t in ipairs({-65,-35,5,35}) do
    local cafe=Instance.new("Model")
    cafe.Name="Cafe_Aussenbereich"
    cafe.Parent=plaza
    at(cafe,"Cafetisch",Vector3.new(2.8,0.25,2.8),t,83,1.15,MAIN,Enum.Material.Wood,rgb(119,83,54))
    at(cafe,"Tischfuss",Vector3.new(0.3,1.0,0.3),t,83,0.5,MAIN,Enum.Material.Metal,C.metal)
    for _,offset in ipairs({-3.2,3.2}) do
        at(cafe,"CafeStuhl",Vector3.new(1.4,1.4,1.4),
            t+offset,83,0.85,MAIN,Enum.Material.Wood,rgb(76,93,82))
    end
end
for _,t in ipairs({-95,0,95,190}) do
    local planter=Instance.new("Model")
    planter.Name="Blumenkuebel"
    planter.Parent=plaza
    at(planter,"Pflanzkuebel",Vector3.new(5,1.1,5),t,68,0.55,MAIN,Enum.Material.Concrete,rgb(137,135,125))
    tree(planter,t,68,0.85)
end

-- Geparkte Autos ausserhalb der Gleise.
local carColors={rgb(191,191,185),rgb(65,83,96),rgb(155,59,47),
    rgb(55,59,61),rgb(205,198,176),rgb(47,94,78)}
local function parkedCar(t,s,index)
    local model=Instance.new("Model")
    model.Name="Geparktes_Auto_"..index
    model.Parent=map
    local cf=localFrame(t,s,0.85)
    local body=carColors[(index-1)%#carColors+1]
    part(model,"Karosserie",Vector3.new(5.7,1.7,11.5),cf,Enum.Material.Metal,body,false)
    part(model,"Fahrgastzelle",Vector3.new(4.6,1.7,5.8),
        cf*CFrame.new(0,1.45,-0.5),Enum.Material.Glass,C.glass,false,0.25)
    part(model,"Motorhaube",Vector3.new(5.4,0.65,3.0),
        cf*CFrame.new(0,1.0,-4.1),Enum.Material.Metal,body,false)
    part(model,"Heck",Vector3.new(5.4,0.65,2.1),
        cf*CFrame.new(0,1.0,4.6),Enum.Material.Metal,body,false)
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
end
local carIndex=0
for _,t in ipairs({-555,-455,-355,-255,310,410,510}) do
    for _,side in ipairs({-1,1}) do
        carIndex=carIndex+1
        parkedCar(t,side*30,carIndex)
    end
end

-- Passanten auf Gehwegen und Rathausplatz.
local skinColors={rgb(212,171,137),rgb(181,132,99),rgb(231,194,163)}
local clothes={rgb(51,89,120),rgb(157,70,55),rgb(68,104,75),rgb(74,75,83),rgb(183,151,93)}
local function pedestrian(t,s,index)
    local model=Instance.new("Model")
    model.Name="Passant_"..index
    model.Parent=map
    local cf=localFrame(t,s,0)
    local outfit=clothes[(index-1)%#clothes+1]
    local skin=skinColors[(index-1)%#skinColors+1]
    part(model,"Koerper",Vector3.new(1.35,2.5,0.72),
        cf*CFrame.new(0,2.25,0),Enum.Material.Fabric,outfit,false)
    local head=part(model,"Kopf",Vector3.new(1.05,1.05,1.05),
        cf*CFrame.new(0,4.05,0),Enum.Material.SmoothPlastic,skin,false)
    head.Shape=Enum.PartType.Ball
    part(model,"Bein_L",Vector3.new(0.48,1.8,0.55),
        cf*CFrame.new(-0.38,0.9,0.08),Enum.Material.Fabric,rgb(45,49,55),false)
    part(model,"Bein_R",Vector3.new(0.48,1.8,0.55),
        cf*CFrame.new(0.38,0.9,-0.08),Enum.Material.Fabric,rgb(45,49,55),false)
    part(model,"Arm_L",Vector3.new(0.42,1.9,0.46),
        cf*CFrame.new(-0.88,2.3,0.12),Enum.Material.Fabric,outfit,false)
    part(model,"Arm_R",Vector3.new(0.42,1.9,0.46),
        cf*CFrame.new(0.88,2.3,-0.12),Enum.Material.Fabric,outfit,false)
end
for i=1,15 do
    pedestrian(-65+(i-1)*17,(i%2==0 and -1 or 1)*52,i)
end
for i=1,6 do pedestrian(-40+i*27,82,20+i) end

-- Laternen und Abfallbehaelter.
local function streetLamp(t,s)
    local model=Instance.new("Model")
    model.Name="Strassenlaterne"
    model.Parent=map
    at(model,"Laternenmast",Vector3.new(0.38,10,0.38),t,s,5,MAIN,Enum.Material.Metal,C.metal)
    at(model,"Laternenarm",Vector3.new(2.8,0.2,0.2),t,s-1.2,9.8,MAIN,Enum.Material.Metal,C.metal)
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
    streetLamp(t,-62)
    streetLamp(t,62)
end
for _,t in ipairs({-90,-20,50,130,205}) do
    local bin=Instance.new("Model")
    bin.Name="Abfallbehaelter"
    bin.Parent=plaza
    at(bin,"Abfalltonne",Vector3.new(1.8,2.8,1.8),t,150,1.4,MAIN,Enum.Material.Metal,rgb(76,85,83))
    at(bin,"Deckel",Vector3.new(2.0,0.2,2.0),t,150,2.9,MAIN,Enum.Material.Metal,rgb(48,57,59))
end

print("[RNV Mannheim] MAP V5 - Seckenheim Rathaus wurde erstellt.")
print("[RNV Mannheim] Hauptstrasse, Altes Rathaus, Rathausplatz, Steig A/B, Bussteige C/D/E, Freiburger Strasse, Kehler Strasse, Brueckenstrasse, Heumarkt, Altstadthaeuser, Autos und Passanten.")
print("[RNV Mannheim] Entfernte SpawnLocation-Objekte: "..removedSpawns)
print("[RNV Mannheim] Alle Kartenobjekte sind unter Workspace > RNV_Mannheim_Map bearbeitbar.")