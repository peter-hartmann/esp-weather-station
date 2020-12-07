-- modules: bme280,bme280_math,file,gpio,i2c,net,node,rtctime,tmr,uart,wifi
gpio.mode(5, gpio.INPUT, gpio.PULLUP)
isDeepSleepMode = gpio.read(5) == 1
deepSleepSec = 60

dofile('config.lua')

print('isDeepSleepMode =', isDeepSleepMode)
print('deepSleepSec =', deepSleepSec)
print('InfluxDB =', InfluxDB)
print('Location =', Location)

tmr.softwd(deepSleepSec)    -- restart if stall

function poll()
  local h,t,b = bme280.humi(),bme280.temp(),bme280.baro()
  local params="baro,mac="..wifi.ap.getmac()..",location="..Location.." value="..(b/10)..
    "\ntemp,mac="..wifi.ap.getmac()..",location="..Location.." value="..(t/100)..
    (h and
      "\nhumi,mac="..wifi.ap.getmac()..",location="..Location.." value="..(h/1000)..
      "\ndewp,mac="..wifi.ap.getmac()..",location="..Location.." value="..(bme280.dewpoint(h,t)/100)
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
