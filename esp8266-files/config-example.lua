-- copy this file to config.lua
pin_gnd=8
pin_scl=7
pin_sda=6
pin_sleepYes=5
SetupName = 'WetterStation-'..node.chipid()
SetupPassword = 'password123'

InfluxDB = 'http://server:8086/write?db=weather'
VoltFactor= 320 / 100 / 1024
TempOffset = 0
