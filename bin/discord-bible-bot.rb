require 'biblegen'
require 'discordrb'

token = ENV["DISCORD_API_TOKEN"] || raise("Missing 'DISCORD_API_TOKEN' environment variable!")
$bible = BibleGen::Bible.from_hash(JSON.load_file("assets/bible.json", symbolize_names: true))
bot = Discordrb::Bot.new(token: token, intents: [:server_messages])

def books()
  $bible.books.map(&:name).join("\n")
end

def citation(book_name, chapter_num, versicle_start, versicle_end=nil)
  raise "Invalid parameters" if
    not book_name or
    chapter_num < 1 or
    versicle_start < 1 or
    (versicle_end and versicle_end < 1 || versicle_end < versicle_start)

  # Find exact book match
  book_name.downcase! # All the searches use lowercase
  book = $bible.books.find{|x| x.name.downcase == book_name}

  # Find partial book match
  if not book
    book = $bible.books.find{ |x|
      cur_name = x.name.downcase
      cur_name.start_with?(book_name) ||
        cur_name.gsub(/\s/, "").start_with?(book_name)
    }
  end

  raise "Book not found: #{book_name}" if not book

  chapter = book.chapters[chapter_num - 1]
  raise "Invalid chapter" if not chapter

  versicle_keys = chapter.versicles.keys
  raise "Invalid versicle start" if versicle_start >= versicle_keys.length
  if not versicle_end
    versicle_end = versicle_start
  else
    versicle_end = [versicle_end, versicle_keys.length - 1].min
  end
    
  versicle_keys = versicle_keys[(versicle_start - 1)..(versicle_end - 1)]
  versicles = versicle_keys.map{|x| "#{x}: “#{chapter.versicles[x]}”"}
  citation = """**#{chapter.title}:#{versicle_start}#{versicle_end != versicle_start ? "-#{versicle_end}" : ""}**
#{versicles.join("\n")}
  """
end

def random_citation()
  book = $bible.books.sample
  chapter_index = Random.rand(0...book.chapters.length)
  chapter = book.chapters[chapter_index]
  versicles = chapter.versicles
  versicle_count = Random.rand(0..2) # versicle notation is [inclusive, inclusive]
  versicle_start = Random.rand(0...versicles.keys.length)
  versicle_end = versicle_start + versicle_count

  citation(book.name, chapter_index + 1, versicle_start, versicle_end)
end

def command_wrapper(&block)
  proc \
    do |event, *args, **kwargs|
      block.call(event, *args, **kwargs)
    rescue => e
      puts "ERROR: #{e}"
      event.respond(content: "Something bad happened :(", ephemeral: true)
    end
end

bot.register_application_command(:books, 'Get a list of the books in the Bible')
bot.application_command(:books, &command_wrapper do |event|
  event.respond(content: books(), ephemeral: true)
end)

bot.register_application_command(:citation, 'Get a specific citation from the Bible') do |cmd|
  cmd.string('book', 'The book to get the citation from', required: true)
  cmd.integer('chapter', 'The chapter from the book', required: true)
  cmd.integer('versicle_start', 'The first versicle of the citation', required: true)
  cmd.integer('versicle_end', 'The last versicle of the citation', required: false)
end
bot.application_command(:citation, &command_wrapper do |event|
  book = event.options['book']
  chapter = event.options['chapter']
  versicle_start = event.options['versicle_start']
  versicle_end = event.options['versicle_end']
  event.respond(content: citation(book, chapter, versicle_start, versicle_end))
end)

bot.register_application_command(:random_citation, 'Get a random citation from the Bible')
bot.application_command(:random_citation, &command_wrapper do |event|
  citation = random_citation()
  event.respond(content: "#{citation}")
end)

bot.run
