require 'adb-sdklib'
require 'c2048'
require 'arduino_firmata'

adb = AdbSdkLib::Adb.new
device = adb.devices.first

@arduino = ArduinoFirmata.connect(nil, nonblock_io: true, eventmachine: false)

#Configure pins as output and set them to low

4.times do |pin|
  @arduino.pin_mode(pin+2, ArduinoFirmata::OUTPUT)
  @arduino.digital_write(pin+2, ArduinoFirmata::HIGH)
end

def swipe(dir)
  pins = {
    left: [3, 2],
    right: [2, 3],
    up: [5, 4],
    down: [4, 5]
  }
  @arduino.digital_write(pins[dir][0], ArduinoFirmata::LOW)
  sleep 0.50
  @arduino.digital_write(pins[dir][1], ArduinoFirmata::LOW)
  sleep 0.10
  @arduino.digital_write(pins[dir][0], ArduinoFirmata::HIGH)
  sleep 0.25
  @arduino.digital_write(pins[dir][1], ArduinoFirmata::HIGH)
end


points = [
         {x: 120, y: 260},
         {x: 220, y: 260},
         {x: 320, y: 255},
         {x: 420, y: 260},
         {x: 120, y: 360},
         {x: 250, y: 360},
         {x: 320, y: 360},
         {x: 420, y: 360},
         {x: 120, y: 460},
         {x: 220, y: 460},
         {x: 320, y: 460},
         {x: 420, y: 460},         
         {x: 120, y: 560},
         {x: 220, y: 560},
         {x: 320, y: 560},
         {x: 420, y: 560}
]


def color_to_value(color)
  numbers = {
    "-4280160" =>   0,
    "-1121062" =>   2,
    "-1187640" =>   4,
    "-872071"  =>   8,
    "-682653"  =>  16,
    "-623521"  =>  32,
    "-631237"  =>  64,
    "-1192078" => 128
  }
  unless numbers.has_key?(color.to_s)
    numbers.each do |key, value|
      k = key.to_i
      if((color-k) > -10 and (color-k) < 10) 
        return value
      end
    end
  else
    return numbers[color.to_s]
  end
  return nil
end

loop do 
  screen = device.screenshot
  row_counter = 0
  values = []
  points.each do |point|
    row_counter += 1
    value = nil
    [-20,0,20].times do |d|
      color = screen.pixel(point[:x]+d,point[:y]).argb
      v = color_to_value(color)
      if(v)
        value = v
      end
    end
    if(value)
      print value.to_s+" "
      values.push(v)
    else
      print "?"
    end
    if row_counter == 4
      row_counter = 0
      print "\n"
    end
  end
  move = C2048::AI.best_move(values)
  puts m
  swipe(move)
end
