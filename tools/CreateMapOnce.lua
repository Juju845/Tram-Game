-- RNV MANNHEIM TRAM SIMULATOR | CITY MAP V9
-- Vollstaendiger visueller Neuaufbau: Innenstadt-Quadrate, Rhein/Neckar, Hafen,
-- Schloss, Hauptbahnhof, Wasserturm/Friedrichsplatz, Oststadt, Wohnviertel,
-- Seckenheim, Haltestellen, Strassen, Schienen, Oberleitung und Stadtmobiliar.
-- Einmalig in Roblox Studio Command Bar ausfuehren (nicht im Play-Modus).
-- Alle Weltobjekte sind normale, einzeln editierbare Studio-Parts.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local old = Workspace:FindFirstChild("RNV_Mannheim_Map")
if old then old:Destroy() end
local baseplate = Workspace:FindFirstChild("Baseplate")
if baseplate and baseplate:IsA("BasePart") then baseplate:Destroy() end
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("SpawnLocation") then obj:Destroy() end
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local C = {
    ground=rgb(105,130,91), grass=rgb(78,126,75), grass2=rgb(97,143,83),
    asphalt=rgb(43,47,52), asphalt2=rgb(54,58,62), pavement=rgb(177,174,164),
    curb=rgb(219,213,195), concrete=rgb(145,147,141), trackbed=rgb(79,82,82),
    rail=rgb(179,188,193), steel=rgb(57,68,75), glass=rgb(117,174,193),
    cream=rgb(226,211,184), yellow=rgb(226,183,79), brick=rgb(163,101,75),
    roof=rgb(75,68,62), darkroof=rgb(49,54,58), white=rgb(241,238,225),
    blue=rgb(0,91,143), wood=rgb(116,81,54), green=rgb(59,111,67),
    water=rgb(57,126,151), skin=rgb(205,160,124), red=rgb(165,55,48)
}
local function folder(name,parent)
    local f=Instance.new("Folder"); f.Name=name; f.Parent=parent or map; return f
end
local function model(name,parent)
    local m=Instance.new("Model"); m.Name=name; m.Parent=parent or map; return m
end
local function part(parent,name,size,cf,mat,col,collide,transparency)
    local p=Instance.new("Part")
    p.Name=name; p.Size=size
    local base=typeof(cf)=="CFrame" and cf or CFrame.new(cf)
    p.CFrame=base
    p.Anchored=true
    p.Material=mat or Enum.Material.SmoothPlastic
    p.Color=col or C.white
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.CastShadow=true
    p.CanTouch=false
    if collide~=nil then p.CanCollide=collide end
    if transparency~=nil then p.Transparency=transparency end
    p.Parent=parent or map
    return p
end
local function ball(parent,name,size,pos,mat,col)
    local p=part(parent,name,size,pos,mat,col,false)
    p.Shape=Enum.PartType.Ball
    return p
end
local function cylinder(parent,name,size,cf,mat,col)
    local p=part(parent,name,size,cf,mat,col)
    p.Shape=Enum.PartType.Cylinder
    return p
end
local function signFace(p,txt,face,bg)
    local gui=Instance.new("SurfaceGui")
    gui.Face=face or Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=28
    gui.LightInfluence=0
    gui.Parent=p
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1)
    label.BackgroundColor3=bg or C.blue
    label.BorderSizePixel=0
    label.Text=txt
    label.TextColor3=C.white
    label.TextScaled=true
    label.Font=Enum.Font.GothamBold
    label.Parent=gui
end
local function faceOf(front)
    return front==1 and Enum.NormalId.Back or Enum.NormalId.Front
end

-- Beleuchtung und Atmosphaere fuer ein helles, modernes Stadtbild.
Lighting.Technology=Enum.Technology.Future
Lighting.ClockTime=15.1
Lighting.Brightness=2.25
Lighting.GlobalShadows=true
Lighting.ShadowSoftness=0.28
Lighting.Ambient=rgb(112,119,127)
Lighting.OutdoorAmbient=rgb(164,171,178)
Lighting.EnvironmentDiffuseScale=0.62
Lighting.EnvironmentSpecularScale=0.52
for _,name in ipairs({"RNV_Atmosphere","RNV_Color","RNV_Bloom","RNV_Sun"}) do
    local effect=Lighting:FindFirstChild(name)
    if effect then effect:Destroy() end
end
local atmosphere=Instance.new("Atmosphere")
atmosphere.Name="RNV_Atmosphere"
atmosphere.Density=0.24
atmosphere.Offset=0.12
atmosphere.Color=rgb(199,218,232)
atmosphere.Decay=rgb(103,119,139)
atmosphere.Glare=0.18
atmosphere.Haze=1.1
atmosphere.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect")
cc.Name="RNV_Color"
cc.Brightness=0.025
cc.Contrast=0.10
cc.Saturation=0.08
cc.TintColor=rgb(255,249,238)
cc.Parent=Lighting
local bloom=Instance.new("BloomEffect")
bloom.Name="RNV_Bloom"
bloom.Intensity=0.16
bloom.Size=24
bloom.Threshold=1.8
bloom.Parent=Lighting
local sun=Instance.new("SunRaysEffect")
sun.Name="RNV_Sun"
sun.Intensity=0.035
sun.Spread=0.75
sun.Parent=Lighting

-- Stadtgrund: eine einzige glatte Flaeche, keine Kachel- oder Rastertextur.
part(map,"Stadtgrund",Vector3.new(6200,8,6200),Vector3.new(0,-4.2,0),Enum.Material.SmoothPlastic,C.ground,true)
part(map,"Gruenflaeche_Rand",Vector3.new(6000,0.15,6000),Vector3.new(0,0.02,0),Enum.Material.Grass,C.ground,false)

-- Fluesse und Ufer: Neckar im Norden, Rhein am westlichen Kartenrand.
part(map,"Neckar_Wasser",Vector3.new(5650,4,250),Vector3.new(0,0.1,-2710),Enum.Material.Water,C.water,false,0.12)
part(map,"Neckar_Suedufer",Vector3.new(5650,1.1,22),Vector3.new(0,0.55,-2572),Enum.Material.Concrete,rgb(153,151,137))
part(map,"Neckar_Nordufer",Vector3.new(5650,1.1,22),Vector3.new(0,0.55,-2848),Enum.Material.Concrete,rgb(153,151,137))
part(map,"Rhein_Wasser",Vector3.new(250,4,5650),Vector3.new(-2710,0.08,0),Enum.Material.Water,C.water,false,0.12)
part(map,"Rhein_Ostufer",Vector3.new(22,1.1,5650),Vector3.new(-2572,0.55,0),Enum.Material.Concrete,rgb(153,151,137))
part(map,"Rhein_Westufer",Vector3.new(22,1.1,5650),Vector3.new(-2848,0.55,0),Enum.Material.Concrete,rgb(153,151,137))

-- Strassenbau: durchgehende Fahrbahnen mit Buergersteigen und Bordsteinen.
local function roadX(x,z0,z1,width,name)
    local len=z1-z0
    part(map,name or "Strasse",Vector3.new(width,0.28,len),Vector3.new(x,0.17,(z0+z1)/2),Enum.Material.Asphalt,C.asphalt)
    for _,s in ipairs({-1,1}) do
        part(map,"Bordstein",Vector3.new(1.3,0.32,len),Vector3.new(x+s*(width/2+0.65),0.24,(z0+z1)/2),Enum.Material.Concrete,C.curb)
        part(map,"Gehweg",Vector3.new(8,0.22,len),Vector3.new(x+s*(width/2+5.3),0.12,(z0+z1)/2),Enum.Material.Concrete,C.pavement)
    end
end
local function roadZ(z,x0,x1,width,name)
    local len=x1-x0
    part(map,name or "Strasse",Vector3.new(len,0.28,width),Vector3.new((x0+x1)/2,0.17,z),Enum.Material.Asphalt,C.asphalt)
    for _,s in ipairs({-1,1}) do
        part(map,"Bordstein",Vector3.new(len,0.32,1.3),Vector3.new((x0+x1)/2,0.24,z+s*(width/2+0.65)),Enum.Material.Concrete,C.curb)
        part(map,"Gehweg",Vector3.new(len,0.22,8),Vector3.new((x0+x1)/2,0.12,z+s*(width/2+5.3)),Enum.Material.Concrete,C.pavement)
    end
end

-- Mannheimer Quadrate: regelmaessige Blocks, aber mit unterschiedlichen Nutzungen.
local streets={-1080,-780,-480,-180,120,420,720,1020}
for _,x in ipairs(streets) do roadX(x,-1120,1120,42,"Innenstadtstrasse") end
for _,z in ipairs(streets) do roadZ(z,-1120,1120,42,"Innenstadtstrasse") end
-- Groessere Ausfallstrassen und Ringverbindungen.
roadX(-1500,-2350,2350,54,"Ausfallstrasse")
roadX(1500,-2350,2350,54,"Ausfallstrasse")
roadZ(-1450,-2250,2250,54,"Ausfallstrasse")
roadZ(1450,-2250,2250,54,"Ausfallstrasse")
roadX(-2150,-2300,2300,38,"Hafenstrasse")
roadZ(2050,-2300,2300,38,"SuedlicheRingstrasse")

-- Dezente Fahrbahnmarkierungen auf Hauptachsen.
for z=-2300,2300,54 do
    part(map,"Mittellinie",Vector3.new(0.35,0.035,18),Vector3.new(-1500,0.325,z),Enum.Material.SmoothPlastic,C.white,false)
    part(map,"Mittellinie",Vector3.new(0.35,0.035,18),Vector3.new(1500,0.325,z),Enum.Material.SmoothPlastic,C.white,false)
end
for x=-2200,2200,54 do
    part(map,"Mittellinie",Vector3.new(18,0.035,0.35),Vector3.new(x,0.325,1450),Enum.Material.SmoothPlastic,C.white,false)
end
-- Fussgaengerueberwege an den grossen Kreuzungen.
for _,z in ipairs({-780,-180,420,1020,1450}) do
    for i=-4,4 do
        part(map,"Zebrastreifen",Vector3.new(4,0.04,0.75),Vector3.new(i*6,0.34,z-30),Enum.Material.SmoothPlastic,C.white,false)
        part(map,"Zebrastreifen",Vector3.new(4,0.04,0.75),Vector3.new(i*6,0.34,z+30),Enum.Material.SmoothPlastic,C.white,false)
    end
end
for _,x in ipairs({-1080,-480,120,720,1500}) do
    for i=-4,4 do
        part(map,"Zebrastreifen",Vector3.new(0.75,0.04,4),Vector3.new(x-30,0.34,i*6),Enum.Material.SmoothPlastic,C.white,false)
        part(map,"Zebrastreifen",Vector3.new(0.75,0.04,4),Vector3.new(x+30,0.34,i*6),Enum.Material.SmoothPlastic,C.white,false)
    end
end

-- Schienenprofile mit Schienenfuss, Steg und Kopf; Schwellen liegen einzeln editierbar.
local function railBar(axis,x,z,length,sizeY,sizeX,name,col)
    local size,cf
    if axis=="Z" then size=Vector3.new(sizeX,sizeY,length); cf=Vector3.new(x,0.48,z)
    else size=Vector3.new(length,sizeY,sizeX); cf=Vector3.new(x,0.48,z) end
    part(map,name,size,cf,Enum.Material.Metal,col,false)
end
local function track(axis,center,fixed,startPos,endPos)
    local length=endPos-startPos
    local mid=(startPos+endPos)/2
    if axis=="Z" then
        part(map,"Gleisfeld",Vector3.new(17,0.32,length),Vector3.new(center,0.23,mid),Enum.Material.Concrete,C.trackbed)
    else
        part(map,"Gleisfeld",Vector3.new(length,0.32,17),Vector3.new(mid,0.23,fixed),Enum.Material.Concrete,C.trackbed)
    end
    for z=startPos, endPos, 11 do
        if axis=="Z" then
            part(map,"Betonschwelle",Vector3.new(15,0.22,1.25),Vector3.new(center,0.38,z),Enum.Material.Concrete,rgb(118,120,116))
        else
            part(map,"Betonschwelle",Vector3.new(1.25,0.22,15),Vector3.new(z,0.38,fixed),Enum.Material.Concrete,rgb(118,120,116))
        end
    end
    for _,trackOffset in ipairs({-2.55,2.55}) do
        for _,gauge in ipairs({-0.72,0.72}) do
            local coord=center+trackOffset+gauge
            local baseY=0.52
            local function railPiece(name,offsetY,width,height,col)
                local sz,cf
                if axis=="Z" then sz=Vector3.new(width,height,length); cf=Vector3.new(coord,baseY+offsetY,mid)
                else sz=Vector3.new(length,height,width); cf=Vector3.new(mid,baseY+offsetY,fixed+trackOffset+gauge-center) end
                -- Fuer horizontale Strecken liegt die Gleismitte auf fixed, die vier Schienen sind versetzt.
                if axis=="X" then cf=Vector3.new(mid,baseY+offsetY,fixed+trackOffset+gauge) end
                for k=0,math.ceil(length/1500)-1 do
                    local segStart=startPos+k*1500
                    local segLen=math.min(1500,endPos-segStart)
                    local segMid=segStart+segLen/2
                    local segSize
                    if axis=="Z" then segSize=Vector3.new(width,height,segLen); cf=Vector3.new(coord,baseY+offsetY,segMid)
                    else segSize=Vector3.new(segLen,height,width); cf=Vector3.new(segMid,baseY+offsetY,fixed+trackOffset+gauge) end
                    part(map,name,segSize,cf,Enum.Material.Metal,col,false)
                end
            end
            railPiece("Schienenfuss",0,0.92,0.14,C.steel)
            railPiece("Schienensteg",0.16,0.25,0.42,C.rail)
            railPiece("Schienenkopf",0.45,0.52,0.17,rgb(205,211,214))
        end
    end
    -- Oberleitungsmasten, Quertraeger und Fahrdraht.
    for pos=startPos+20,endPos-20,105 do
        for _,side in ipairs({-1,1}) do
            local mx=center+side*14
            local mz=axis=="Z" and pos or fixed+side*14
            local px=axis=="X" and pos or mx
            part(map,"Oberleitungsmast",Vector3.new(0.75,17,0.75),Vector3.new(px,8.5,mz),Enum.Material.Metal,C.steel)
            part(map,"Ausleger",axis=="Z" and Vector3.new(31,0.35,0.35) or Vector3.new(0.35,0.35,31),Vector3.new(px,16.5,mz),Enum.Material.Metal,C.steel)
        end
    end
    for _,trackOffset in ipairs({-2.55,2.55}) do
        local wireX=axis=="Z" and center+trackOffset or (startPos+endPos)/2
        local wireZ=axis=="Z" and (startPos+endPos)/2 or fixed+trackOffset
        local wireSize=axis=="Z" and Vector3.new(0.12,0.12,length) or Vector3.new(length,0.12,0.12)
        for k=0,math.ceil(length/1500)-1 do
            local segStart=startPos+k*1500
            local segLen=math.min(1500,endPos-segStart)
            local segMid=segStart+segLen/2
            local pos=axis=="Z" and Vector3.new(wireX,16,segMid) or Vector3.new(segMid,16,wireZ)
            local size=axis=="Z" and Vector3.new(0.12,0.12,segLen) or Vector3.new(segLen,0.12,0.12)
            part(map,"Fahrdraht",size,pos,Enum.Material.Metal,rgb(191,171,129),false)
        end
    end
end
track("Z",120,120,-2500,2450)
track("X",0,120,-2200,2200)
track("Z",1500,1500,-1800,2250)

-- Historische und moderne Gebaeude. Jede Fassade wird aus Studio-Parts aufgebaut.
local facades={rgb(221,204,177),rgb(190,186,174),rgb(205,174,151),rgb(181,196,190),rgb(226,216,194),rgb(179,160,143),rgb(202,196,183)}
local roofs={rgb(68,62,59),rgb(103,70,61),rgb(58,65,69),rgb(91,78,68)}
local shopNames={"CAFÉ","BÄCKEREI","MARKT","BLUMEN","KIOSK","APOTHEKE","BUCHLADEN","RESTAURANT"}
local rng=Random.new(20261117)
local function building(name,x,z,w,d,h,front,style,shop)
    local m=model(name)
    local facade=facades[rng:NextInteger(1,#facades)]
    local floors=math.max(2,math.floor(h/8))
    part(m,"Gebaeudekoerper",Vector3.new(w,h,d),Vector3.new(x,h/2,z),Enum.Material.Concrete,facade)
    part(m,"Sockel",Vector3.new(w+1,1.0,d+1),Vector3.new(x,0.5,z),Enum.Material.Concrete,rgb(139,133,121))
    part(m,"Dachplatte",Vector3.new(w+2,1.0,d+2),Vector3.new(x,h+0.5,z),Enum.Material.Concrete,roofs[rng:NextInteger(1,#roofs)])
    -- Dachaufbauten geben den Gebaeuden eine erkennbare Silhouette.
    if style=="modern" then
        part(m,"Dachtechnik",Vector3.new(w*0.38,2.2,d*0.34),Vector3.new(x+w*0.18,h+2,z-d*0.1),Enum.Material.Metal,rgb(117,122,124))
        part(m,"Attika",Vector3.new(w,1.1,0.7),Vector3.new(x,h+1.1,z+d/2),Enum.Material.Concrete,facade)
    elseif style=="historic" then
        part(m,"Dachgaube",Vector3.new(w*0.22,3.0,2.5),Vector3.new(x,h+2.0,z-d*0.2),Enum.Material.Brick,roofs[2])
    end
    local faceZ=z+front*(d/2+0.16)
    for floor=1,floors do
        local y=3.4+(floor-1)*7.0
        for col=-1,1 do
            if not (shop and floor==1 and col==0) then
                local wx=x+col*(w/3.7)
                local win=part(m,"Fenster",Vector3.new(5.4,4.4,0.24),Vector3.new(wx,y,faceZ),Enum.Material.Glass,C.glass,false,0.08)
                part(m,"Fensterrahmen_oben",Vector3.new(5.8,0.22,0.38),Vector3.new(wx,y+2.3,faceZ+front*0.08),Enum.Material.Concrete,C.white,false)
                part(m,"Fensterbank",Vector3.new(5.8,0.25,0.42),Vector3.new(wx,y-2.3,faceZ+front*0.08),Enum.Material.Concrete,C.white,false)
                if style=="historic" and floor>1 then
                    part(m,"Fenstersturz",Vector3.new(6.0,0.28,0.4),Vector3.new(wx,y+2.55,faceZ+front*0.08),Enum.Material.Brick,rgb(173,145,116),false)
                end
            end
        end
    end
    if shop then
        for col=-1,1 do
            if col~=0 then
                part(m,"Schaufenster",Vector3.new(7.1,5.3,0.25),Vector3.new(x+col*(w/3.6),3.2,faceZ+front*0.03),Enum.Material.Glass,C.glass,false,0.06)
            end
        end
        part(m,"Eingang",Vector3.new(3.1,6.0,0.35),Vector3.new(x,3.1,faceZ+front*0.1),Enum.Material.Wood,C.wood,false)
        local fascia=part(m,"Ladenschild",Vector3.new(math.min(19,w*0.7),1.6,0.42),Vector3.new(x,7.0,faceZ+front*0.32),Enum.Material.SmoothPlastic,rng:NextInteger(1,2)==1 and C.blue or rgb(64,99,76),false)
        signFace(fascia,shopNames[rng:NextInteger(1,#shopNames)],faceOf(front),fascia.Color)
    end
    -- Balkone nicht an jedem Haus, damit Strassenfronten abwechslungsreich bleiben.
    if style=="residential" and rng:NextNumber()<0.58 then
        for floor=2,floors do
            local by=3.6+(floor-1)*7
            local bx=x+w*0.26
            part(m,"Balkonplatte",Vector3.new(7,0.35,2.0),Vector3.new(bx,by-2.6,faceZ+front*1.0),Enum.Material.Concrete,C.concrete)
            part(m,"Balkongelaender",Vector3.new(7,1.0,0.18),Vector3.new(bx,by-2.0,faceZ+front*1.9),Enum.Material.Metal,C.steel,false)
        end
    end
    return m
end

-- Dichte Innenstadt: geschlossene Strassenraeume und abwechslungsreiche Gebaeudehoehen.
local index=0
for _,x in ipairs({-930,-630,-330,-30,270,570,870}) do
    for _,z in ipairs({-930,-630,-330,-30,270,570,870}) do
        index+=1
        local width=rng:NextInteger(70,96)
        local depth=rng:NextInteger(66,92)
        local height=rng:NextInteger(25,48)
        local style=(index%5==0) and "historic" or ((index%4==0) and "modern" or "residential")
        building("Innenstadt_Quadrat_"..index,x,z,width,depth,height,(z<0) and 1 or -1,style,index%3==0)
        if index%4==0 then
            building("Hofgebaeude_"..index,x+105,z+72,48,48,rng:NextInteger(18,27),(z<0) and 1 or -1,"residential",false)
        end
    end
end

-- Aussenviertel: Neckarstadt, Oststadt, Lindenhof und Jungbusch mit eigener Bauweise.
local outIndex=0
for _,area in ipairs({
    {name="Neckarstadt",x=-1550,z=-1500,front=1,style="historic"},
    {name="Jungbusch",x=-1900,z=-650,front=1,style="modern"},
    {name="Oststadt",x=1800,z=-650,front=-1,style="historic"},
    {name="Lindenhof",x=750,z=1850,front=-1,style="residential"},
    {name="Waldhof",x=-1650,z=1450,front=1,style="residential"},
    {name="Feudenheim",x=1850,z=1450,front=-1,style="residential"}
}) do
    for row=0,3 do
        for col=0,3 do
            outIndex+=1
            local bx=area.x+col*112
            local bz=area.z+row*112
            building(area.name.."_Haus_"..outIndex,bx,bz,rng:NextInteger(42,68),rng:NextInteger(42,65),rng:NextInteger(15,31),area.front,area.style,outIndex%5==0)
        end
    end
end

-- Hafenquartier mit Lagerhallen, Kranen und Kaikante.
for i=1,7 do
    local hx=-2150+(i%3)*115
    local hz=-1800+math.floor((i-1)/3)*155
    local hall=model("Hafen_Lagerhalle_"..i)
    part(hall,"Lagerhalle",Vector3.new(95,24,110),Vector3.new(hx,12,hz),Enum.Material.Metal,rgb(135,143,145))
    part(hall,"Hallendach",Vector3.new(99,2,114),Vector3.new(hx,25,hz),Enum.Material.Metal,rgb(76,85,91))
    for wx=hx-32,hx+32,32 do
        part(hall,"Hallentor",Vector3.new(18,13,0.5),Vector3.new(wx,7,hz+55),Enum.Material.Metal,rgb(75,87,93),false)
    end
end
for i=1,3 do
    local crane=model("Hafenkran_"..i)
    local cx=-2400+(i-1)*125
    local cz=-1800
    part(crane,"Kranmast",Vector3.new(5,48,5),Vector3.new(cx,24,cz),Enum.Material.Metal,C.yellow)
    part(crane,"Kranarm",Vector3.new(85,4,4),Vector3.new(cx+37,47,cz),Enum.Material.Metal,C.yellow)
    part(crane,"Kranstrebe",Vector3.new(3,36,3),Vector3.new(cx+65,29,cz),Enum.Material.Metal,C.steel)
    part(crane,"Kranseil",Vector3.new(0.35,24,0.35),Vector3.new(cx+68,15,cz),Enum.Material.Metal,C.steel)
    part(crane,"Kranhaken",Vector3.new(3,1.2,2),Vector3.new(cx+68,2.8,cz),Enum.Material.Metal,C.steel)
end

-- Schloss Mannheim: grosse barocke Anlage mit Innenhof, Seitenfluegeln und Ehrenplatz.
local palace=model("Mannheimer_Schloss")
part(palace,"Haupttrakt",Vector3.new(250,45,54),Vector3.new(-1430,22.5,950),Enum.Material.Brick,rgb(194,157,113))
part(palace,"Westfluegel",Vector3.new(56,37,160),Vector3.new(-1583,18.5,1000),Enum.Material.Brick,rgb(207,174,132))
part(palace,"Ostfluegel",Vector3.new(56,37,160),Vector3.new(-1277,18.5,1000),Enum.Material.Brick,rgb(207,174,132))
part(palace,"Dach_Haupttrakt",Vector3.new(258,3,60),Vector3.new(-1430,46,950),Enum.Material.Slate,C.roof)
part(palace,"Dach_West",Vector3.new(62,3,166),Vector3.new(-1583,38,1000),Enum.Material.Slate,C.roof)
part(palace,"Dach_Ost",Vector3.new(62,3,166),Vector3.new(-1277,38,1000),Enum.Material.Slate,C.roof)
for x=-1540,-1320,27 do
    for y=1,4 do
        part(palace,"Schlossfenster",Vector3.new(8,6,0.35),Vector3.new(x,5+y*8,922),Enum.Material.Glass,C.glass,false)
    end
end
for i=1,9 do
    local cx=-1540+(i-1)*27
    part(palace,"Schloss_Pilaster",Vector3.new(1.8,38,1.8),Vector3.new(cx,19,920),Enum.Material.Concrete,C.white)
end
part(map,"Schlossplatz",Vector3.new(390,0.2,270),Vector3.new(-1430,0.12,1190),Enum.Material.Cobblestone,rgb(157,153,142))

-- Friedrichsplatz und Wasserturm: gruene symmetrische Gartenanlage.
part(map,"Friedrichsplatz_Anlage",Vector3.new(430,0.24,390),Vector3.new(1240,0.14,280),Enum.Material.Grass,C.grass,false)
part(map,"Friedrichsplatz_Weg_NS",Vector3.new(28,0.12,380),Vector3.new(1240,0.31,280),Enum.Material.Concrete,C.curb,false)
part(map,"Friedrichsplatz_Weg_EW",Vector3.new(410,0.12,28),Vector3.new(1240,0.31,280),Enum.Material.Concrete,C.curb,false)
cylinder(map,"Wasserturm_Brunnen",Vector3.new(3,86,86),CFrame.new(1240,1.8,280)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Concrete,rgb(205,204,193))
cylinder(map,"Brunnenwasser",Vector3.new(1.2,66,66),CFrame.new(1240,3.1,280)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Water,rgb(77,153,177),false)
local tower=model("Mannheimer_Wasserturm")
cylinder(tower,"Sockel_unten",Vector3.new(29,32,32),CFrame.new(1240,18,280)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Concrete,rgb(191,155,111))
cylinder(tower,"Turmschaft",Vector3.new(47,24,24),CFrame.new(1240,53,280)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Sandstone,rgb(209,176,131))
cylinder(tower,"Aussichtskranz",Vector3.new(8,31,31),CFrame.new(1240,80,280)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Sandstone,rgb(190,151,107))
cylinder(tower,"Dachbasis",Vector3.new(18,26,26),CFrame.new(1240,93,280)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Slate,rgb(67,94,88))
ball(tower,"Turmspitze",Vector3.new(10,10,10),Vector3.new(1240,105,280),Enum.Material.Metal,C.yellow)
for a=0,315,45 do
    local rad=math.rad(a)
    local tx=1240+math.cos(rad)*160
    local tz=280+math.sin(rad)*145
    local treeModel=model("Friedrichsplatz_Baum")
    cylinder(treeModel,"Stamm",Vector3.new(7,2,2),CFrame.new(tx,3.5,tz)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Wood,C.wood)
    ball(treeModel,"Krone",Vector3.new(14,17,14),Vector3.new(tx,13,tz),Enum.Material.Grass,C.green)
end

-- Hauptbahnhof als grosser, moderner Verkehrsbau.
local station=model("Mannheim_Hauptbahnhof")
part(station,"Empfangsgebaeude",Vector3.new(210,33,48),Vector3.new(0,16.5,1640),Enum.Material.Concrete,rgb(190,193,190))
part(station,"Glasfront",Vector3.new(185,22,0.6),Vector3.new(0,18,1615),Enum.Material.Glass,C.glass,false,0.08)
part(station,"Vordach",Vector3.new(235,2,24),Vector3.new(0,34,1598),Enum.Material.Metal,C.steel)
part(station,"Dach",Vector3.new(220,3,60),Vector3.new(0,34,1640),Enum.Material.Metal,rgb(82,94,100))
for x=-85,85,34 do
    part(station,"Fassadenstuetze",Vector3.new(2,28,2),Vector3.new(x,14,1613),Enum.Material.Metal,C.white)
end
local hbfSign=part(station,"Bahnhofsschild",Vector3.new(58,5,0.7),Vector3.new(0,29,1612),Enum.Material.SmoothPlastic,C.blue,false)
signFace(hbfSign,"MANNHEIM HBF",Enum.NormalId.Back,C.blue)

-- Stadtbahn-Haltestellen mit Bahnsteig, taktiler Kante, Wartehalle und Anzeige.
local function stopPlatform(name,x,z,axis)
    local p=model(name)
    local length=110
    local width=15
    part(p,"Bahnsteig",Vector3.new(width,0.62,length),Vector3.new(x,0.53,z),Enum.Material.Concrete,rgb(177,176,166))
    part(p,"Bahnsteigkante",Vector3.new(0.55,0.18,length-4),Vector3.new(x-width/2+0.5,0.92,z),Enum.Material.Concrete,C.yellow)
    for dz=-48,48,6 do
        part(p,"Taktiler_Streifen",Vector3.new(1.1,0.08,2.4),Vector3.new(x-width/2+2,1.02,z+dz),Enum.Material.Concrete,C.yellow,false)
    end
    part(p,"Wartehalle_Dach",Vector3.new(12,0.55,28),Vector3.new(x+2,6.2,z-12),Enum.Material.Metal,C.steel)
    for _,dx in ipairs({-3.5,7.5}) do
        for _,dz in ipairs({-24,0}) do
            part(p,"Wartehalle_Pfosten",Vector3.new(0.3,5.4,0.3),Vector3.new(x+dx,3.4,z+dz-12),Enum.Material.Metal,C.steel)
        end
    end
    part(p,"Wartehalle_Glas",Vector3.new(0.15,4.8,22),Vector3.new(x-3.3,3.5,z-12),Enum.Material.Glass,C.glass,false,0.15)
    part(p,"Sitzbank",Vector3.new(4.5,0.35,1.1),Vector3.new(x+1.0,1.55,z-14),Enum.Material.Wood,C.wood)
    local info=part(p,"Fahrgastinformation",Vector3.new(0.35,4.5,2.5),Vector3.new(x+7.1,2.75,z+34),Enum.Material.Metal,C.steel)
    signFace(info,"RNV\\nFAHRPLAN",Enum.NormalId.Left,C.blue)
    local display=part(p,"Abfahrtsanzeige",Vector3.new(0.35,2.6,4.5),Vector3.new(x+7.1,4.0,z+18),Enum.Material.SmoothPlastic,rgb(20,31,38))
    signFace(display,"LINIE    ZIEL\\nABFAHRT",Enum.NormalId.Left,rgb(20,31,38))
    local pole=part(p,"Haltestellenmast",Vector3.new(0.5,6,0.5),Vector3.new(x+5.5,3.7,z+48),Enum.Material.Metal,C.steel)
    local logo=part(p,"RNV_Schild",Vector3.new(0.35,2.6,2.2),Vector3.new(x+5.5,6.4,z+48),Enum.Material.SmoothPlastic,C.blue)
    signFace(logo,"RNV",Enum.NormalId.Left,C.blue)
    part(p,"Abfallbehaelter",Vector3.new(1.1,1.7,1.1),Vector3.new(x+5,1.4,z-37),Enum.Material.Metal,C.steel)
end
stopPlatform("Haltestelle_Innenstadt_Nord",105,-650,"Z")
stopPlatform("Haltestelle_Paradeplatz",105,-70,"Z")
stopPlatform("Haltestelle_Friedrichsplatz",1480,280,"Z")
stopPlatform("Haltestelle_Hauptbahnhof",105,1190,"Z")
stopPlatform("Haltestelle_Seckenheim",1480,1750,"Z")

-- Seckenheim: kleinstaedtischer Ortskern, Platz, Rathaus und Kirche.
part(map,"Seckenheim_Platz",Vector3.new(260,0.2,230),Vector3.new(1840,0.14,1930),Enum.Material.Cobblestone,rgb(160,156,144))
local townhall=model("Seckenheim_Rathaus")
part(townhall,"Rathauskoerper",Vector3.new(76,29,62),Vector3.new(1840,14.5,1900),Enum.Material.Concrete,rgb(224,208,177))
part(townhall,"Rathausdach",Vector3.new(82,2,68),Vector3.new(1840,30,1900),Enum.Material.Slate,C.brick)
for x=1810,1870,20 do
    for y=8,22,12 do
        part(townhall,"Fenster",Vector3.new(7,6,0.25),Vector3.new(x,y,1868),Enum.Material.Glass,C.glass,false)
    end
end
part(townhall,"Rathauseingang",Vector3.new(9,8,0.5),Vector3.new(1840,4,1867),Enum.Material.Wood,C.wood)
local church=model("Seckenheim_Kirche")
part(church,"Kirchenschiff",Vector3.new(48,34,105),Vector3.new(2120,17,1900),Enum.Material.Brick,rgb(201,185,157))
part(church,"Kirchendach",Vector3.new(54,2,112),Vector3.new(2120,35,1900),Enum.Material.Slate,C.roof)
part(church,"Kirchturm",Vector3.new(18,63,18),Vector3.new(2120,31.5,1840),Enum.Material.Brick,rgb(190,169,139))
part(church,"Turmhelm",Vector3.new(22,18,22),Vector3.new(2120,72,1840),Enum.Material.Slate,C.darkroof)
part(church,"Kirchturmspitze",Vector3.new(1,12,1),Vector3.new(2120,87,1840),Enum.Material.Metal,C.steel)
for x=2100,2140,20 do
    part(church,"Kirchenfenster",Vector3.new(5,12,0.3),Vector3.new(x,18,1846),Enum.Material.Glass,C.glass,false)
end

-- Parkanlagen mit Wegen, Baumgruppen, Beeten und Sitzbaenken.
local function tree(x,z,scale,variant)
    local t=model("Stadtbaum")
    local trunkH=7*scale
    cylinder(t,"Stamm",Vector3.new(trunkH,1.4*scale,1.4*scale),CFrame.new(x,trunkH/2,z)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Wood,C.wood)
    local crown=ball(t,"Baumkrone",Vector3.new(8*scale,9*scale,8*scale),Vector3.new(x,trunkH+3*scale,z),Enum.Material.Grass,variant and C.grass2 or C.green)
    crown.CastShadow=true
end
local function bench(x,z)
    local b=model("Parkbank")
    part(b,"Sitz",Vector3.new(6,0.35,1.2),Vector3.new(x,1.25,z),Enum.Material.Wood,C.wood)
    part(b,"Lehne",Vector3.new(6,1.2,0.3),Vector3.new(x,1.95,z+0.55),Enum.Material.Wood,C.wood)
    for _,dx in ipairs({-2.3,2.3}) do
        part(b,"Bankfuss",Vector3.new(0.3,1.2,0.8),Vector3.new(x+dx,0.65,z),Enum.Material.Metal,C.steel)
    end
end
-- Luisenpark-aehnliche grosse Gruenanlage im Osten.
part(map,"Ostpark_Wiese",Vector3.new(520,0.2,660),Vector3.new(1850,0.14,-700),Enum.Material.Grass,C.grass,false)
for _,x in ipairs({1640,1780,1920,2060}) do
    for _,z in ipairs({-930,-760,-590,-420}) do
        tree(x,z,1.1,((x+z)%2==0))
    end
end
for _,z in ipairs({-900,-650,-400}) do
    part(map,"Parkweg",Vector3.new(480,0.12,9),Vector3.new(1850,0.29,z),Enum.Material.Concrete,C.curb,false)
end
for _,p in ipairs({{1700,-830},{1980,-830},{1700,-520},{1980,-520}}) do bench(p[1],p[2]) end
-- Grueninseln und Baeume entlang wichtiger Strassen.
for z=-2250,2250,115 do
    tree(-1460,z,0.85,(z%2==0))
    tree(1460,z,0.85,(z%2==0))
end
for x=-2100,2100,145 do
    tree(x,1430,0.8,(x%2==0))
end

-- Strassenlaternen mit warmem Licht an Gehwegen.
for z=-2100,2100,135 do
    for _,x in ipairs({-1535,-1120,1120,1535}) do
        local l=model("Strassenlaterne")
        part(l,"Mast",Vector3.new(0.42,10,0.42),Vector3.new(x,5,z),Enum.Material.Metal,C.steel)
        local head=part(l,"Leuchte",Vector3.new(2.8,0.45,1.0),Vector3.new(x,10,z),Enum.Material.Metal,rgb(236,224,190))
        local light=Instance.new("PointLight")
        light.Color=rgb(255,231,184); light.Brightness=0.55; light.Range=18; light.Shadows=true; light.Parent=head
    end
end

-- Ampeln an den grossen Kreuzungen.
local function trafficLight(x,z,rot)
    local t=model("Ampelanlage")
    local pole=part(t,"Ampelmast",Vector3.new(0.5,7,0.5),Vector3.new(x,3.5,z),Enum.Material.Metal,C.steel)
    local box=part(t,"Ampelgehause",Vector3.new(1.15,3.5,1.0),Vector3.new(x,7.0,z),Enum.Material.Metal,rgb(35,39,42))
    for i,col in ipairs({C.red,C.yellow,rgb(45,164,81)}) do
        local bulb=ball(t,"Signallicht",Vector3.new(0.68,0.68,0.28),Vector3.new(x,8.0-i*0.95,z+0.58),Enum.Material.Neon,col)
    end
end
for _,z in ipairs({-780,-180,420,1020,1450}) do
    trafficLight(-115,z); trafficLight(115,z)
end
for _,x in ipairs({-1080,-480,120,720,1500}) do
    trafficLight(x,-115); trafficLight(x,115)
end

-- Parkende Fahrzeuge als kompakte, abwechslungsreiche Stadtobjekte.
local carColors={rgb(180,187,192),rgb(61,82,101),rgb(151,57,49),rgb(48,55,61),rgb(197,183,158),rgb(99,123,100)}
for i=1,38 do
    local x,z
    if i<=19 then x=-1450+(i%2)*24; z=-1750+math.floor(i/2)*185
    else x=1450-(i%2)*24; z=-1600+math.floor((i-19)/2)*185 end
    local car=model("Parkendes_Auto")
    local cc=carColors[(i-1)%#carColors+1]
    part(car,"Karosserie",Vector3.new(5.6,1.7,10.5),Vector3.new(x,1.0,z),Enum.Material.Metal,cc,false)
    part(car,"Dach",Vector3.new(4.3,1.5,5.3),Vector3.new(x,2.55,z),Enum.Material.Glass,C.glass,false,0.12)
    for _,dx in ipairs({-2.75,2.75}) do
        for _,dz in ipairs({-3.1,3.1}) do
            local w=cylinder(car,"Rad",Vector3.new(0.65,1.4,1.4),CFrame.new(x+dx,0.8,z+dz),Enum.Material.SmoothPlastic,rgb(28,30,32))
        end
    end
end

-- Kleine Details: Blumenkuebel, Muelleimer, Fahrradstaender und Sitzgelegenheiten.
for i=1,22 do
    local x=-1000+(i%6)*390
    local z=-1200+math.floor(i/6)*720
    local pot=model("Pflanzkuebel")
    part(pot,"Kuebel",Vector3.new(4,1.4,4),Vector3.new(x,0.8,z),Enum.Material.Concrete,rgb(112,113,106))
    ball(pot,"Busch",Vector3.new(4.5,4.2,4.5),Vector3.new(x,3.2,z),Enum.Material.Grass,C.green)
end
for i=1,16 do
    local x=-980+(i%4)*620
    local z=-950+math.floor(i/4)*620
    bench(x,z)
end

-- Einfache Fussgaenger-Modelle mit sauber getrennten Koerperteilen.
-- Die spaetere Laufanimation kommt ueber ein separates ServerScript, damit die
-- Karte hier auch ohne Skript-Source-Berechtigung vollstaendig erstellt wird.
local people=folder("Passanten")
local clothes={rgb(48,83,119),rgb(153,67,56),rgb(70,106,76),rgb(75,75,86),rgb(177,143,88)}
for i=1,20 do
    local x=(i%2==0) and -1100 or 1100
    local z=-900+(i-1)*92
    local npc=model("Fussgaenger_"..i,people)
    local body=part(npc,"Koerper",Vector3.new(1.5,2.4,0.8),Vector3.new(x,1.8,z),Enum.Material.Fabric,clothes[(i-1)%#clothes+1],false)
    npc.PrimaryPart=body
    ball(npc,"Kopf",Vector3.new(1,1,1),Vector3.new(x,3.5,z),Enum.Material.SmoothPlastic,C.skin)
    part(npc,"Bein_links",Vector3.new(0.5,1.3,0.55),Vector3.new(x-0.35,0.65,z),Enum.Material.Fabric,C.darkroof,false)
    part(npc,"Bein_rechts",Vector3.new(0.5,1.3,0.55),Vector3.new(x+0.35,0.65,z),Enum.Material.Fabric,C.darkroof,false)
end

print("[RNV MAP V9] Mannheim-Stadtkarte wurde neu aufgebaut.")
print("[RNV MAP V9] Quadrate, Hafen, Neckar/Rhein, Schloss, Hauptbahnhof, Friedrichsplatz/Wasserturm, Ostpark und Seckenheim angelegt.")
print("[RNV MAP V9] Alle Gebaeude, Strassen, Schienen und Details sind editierbare Studio-Parts.")
print("[RNV MAP V9] Bitte zuerst aus der Vogelperspektive pruefen; danach Details gezielt weiter verbessern.")
