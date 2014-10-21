require 'adb-sdklib'
require 'c2048'

adb = AdbSdkLib::Adb.new
device = adb.devices.first

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
    "-4280160" => {
      value: 0
    },
    "-1121062" => {
      value: 2
    },
    "-1187640" => {
      value: 4
    },
    "-872071" => {
      value: 8
    },
    "-682653" => {
      value: 16
    },
    "-623521" => {
      value: 32
    },
    "-631237" => {
      value: 64
    },
    "-1192078" => {
      value: 128
    }
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

last_value = 0

screen = device.screenshot

lols = [-20,0,20]
a = 0
1.times do 
  values = []
  screen = device.screenshot
  points.each do |point|
    a += 1
    cl = 0
    v = nil
    3.times do |i|
      cl = screen.pixel(point[:x]+lols[i],point[:y]+i)
      puts cl
      vl = color_to_value(cl)
      if(vl)
        v = vl
      end
    end
    if(v)
      print v[:value].to_s+" "
      values.push(v[:value])
    else
      print cl.to_s+" "
    end
    if a == 4
      a = 0
      print "\n"
    end
  end
  puts C2048::AI.best_move(values)
  sleep 3
end
