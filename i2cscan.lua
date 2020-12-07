-- nur zum Testen:  dofile('i2cscan.lua')

-- http://www.esp8266.com/viewtopic.php?f=19&t=771
-- Scan for I2C devices

id=0
sda=6
scl=7


-- initialize i2c, set pin1 as sda, set pin0 as scl

print("PIN 8 = HIGH") gpio.mode(8, gpio.OPENDRAIN) gpio.write(8, gpio.HIGH) tmr.delay(1000000) print("PIN 8 = LOW") gpio.write(8, gpio.LOW) tmr.delay(1000000)
print("i2c.setup")
i2c.setup(id,sda,scl,i2c.SLOW)

for i=0,127 do
  print("pinging device at "..string.format("%02x", i))
  i2c.start(id)
  resCode = i2c.address(id, i, i2c.TRANSMITTER)
  i2c.stop(id)
  if resCode == true then print("We have a device on address 0x" .. string.format("%02x", i) .. " (" .. i ..")") end
end
