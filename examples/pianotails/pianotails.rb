require 'arduino_firmata'
require 'adb-sdklib'

@arduino = ArduinoFirmata.connect(nil, nonblock_io: true, eventmachine: false)

adb = AdbSdkLib::Adb.new
@device = adb.devices.first
screen = @device.screenshot

def tap(x,y, width, height)
  command = "sendevent /dev/input/event2 "
  parameters = [
                #EV_ABS ABS_MT_PRESSURE
                "3 58 51",
                #EV_ABS ABS_MT_TOUCH_MAJOR
                "3 48 51",
                #EV_ABS ABS_MT_WIDTH_MAJOR
                "3 50 6",
                #EV_ABS ABS_MT_POSITION_X
                "3 53 "+x.to_s,
                #EV_ABS ABS_MT_POSITION_Y
                "3 54 "+y.to_s,
                #EV_SYN SYN_MT_REPORT
                "0 2 0",
                #EV_SYN REPORT
                "0 0 0",
                #EV_SYN SYN_MT_REPORT
                "0 2 0",
                #EV_SYN REPORT
                "0 0 0",
             ]
  parameters.each do |param|
    @device.shell(command+param)
  end
end

tails = [
         {x: 60 , y: 600 },
         {x: 200 , y: 600 },
         {x: 350 , y: 600 },
         {x: 480 , y: 600 }
        ]

50.times do
  4.times do |tail|
    value = @arduino.analog_read(tail)
    sleep 0.005
    if(value < 250)
      puts tail
      tap(tails[tail][:x], tails[tail][:y], screen.width, screen.height)
    end
  end
  sleep 0.2
end
