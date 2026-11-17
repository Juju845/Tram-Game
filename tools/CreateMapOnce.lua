-- RNV MANNHEIM TRAM SIMULATOR | MAP V6
-- Neuaufbau mit einfachem Koordinatensystem, durchgehendem Untergrund
-- und klar getrennten Bauzonen. Einmalig in Studio Command Bar ausfuehren.
-- Ersetzt ausschliesslich Workspace.RNV_Mannheim_Map und entfernt SpawnLocations.

local W = game:GetService("Workspace")
local L = game:GetService("Lighting")
local old = W:FindFirstChild("RNV_Mannheim_Map")
if old then old:Destroy() end
for _,v in ipairs(W:GetDescendants()) do
    if v:IsA("SpawnLocation") then v:Destroy() end
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = W

local function col(r,g,b) return Color3.fromRGB(r,g,b) end
local C = {
    ground=col(126,133,119), road=col(48,51,54), pavement=col(174,171,160),
    curb=col(207,202,187), trackbed=col(74,76,74), rail=col(170,177,180),
    steel=col(54,65,70), glass=col(105,153,170), white=col(240,238,226),
    yellow=col(242,190,54), blue=col(0,101,153), brick=col(191,171,144),
    cream=col(222,204,171), red=col(139,62,48), roof=col(74,67,61),
    green=col(65,119,70), wood=col(116,82,53)
}
local function part(parent,name,size,pos,material,color,collide)
    local p=Instance.new("Part")
    p.Name=name
    p.Size=size
    p.Position=pos
    p.Anchored=true
    p.Material=material or Enum.Material.SmoothPlastic
    p.Color=color or C.cream
    p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth
    p.CastShadow=true
    p.CanTouch=false
    if collide~=nil then p.CanCollide=collide end
    p.Parent=parent or map
    return p
end
local function model(name,parent)
    local m=Instance.new("Model")
    m.Name=name
    m.Parent=parent or map
    return m
end
local function textSign(p,txt,face,bg)
    local gui=Instance.new("SurfaceGui")
    gui.Face=face or Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=35
    gui.LightInfluence=0
    gui.Parent=p
    local t=Instance.new("TextLabel")
    t.Size=UDim2.fromScale(1,1)
    t.BackgroundColor3=bg or C.blue
    t.BorderSizePixel=0
    t.Text=txt
    t.TextColor3=C.white
    t.TextScaled=true
    t.Font=Enum.Font.GothamBold
    t.Parent=gui
end

-- Einheitliche Beleuchtung und eine einzige ebene Grundflaeche.
L.ClockTime=14.5
L.Brightness=2.2
L.GlobalShadows=true
L.Ambient=col(130,133,137)
L.OutdoorAmbient=col(166,168,170)
L.EnvironmentDiffuseScale=0.5
L.EnvironmentSpecularScale=0.35
local sky=L:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",L)
sky.Density=0.16
sky.Haze=0.7
sky.Color=col(210,222,235)
sky.Decay=col(120,135,150)
part(map,"Einheitlicher_Stadtboden",Vector3.new(2400,8,2400),Vector3.new(0,-4,0),Enum.Material.Ground,C.ground)

-- Hauptstrasse liegt auf Z=0; Strassen und Gehwege sind nicht uebereinander geschichtet.
part(map,"Hauptstrasse",Vector3.new(240,0.35,1800),Vector3.new(0,0.18,0),Enum.Material.Asphalt,C.road)
for _,x in ipairs({-126,126}) do
    part(map,"Bordstein",Vector3.new(1.2,0.35,1800),Vector3.new(x,0.35,0),Enum.Material.Concrete,C.curb)
    part(map,"Gehweg",Vector3.new(34,0.3,1800),Vector3.new(x+(x<0 and -17 or 17),0.18,0),Enum.Material.Concrete,C.pavement)
end
for z=-850,850,32 do
    part(map,"Fahrbahn_Mittellinie",Vector3.new(0.35,0.025,13),Vector3.new(0,0.37,z),Enum.Material.SmoothPlastic,C.white,false)
end
for _,x in ipairs({-75,75}) do
    part(map,"Fahrstreifenlinie",Vector3.new(0.22,0.025,1750),Vector3.new(x,0.37,0),Enum.Material.SmoothPlastic,C.white,false)
end

-- Strassenbahntrasse mit zwei getrennten Gleisen.
part(map,"Gleisbereich",Vector3.new(34,0.22,1800),Vector3.new(0,0.39,0),Enum.Material.Asphalt,C.trackbed)
for _,trackX in ipairs({-5,5}) do
    for z=-880,880,5 do
        part(map,"Schwelle",Vector3.new(13,0.16,1.1),Vector3.new(trackX,0.59,z),Enum.Material.Concrete,col(104,105,101))
    end
    for _,dx in ipairs({-1.25,1.25}) do
        part(map,"Schienenprofil",Vector3.new(0.42,0.28,1800),Vector3.new(trackX+dx,0.77,0),Enum.Material.Metal,C.rail)
    end
end
-- Oberleitungsmasten und Fahrdraht.
for z=-840,840,70 do
    local x=(math.floor((z+840)/70)%2==0) and -23 or 23
    part(map,"Fahrleitungsmast",Vector3.new(0.65,18,0.65),Vector3.new(x,9,z),Enum.Material.Metal,C.steel)
    part(map,"Ausleger",Vector3.new(48,0.3,0.3),Vector3.new(0,17.5,z),Enum.Material.Metal,C.steel)
end
for _,x in ipairs({-5,5}) do
    part(map,"Fahrdraht",Vector3.new(0.12,0.12,1800),Vector3.new(x,17.1,0),Enum.Material.Metal,col(190,166,112),false)
end

-- Querstrassen als klare, rechtwinklige Anschluesse.
for _,z in ipairs({-720,-360,360,720}) do
    part(map,"Querstrasse",Vector3.new(900,0.34,72),Vector3.new(0,0.19,z),Enum.Material.Asphalt,C.road)
    for _,x in ipairs({-450,450}) do
        part(map,"Querstrassen_Gehweg",Vector3.new(900,0.28,13),Vector3.new(0,0.18,z+x*0),Enum.Material.Concrete,C.pavement)
    end
end

-- Vollstaendige Haltestellen: je zwei Bahnsteige pro Haltepunkt, ohne Namens-Billboards.
local function shelter(parent,cx,cz)
    local s=model("Wartehalle",parent)
    part(s,"Bodenplatte",Vector3.new(12,0.35,25),Vector3.new(cx,0.72,cz),Enum.Material.Concrete,col(155,157,151))
    part(s,"Dach",Vector3.new(13,0.55,26),Vector3.new(cx,7.0,cz),Enum.Material.Metal,C.steel)
    for _,dx in ipairs({-5.8,5.8}) do
        for _,dz in ipairs({-11.5,11.5}) do
            part(s,"Dachstuetze",Vector3.new(0.35,6.2,0.35),Vector3.new(cx+dx,3.8,cz+dz),Enum.Material.Metal,C.steel)
        end
    end
    part(s,"Rueckwand_Glas",Vector3.new(0.18,5.6,22),Vector3.new(cx-5.7,3.8,cz),Enum.Material.Glass,C.glass,false)
    part(s,"Seitenwand_Glas",Vector3.new(11.2,5.6,0.18),Vector3.new(cx,3.8,cz+11.3),Enum.Material.Glass,C.glass,false)
    part(s,"Sitzbank",Vector3.new(3.8,0.3,1.0),Vector3.new(cx+1.0,1.8,cz-2),Enum.Material.Wood,C.wood)
    part(s,"Banklehne",Vector3.new(0.25,1.4,3.8),Vector3.new(cx-0.8,2.45,cz-2),Enum.Material.Wood,C.wood)
    local info=part(s,"Fahrplanauskunft",Vector3.new(0.25,4.5,2.5),Vector3.new(cx+7.0,2.8,cz-10),Enum.Material.Metal,C.steel)
    textSign(info,"RNV\nFAHRPLAN\nLINIEN",Enum.NormalId.Left,C.blue)
    local screen=part(s,"Dynamische_Anzeige",Vector3.new(0.25,2.5,4.0),Vector3.new(cx+7.0,4.0,cz+8),Enum.Material.SmoothPlastic,col(26,39,46))
    textSign(screen,"LINIE 5   40\nABFAHRT",Enum.NormalId.Left,col(26,39,46))
end
local function platform(label,z)
    for _,x in ipairs({-18,18}) do
        local m=model("Haltestellensteig_"..label.."_"..(x<0 and "A" or "B"))
        part(m,"Bahnsteig",Vector3.new(15,0.65,112),Vector3.new(x,0.65,z),Enum.Material.Concrete,col(174,173,165))
        part(m,"Bahnsteigkante",Vector3.new(0.35,0.12,108),Vector3.new(x+(x<0 and 7.1 or -7.1),1.04,z),Enum.Material.Concrete,C.yellow)
        part(m,"Taktiles_Leitsystem",Vector3.new(1.0,0.08,104),Vector3.new(x+(x<0 and 6.2 or -6.2),1.08,z),Enum.Material.SmoothPlastic,C.yellow,false)
        shelter(m,x,z-10)
        local pole=part(m,"Haltestellenmast",Vector3.new(0.4,5.5,0.4),Vector3.new(x+(x<0 and 6 or -6),3.2,z+43),Enum.Material.Metal,C.steel)
        local sign=part(m,"RNV_Haltestellenschild",Vector3.new(0.25,2.6,2.0),pole.Position+Vector3.new(0,3.1,0),Enum.Material.SmoothPlastic,C.blue)
        textSign(sign,"RNV",Enum.NormalId.Front,C.blue)
        local marker=part(m,"Steigkennung",Vector3.new(0.2,1.2,1.4),pole.Position+Vector3.new(0,1.5,0),Enum.Material.SmoothPlastic,C.blue)
        textSign(marker,"STEIG "..(x<0 and "A" or "B"),Enum.NormalId.Front,C.blue)
        part(m,"Muelleimer",Vector3.new(1.1,1.8,1.1),Vector3.new(x,1.25,z+28),Enum.Material.Metal,col(67,79,77))
    end
end
platform("01",-600)
platform("02",0)
platform("03",600)

-- Rathausplatz als eigene, ebene Pflasterflaeche neben der Hauptstrasse.
part(map,"Rathausplatz",Vector3.new(250,0.22,230),Vector3.new(280,0.31,0),Enum.Material.Cobblestone,col(151,148,137))
-- Rathausbau mit klaren Wandflaechen, Fenstern, Dach und Eingangsfront.
local town=model("Rathaus")
local tx,tz=330,-5
part(town,"Hauptkoerper",Vector3.new(100,38,150),Vector3.new(tx,19,tz),Enum.Material.Concrete,C.cream)
part(town,"Sockel",Vector3.new(104,2,154),Vector3.new(tx,1,tz),Enum.Material.Concrete,col(165,151,129))
part(town,"Dachgeschoss",Vector3.new(104,2,154),Vector3.new(tx,38,tz),Enum.Material.Concrete,C.brick)
part(town,"Dach_Vorderseite",Vector3.new(106,2,78),Vector3.new(tx,42,tz-37),Enum.Material.Slate,C.red)
part(town,"Dach_Rueckseite",Vector3.new(106,2,78),Vector3.new(tx,42,tz+37),Enum.Material.Slate,C.red)
part(town,"Dachfirst",Vector3.new(2,2,154),Vector3.new(tx,44,tz),Enum.Material.Wood,C.roof)
for floor=1,3 do
    local y=7+(floor-1)*10
    for x=tx-38,tx+39,19 do
        local win=part(town,"Fenster",Vector3.new(0.25,6,8),Vector3.new(x,y,tz-75.2),Enum.Material.Glass,C.glass,false)
        part(town,"Fensterbank",Vector3.new(1.0,0.35,9),Vector3.new(x,y-3.2,tz-75.5),Enum.Material.Concrete,C.white)
    end
end
for x=tx-36,tx+36,18 do
    part(town,"Arkadenpfeiler",Vector3.new(2,12,2),Vector3.new(x,6,tz-77),Enum.Material.Concrete,C.white)
end
part(town,"Eingangsportal",Vector3.new(16,11,0.6),Vector3.new(tx,5.5,tz-76),Enum.Material.Wood,C.wood)
part(town,"Turm",Vector3.new(24,25,24),Vector3.new(tx,55,tz),Enum.Material.Concrete,C.brick)
part(town,"Turmdach",Vector3.new(29,12,29),Vector3.new(tx,73,tz),Enum.Material.Slate,C.roof)
part(town,"Turmspitze",Vector3.new(1,12,1),Vector3.new(tx,84,tz),Enum.Material.Metal,C.steel)
for _,x in ipairs({tx-12.2,tx+12.2}) do
    local clock=part(town,"Uhr",Vector3.new(0.25,6,6),Vector3.new(x,55,tz-12.3),Enum.Material.SmoothPlastic,col(243,235,210))
    textSign(clock,"12",Enum.NormalId.Front,col(243,235,210))
end

-- Stadtquartiere: Gebaeude stehen auf freien Parzellen, mit Luecken und Abstand.
local facade={col(215,197,169),col(192,183,168),col(205,177,158),col(183,194,190),col(224,211,187),col(190,171,151)}
local shop={"CAFÉ","BÄCKEREI","APOTHEKE","BLUMEN","KIOSK","MARKT"}
local rng=Random.new(2841)
local function house(name,x,z,index)
    local w=rng:NextInteger(34,48)
    local d=rng:NextInteger(36,50)
    local h=rng:NextInteger(24,38)
    local m=model(name)
    local fc=facade[(index-1)%#facade+1]
    part(m,"Gebaeude",Vector3.new(w,h,d),Vector3.new(x,h/2,z),Enum.Material.Concrete,fc)
    part(m,"Sockel",Vector3.new(w+1,1.5,d+1),Vector3.new(x,0.75,z),Enum.Material.Concrete,col(143,133,116))
    -- Strassenfront zeigt nach vorne (negative Z).
    for floor=1,math.floor((h-5)/9) do
        local y=4+floor*8
        for colIndex=-1,1 do
            local wx=x+colIndex*(w/3)
            part(m,"Fensterglas",Vector3.new(6,4.8,0.22),Vector3.new(wx,y,z-d/2-0.13),Enum.Material.Glass,C.glass,false)
            part(m,"Fenstersturz",Vector3.new(7,0.25,0.35),Vector3.new(wx,y+2.5,z-d/2-0.25),Enum.Material.Concrete,C.white,false)
            part(m,"Fensterbank",Vector3.new(7,0.35,0.45),Vector3.new(wx,y-2.5,z-d/2-0.3),Enum.Material.Concrete,C.white,false)
        end
    end
    for colIndex=-1,1 do
        local wx=x+colIndex*(w/3)
        part(m,"Schaufenster",Vector3.new(7,5.5,0.25),Vector3.new(wx,3,z-d/2-0.16),Enum.Material.Glass,C.glass,false)
    end
    part(m,"Ladenschild",Vector3.new(14,2.2,0.5),Vector3.new(x,6.8,z-d/2-0.4),Enum.Material.SmoothPlastic,index%2==0 and C.blue or col(77,104,77),false)
    local sign=m:FindFirstChild("Ladenschild")
    textSign(sign,shop[(index-1)%#shop+1],Enum.NormalId.Front,sign.Color)
    part(m,"Dach",Vector3.new(w+3,1.5,d+3),Vector3.new(x,h+0.6,z),Enum.Material.Slate,index%2==0 and C.red or C.roof)
end
local idx=0
-- Blocks around the main road, with planned empty street corridors.
for _,z in ipairs({-820,-620,-420,-220,220,420,620,820}) do
    for _,x in ipairs({-390,-300,-210,210,300,390}) do
        idx+=1
        house("Altstadthaus_"..idx,x,z,idx)
    end
end
-- Weitere Quartiere seitlich des Zentrums, damit die Karte gross und offen wirkt.
for _,z in ipairs({-760,-560,-360,-160,160,360,560,760}) do
    for _,x in ipairs({-760,-650,650,760}) do
        idx+=1
        house("Wohnhaus_"..idx,x,z,idx)
    end
end

-- Nebenstrassen in den Quartieren: erst Fahrbahn, dann Gehwege, ohne Boden-Patchwork.
for _,x in ipairs({-500,-100,100,500}) do
    part(map,"Quartierstrasse",Vector3.new(48,0.3,1700),Vector3.new(x,0.16,0),Enum.Material.Asphalt,C.road)
    for _,dx in ipairs({-26,26}) do
        part(map,"Quartier_Gehweg",Vector3.new(9,0.26,1700),Vector3.new(x+dx,0.17,0),Enum.Material.Concrete,C.pavement)
    end
end
for _,z in ipairs({-900,-500,500,900}) do
    part(map,"Quartier_Querstrasse",Vector3.new(1700,0.3,46),Vector3.new(0,0.16,z),Enum.Material.Asphalt,C.road)
end

-- Gruenflaechen, Baeume und Stadtmoeblierung auf den Gehwegen.
local function tree(x,z,scale)
    local m=model("Stadtbaum")
    part(m,"Stamm",Vector3.new(1.6*scale,8*scale,1.6*scale),Vector3.new(x,4*scale,z),Enum.Material.Wood,C.wood,false)
    local crown=part(m,"Krone",Vector3.new(9*scale,9*scale,9*scale),Vector3.new(x,10*scale,z),Enum.Material.Grass,C.green,false)
    crown.Shape=Enum.PartType.Ball
end
for z=-850,850,100 do
    tree(-150,z,1)
    tree(150,z,1)
end
for x=220,420,50 do
    tree(x,120,1.1)
    tree(x,-120,1.1)
end
for z=-850,850,120 do
    for _,x in ipairs({-145,145}) do
        local lamp=model("Strassenlaterne")
        part(lamp,"Mast",Vector3.new(0.35,9,0.35),Vector3.new(x,4.5,z),Enum.Material.Metal,C.steel)
        part(lamp,"Leuchte",Vector3.new(2.5,0.25,0.8),Vector3.new(x,9,z),Enum.Material.Metal,col(230,222,192))
    end
end

-- Geparkte Autos mit einfacher, sauberer Silhouette.
local carColors={col(190,193,192),col(67,84,99),col(150,58,48),col(51,57,61),col(202,190,165)}
for i,z in ipairs({-790,-690,-490,-290,290,490,690,790}) do
    for _,x in ipairs({-103,103}) do
        local m=model("Parkendes_Auto")
        local cc=carColors[(i-1)%#carColors+1]
        part(m,"Karosserie",Vector3.new(5.5,1.7,11),Vector3.new(x,1.2,z),Enum.Material.Metal,cc,false)
        part(m,"Fenster",Vector3.new(4.5,1.5,5),Vector3.new(x,2.7,z),Enum.Material.Glass,C.glass,false)
        for _,dx in ipairs({-2.7,2.7}) do
            for _,dz in ipairs({-3.5,3.5}) do
                local wheel=part(m,"Rad",Vector3.new(0.7,1.5,1.5),Vector3.new(x+dx,0.8,z+dz),Enum.Material.Rubber,col(29,30,31),false)
                wheel.Shape=Enum.PartType.Cylinder
            end
        end
    end
end

-- Einfache Passanten mit beweglicher Laufanimation ueber feste Gehweg-Routen.
local npcFolder=model("Passanten")
local clothes={col(49,85,119),col(155,67,55),col(69,105,75),col(76,76,86),col(177,143,88)}
for i=1,12 do
    local x=(i%2==0) and -145 or 145
    local z=-520+(i-1)*92
    local m=model("Passant_"..i,npcFolder)
    local torso=part(m,"Koerper",Vector3.new(1.5,2.5,0.8),Vector3.new(x,2.0,z),Enum.Material.Fabric,clothes[(i-1)%#clothes+1],false)
    m.PrimaryPart=torso
    local head=part(m,"Kopf",Vector3.new(1.05,1.05,1.05),Vector3.new(x,3.8,z),Enum.Material.SmoothPlastic,col(207,166,132),false)
    head.Shape=Enum.PartType.Ball
    part(m,"Bein_L",Vector3.new(0.55,1.6,0.6),Vector3.new(x-0.38,0.8,z),Enum.Material.Fabric,col(43,47,54),false)
    part(m,"Bein_R",Vector3.new(0.55,1.6,0.6),Vector3.new(x+0.38,0.8,z),Enum.Material.Fabric,col(43,47,54),false)
end
local controller=Instance.new("Script")
controller.Name="Passanten_Bewegung"
controller.Source=[[
local TweenService=game:GetService("TweenService")
local folder=script.Parent:WaitForChild("Passanten")
for _,npc in ipairs(folder:GetChildren()) do
    task.spawn(function()
        local root=npc.PrimaryPart
        if not root then return end
        local origin=root.Position
        local direction=(npc.Name:match("%d+$") and tonumber(npc.Name:match("%d+$"))%2==0) and 1 or -1
        while npc.Parent do
            local target=origin+Vector3.new(0,0,direction*55)
            local start=npc:GetPivot()
            local goal=start+Vector3.new(0,0,direction*55)
            local value=Instance.new("CFrameValue")
            value.Value=start
            local conn=value:GetPropertyChangedSignal("Value"):Connect(function()
                if npc.Parent then npc:PivotTo(value.Value) end
            end)
            local tween=TweenService:Create(value,TweenInfo.new(18,Enum.EasingStyle.Linear),{Value=goal})
            tween:Play()
            tween.Completed:Wait()
            conn:Disconnect()
            value:Destroy()
            task.wait(1)
            direction=-direction
        end
    end)
end
]]
controller.Parent=map

print("[RNV MAP V6] Neuer, sauberer Kartenaufbau erstellt.")
print("[RNV MAP V6] Grosse Stadt, ebener Untergrund, getrennte Strassen, Gleise, 3 Haltepunkte, Rathaus, Quartiere und bewegte Passanten.")
print("[RNV MAP V6] Alle Objekte liegen unter Workspace > RNV_Mannheim_Map.")
