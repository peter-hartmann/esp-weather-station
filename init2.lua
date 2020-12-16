-- eus_params.lua exists after connecting the wifi, it contains wifi creds that we better delete
if file.exists('eus_params.lua') then
  p = dofile('eus_params.lua')
  p.aplist=nil
  p.wifi_ssid=nil
  p.wifi_password=nil
  file.open("params.lua", "w+")
  for k, v in pairs(p) do file.writeline(k.."='"..v.."'") end
  file.close()
  file.remove('eus_params.lua')
  node.restart()
  return
end

print('WIFI Setup, look for access point "'..SetupName..'"')
wifi.sta.disconnect()
wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid=SetupName, auth=wifi.WPA2_PSK, pwd=SetupPassword})
enduser_setup.manual(true)
enduser_setup.start()
adc.force_init_mode(adc.INIT_ADC)
