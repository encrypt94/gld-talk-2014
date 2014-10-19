require 'adb-sdklib'
require 'tesseract'
require 'chunky_png'
require 'sqlite3'
require 'similar_text'

# env JAVA_HOME=/usr/lib/jvm/java-7-openjdk ruby quizduello.rb
db = SQLite3::Database.open("/home/marco/quizkampen")
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
  read_answers.each do |ra|
    #puts ra
    if a.similar(ra) >= 89
      puts ra
    end
  end
end
