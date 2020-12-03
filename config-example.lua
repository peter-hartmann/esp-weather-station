-- rename this file to config.lua
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid="wifi-name",pwd="wifi-password"})
wifi.sta.connect()
InfluxDB = 'http://server:8086/write?db=weather'
Location = 'location'
