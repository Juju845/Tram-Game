local Config = {}

Config.Map = {
    Name = "Mannheim",
    GroundSize = Vector3.new(500, 1, 500),
    RoadLength = 240,
    RoadWidth = 44,
    TrackLength = 220,
    TrackGauge = 2.87, -- Roblox studs; approx. 1.435 m at 2 studs per metre
}

Config.Tram = {
    Name = "RNV M8C",
    MaxSpeed = 55, -- km/h; placeholder for the driving system
}

return Config
