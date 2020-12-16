-- modules: adc,bme280,bme280_math,enduser_setup,file,gpio,http,i2c,net,node,rtctime,tmr,uart,wifi
gpio.mode(5, gpio.INPUT, gpio.PULLUP)
isDeepSleepMode = gpio.read(5) == 1
gpio.mode(2, gpio.INPUT, gpio.PULLUP)
if gpio.read(2) == 0 then file.remove('eus_params.lua') file.remove('params.lua') end

dofile('config.lua')
if not file.exists('params.lua') then dofile('init2.lua') return end
dofile('params.lua')

print('InfluxDB', '=', InfluxDB)
print('isDeepSleepMode', '=', isDeepSleepMode)
print('WIFI device_name', '=', device_name)
print('deepSleepSec', '=', deepSleepSec)

tmr.softwd(deepSleepSec)

function poll()
  local h,t,b = bme280.humi(),bme280.temp(),bme280.baro()
  local params="volt,mac="..wifi.ap.getmac()..",location="..device_name.." value="..adc.read(0)..
    "\nbaro,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(b/10)..
    "\ntemp,mac="..wifi.ap.getmac()..",location="..device_name.." value="..(t/100)..
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

gpio.mode(8, gpio.OUTPUT) gpio.write(8, gpio.LOW)
i2c.setup(0, 6, 7, i2c.SLOW)
bme280.setup()

if wifi.sta.status() == wifi.STA_GOTIP then
  poll();
else
  wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, poll)
end
