-- modules: adc,bme280,bme280_math,enduser_setup,file,gpio,http,i2c,net,node,rtctime,tmr,uart,wifi
pin_gnd=8
pin_scl=7
pin_sda=6
pin_sleepYes=5
pin_configOn=2
VoltFactor= 320 / 100 / 1024
TempOffset = 0

dofile('config.lua')
gpio.mode(pin_sleepYes, gpio.INPUT, gpio.PULLUP)
isDeepSleepMode = gpio.read(pin_sleepYes) == 1
gpio.mode(pin_configOn, gpio.INPUT, gpio.PULLUP)
if gpio.read(pin_configOn) == 0 then file.remove('eus_params.lua') file.remove('params.lua') end

if not file.exists('params.lua') then dofile('init2.lua') return end
dofile('params.lua')

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
