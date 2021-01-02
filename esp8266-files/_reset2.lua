tmr.create():alarm(1000, tmr.ALARM_AUTO, function()
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
    node.startup({command="@init.lua"})
    node.restart()
    return
  end
end)

dofile('config-example.lua')
dofile('config.lua')

print('WIFI Setup, look for access point "'..SetupName..'"')
gpio.mode(4, gpio.OUTPUT) gpio.write(4,1) tmr.create():alarm(1000, tmr.ALARM_AUTO, function() gpio.write(4,0) tmr.delay(100) gpio.write(4,1) end)

wifi.sta.disconnect()
wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid=SetupName, auth=wifi.WPA2_PSK, pwd=SetupPassword})
enduser_setup.manual(true)
enduser_setup.start(SetupName)
adc.force_init_mode(adc.INIT_ADC)
