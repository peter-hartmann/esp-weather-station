InfluxDB = 'http://server:8086/write?db=weather'
SetupName = 'WetterStation-'..node.chipid()
SetupPassword = 'password123'
VoltFactor = 500 / 100 / 1024
TempOffset = 0
