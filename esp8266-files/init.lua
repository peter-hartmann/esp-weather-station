-- modules: adc,bme280,bme280_math,enduser_setup,file,gpio,http,i2c,net,node,rtctime,tmr,uart,wifi
local _,r = node.bootreason()
if r == 6 then node.startup({command="@_reset1.lua"}) node.restart() end
dofile('params.lua')

dofile('config-example.lua')
dofile('config.lua')

gpio.mode(pin_sleepYes, gpio.INPUT, gpio.PULLUP)
isDeepSleepMode = gpio.read(pin_sleepYes) == 1

print('InfluxDB', '=', InfluxDB)
print('isDeepSleepMode', '=', isDeepSleepMode)
print('WIFI device_name', '=', device_name)
print('deepSleepSec', '=', deepSleepSec)
print('VoltFactor', '=', VoltFactor)

tmr.softwd(deepSleepSec)

function poll()
  local h,t,b = bme280.humi(),bme280.temp(),bme280.baro()
  local params="volt,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(VoltFactor*adc.read(0))..
    "\nbaro,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(b/10)..
    "\ntemp,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(TempOffset+t/100)..
    (h and
      "\nhumi,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(h/1000)..
      "\ndewp,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(bme280.dewpoint(h,t)/100)
      or "")
  print('params:\n', params)
  http.post(InfluxDB, nil, params, function(code, data)
    if isDeepSleepMode then
      print('done sending, deep sleep') rtctime.dsleep(deepSleepSec*1000000, 4)
    else
      print('done sending, staying awake')
    end
  end)
end

gpio.mode(pin_gnd, gpio.OUTPUT) gpio.write(pin_gnd, gpio.LOW)
i2c.setup(0, pin_sda, pin_scl, i2c.SLOW)
bme280.setup()

wifi.setmode(wifi.STATION)
if wifi.sta.status() == wifi.STA_GOTIP then
  poll();
else
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, poll)
end
