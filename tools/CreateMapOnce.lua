-- LINDENHAFEN V16 - verlaengerte Stadt- und Ueberlandstrecke mit Landabschnitt
-- Einmalig in Roblox Studio Command Bar ausfuehren. Alle Teile bleiben editierbar.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local old = Workspace:FindFirstChild("RNV_Mannheim_Map")
if old then old:Destroy() end
local base = Workspace:FindFirstChild("Baseplate")
if base then base:Destroy() end
for _,v in ipairs(Workspace:GetDescendants()) do
 if v:IsA("SpawnLocation") then v:Destroy() end
end

local map=Instance.new("Folder"); map.Name="RNV_Mannheim_Map"; map.Parent=Workspace
local function col(r,g,b) return Color3.fromRGB(r,g,b) end
local C={
 grass=col(94,137,88), grass2=col(119,151,99), asphalt=col(48,53,58),
 sidewalk=col(187,184,171), curb=col(221,215,197), concrete=col(143,149,149),
 bed=col(65,72,77), sleeper=col(125,132,132), rail=col(207,215,216),
 steel=col(48,61,69), wire=col(181,145,91), glass=col(105,169,190),
 white=col(241,238,224), green=col(69,119,75), dark=col(54,57,60),
 wood=col(139,101,70), yellow=col(231,190,75)
}
local function folder(n,p) local o=Instance.new("Folder"); o.Name=n; o.Parent=p or map; return o end
local function model(n,p) local o=Instance.new("Model"); o.Name=n; o.Parent=p or map; return o end
local function part(p,n,s,cf,mat,c,collide,trans)
 local o=Instance.new("Part"); o.Name=n; o.Size=s; o.CFrame=cf
 o.Anchored=true; o.Material=mat or Enum.Material.SmoothPlastic; o.Color=c or C.white
 o.TopSurface=Enum.SurfaceType.Smooth; o.BottomSurface=Enum.SurfaceType.Smooth
 o.CanCollide=collide==true; o.CanTouch=false; o.CastShadow=true
 if trans then o.Transparency=trans end
 o.Parent=p or map; return o
end
local function block(p,n,s,pos,mat,c,collide)
 return part(p,n,s,CFrame.new(pos),mat,c,collide)
end
local function segment(p,n,w,h,a,b,y,mat,c,collide)
 local d=Vector3.new(b.X-a.X,0,b.Z-a.Z)
 if d.Magnitude<0.1 then return end
 local mid=(a+b)*0.5
 local cf=CFrame.lookAt(Vector3.new(mid.X,y,mid.Z),Vector3.new(mid.X,y,mid.Z)+d.Unit)
 return part(p,n,Vector3.new(w,h,d.Magnitude+0.08),cf,mat,c,collide)
end
local function cat(p0,p1,p2,p3,t)
 local t2=t*t; local t3=t2*t
 return (p1*2+(p2-p0)*t+(p0*2-p1*5+p2*4-p3)*t2+(-p0+p1*3-p2*3+p3)*t3)*0.5
end
local function smooth(nodes,steps)
 local out={}
 for i=1,#nodes-1 do
  local p0=nodes[math.max(1,i-1)]; local p1=nodes[i]
  local p2=nodes[i+1]; local p3=nodes[math.min(#nodes,i+2)]
  for j=0,steps-1 do out[#out+1]=cat(p0,p1,p2,p3,j/steps) end
 end
 out[#out+1]=nodes[#nodes]; return out
end
local function basis(points,i)
 local d=points[math.min(#points,i+1)]-points[math.max(1,i-1)]
 if d.Magnitude<0.001 then d=Vector3.new(1,0,0) end
 local t=d.Unit; return t,Vector3.new(-t.Z,0,t.X)
end
local function offset(points,n)
 local out={}
 for i,p in ipairs(points) do local _,normal=basis(points,i); out[i]=p+normal*n end
 return out
end
local function pathLength(points)
 local sum=0; for i=1,#points-1 do sum+=(points[i+1]-points[i]).Magnitude end; return sum
end
local function atDistance(points,dist)
 local left=math.clamp(dist,0,pathLength(points))
 for i=1,#points-1 do
  local d=(points[i+1]-points[i]).Magnitude
  if left<=d or i==#points-1 then
   local a=d>0 and math.clamp(left/d,0,1) or 0
   local p=points[i]:Lerp(points[i+1],a); local t=(points[i+1]-points[i]).Unit
   return p,t,Vector3.new(-t.Z,0,t.X)
  end
  left-=d
 end
 local t,n=basis(points,#points); return points[#points],t,n
end

-- Lighting
Lighting.ClockTime=14; Lighting.Brightness=2.1; Lighting.GlobalShadows=true
Lighting.ShadowSoftness=0.35; Lighting.Ambient=col(125,130,132)
Lighting.OutdoorAmbient=col(164,171,169)
for _,n in ipairs({"RNV_Atmosphere","RNV_Color"}) do local e=Lighting:FindFirstChild(n); if e then e:Destroy() end end
local atmosphere=Instance.new("Atmosphere"); atmosphere.Name="RNV_Atmosphere"
atmosphere.Density=0.18; atmosphere.Offset=0.08; atmosphere.Haze=0.6
atmosphere.Color=col(208,222,229); atmosphere.Decay=col(128,143,149); atmosphere.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect"); cc.Name="RNV_Color"
cc.Contrast=0.06; cc.Saturation=0.03; cc.TintColor=col(255,249,239); cc.Parent=Lighting

-- Grosses, zusammenhaengendes Stadtgebiet statt vier kleiner Bodenplatten.
block(map,"Stadtgebiet_Lindenhafen",Vector3.new(8600,3,5000),Vector3.new(0,-1.5,0),Enum.Material.Grass,C.grass,true) -- Oberkante exakt auf Y=0

-- Offene Linie: lange Gerade, sanfte Kurven, weitere Gerade und ein zweiter Bogen.
-- Kein geschlossener Ring. Enden bleiben fuer spaetere Erweiterungen offen.
local route=smooth({
 Vector3.new(-1645,0,-1000),Vector3.new(-1150,0,-1000),
 Vector3.new(-650,0,-1000),Vector3.new(-300,0,-920),
 Vector3.new(0,0,-700),Vector3.new(220,0,-430),
 Vector3.new(300,0,-100),Vector3.new(300,0,350),
 Vector3.new(420,0,700),Vector3.new(720,0,930),
 Vector3.new(1150,0,980),Vector3.new(1650,0,980),
 -- Ueberlandverlaengerung: aus dem Stadtrand hinaus in offene Landschaft.
 Vector3.new(2150,0,1020),Vector3.new(2650,0,930),
 Vector3.new(3100,0,650),Vector3.new(3500,0,250),
 Vector3.new(3850,0,-180)
},18)
local total=pathLength(route)

-- Strassen parallel zur Tramtrasse: eigene Fahrbahnen, keine Asphaltdecke ueber den Gleisen.
local roads=folder("Strassen_und_Kreuzungen")
local function road(points,width,name)
 local m=model(name,roads)
 local leftC=offset(points,-width/2-0.8); local rightC=offset(points,width/2+0.8)
 local leftS=offset(points,-width/2-5.2); local rightS=offset(points,width/2+5.2)
 for i=1,#points-1 do
  segment(m,"Fahrbahn",width,0.28,points[i],points[i+1],0.02,Enum.Material.Asphalt,C.asphalt,true)
  segment(m,"Bordstein",0.8,0.28,leftC[i],leftC[i+1],0.14,Enum.Material.Concrete,C.curb,true)
  segment(m,"Bordstein",0.8,0.28,rightC[i],rightC[i+1],0.14,Enum.Material.Concrete,C.curb,true)
  segment(m,"Gehweg",8,0.2,leftS[i],leftS[i+1],0.12,Enum.Material.Concrete,C.sidewalk,true)
  segment(m,"Gehweg",8,0.2,rightS[i],rightS[i+1],0.12,Enum.Material.Concrete,C.sidewalk,true)
 end
 return m
end
-- Die breiten Boulevards enden am Stadtrand. Der Landabschnitt bleibt bewusst ohne durchgehende Parallelstrasse.
local urbanRoute={}
for d=0,total*0.58,35 do local p=atDistance(route,d); urbanRoute[#urbanRoute+1]=p end
local lastUrban=atDistance(route,total*0.58); urbanRoute[#urbanRoute+1]=lastUrban
road(offset(urbanRoute,57),23,"Boulevard_Nord")
road(offset(urbanRoute,-57),23,"Boulevard_Sued")
local crossRoads={
 {Vector3.new(-1050,0,-1370),Vector3.new(-1000,0,-1120),Vector3.new(-980,0,-850),Vector3.new(-900,0,-580)},
 {Vector3.new(-450,0,-1370),Vector3.new(-420,0,-1110),Vector3.new(-390,0,-850),Vector3.new(-300,0,-600)},
 {Vector3.new(100,0,-1350),Vector3.new(130,0,-1080),Vector3.new(180,0,-820),Vector3.new(230,0,-570)},
 {Vector3.new(650,0,-250),Vector3.new(900,0,-180),Vector3.new(1180,0,-100),Vector3.new(1450,0,40)},
 {Vector3.new(650,0,450),Vector3.new(900,0,500),Vector3.new(1180,0,600),Vector3.new(1500,0,740)},
 {Vector3.new(-150,0,900),Vector3.new(150,0,1080),Vector3.new(480,0,1190),Vector3.new(850,0,1240)},
 {Vector3.new(1000,0,1250),Vector3.new(1250,0,1270),Vector3.new(1500,0,1280),Vector3.new(1800,0,1280)}
}
for i,nodes in ipairs(crossRoads) do road(smooth(nodes,12),22,"Quartiersstrasse_"..i) end

-- Doppelgleis mit grossem Mittenabstand von 18 Studs.
-- Schwellen quer zur Fahrtrichtung; Schienenkoepfe korrekt auf den Schienenstegen.
local track=model("Doppelgleis_4_Schienen")
local centers={-9,9}
for laneIndex,centre in ipairs(centers) do
 local lane=model(laneIndex==1 and "Gleis_A" or "Gleis_B",track)
 local lanePath=offset(route,centre)
 for i=1,#lanePath-1 do
  segment(lane,"Gleisunterbau",6.5,0.38,lanePath[i],lanePath[i+1],0.3,Enum.Material.Concrete,C.bed,true)
 end
 for d=0,total,8 do
  local p,t,n=atDistance(route,d); p=p+n*centre
  local cf=CFrame.lookAt(Vector3.new(p.X,0.58,p.Z),Vector3.new(p.X,0.58,p.Z)+t)
  part(lane,"Querschwelle",Vector3.new(5.9,0.22,1.35),cf,Enum.Material.Concrete,C.sleeper,true)
 end
 for _,gauge in ipairs({-1.5,1.5}) do
  local rp=offset(route,centre+gauge)
  for i=1,#rp-1 do
   segment(lane,"Schienensteg",0.42,0.48,rp[i],rp[i+1],0.82,Enum.Material.Metal,C.dark,false)
   segment(lane,"Schienenkopf",0.66,0.2,rp[i],rp[i+1],1.13,Enum.Material.Metal,C.rail,false)
  end
 end
end

-- Depot: Halle direkt an den Streckenanfang angeschlossen, zwei breite Tore.
local depot=model("Betriebshof")
block(depot,"Hofplatte",Vector3.new(260,0.35,190),Vector3.new(-1770,0.1,-1000),Enum.Material.Concrete,C.sidewalk,true)
local hall=model("Wagenhalle",depot)
block(hall,"Rueckwand",Vector3.new(2,19,100),Vector3.new(-1835,9.5,-1000),Enum.Material.Concrete,col(183,190,188),true)
block(hall,"Seitenwand_Nord",Vector3.new(125,19,2),Vector3.new(-1772,9.5,-1050),Enum.Material.Concrete,col(183,190,188),true)
block(hall,"Seitenwand_Sued",Vector3.new(125,19,2),Vector3.new(-1772,9.5,-950),Enum.Material.Concrete,col(183,190,188),true)
block(hall,"Dach",Vector3.new(130,1.5,106),Vector3.new(-1772,19.5,-1000),Enum.Material.Metal,C.steel,true)
-- Portalrahmen an der Ostseite, Tore bleiben offen und Gleise laufen hinein.
for _,z in ipairs({-1045,-1000,-955}) do
 block(hall,"Torpfosten",Vector3.new(2,15,2),Vector3.new(-1708,7.5,z),Enum.Material.Metal,C.steel,true)
end
block(hall,"Torsturz",Vector3.new(2,2,100),Vector3.new(-1708,17,-1000),Enum.Material.Metal,C.steel,true)
-- Zwei Anschlussgleise mit je zwei Schienen, passend zum Haupt-Doppelgleis.
for _,centre in ipairs({-9,9}) do
 local z=-1000+centre
 segment(depot,"Depotanschluss_Bett",6.5,0.35,Vector3.new(-1708,0,z),Vector3.new(-1645,0,z),0.3,Enum.Material.Concrete,C.bed,true)
 for _,g in ipairs({-1.5,1.5}) do
  local zz=z+g
  segment(depot,"Depotanschluss_Schiene",0.66,0.2,Vector3.new(-1708,0,zz),Vector3.new(-1645,0,zz),1.13,Enum.Material.Metal,C.rail,false)
 end
end
-- Spawn ausserhalb der Hallentore
local spawn=Instance.new("SpawnLocation"); spawn.Name="SpielerSpawn_Betriebshof"
spawn.Size=Vector3.new(8,1,8); spawn.CFrame=CFrame.new(-1770,1,-1110)
spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0
spawn.Material=Enum.Material.Concrete; spawn.Color=col(83,145,116); spawn.Parent=depot

-- Oberleitung folgt der Strecke; Masten links/rechts und Draht ueber jedem Gleis.
local overhead=model("Oberleitung")
for i=4,#route-3,6 do
 local _,normal=basis(route,i); local p=route[i]
 local left=p-normal*23; local right=p+normal*23
 for _,q in ipairs({left,right}) do
  block(overhead,"Mastfundament",Vector3.new(2,0.65,2),Vector3.new(q.X,0.33,q.Z),Enum.Material.Concrete,C.concrete,true)
  block(overhead,"Oberleitungsmast",Vector3.new(0.75,17.5,0.75),Vector3.new(q.X,9.1,q.Z),Enum.Material.Metal,C.steel,true)
 end
 segment(overhead,"Quertragwerk",0.45,0.45,left,right,16.8,Enum.Material.Metal,C.steel,false)
end
for _,centre in ipairs(centers) do
 local wirePath=offset(route,centre)
 for i=1,#wirePath-1 do
  segment(overhead,"Fahrdraht",0.18,0.18,wirePath[i],wirePath[i+1],15.2,Enum.Material.Metal,C.wire,false)
 end
end

-- Haltestellen: Bahnsteige liegen parallel zum Gleis und seitlich ausserhalb der Gleise.
local stations=model("Haltestellen")
local function station(name,distance)
 local p,t,n=atDistance(route,distance); local s=model(name,stations)
 for _,side in ipairs({-1,1}) do
  local centre=side*20; local pos=p+n*centre
  local platformCF=CFrame.lookAt(Vector3.new(pos.X,0.45,pos.Z),Vector3.new(pos.X,0.45,pos.Z)+t)
  part(s,"Bahnsteig",Vector3.new(7.5,0.8,76),platformCF,Enum.Material.Concrete,C.sidewalk,true)
  local edgePos=pos-n*(side*3.25)
  local edgeCF=CFrame.lookAt(Vector3.new(edgePos.X,0.98,edgePos.Z),Vector3.new(edgePos.X,0.98,edgePos.Z)+t)
  part(s,"Taktile_Bahnsteigkante",Vector3.new(0.55,0.16,74),edgeCF,Enum.Material.SmoothPlastic,C.yellow,false)
  -- Shelter has a narrow footprint and a long roof aligned with the platform.
  for _,along in ipairs({-23,23}) do
   for _,across in ipairs({-2.3,2.3}) do
    local q=pos+t*along+n*across
    block(s,"Dachstuetze",Vector3.new(0.32,4.2,0.32),Vector3.new(q.X,3.0,q.Z),Enum.Material.Metal,C.steel,true)
   end
  end
  local roofCF=CFrame.lookAt(Vector3.new(pos.X,5.25,pos.Z),Vector3.new(pos.X,5.25,pos.Z)+t)
  part(s,"Haltestellendach",Vector3.new(6.4,0.45,55),roofCF,Enum.Material.Metal,C.steel,true)
  for _,along in ipairs({-18,18}) do
   local q=pos+t*along+n*2.6
   local glassCF=CFrame.lookAt(Vector3.new(q.X,2.1,q.Z),Vector3.new(q.X,2.1,q.Z)+t)
   part(s,"Glaswand",Vector3.new(0.18,2.6,3.5),glassCF,Enum.Material.Glass,C.glass,false,0.16)
  end
  local bench=pos+t*7+n*(side*1.4)
  block(s,"Sitzbank",Vector3.new(1.1,0.45,8),Vector3.new(bench.X,1.3,bench.Z),Enum.Material.Wood,C.wood,true)
  local bin=pos+t*(-28)+n*(side*2.1)
  block(s,"Abfallbehaelter",Vector3.new(1.1,1.6,1.1),Vector3.new(bin.X,1.2,bin.Z),Enum.Material.Metal,C.steel,true)
  local pole=pos+t*(-31)+n*(side*2.5)
  block(s,"Anzeigemast",Vector3.new(0.35,4.8,0.35),Vector3.new(pole.X,2.8,pole.Z),Enum.Material.Metal,C.steel,true)
  block(s,"Anzeige_ohne_Text",Vector3.new(2.2,1.4,0.35),Vector3.new(pole.X,5.2,pole.Z),Enum.Material.SmoothPlastic,C.dark,false)
 end
end
station("Haltestelle_Westtor",total*0.18)
station("Haltestelle_Stadtmitte",total*0.48)
station("Haltestelle_Hafenpark",total*0.62)
station("Haltestelle_Landbahnhof",total*0.91)

-- Stadtgebaeude. Die Reihen folgen den Boulevardstrassen und stehen sichtbar naeher an der Tram.
local buildings=model("Stadtgebaeude")
local rng=Random.new(191126)
local facades={col(218,202,174),col(190,190,179),col(185,132,105),col(208,216,211),col(224,216,195),col(164,181,181),col(204,184,162)}
local roofs={col(63,67,70),col(93,74,63),col(109,88,72),col(75,84,87)}
local function house(name,x,z,w,d,floors,rot,kind)
 local m=model(name,buildings); local cf=CFrame.new(x,0,z)*CFrame.Angles(0,math.rad(rot),0)
 local h=floors*8.5; local facade=facades[rng:NextInteger(1,#facades)]
 part(m,"Fassade",Vector3.new(w,h,d),cf*CFrame.new(0,h/2,0),Enum.Material.SmoothPlastic,facade,true)
 part(m,"Sockel",Vector3.new(w+0.8,1,d+0.8),cf*CFrame.new(0,0.55,0),Enum.Material.Concrete,C.concrete,true)
 part(m,"Dach",Vector3.new(w+2,1.1,d+2),cf*CFrame.new(0,h+0.5,0),Enum.Material.Slate,roofs[rng:NextInteger(1,#roofs)],true)
 local count=math.max(2,math.floor(w/11))
 for fy=1,floors do
  for wx=1,count do
   local xx=-w/2+wx*w/(count+1); local yy=2.5+(fy-1)*8.5
   part(m,"Fenster",Vector3.new(3.8,3.8,0.22),cf*CFrame.new(xx,yy,-d/2-0.13),Enum.Material.Glass,C.glass,false,0.08)
   part(m,"Fensterbank",Vector3.new(4.3,0.2,0.42),cf*CFrame.new(xx,yy-2,-d/2-0.18),Enum.Material.Concrete,C.white,false)
  end
 end
 part(m,"Eingangstuer",Vector3.new(3.6,6.4,0.35),cf*CFrame.new(0,3.2,-d/2-0.2),Enum.Material.Wood,C.wood,false)
 part(m,"Vordach",Vector3.new(7,0.45,3),cf*CFrame.new(0,6.8,-d/2-1.3),Enum.Material.Metal,C.steel,true)
 if kind=="shop" then
  part(m,"Schaufenster",Vector3.new(w*0.65,4.2,0.3),cf*CFrame.new(0,3.5,-d/2-0.22),Enum.Material.Glass,C.glass,false,0.08)
  part(m,"Markise",Vector3.new(w*0.75,0.4,2.6),cf*CFrame.new(0,6.1,-d/2-1.3),Enum.Material.SmoothPlastic,col(170,91,73),false)
 end
 if kind=="apartment" then
  for fy=1,floors-1 do
   local yy=4.2+(fy-1)*8.5
   part(m,"Balkon",Vector3.new(6,0.3,1.8),cf*CFrame.new(-w*0.22,yy,-d/2-0.9),Enum.Material.Concrete,C.concrete,true)
   part(m,"Balkongelaender",Vector3.new(6,1,0.16),cf*CFrame.new(-w*0.22,yy+0.65,-d/2-1.7),Enum.Material.Metal,C.white,false)
  end
 end
 return m
end

-- Gebaeudezeilen an beiden Strassenseiten entlang der gesamten Tramachse.
for sideIndex,side in ipairs({-1,1}) do
 for d=105,math.floor(total-70),155 do
  local p,t,n=atDistance(route,d)
  local q=p+n*(side*108)
  local width=rng:NextInteger(42,58); local depth=rng:NextInteger(34,46)
  local kind=(d%3==0) and "shop" or ((d%2==0) and "apartment" or "house")
  house("Quartierhaus_"..sideIndex.."_"..d,q.X,q.Z,width,depth,rng:NextInteger(2,4),math.deg(math.atan2(-t.Z,t.X)),kind)
 end
end

-- Markante oeffentliche Gebaeude in den Stadtquartieren.
local function publicBuilding(name,x,z,w,d,h,facade)
 local m=model(name,buildings)
 block(m,"Baukörper",Vector3.new(w,h,d),Vector3.new(x,h/2,z),Enum.Material.Concrete,facade,true)
 block(m,"Dachkante",Vector3.new(w+4,1.5,d+4),Vector3.new(x,h+0.75,z),Enum.Material.Metal,C.steel,true)
 for i=-2,2 do block(m,"Glasfassade",Vector3.new(w/6,h*0.65,0.35),Vector3.new(x+i*w/6,h*0.48,z-d/2-0.22),Enum.Material.Glass,C.glass,false,0.12) end
end
publicBuilding("Rathaus",-650,-480,100,68,32,col(202,196,178))
publicBuilding("Stadtbibliothek",500,1180,110,72,27,col(186,199,195))
publicBuilding("Einkaufszentrum",1280,650,132,82,30,col(187,195,191))
publicBuilding("Feuerwache",-1350,-650,92,64,24,col(195,190,178))
publicBuilding("Schule",-450,1180,120,78,25,col(214,204,184))
publicBuilding("Hafenhalle",1450,350,118,74,22,col(174,187,186))

-- Ueberlandabschnitt: Felder, Wiesenstreifen, Baumgruppen und ein kleiner Hof.
local countryside=folder("Ueberland_und_Landwirtschaft")
for i=1,8 do
 local d=total*(0.66+i*0.037)
 local p,t,n=atDistance(route,d)
 for side=-1,1,2 do
  local q=p+n*(side*190)
  local field=block(countryside,"Ackerfeld_"..i.."_"..side,Vector3.new(175,0.18,115),Vector3.new(q.X,0.07,q.Z),Enum.Material.Grass,(i%2==0) and col(151,157,91) or col(174,166,104),false)
  field.CFrame=CFrame.lookAt(field.Position,field.Position+Vector3.new(t.X,0,t.Z))
 end
end
-- Feldweg und Zufahrt zu einem kleinen Aussiedlerhof, nicht parallel zur Tramlinie.
road(smooth({Vector3.new(2450,0,1450),Vector3.new(2700,0,1650),Vector3.new(3000,0,1740),Vector3.new(3260,0,1690)},10),9,"Landwirtschaftlicher_Feldweg")
local farm=model("Aussiedlerhof",countryside)
block(farm,"Wohnhaus",Vector3.new(34,18,28),Vector3.new(2940,9,1580),Enum.Material.Brick,col(190,160,130),true)
block(farm,"Wohnhausdach",Vector3.new(38,2,32),Vector3.new(2940,19,1580),Enum.Material.Slate,C.steel,true)
block(farm,"Scheune",Vector3.new(48,15,34),Vector3.new(3020,7.5,1650),Enum.Material.Wood,C.wood,true)
block(farm,"Scheunendach",Vector3.new(53,2,39),Vector3.new(3020,16,1650),Enum.Material.Metal,col(105,76,59),true)
for i=1,9 do
 local x=2800+i*28
 block(countryside,"Hain_Stamm_"..i,Vector3.new(1.3,7,1.3),Vector3.new(x,3.5,1780+(i%2)*18),Enum.Material.Wood,C.wood,false)
 local crown=block(countryside,"Hain_Krone_"..i,Vector3.new(7,7,7),Vector3.new(x,8,1780+(i%2)*18),Enum.Material.Grass,C.green,false)
 crown.Shape=Enum.PartType.Ball
end

-- Fest abgestellte, selbstgebaute Autos am Strassenrand (statisch, keine Bewegung).
local parkedCars=folder("Statische_Autos")
local carColors={col(180,55,48),col(55,91,142),col(210,193,145),col(65,105,76),col(65,66,70),col(220,220,210)}
local function parkedCar(name,distance,side,colorIndex)
 local p,t,n=atDistance(route,distance)
 local center=p+n*(side*57)
 local cf=CFrame.lookAt(Vector3.new(center.X,0.25,center.Z),Vector3.new(center.X,0.25,center.Z)+t)
 local m=model(name,parkedCars)
 local color=carColors[colorIndex]
 part(m,"Karosserie",Vector3.new(7.2,2.1,13.5),cf*CFrame.new(0,1.25,0),Enum.Material.Metal,color,true)
 part(m,"Fahrgastzelle",Vector3.new(6.1,2.0,6.7),cf*CFrame.new(0,3.1,-0.4),Enum.Material.Metal,color,true)
 part(m,"Frontscheibe",Vector3.new(5.7,1.45,0.16),cf*CFrame.new(0,3.15,-3.82),Enum.Material.Glass,C.glass,false,0.12)
 part(m,"Heckscheibe",Vector3.new(5.7,1.35,0.16),cf*CFrame.new(0,3.1,3.05),Enum.Material.Glass,C.glass,false,0.12)
 for _,x in ipairs({-3.75,3.75}) do
  for _,z in ipairs({-4.2,4.2}) do
   local wheel=part(m,"Rad",Vector3.new(1.1,2.2,2.2),cf*CFrame.new(x,1.0,z)*CFrame.Angles(0,0,math.rad(90)),Enum.Material.Rubber,C.dark,true)
   wheel.Shape=Enum.PartType.Cylinder
  end
 end
 part(m,"Frontlicht_L",Vector3.new(0.22,0.5,1.1),cf*CFrame.new(-2.55,1.55,-6.85),Enum.Material.Neon,C.white,false)
 part(m,"Frontlicht_R",Vector3.new(0.22,0.5,1.1),cf*CFrame.new(2.55,1.55,-6.85),Enum.Material.Neon,C.white,false)
end
for i,d in ipairs({180,310,455,590,730,870,1010,1150,1290,1430}) do
 if d<total*0.54 then parkedCar("Parkendes_Auto_"..i,d,(i%2==0) and -1 or 1,((i-1)%#carColors)+1) end
end

-- Baeume und Stadtmobiliar auf Gehwegen und in Parks.
local greenery=folder("Baeume_und_Stadtmobiliar")
local function tree(x,z,scale)
 local m=model("Stadtbaum",greenery)
 block(m,"Stamm",Vector3.new(1.2*scale,6*scale,1.2*scale),Vector3.new(x,3*scale,z),Enum.Material.Wood,C.wood,true)
 local a=block(m,"Baumkrone",Vector3.new(7*scale,7*scale,7*scale),Vector3.new(x,7*scale,z),Enum.Material.Grass,C.green,false); a.Shape=Enum.PartType.Ball
 local b=block(m,"Kronenspitze",Vector3.new(5.5*scale,6*scale,5.5*scale),Vector3.new(x+1,10*scale,z),Enum.Material.Grass,col(83,139,78),false); b.Shape=Enum.PartType.Ball
end
for sideIndex,side in ipairs({-1,1}) do
 for d=70,math.floor(total-40),90 do
  local p,t,n=atDistance(route,d)
  local q=p+n*(side*43)
  tree(q.X,q.Z,0.9)
 end
end
local function lamp(x,z)
 local m=model("Strassenlaterne",greenery)
 block(m,"Mast",Vector3.new(0.38,8.5,0.38),Vector3.new(x,4.25,z),Enum.Material.Metal,C.steel,true)
 block(m,"Ausleger",Vector3.new(2.2,0.25,0.25),Vector3.new(x+0.9,8.2,z),Enum.Material.Metal,C.steel,false)
 local l=block(m,"Leuchte",Vector3.new(1.1,0.35,0.65),Vector3.new(x+1.8,8,z),Enum.Material.SmoothPlastic,C.white,false)
 local light=Instance.new("PointLight"); light.Brightness=0.4; light.Range=16; light.Color=col(255,231,185); light.Parent=l
end
for sideIndex,side in ipairs({-1,1}) do
 for d=40,math.floor(total-20),135 do
  local p,t,n=atDistance(route,d); local q=p+n*(side*48); lamp(q.X,q.Z)
 end
end

-- Park mit Teich im noerdlichen Stadtteil.
local park=folder("Lindenpark")
block(park,"Parkwiese",Vector3.new(390,0.25,240),Vector3.new(650,0.08,1450),Enum.Material.Grass,C.grass2,false)
block(park,"Teich",Vector3.new(150,0.4,76),Vector3.new(650,0.2,1450),Enum.Material.Glass,col(62,139,157),false)
block(park,"Uferweg",Vector3.new(210,0.25,10),Vector3.new(650,0.28,1495),Enum.Material.Concrete,C.sidewalk,false)
for _,p in ipairs({{480,1360},{560,1370},{750,1360},{830,1430},{500,1530},{780,1540}}) do tree(p[1],p[2],1.1) end

-- GESAMTE KARTE VERGROESSERN: Strecke, Gleisabstand, Gebaeude, Strassen,
-- Haltestellen, Oberleitung, Mobiliar und Grasflaeche werden gemeinsam skaliert.
-- Dadurch bleiben alle Abstaende und Hoehenverhaeltnisse erhalten.
local MAP_SCALE = 1.5
-- Alle Bauteile inklusive Spawn, Gleise, Gebaeude und Deko einheitlich skalieren.
for _,obj in ipairs(map:GetDescendants()) do
 if obj:IsA("BasePart") then
  local oldCF=obj.CFrame
  local rotation=oldCF-oldCF.Position
  obj.Size=obj.Size*MAP_SCALE
  obj.CFrame=CFrame.new(oldCF.Position*MAP_SCALE)*rotation
 end
end
-- Grasoberkante exakt auf Y=0 setzen, damit Gebaeude nicht schweben.
local ground=map:FindFirstChild("Stadtgebiet_Lindenhafen")
if ground then ground.Position=Vector3.new(0,-ground.Size.Y/2,0) end

print("[LINDENHAFEN V16] Verlaengerte Tramstrecke mit Stadt-, Feld- und Ueberlandabschnitt erstellt.")
print("[LINDENHAFEN V16] Stadtboulevards enden am Stadtrand; Landabschnitt ohne durchgehende Parallelstrasse.")
print("[LINDENHAFEN V16] Statische, selbstgebaute Autos und Aussiedlerhof hinzugefuegt.")
print("[LINDENHAFEN V16] Bodenflaeche vergroessert; alle Objekte bleiben editierbar.")
