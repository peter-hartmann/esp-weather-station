node.startup({command="@_reset2.lua"})
print('Double reset detectiion active for the next 2 sec')
gpio.mode(4, gpio.OUTPUT) gpio.write(4,1) tmr.create():alarm(30, tmr.ALARM_AUTO, function() gpio.write(4,0) tmr.delay(1) gpio.write(4,1) end)
tmr.create():alarm(2000, tmr.ALARM_SINGLE, function() node.startup({command="@init.lua"}) node.restart() end)
