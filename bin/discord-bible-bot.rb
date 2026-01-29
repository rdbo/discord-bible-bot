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

  book = $bible.books.find{|x| x.name == book_name} || raise("Book not found: #{book_name}")
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
  chapter = book.chapters.sample
  versicles = chapter.versicles
  versicle = versicles.keys.sample
  citation = versicles[versicle]

  "**#{chapter.title}:#{versicle}**\n“#{citation}”"
end

bot.register_application_command(:books, 'Get a list of the books in the Bible')
bot.application_command(:books) do |event|
  event.respond(content: books(), ephemeral: true)
end

bot.register_application_command(:citation, 'Get a specific citation from the Bible') do |cmd|
  cmd.string('book', 'The book to get the citation from', required: true)
  cmd.integer('chapter', 'The chapter from the book', required: true)
  cmd.integer('versicle_start', 'The first versicle of the citation', required: true)
  cmd.integer('versicle_end', 'The last versicle of the citation', required: false)
end
bot.application_command(:citation) do |event|
  book = event.options['book']
  chapter = event.options['chapter']
  versicle_start = event.options['versicle_start']
  versicle_end = event.options['versicle_end']
  event.respond(content: citation(book, chapter, versicle_start, versicle_end))
end

bot.register_application_command(:random_citation, 'Get a random citation from the Bible')
bot.application_command(:random_citation) do |event|
  citation = random_citation()
  event.respond(content: "#{citation}")
end

bot.run
