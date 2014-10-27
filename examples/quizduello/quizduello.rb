require 'adb-sdklib'
require 'tesseract'
require 'chunky_png'
require 'sqlite3'
require 'similar_text'
require 'arduino_firmata'

@arduino = ArduinoFirmata.connect(nil, nonblock_io: true, eventmachine: false)
@arduino.pin_mode(2, ArduinoFirmata::OUTPUT)
@arduino.pin_mode(3, ArduinoFirmata::OUTPUT)
@arduino.pin_mode(4, ArduinoFirmata::OUTPUT)
@arduino.pin_mode(5, ArduinoFirmata::OUTPUT)
@arduino.pin_mode(6, ArduinoFirmata::OUTPUT)
@arduino.digital_write(2, ArduinoFirmata::HIGH)
@arduino.digital_write(3, ArduinoFirmata::HIGH)
@arduino.digital_write(4, ArduinoFirmata::HIGH)
@arduino.digital_write(5, ArduinoFirmata::HIGH)
@arduino.digital_write(6, ArduinoFirmata::HIGH)
def atap(pin)
  @arduino.digital_write(pin, ArduinoFirmata::LOW)
  sleep 0.70
  @arduino.digital_write(pin, ArduinoFirmata::HIGH)
  sleep 0.08
end

db = SQLite3::Database.open("~/quizkampen")
questions = []

db.execute("SELECT * FROM qk_questions") do |row|
  questions.push({
                   question: row[1],
                   answer: row[2]
                 })
end

adb = AdbSdkLib::Adb.new
device = adb.devices.first
tesseract = Tesseract::Engine.new('/usr/share/tessdata/', :ita) { |e|
  e.blacklist = '|'
}

3.times do
  atap(6)
  sleep 2
  puts "screening"
  screen = device.screenshot
  
  question = ChunkyPNG::Image.new(450, 200, ChunkyPNG::Color::TRANSPARENT)
  450.times do |x|
    200.times do |y|
      c = screen.pixel(x+60,y+185)
      question[x,y] = ChunkyPNG::Color.rgba(c.red, c.green, c.blue, c.alpha)
    end
  end
  
  question = tesseract.text_for(question).strip
  answers = []
  puts question
  questions.each do |q|
    if question.similar(q[:question]) >= 85
      answers.push q[:answer]
    end
  end
  
  read_answers = []
  answer_positions =
    [
     { x: 15, y: 490},
     { x: 15, y: 695},
     { x: 285, y: 490},
     { x: 285, y: 695}
  ]
  answer_container = ChunkyPNG::Image.new(245, 160, ChunkyPNG::Color::TRANSPARENT)
  answer_positions.each do |p|
    245.times do |x|
      160.times do |y|
        c = screen.pixel(x+p[:x],y+p[:y])
        answer_container[x,y] = ChunkyPNG::Color.rgba(c.red, c.green, c.blue, c.alpha)
      end
    end
    read_answers.push tesseract.text_for(answer_container).strip
  end
  
  answers.each do |a|
    read_answers.each_index do |i|
      puts read_answers[i]
      puts i
      if a.similar(read_answers[i]) >= 87
        puts "============="
        puts read_answers[i]
        puts i
        atap(i+2)
      end
    end
  end
end
