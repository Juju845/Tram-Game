-- LINDENHAFEN TRAM CITY | MAP V12
-- Komplett neue Stadtgestaltung. Einmalig in Studio Command Bar ausfuehren.
-- Alle Objekte bleiben normale, einzeln editierbare Parts/Models.
-- Keine schwebenden Karten-, Bauplatz- oder Haltestellen-Billboards.

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local old = Workspace:FindFirstChild("RNV_Mannheim_Map")
if old then old:Destroy() end
local base = Workspace:FindFirstChild("Baseplate")
if base then base:Destroy() end
for _,v in ipairs(Workspace:GetDescendants()) do
    if v:IsA("SpawnLocation") then v:Destroy() end
end

local map = Instance.new("Folder")
map.Name = "Lindenhafen_Stadt"
map.Parent = Workspace

local function color(r,g,b) return Color3.fromRGB(r,g,b) end
local C = {
 grass=color(91,135,83), grass2=color(112,151,93), asphalt=color(48,53,57),
 sidewalk=color(185,183,172), curb=color(220,215,197), concrete=color(139,145,145),
 trackbed=color(66,73,77), sleeper=color(126,132,130), rail=color(202,211,213),
 steel=color(48,61,69), wire=color(181,145,91), glass=color(105,169,190),
 cream=color(224,211,184), brick=color(177,105,82), white=color(241,238,224),
 green=color(65,117,73), water=color(62,139,157), dark=color(54,57,60)
}
local function folder(name,parent)
 local x=Instance.new("Folder"); x.Name=name; x.Parent=parent or map; return x
end
local function model(name,parent)
 local x=Instance.new("Model"); x.Name=name; x.Parent=parent or map; return x
end
local function part(parent,name,size,cf,mat,col,collide,trans)
 local p=Instance.new("Part"); p.Name=name; p.Size=size; p.CFrame=cf
 p.Anchored=true; p.Material=mat or Enum.Material.SmoothPlastic
 p.Color=col or C.white; p.TopSurface=Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth; p.CastShadow=true
 p.CanTouch=false; p.CanCollide=collide==true
 if trans then p.Transparency=trans end
 p.Parent=parent or map; return p
end
local function block(parent,name,size,pos,mat,col,collide)
 return part(parent,name,size,CFrame.new(pos),mat,col,collide)
end
local function segment(parent,name,width,height,a,b,y,mat,col,collide)
 local d=b-a; local flat=Vector3.new(d.X,0,d.Z)
 if flat.Magnitude<0.05 then return end
 local mid=(a+b)*0.5
 local cf=CFrame.lookAt(Vector3.new(mid.X,y,mid.Z),Vector3.new(mid.X, y, mid.Z)+flat.Unit,Vector3.yAxis)
 return part(parent,name,Vector3.new(width,height,flat.Magnitude+0.15),cf,mat,col,collide)
end
local function ball(parent,name,size,pos,mat,col)
 local p=block(parent,name,size,pos,mat,col,false); p.Shape=Enum.PartType.Ball; return p
end

-- Tageslicht und ruhige, warme Stadtfarben.
Lighting.ClockTime=14.1; Lighting.Brightness=2.15; Lighting.GlobalShadows=true
Lighting.ShadowSoftness=0.38; Lighting.Ambient=color(118,125,127)
Lighting.OutdoorAmbient=color(164,171,169); Lighting.EnvironmentDiffuseScale=0.7
Lighting.EnvironmentSpecularScale=0.42
for _,n in ipairs({"RNV_Atmosphere","RNV_Color","RNV_Bloom"}) do
 local e=Lighting:FindFirstChild(n); if e then e:Destroy() end
end
local at=Instance.new("Atmosphere"); at.Name="RNV_Atmosphere"; at.Density=0.19
at.Offset=0.08; at.Color=color(205,222,229); at.Decay=color(124,139,145)
at.Haze=0.65; at.Glare=0.04; at.Parent=Lighting
local cc=Instance.new("ColorCorrectionEffect"); cc.Name="RNV_Color"
cc.Brightness=0.01; cc.Contrast=0.07; cc.Saturation=0.04
cc.TintColor=color(255,249,238); cc.Parent=Lighting

-- Stadtgrund und Park-/Wasserflaechen.
for _,x in ipairs({-650,650}) do
 for _,z in ipairs({-650,650}) do
  block(map,"Stadtterrain",Vector3.new(1300,2,1300),Vector3.new(x,-1.1,z),Enum.Material.Grass,C.grass,true)
 end
end
local nature=folder("Parks_und_Ufer")
block(nature,"Lindenpark_Wiese",Vector3.new(360,0.25,250),Vector3.new(-680,0.08,500),Enum.Material.Grass,C.grass2,false)
block(nature,"Stadtteich",Vector3.new(180,0.45,92),Vector3.new(-680,0.18,500),Enum.Material.Glass,C.water,false)
block(nature,"Uferpromenade",Vector3.new(230,0.35,12),Vector3.new(-680,0.25,550),Enum.Material.Concrete,C.sidewalk,true)

-- Weiche Kurven fuer Tram und Strassen.
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
 if d.Magnitude<0.001 then d=Vector3.new(0,0,-1) end
 local t=d.Unit; return t,Vector3.new(-t.Z,0,t.X)
end
local function offset(points,n)
 local out={}
 for i,p in ipairs(points) do local _,normal=basis(points,i); out[i]=p+normal*n end
 return out
end
local function length(points)
 local n=0; for i=1,#points-1 do n+=(points[i+1]-points[i]).Magnitude end; return n
end
local function atDistance(points,dist)
 local left=dist
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

-- Neue eigene Stadt: zentrale Tramachse mit zwei grosszuegigem Abstand.
local route=smooth({
 Vector3.new(-1120,0,-720),Vector3.new(-900,0,-720),
 Vector3.new(-650,0,-640),Vector3.new(-420,0,-430),
 Vector3.new(-180,0,-330),Vector3.new(100,0,-350),
 Vector3.new(360,0,-250),Vector3.new(560,0,-40),
 Vector3.new(650,0,230),Vector3.new(590,0,480),
 Vector3.new(390,0,690),Vector3.new(100,0,790),
 Vector3.new(-200,0,760),Vector3.new(-440,0,600),
 Vector3.new(-570,0,350),Vector3.new(-600,0,100)
},14)

-- Strassen mit breiten Gehwegen und Bordsteinen.
local roads=folder("Strassen_und_Kreuzungen")
local function road(points,width,name)
 local m=model(name,roads); local l1=offset(points,-width/2-0.7); local r1=offset(points,width/2+0.7)
 local l2=offset(points,-width/2-5.0); local r2=offset(points,width/2+5.0)
 for i=1,#points-1 do
  segment(m,"Asphalt",width,0.3,points[i],points[i+1],0.03,Enum.Material.Asphalt,C.asphalt,true)
  segment(m,"Bordstein",1,0.3,l1[i],l1[i+1],0.16,Enum.Material.Concrete,C.curb,true)
  segment(m,"Bordstein",1,0.3,r1[i],r1[i+1],0.16,Enum.Material.Concrete,C.curb,true)
  segment(m,"Gehweg",8,0.22,l2[i],l2[i+1],0.12,Enum.Material.Concrete,C.sidewalk,true)
  segment(m,"Gehweg",8,0.22,r2[i],r2[i+1],0.12,Enum.Material.Concrete,C.sidewalk,true)
 end
 return m
end
road(route,58,"Boulevard_mit_Tramtrasse")
local roadPaths={
 {Vector3.new(-1120,0,-180),Vector3.new(-850,0,-100),Vector3.new(-570,0,40),Vector3.new(-300,0,150),Vector3.new(0,0,180),Vector3.new(330,0,280),Vector3.new(650,0,470),Vector3.new(950,0,650)},
 {Vector3.new(-900,0,-1050),Vector3.new(-600,0,-980),Vector3.new(-280,0,-900),Vector3.new(50,0,-850),Vector3.new(380,0,-730),Vector3.new(700,0,-530),Vector3.new(1000,0,-260)},
 {Vector3.new(-1150,0,900),Vector3.new(-850,0,950),Vector3.new(-550,0,930),Vector3.new(-250,0,970),Vector3.new(80,0,1050),Vector3.new(420,0,1120),Vector3.new(800,0,1150)},
 {Vector3.new(850,0,-1050),Vector3.new(980,0,-900),Vector3.new(1100,0,-650),Vector3.new(1160,0,-350),Vector3.new(1130,0,-80)}
}
for i,nodes in ipairs(roadPaths) do road(smooth(nodes,10),i==3 and 24 or 26,"Quartiersstrasse_"..i) end

-- Vier Schienen mit deutlich mehr Abstand: Gleismitten 18 Studs auseinander.
local trackFolder=model("Doppelgleis_mit_4_Schienen")
local centers={-9,9}
local total=length(route)
for laneIndex,centre in ipairs(centers) do
 local lane=model(laneIndex==1 and "Gleis_Stadtauswaerts" or "Gleis_Stadteinwaerts",trackFolder)
 local lanePath=offset(route,centre)
 for i=1,#lanePath-1 do
  segment(lane,"Gleiswanne",6.2,0.38,lanePath[i],lanePath[i+1],0.32,Enum.Material.Concrete,C.trackbed,true)
 end
 for d=0,total,9 do
  local p,t,n=atDistance(route,d); p=p+n*centre
  local cf=CFrame.lookAt(Vector3.new(p.X,0.57,p.Z),Vector3.new(p.X,0.57,p.Z)+t,Vector3.yAxis)
  part(lane,"Betonschwelle",Vector3.new(5.7,0.22,1.35),cf,Enum.Material.Concrete,C.sleeper,true)
 end
 for _,gauge in ipairs({-1.5,1.5}) do
  local rp=offset(route,centre+gauge)
  for i=1,#rp-1 do
   segment(lane,"Schienensteg",0.38,0.48,rp[i],rp[i+1],0.83,Enum.Material.Metal,C.dark,false)
   segment(lane,"Schienenkopf",0.62,0.18,rp[i],rp[i+1],1.12,Enum.Material.Metal,C.rail,false)
  end
 end
end

-- Oberleitung mit Masten ausserhalb der beiden Gleise, Quertragwerken und Fahrdraht.
local overhead=model("Oberleitung_komplett")
for i=5,#route-4,6 do
 local p,t,n=basis(route,i); local pos=route[i]
 local left=pos-n*20; local right=pos+n*20
 for _,q in ipairs({left,right}) do
  block(overhead,"Mastfuss",Vector3.new(2,0.65,2),Vector3.new(q.X,0.33,q.Z),Enum.Material.Concrete,C.concrete,true)
  block(overhead,"Stahlmast",Vector3.new(0.75,17.5,0.75),Vector3.new(q.X,9.1,q.Z),Enum.Material.Metal,C.steel,true)
  block(overhead,"Mastkappe",Vector3.new(1.3,0.5,1.3),Vector3.new(q.X,17.9,q.Z),Enum.Material.Metal,C.dark,false)
 end
 segment(overhead,"Quertragwerk",0.45,0.45,left,right,16.8,Enum.Material.Metal,C.steel,false)
 for _,centre in ipairs(centers) do
  local wp=pos+n*centre
  block(overhead,"Isolator",Vector3.new(0.7,0.65,0.7),Vector3.new(wp.X,16.35,wp.Z),Enum.Material.SmoothPlastic,C.cream,false)
 end
end
for _,centre in ipairs(centers) do
 local wp=offset(route,centre)
 for i=1,#wp-1 do
  segment(overhead,"Kupferfahrdraht",0.18,0.18,wp[i],wp[i+1],15.15,Enum.Material.Metal,C.wire,false)
  segment(overhead,"Tragseil",0.12,0.12,wp[i],wp[i+1],16.7,Enum.Material.Metal,C.rail,false)
 end
 for i=3,#wp-3,4 do
  block(overhead,"Drahtanhaenger",Vector3.new(0.1,1.5,0.1),Vector3.new(wp[i].X,15.95,wp[i].Z),Enum.Material.Metal,C.wire,false)
 end
end

-- Drei grosse Haltestellen mit Bahnsteigen, Dächern, Sitzbänken und Licht.
local stations=model("Haltestellen")
local function station(name,distance)
 local p,t,n=atDistance(route,distance)
 local s=model(name,stations)
 for _,side in ipairs({-1,1}) do
  local centre=side*19
  local pos=p+n*centre
  local cf=CFrame.lookAt(Vector3.new(pos.X,0.45,pos.Z),Vector3.new(pos.X,0.45,pos.Z)+t,Vector3.yAxis)
  part(s,"Bahnsteig",Vector3.new(76,0.8,7.5),cf,Enum.Material.Concrete,C.sidewalk,true)
  for _,endOffset in ipairs({-34,34}) do
   local e=pos+t*endOffset+n*(side*1.5)
   block(s,"Bahnsteigkante",Vector3.new(1,0.22,7.8),Vector3.new(e.X,0.98,e.Z),Enum.Material.SmoothPlastic,color(229,190,76),false)
  end
  -- Dach auf vier schlanken Stuetzen
  for _,along in ipairs({-24,24}) do
   for _,across in ipairs({-2.3,2.3}) do
    local q=pos+t*along+n*(side*across)
    block(s,"Dachstuetze",Vector3.new(0.32,4.2,0.32),Vector3.new(q.X,3.0,q.Z),Enum.Material.Metal,C.steel,true)
   end
  end
  local roofPos=pos+n*(side*0.0)
  local roofCf=CFrame.lookAt(Vector3.new(roofPos.X,5.25,roofPos.Z),Vector3.new(roofPos.X,5.25,roofPos.Z)+t,Vector3.yAxis)
  part(s,"Haltestellendach",Vector3.new(56,0.45,6.2),roofCf,Enum.Material.Metal,C.steel,true)
  -- Glaswindschutz
  for _,along in ipairs({-19,19}) do
   local q=pos+t*along+n*(side*1.8)
   local glassCf=CFrame.lookAt(Vector3.new(q.X,2.2,q.Z),Vector3.new(q.X,2.2,q.Z)+t,Vector3.yAxis)
   part(s,"Glaswindschutz",Vector3.new(0.18,2.6,3.8),glassCf,Enum.Material.Glass,C.glass,false,0.18)
  end
  local benchPos=pos+t*8+n*(side*1.5)
  block(s,"Sitzbank",Vector3.new(9,0.45,1.2),Vector3.new(benchPos.X,1.35,benchPos.Z),Enum.Material.Wood,C.wood,true)
  for _,dx in ipairs({-3.5,3.5}) do
   block(s,"Bankfuss",Vector3.new(0.35,1.2,0.35),Vector3.new(benchPos.X+dx,0.8,benchPos.Z),Enum.Material.Metal,C.steel,true)
  end
  local bin=pos+t*(-27)+n*(side*2.2)
  block(s,"Abfallbehaelter",Vector3.new(1.1,1.7,1.1),Vector3.new(bin.X,1.3,bin.Z),Enum.Material.Metal,C.steel,true)
  local pole=pos+t*(-31)+n*(side*2.5)
  block(s,"Haltestellenmast",Vector3.new(0.35,5,0.35),Vector3.new(pole.X,3,pole.Z),Enum.Material.Metal,C.steel,true)
  block(s,"Haltestellenanzeige",Vector3.new(0.5,2.0,2.5),Vector3.new(pole.X,5.9,pole.Z),Enum.Material.SmoothPlastic,color(36,47,53),false)
 end
end
station("Haltestelle_Parkallee",total*0.23)
station("Haltestelle_Altstadt",total*0.49)
station("Haltestelle_Hafenforum",total*0.76)

-- Gebaeude: individuell gestaltete Fassaden, Fenster, Geschaeftsfronten, Daecher.
local buildings=model("Stadtgebaeude_komplett_neu")
local rng=Random.new(191126)
local facades={color(218,202,174),color(190,190,179),color(185,132,105),color(208,216,211),color(224,216,195),color(164,181,181),color(204,184,162)}
local roofs={color(63,67,70),color(93,74,63),color(109,88,72),color(75,84,87)}
local function house(name,x,z,w,d,floors,rot,kind)
 local m=model(name,buildings); local cf=CFrame.new(x,0,z)*CFrame.Angles(0,math.rad(rot),0)
 local h=floors*8.5; local facade=facades[rng:NextInteger(1,#facades)]
 local shop=kind=="shop"; local apartment=kind=="apartment"
 part(m,"Fassade",Vector3.new(w,h,d),cf*CFrame.new(0,h/2,0),Enum.Material.SmoothPlastic,facade,true)
 part(m,"Sockel",Vector3.new(w+0.8,1,d+0.8),cf*CFrame.new(0,0.55,0),Enum.Material.Concrete,C.concrete,true)
 part(m,"Dach",Vector3.new(w+2,1.1,d+2),cf*CFrame.new(0,h+0.5,0),Enum.Material.Slate,roofs[rng:NextInteger(1,#roofs)],true)
 -- Fenster mit Rahmen und Fensterbank
 local rows=floors
 local count=math.max(2,math.floor(w/10))
 for fy=1,rows do
  for wx=1,count do
   local xx=-w/2+wx*w/(count+1); local yy=2.5+(fy-1)*8.5
   local ww=shop and 6.2 or 3.6; local wh=shop and 5.2 or 3.7
   part(m,"Fensterglas",Vector3.new(ww,wh,0.24),cf*CFrame.new(xx,yy,-d/2-0.13),Enum.Material.Glass,C.glass,false,0.1)
   part(m,"Fensterbank",Vector3.new(ww+0.5,0.22,0.45),cf*CFrame.new(xx,yy-wh/2-0.1,-d/2-0.18),Enum.Material.Concrete,C.white,false)
   part(m,"Fenstersturz",Vector3.new(ww+0.35,0.18,0.35),cf*CFrame.new(xx,yy+wh/2+0.1,-d/2-0.18),Enum.Material.Concrete,C.white,false)
  end
 end
 -- Eingang und Vordach
 part(m,"Eingangstuer",Vector3.new(3.6,6.4,0.35),cf*CFrame.new(0,3.2,-d/2-0.2),Enum.Material.Wood,C.wood,false)
 part(m,"Vordach",Vector3.new(7,0.45,3),cf*CFrame.new(0,6.8,-d/2-1.3),Enum.Material.Metal,C.steel,true)
 if apartment then
  for fy=1,floors-1 do
   local yy=4.2+(fy-1)*8.5
   part(m,"Balkonplatte",Vector3.new(6,0.3,1.8),cf*CFrame.new(-w*0.22,yy,-d/2-0.9),Enum.Material.Concrete,C.concrete,true)
   part(m,"Balkongelaender",Vector3.new(6,1,0.16),cf*CFrame.new(-w*0.22,yy+0.65,-d/2-1.7),Enum.Material.Metal,C.white,false)
  end
 end
 if shop then
  part(m,"Schaufenster",Vector3.new(w*0.68,4.4,0.3),cf*CFrame.new(0,3.5,-d/2-0.22),Enum.Material.Glass,C.glass,false,0.08)
  part(m,"Markise",Vector3.new(w*0.78,0.4,2.8),cf*CFrame.new(0,6.1,-d/2-1.3),Enum.Material.Fabric,color(170,91,73),false)
  part(m,"Ladenschild_ohne_Text",Vector3.new(w*0.72,1.5,0.35),cf*CFrame.new(0,7.7,-d/2-0.3),Enum.Material.SmoothPlastic,color(49,91,108),false)
 end
 if rng:NextNumber()>0.45 then
  block(m,"Schornstein",Vector3.new(2.2,3.5,2.2),Vector3.new(x+w*0.27,h+2,z+d*0.2),Enum.Material.Brick,color(139,88,70),true)
 end
 return m
end

-- Locker verteilte Stadtquartiere mit Luecken fuer Innenhoefe und Gruen.
local lots={
 {-1120,420,52,42,2,8,"house"},{-980,455,56,44,3,-8,"apartment"},{-830,420,58,45,3,12,"apartment"},
 {-1120,610,60,46,3,-10,"apartment"},{-960,640,48,40,2,9,"house"},{-800,620,54,44,3,-7,"apartment"},
 {-610,920,56,44,3,8,"apartment"},{-455,950,48,40,2,-9,"house"},{-300,930,58,46,3,11,"apartment"},
 {-120,970,50,42,2,-8,"house"},{60,960,62,48,4,10,"apartment"},{230,920,50,42,2,-11,"house"},
 {760,730,58,46,3,10,"apartment"},{920,760,50,42,2,-8,"house"},{1080,720,60,46,3,12,"apartment"},
 {760,920,52,42,2,-9,"house"},{930,950,58,45,3,8,"apartment"},{1090,930,48,40,2,-10,"house"},
 {-1100,-250,56,44,3,9,"apartment"},{-950,-280,48,40,2,-8,"house"},{-800,-250,60,46,3,12,"apartment"},
 {-1120,-440,50,42,2,-9,"house"},{-960,-470,58,45,3,10,"apartment"},{-800,-450,50,42,2,-12,"house"},
 {-620,-930,58,45,3,9,"apartment"},{-460,-960,50,42,2,-8,"house"},{-300,-930,62,48,4,11,"apartment"},
 {-120,-960,50,42,2,-10,"house"},{80,-940,58,45,3,8,"apartment"},{250,-900,50,42,2,-9,"house"},
 {800,-900,60,48,3,10,"apartment"},{970,-930,52,42,2,-8,"house"},{1130,-900,58,46,3,12,"apartment"},
 {810,-710,50,42,2,-9,"house"},{970,-700,60,46,3,8,"apartment"},{1130,-700,50,42,2,-10,"house"},
 {-1130,80,64,48,3,8,"shop"},{-970,100,62,46,3,-9,"shop"},{-800,70,58,44,3,10,"shop"},
 {820,250,62,48,3,-8,"shop"},{990,260,66,50,3,9,"shop"},{1150,230,58,44,2,-10,"shop"}
}
for i,v in ipairs(lots) do house("Haus_"..string.format("%02d",i),v[1],v[2],v[3],v[4],v[5],v[6],v[7]) end

-- Markante oeffentliche Gebaeude mit echter Fassadengliederung.
local function publicBuilding(name,x,z,w,d,h,facade)
 local m=model(name,buildings)
 block(m,"Baukörper",Vector3.new(w,h,d),Vector3.new(x,h/2,z),Enum.Material.Concrete,facade,true)
 block(m,"Dachkante",Vector3.new(w+4,1.6,d+4),Vector3.new(x,h+0.8,z),Enum.Material.Metal,C.steel,true)
 for i=-2,2 do
  block(m,"Glasfassade",Vector3.new(w/6, h*0.68,0.35),Vector3.new(x+i*w/6,h*0.48,z-d/2-0.22),Enum.Material.Glass,C.glass,false,0.12)
 end
 for i=-1,1 do
  block(m,"Eingangspfeiler",Vector3.new(1.2,h*0.75,1.2),Vector3.new(x+i*8,h*0.42,z-d/2-1),Enum.Material.Concrete,C.white,true)
 end
end
publicBuilding("Rathaus", -480,250,110,72,34,color(202,196,178))
publicBuilding("Stadtbibliothek", 420,900,104,66,27,color(186,199,195))
publicBuilding("Einkaufszentrum", 1110,470,132,82,30,color(187,195,191))
publicBuilding("Feuerwache", -1090,820,92,64,24,color(195,190,178))
publicBuilding("Schule", -430,-700,120,78,25,color(214,204,184))
publicBuilding("Hafenhalle", 980,-400,118,74,22,color(174,187,186))

-- Baeume, Beete, Laternen, Fahrradstaender und Stadtmobiliar.
local trees=folder("Strassenbaeume_und_Gruen")
local function tree(x,z,scale)
 local m=model("Stadtbaum",trees)
 block(m,"Stamm",Vector3.new(1.3*scale,6*scale,1.3*scale),Vector3.new(x,3*scale,z),Enum.Material.Wood,color(111,79,55),true)
 ball(m,"Krone_unten",Vector3.new(7*scale,7*scale,7*scale),Vector3.new(x,7*scale,z),Enum.Material.Grass,C.green)
 ball(m,"Krone_oben",Vector3.new(5.5*scale,6*scale,5.5*scale),Vector3.new(x+1,10*scale,z),Enum.Material.Grass,color(83,139,78))
end
for _,p in ipairs({
 {-1180,350},{-1050,350},{-900,350},{-1160,550},{-1010,570},{-850,560},
 {-650,850},{-500,850},{-340,850},{-160,850},{40,850},{220,820},
 {720,650},{870,650},{1030,650},{1180,650},{760,850},{1100,850},
 {-1160,-180},{-1000,-180},{-840,-180},{-1120,-600},{-950,-600},{-780,-600},
 {-600,-850},{-430,-850},{-260,-850},{-70,-850},{130,-830},{300,-820},
 {820,-1050},{1000,-1050},{1160,-1050},{850,-600},{1030,-600}
}) do tree(p[1],p[2],1) end

local function streetLamp(x,z)
 local m=model("Strassenlaterne",trees)
 block(m,"Mast",Vector3.new(0.38,9,0.38),Vector3.new(x,4.5,z),Enum.Material.Metal,C.steel,true)
 block(m,"Ausleger",Vector3.new(2.4,0.25,0.25),Vector3.new(x+1,8.7,z),Enum.Material.Metal,C.steel,false)
 local l=block(m,"Leuchte",Vector3.new(1.2,0.35,0.65),Vector3.new(x+2,8.5,z),Enum.Material.SmoothPlastic,C.white,false)
 local light=Instance.new("PointLight"); light.Brightness=0.45; light.Range=17; light.Color=color(255,231,185); light.Parent=l
end
for _,p in ipairs({{-1100,280},{-900,280},{-650,280},{-300,280},{100,260},{480,380},{700,600},{950,600},{-1080,-100},{-800,-100},{-500,-780},{-180,-780},{250,-720},{800,-600},{1100,-600}}) do streetLamp(p[1],p[2]) end

-- Kleine Plaetze und Querungen, ohne Texttafeln oder schwebende Beschriftungen.
local squares=model("Stadtplaetze_und_Details")
block(squares,"Altstadtplatz",Vector3.new(150,0.28,110),Vector3.new(-480,130,0),Enum.Material.Cobblestone,color(155,153,143),false)
block(squares,"Platzbeet_1",Vector3.new(18,1.1,12),Vector3.new(-535,0.7,35),Enum.Material.Grass,C.green,true)
block(squares,"Platzbeet_2",Vector3.new(18,1.1,12),Vector3.new(-425,0.7,35),Enum.Material.Grass,C.green,true)
for _,x in ipairs({-550,-520,-450,-420}) do tree(x,70,0.8) end
for _,z in ipairs({-540,-520,-500,-480}) do
 block(squares,"Fahrradstaender",Vector3.new(0.25,1.3,4),Vector3.new(-450,0.7,z),Enum.Material.Metal,C.steel,false)
end

-- Betriebshof mit zwei Einfahrtsgleisen und Hallengebaeude am westlichen Kartenrand.
local depot=model("Betriebshof")
block(depot,"Hofplatte",Vector3.new(250,0.35,190),Vector3.new(-1190,0.12,-920),Enum.Material.Concrete,C.sidewalk,true)
local hall=model("Wagenhalle",depot)
block(hall,"Rueckwand",Vector3.new(110,18,2),Vector3.new(-1270,9,-1030),Enum.Material.Concrete,color(181,190,188),true)
block(hall,"Seitenwand_A",Vector3.new(2,18,100),Vector3.new(-1325,9,-980),Enum.Material.Concrete,color(181,190,188),true)
block(hall,"Seitenwand_B",Vector3.new(2,18,100),Vector3.new(-1215,9,-980),Enum.Material.Concrete,color(181,190,188),true)
block(hall,"Dach",Vector3.new(116,1.5,108),Vector3.new(-1270,18.5,-980),Enum.Material.Metal,C.steel,true)
for _,z in ipairs({-1004,-980,-956}) do
 block(hall,"Torrahmen",Vector3.new(1.2,14,1.2),Vector3.new(-1213,7,z),Enum.Material.Metal,C.steel,true)
end
for _,x in ipairs({-1300,-1270,-1240}) do
 block(hall,"Hallenlicht",Vector3.new(3,0.3,3),Vector3.new(x,17.5,-980),Enum.Material.Neon,color(255,239,196),false)
end

-- Spawn ausserhalb der Gleise.
local spawn=Instance.new("SpawnLocation"); spawn.Name="SpielerSpawn_Betriebshof"
spawn.Size=Vector3.new(8,1,8); spawn.CFrame=CFrame.new(-1150,1,-1080)
spawn.Anchored=true; spawn.Neutral=true; spawn.Duration=0
spawn.Material=Enum.Material.Concrete; spawn.Color=color(83,145,116); spawn.Parent=depot

print("[LINDENHAFEN V12] Neue Stadtkarte wurde aufgebaut.")
print("[LINDENHAFEN V12] Gleismittenabstand 18 Studs; vier Schienen mit deutlich breiterem Zwischenraum.")
print("[LINDENHAFEN V12] Drei grosse Haltestellen, Oberleitung, Strassen, Parks und neu gestaltete Gebaeude.")
print("[LINDENHAFEN V12] Keine schwebenden Bauplatz-/Haltestellen-Beschriftungen.")
print("[LINDENHAFEN V12] Alle Stadtobjekte liegen einzeln editierbar unter Workspace > Lindenhafen_Stadt.")
