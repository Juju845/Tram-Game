-- RNV MANNHEIM TRAM SIMULATOR | MAP V8
-- Sauberer, modularer Neuaufbau fuer Seckenheim-inspirierte Stadtstrassen.
-- Einmalig in Roblox Studio Command Bar ausfuehren (nicht im Play-Modus).
-- Ersetzt ausschliesslich Workspace.RNV_Mannheim_Map und entfernt SpawnLocations.

local Workspace = game:GetService("Workspace")
local MAP_SCALE = 1.65 -- groesserer Stadtmassstab
local Lighting = game:GetService("Lighting")
local old = Workspace:FindFirstChild("RNV_Mannheim_Map")
if old then old:Destroy() end
for _, item in ipairs(Workspace:GetDescendants()) do
    if item:IsA("SpawnLocation") then item:Destroy() end
end

local map = Instance.new("Folder")
map.Name = "RNV_Mannheim_Map"
map.Parent = Workspace

local function color(r,g,b) return Color3.fromRGB(r,g,b) end
local C = {
    asphalt=color(48,51,55), pavement=color(177,174,164), curb=color(215,210,195),
    concrete=color(145,145,137), trackbed=color(75,77,76), rail=color(177,184,187),
    steel=color(55,65,71), glass=color(105,157,177), cream=color(225,211,185),
    yellow=color(220,177,75), brick=color(177,117,83), roof=color(75,69,64),
    darkroof=color(57,57,56), green=color(69,119,72), wood=color(113,79,52),
    white=color(242,239,226), blue=color(0,91,139), skin=color(207,165,129)
}
local function folder(name,parent)
    local f=Instance.new("Folder"); f.Name=name; f.Parent=parent or map; return f
end
local function model(name,parent)
    local m=Instance.new("Model"); m.Name=name; m.Parent=parent or map; return m
end
local function part(parent,name,size,cf,mat,col,collide)
    local p=Instance.new("Part")
    p.Name=name; p.Size=size*MAP_SCALE; local baseCF=typeof(cf)=="CFrame" and cf or CFrame.new(cf); p.CFrame=CFrame.new(baseCF.Position*MAP_SCALE)*baseCF.Rotation
    p.Anchored=true; p.Material=mat or Enum.Material.SmoothPlastic
    p.Color=col or C.cream; p.TopSurface=Enum.SurfaceType.Smooth
    p.BottomSurface=Enum.SurfaceType.Smooth; p.CastShadow=true
    p.CanTouch=false
    if collide~=nil then p.CanCollide=collide end
    p.Parent=parent or map
    return p
end
local function signFace(p,text,face,bg)
    local gui=Instance.new("SurfaceGui")
    gui.Face=face or Enum.NormalId.Front
    gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud
    gui.PixelsPerStud=32; gui.LightInfluence=0; gui.Parent=p
    local label=Instance.new("TextLabel")
    label.Size=UDim2.fromScale(1,1); label.BackgroundColor3=bg or C.blue
    label.BorderSizePixel=0; label.Text=text; label.TextColor3=C.white
    label.TextScaled=true; label.Font=Enum.Font.GothamBold; label.Parent=gui
end

-- Beleuchtung: bewusst klare Tageslichtstimmung ohne unnoetige Effekte.
Lighting.ClockTime=14
Lighting.Brightness=2
Lighting.GlobalShadows=true
Lighting.Ambient=color(125,129,134)
Lighting.OutdoorAmbient=color(165,169,174)
Lighting.EnvironmentDiffuseScale=0.55
Lighting.EnvironmentSpecularScale=0.35

-- Eine durchgehende Grundplatte: alle Strassen, Gehwege und Bauparzellen liegen darueber.
part(map,"Durchgehender_Untergrund",Vector3.new(5000,8,5000),Vector3.new(0,-4,0),Enum.Material.SmoothPlastic,color(112,119,108),true)

-- Hauptstrasse: zwei Fahrbahnen, dazwischen ein klar definierter Doppelgleisbereich.
for _,x in ipairs({-82,82}) do
    part(map,"Hauptfahrbahn",Vector3.new(128,0.22,2200),Vector3.new(x,0.11,0),Enum.Material.Asphalt,C.asphalt)
end
part(map,"Gleisunterbau",Vector3.new(34,0.24,2200),Vector3.new(0,0.12,0),Enum.Material.Concrete,C.trackbed)

-- Bordsteine und breite Gehwege, exakt ausserhalb der Fahrbahnen.
for _,side in ipairs({-1,1}) do
    local x=side*153
    part(map,"Bordstein",Vector3.new(1.5,0.3,2200),Vector3.new(x,0.22,0),Enum.Material.Concrete,C.curb)
    part(map,"Gehweg",Vector3.new(28,0.22,2200),Vector3.new(side*169,0.11,0),Enum.Material.Concrete,C.pavement)
    part(map,"Randstreifen",Vector3.new(2,0.12,2200),Vector3.new(side*185,0.06,0),Enum.Material.Concrete,C.curb)
end

-- Fahrbahnmarkierungen mit Abstand zu Kreuzungen und Haltestellen.
for z=-1040,1040,34 do
    part(map,"Mittellinienmarkierung",Vector3.new(0.35,0.035,13),Vector3.new(-82,0.245,z),Enum.Material.SmoothPlastic,C.white,false)
    part(map,"Mittellinienmarkierung",Vector3.new(0.35,0.035,13),Vector3.new(82,0.245,z),Enum.Material.SmoothPlastic,C.white,false)
end
for _,x in ipairs({-142,-22,22,142}) do
    part(map,"Fahrbahnbegrenzung",Vector3.new(0.22,0.025,2150),Vector3.new(x,0.24,0),Enum.Material.SmoothPlastic,color(220,216,203),false)
end

-- Doppelgleis. Schienen und Schwellen sind als getrennte, editierbare Teile gebaut.
for _,trackX in ipairs({-5.0,5.0}) do
    for z=-1070,1070,5 do
        part(map,"Betonschwelle",Vector3.new(13,0.18,1.15),Vector3.new(trackX,0.32,z),Enum.Material.Concrete,color(112,113,108))
    end
    for _,offset in ipairs({-1.435,1.435}) do
        part(map,"Schienenfuss",Vector3.new(1.05,0.16,2200),Vector3.new(trackX+offset,0.43,0),Enum.Material.Metal,C.steel)\n        part(map,"Schienensteg",Vector3.new(0.28,0.42,2200),Vector3.new(trackX+offset,0.66,0),Enum.Material.Metal,C.rail)\n        part(map,"Schienenkopf",Vector3.new(0.58,0.18,2200),Vector3.new(trackX+offset,0.91,0),Enum.Material.Metal,color(195,201,204))
        part(map,"Schienenbefestigung",Vector3.new(1.15,0.16,0.9),Vector3.new(trackX+offset,0.43,0),Enum.Material.Metal,C.steel)
    end
end

-- Oberleitung: regelmaessige Masten, Ausleger und zwei Fahrdraehte.
for z=-1020,1020,72 do
    for _,side in ipairs({-1,1}) do
        local x=side*25
        part(map,"Oberleitungsmast",Vector3.new(0.85,20,0.85),Vector3.new(x,9,z),Enum.Material.Metal,C.steel)
        part(map,"Quertraeger",Vector3.new(62,0.4,0.4),Vector3.new(0,17.7,z),Enum.Material.Metal,C.steel)
        part(map,"Isolator",Vector3.new(0.55,0.8,0.55),Vector3.new(side*5,17.1,z),Enum.Material.Metal,C.white)
    end
end
for _,x in ipairs({-5,5}) do
    part(map,"Fahrdraht",Vector3.new(0.18,0.18,2200),Vector3.new(x,17.0,0),Enum.Material.Metal,color(185,164,119),false)
end

-- Kreuzungen: breite Querstrassen schneiden die Hauptachse im rechten Winkel.
local crossZ={-900,-600,-300,300,600,900}
for _,z in ipairs(crossZ) do
    part(map,"Querstrasse",Vector3.new(1900,0.24,58),Vector3.new(0,0.12,z),Enum.Material.Asphalt,C.asphalt)
    for _,x in ipairs({-151,151}) do
        part(map,"Querstrassenbordstein",Vector3.new(1.5,0.3,58),Vector3.new(x,0.22,z),Enum.Material.Concrete,C.curb)
    end
    for lane=-3,3 do
        part(map,"Fussgaengerueberweg",Vector3.new(4,0.035,0.7),Vector3.new(lane*5,0.255,z-35),Enum.Material.SmoothPlastic,C.white,false)
        part(map,"Fussgaengerueberweg",Vector3.new(4,0.035,0.7),Vector3.new(lane*5,0.255,z+35),Enum.Material.SmoothPlastic,C.white,false)
    end
end

-- Haltestellen mit zwei Seitenbahnsteigen, Glaswartehalle, Sitzbank,
-- Fahrplanauskunft, digitaler Anzeige und eigenem Haltestellenmast.
local function shelter(parent,cx,cz)
    local s=model("Glaswartehalle",parent)
    part(s,"Boden",Vector3.new(13,0.32,25),Vector3.new(cx,0.56,cz),Enum.Material.Concrete,color(155,157,151))
    part(s,"Dach",Vector3.new(14,0.5,26),Vector3.new(cx,6.5,cz),Enum.Material.Metal,C.steel)
    for _,dx in ipairs({-6.2,6.2}) do
        for _,dz in ipairs({-11.5,11.5}) do
            part(s,"Stuetzpfosten",Vector3.new(0.32,5.8,0.32),Vector3.new(cx+dx,3.55,cz+dz),Enum.Material.Metal,C.steel)
        end
    end
    part(s,"Rueckwand_Glas",Vector3.new(0.16,5.2,22),Vector3.new(cx-6.1,3.5,cz),Enum.Material.Glass,C.glass,false)
    part(s,"Seitenwand_Glas",Vector3.new(12,5.2,0.16),Vector3.new(cx,3.5,cz+11.4),Enum.Material.Glass,C.glass,false)
    part(s,"Sitzflaeche",Vector3.new(4.5,0.32,1.1),Vector3.new(cx+1.0,1.7,cz-2),Enum.Material.Wood,C.wood)
    part(s,"Rueckenlehne",Vector3.new(0.25,1.3,4.5),Vector3.new(cx-1.0,2.35,cz-2),Enum.Material.Wood,C.wood)
    local info=part(s,"Fahrplanauskunft",Vector3.new(0.25,4.4,2.7),Vector3.new(cx+7.3,2.7,cz-9),Enum.Material.Metal,C.steel)
    signFace(info,"RNV\nFAHRPLAN",Enum.NormalId.Left,C.blue)
    local display=part(s,"Abfahrtsanzeige",Vector3.new(0.25,2.5,4.5),Vector3.new(cx+7.3,4.0,cz+8),Enum.Material.SmoothPlastic,color(24,36,43))
    signFace(display,"LINIE     ZIEL\nABFAHRT",Enum.NormalId.Left,color(24,36,43))
    part(s,"Papierkorb",Vector3.new(1.0,1.6,1.0),Vector3.new(cx+4.5,1.35,cz+9),Enum.Material.Metal,color(65,76,74))
end
local function platform(index,z)
    for _,side in ipairs({-1,1}) do
        local cx=side*25
        local p=model("Bahnsteig_"..index.."_"..(side<0 and "West" or "Ost"))
        part(p,"Bahnsteigplatte",Vector3.new(18,0.62,118),Vector3.new(cx,0.55,z),Enum.Material.Concrete,color(176,174,165))
        part(p,"Bahnsteigkante",Vector3.new(0.45,0.14,114),Vector3.new(cx-side*8.75,0.93,z),Enum.Material.Concrete,C.yellow)
        for dz=-54,54,6 do
            part(p,"Taktiler_Leitstreifen",Vector3.new(1.25,0.08,2.4),Vector3.new(cx-side*7.55,1.0,z+dz),Enum.Material.Concrete,C.yellow,false)
        end
        shelter(p,cx+side*1.0,z-12)
        local pole=part(p,"Haltestellenmast",Vector3.new(0.45,5.6,0.45),Vector3.new(cx+side*7.0,3.4,z+47),Enum.Material.Metal,C.steel)
        local sign=part(p,"Haltestellenschild",Vector3.new(0.25,2.8,2.3),pole.Position+Vector3.new(0,3.0,0),Enum.Material.SmoothPlastic,C.blue)
        signFace(sign,"RNV",Enum.NormalId.Front,C.blue)
        part(p,"Sitzbank",Vector3.new(4,0.35,1.1),Vector3.new(cx,z*0+1.55,z+34),Enum.Material.Wood,C.wood)
        part(p,"Muelleimer",Vector3.new(1.0,1.6,1.0),Vector3.new(cx+side*4,1.35,z+37),Enum.Material.Metal,C.steel)
    end
end
platform("01",-600)
platform("02",0)
platform("03",600)

-- Rathausplatz und Rathaus: auf separater, ebener Parzelle neben der Hauptachse.
part(map,"Rathausplatz_Pflaster",Vector3.new(230,0.18,220),Vector3.new(330,0.10,80),Enum.Material.Cobblestone,color(157,153,142))
local town=model("Historisches_Rathaus")
local tx,tz=355,65
part(town,"Hauptgebaeude",Vector3.new(92,34,104),Vector3.new(tx,17,tz),Enum.Material.Concrete,color(225,205,166))
part(town,"Sockel",Vector3.new(96,1.6,108),Vector3.new(tx,0.8,tz),Enum.Material.Concrete,color(151,137,119))
part(town,"Dach_vorne",Vector3.new(98,1.1,54),CFrame.new(tx,35,tz-26)*CFrame.Angles(math.rad(-18),0,0),Enum.Material.Slate,C.brick)
part(town,"Dach_hinten",Vector3.new(98,1.1,54),CFrame.new(tx,35,tz+26)*CFrame.Angles(math.rad(18),0,0),Enum.Material.Slate,C.brick)
part(town,"Dachfirst",Vector3.new(2,2,108),Vector3.new(tx,43,tz),Enum.Material.Wood,C.roof)
-- Symmetrische Fensterreihen auf der Platzfassade.
for floor=1,3 do
    local y=5+floor*8
    for x=tx-34,tx+34,17 do
        part(town,"Fenster",Vector3.new(6,5,0.22),Vector3.new(x,y,tz-52.2),Enum.Material.Glass,C.glass,false)
        part(town,"Fenstersturz",Vector3.new(7,0.3,0.45),Vector3.new(x,y+2.7,tz-52.35),Enum.Material.Concrete,C.white,false)
        part(town,"Fensterbank",Vector3.new(7,0.3,0.45),Vector3.new(x,y-2.7,tz-52.35),Enum.Material.Concrete,C.white,false)
    end
end
for x=tx-30,tx+30,15 do
    part(town,"Eingangspfeiler",Vector3.new(1.8,10,1.8),Vector3.new(x,5,tz-54),Enum.Material.Concrete,C.white)
end
part(town,"Haupteingang",Vector3.new(10,8,0.5),Vector3.new(tx,4,tz-53),Enum.Material.Wood,C.wood)
part(town,"Turm",Vector3.new(22,25,22),Vector3.new(tx,47,tz),Enum.Material.Concrete,color(216,194,157))
part(town,"Turmdach",Vector3.new(28,11,28),Vector3.new(tx,65,tz),Enum.Material.Slate,C.roof)
part(town,"Turmspitze",Vector3.new(0.8,8,0.8),Vector3.new(tx,74,tz),Enum.Material.Metal,C.steel)
for _,x in ipairs({tx-11.2,tx+11.2}) do
    local clock=part(town,"Uhr",Vector3.new(0.2,5.5,5.5),Vector3.new(x,47,tz-11.2),Enum.Material.SmoothPlastic,C.white)
    signFace(clock,"12",Enum.NormalId.Front,C.white)
end

-- Geschaefts- und Wohnhaeuser in getrennten Bauparzellen.
-- Jede Parzelle bekommt Abstand zu Strasse, Kreuzung und Nachbargebaeude.
local facades={color(218,199,171),color(191,184,170),color(207,176,153),color(184,196,190),color(226,214,190),color(183,164,146)}
local roofColors={C.roof,C.brick,color(89,77,68)}
local shops={"CAFÉ","BÄCKEREI","BLUMEN","KIOSK","MARKT","APOTHEKE"}
local rng=Random.new(711)
local function house(index,x,z,front)
    local m=model("Stadthaus_"..index)
    local w=rng:NextInteger(34,42)
    local d=rng:NextInteger(34,42)
    local h=rng:NextInteger(25,34)
    local fc=facades[(index-1)%#facades+1]
    part(m,"Fassade",Vector3.new(w,h,d),Vector3.new(x,h/2,z),Enum.Material.Concrete,fc)
    part(m,"Sockel",Vector3.new(w+1,1.2,d+1),Vector3.new(x,0.6,z),Enum.Material.Concrete,color(144,135,119))
    part(m,"Dach",Vector3.new(w+3,1.3,d+3),Vector3.new(x,h+0.65,z),Enum.Material.Slate,roofColors[(index-1)%#roofColors+1])
    -- Frontfassade zeigt zur naechsten Strasse.
    local faceZ=z+front*(d/2+0.14)
    for floor=1,math.floor((h-5)/8) do
        local y=4+floor*7
        for colIndex=-1,1 do
            local wx=x+colIndex*(w/3.5)
            part(m,"Fenster",Vector3.new(5.2,4.6,0.2),Vector3.new(wx,y,faceZ),Enum.Material.Glass,C.glass,false)
            part(m,"Fensterbank",Vector3.new(6,0.28,0.4),Vector3.new(wx,y-2.45,faceZ+front*0.1),Enum.Material.Concrete,C.white,false)
        end
    end
    for colIndex=-1,1 do
        local wx=x+colIndex*(w/3.5)
        part(m,"Schaufenster",Vector3.new(6,5.2,0.2),Vector3.new(wx,3,faceZ+front*0.02),Enum.Material.Glass,C.glass,false)
    end
    part(m,"Ladenschild",Vector3.new(13,1.8,0.35),Vector3.new(x,6.2,faceZ+front*0.3),Enum.Material.SmoothPlastic,index%2==0 and C.blue or color(76,104,76),false)
    -- Schrift nur an Geschaeften, keine schwebenden Orts-/Haltestellennamen.
    local plaque=m:FindFirstChild("Ladenschild")
    signFace(plaque,shops[(index-1)%#shops+1],front==1 and Enum.NormalId.Back or Enum.NormalId.Front,plaque.Color)
    part(m,"Eingangstuer",Vector3.new(3.2,6,0.25),Vector3.new(x,3,faceZ+front*0.16),Enum.Material.Wood,C.wood,false)
end

local idx=0
-- Vier Seitenquartiere, weit genug von der Hauptstrasse und den Querstrassen entfernt.
for _,x in ipairs({-300,-430,-560,-690,-820,300,430,560,690,820}) do
    for _,z in ipairs({-800,-500,-200,200,500,800}) do
        idx+=1
        local front=(z<0) and 1 or -1
        house(idx,x,z,front)
    end
end

-- Kleine Seitenstrassen und ruhige Wohnstrassen als klares Raster.
for _,x in ipairs({-235,-365,-495,-625,-755,235,365,495,625,755}) do
    part(map,"Nebenstrasse",Vector3.new(34,0.2,2050),Vector3.new(x,0.1,0),Enum.Material.Asphalt,C.asphalt)
    for _,side in ipairs({-1,1}) do
        part(map,"Nebenstrassen_Gehweg",Vector3.new(7,0.18,2050),Vector3.new(x+side*20.5,0.09,0),Enum.Material.Concrete,C.pavement)
    end
end

-- Platzmoeblierung, Baeume und Strassenlaternen.
local function tree(x,z,scale)
    local m=model("Baum")
    part(m,"Stamm",Vector3.new(1.4*scale,7*scale,1.4*scale),Vector3.new(x,3.5*scale,z),Enum.Material.Wood,C.wood,false)
    local crown=part(m,"Baumkrone",Vector3.new(8*scale,8*scale,8*scale),Vector3.new(x,8*scale,z),Enum.Material.Grass,C.green,false)
    crown.Shape=Enum.PartType.Ball
end
for z=-980,980,110 do
    tree(-190,z,1); tree(190,z,1)
end
for x=250,430,45 do
    tree(x,205,1.1); tree(x,-45,1.1)
end
for z=-950,950,130 do
    for _,x in ipairs({-190,190}) do
        local lamp=model("Strassenlaterne")
        part(lamp,"Mast",Vector3.new(0.35,9,0.35),Vector3.new(x,4.5,z),Enum.Material.Metal,C.steel)
        part(lamp,"Leuchtenkopf",Vector3.new(2.5,0.3,0.8),Vector3.new(x,9,z),Enum.Material.Metal,color(235,226,198))
    end
end
for _,z in ipairs({-35,35}) do
    part(map,"Sitzbank",Vector3.new(6,0.35,1.2),Vector3.new(250,1.2,z),Enum.Material.Wood,C.wood)
end

-- Geparkte Autos in Parkbuchten ausserhalb der Gehwege.
local carColors={color(185,190,193),color(63,82,99),color(146,60,51),color(50,57,63),color(201,187,163)}
for i,z in ipairs({-850,-720,-470,-170,170,470,720,850}) do
    for _,x in ipairs({-112,112}) do
        local car=model("Geparktes_Auto")
        local cc=carColors[(i-1)%#carColors+1]
        part(car,"Karosserie",Vector3.new(5.8,1.8,11.5),Vector3.new(x,1.1,z),Enum.Material.Metal,cc,false)
        part(car,"Dach",Vector3.new(4.6,1.5,5.7),Vector3.new(x,2.65,z),Enum.Material.Glass,C.glass,false)
        for _,dx in ipairs({-2.8,2.8}) do
            for _,dz in ipairs({-3.6,3.6}) do
                local wheel=part(car,"Rad",Vector3.new(0.7,1.5,1.5),CFrame.new(x+dx,0.8,z+dz)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Rubber,color(30,31,32),false)
                wheel.Shape=Enum.PartType.Cylinder
            end
        end
    end
end

-- Bewegte Passanten: einfache Figuren laufen auf Gehwegen hin und her.
-- Die Bewegung ist absichtlich begrenzt, damit niemand in Strasse oder Gleise geraet.
local pedestrians=folder("Passanten")
local clothes={color(48,83,119),color(153,67,56),color(70,106,76),color(75,75,86),color(177,143,88)}
for i=1,16 do
    local x=(i%2==0) and -169 or 169
    local z=-770+(i-1)*100
    local npc=model("Passant_"..i,pedestrians)
    local body=part(npc,"Koerper",Vector3.new(1.5,2.4,0.8),Vector3.new(x,1.9,z),Enum.Material.Fabric,clothes[(i-1)%#clothes+1],false)
    npc.PrimaryPart=body
    local head=part(npc,"Kopf",Vector3.new(1.0,1.0,1.0),Vector3.new(x,3.6,z),Enum.Material.SmoothPlastic,C.skin,false)
    head.Shape=Enum.PartType.Ball
    part(npc,"Linkes_Bein",Vector3.new(0.5,1.4,0.55),Vector3.new(x-0.35,0.7,z),Enum.Material.Fabric,color(44,48,55),false)
    part(npc,"Rechtes_Bein",Vector3.new(0.5,1.4,0.55),Vector3.new(x+0.35,0.7,z),Enum.Material.Fabric,color(44,48,55),false)
end
local movement=Instance.new("Script")
movement.Name="Passanten_Bewegung"
movement.Source = [=[
local TweenService=game:GetService("TweenService")
local folder=script.Parent:WaitForChild("Passanten")
for _,npc in ipairs(folder:GetChildren()) do
    task.spawn(function()
        local root=npc.PrimaryPart
        if not root then return end
        local direction=(tonumber(npc.Name:match("%d+$")) or 1)%2==0 and 1 or -1
        while npc.Parent do
            local start=npc:GetPivot()
            local finish=start+Vector3.new(0,0,direction*58)
            local value=Instance.new("CFrameValue")
            value.Value=start
            local connection=value:GetPropertyChangedSignal("Value"):Connect(function()
                if npc.Parent then npc:PivotTo(value.Value) end
            end)
            local tween=TweenService:Create(value,TweenInfo.new(22,Enum.EasingStyle.Linear),{Value=finish})
            tween:Play()
            tween.Completed:Wait()
            connection:Disconnect()
            value:Destroy()
            direction=-direction
            task.wait(0.8)
        end
    end)
end
]=]
movement.Parent=map

print("[RNV MAP V8] Neuer Kartenaufbau erstellt.")
print("[RNV MAP V7] Groessere Stadt im Massstab 1.65; glatter durchgehender Boden ohne Ground-Raster; verstaerkter Gleisaufbau mit breiteren Schienenkoepfen, Schienenfuss und Befestigungen; vergroesserte Oberleitung; 3 vollstaendige Haltestellen; Rathaus; Quartiere; bewegte Passanten.")
print("[RNV MAP V7] Alle Weltobjekte liegen unter Workspace > RNV_Mannheim_Map.")
