require 'arduino_firmata'

@arduino = ArduinoFirmata.connect(nil, nonblock_io: true, eventmachine: false)
@arduino.pin_mode(2, ArduinoFirmata::OUTPUT)

def tap(pin)
  @arduino.digital_write(pin, ArduinoFirmata::HIGH)
  sleep 0.025
  @arduino.digital_write(pin, ArduinoFirmata::LOW)
  sleep 0.025
end

99999.times do
  tap 2
end
