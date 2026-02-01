#!/usr/bin/ruby
require_relative '../lib/discord_bible'

token = ENV["DISCORD_API_TOKEN"] || raise("Missing 'DISCORD_API_TOKEN' environment variable!")
bot = DiscordBible::Bot.new(token, 'assets/bible.json')
bot.run

# old code
=begin
bot = Discordrb::Bot.new(token: token, intents: [:server_messages])
channels = { "1234": "876530451039256647" }
last_daily_update = nil
daily_chapter_index = 0

# ----- Update profile picture (run once) -----
# avatar = File.open('assets/bible.png')
# bot.profile.avatar = avatar
# avatar.close
# ---------------------------------------------

def books()
  $bible.books.map(&:name).join("\n")
end

def citation(book_name, chapter_num, versicle_start, versicle_end=nil, decorate=true)
  cit = $bible.citation(book_name, chapter_num, versicle_start, versicle_end)

  versicles = if decorate
                cit.versicles.map{|k, v| "#{k}: “#{v}”"}
              else
                cit.versicles.map{|_k, v| v}
              end

  """**#{cit.header}**
#{versicles.join("\n")}"""
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

def update_daily_message_channel(server_id, channel=nil)
  channels[server_id] = channel
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

bot.register_application_command(:daily_message_channel, 'Set/unset the daily message channel') do |cmd|
  cmd.channel('channel', 'The channel that will receeive daily updates from this bot', required: false)
end
bot.application_command(:daily_message_channel, &command_wrapper do |event|
  update_daily_message_channel(event.server_id, event.options['channel'])
  event.respond(content: "Channel updated successfully!", ephemeral: true)
end)

daily_check_interval = 3600
ordered_chapters = $bible.books.map do |book|
  book.chapters.map.with_index do |chapter, index|
    citation(book.name, index + 1, 1, chapter.versicles.length - 1, false)
  end
end.flatten
# Break into messages of 2000 chars
ordered_chapters = ordered_chapters.map do |s|
  lines = s.split("\n")
  blocks = [""]
  for line in lines
    last_block = blocks.last
    line += "\n"
    if last_block.length + line.length <= 2000
      blocks[-1] = last_block + line
    else
      blocks.append(line)
    end
  end
  blocks
end
puts ordered_chapters[0]
_daily_message_thread = Thread.new do
  loop do
    begin
      if not last_daily_update
        for channel in channels.values
          continue unless channel
          for block in ordered_chapters[daily_chapter_index]
            bot.send_message(channel, block)
            sleep 1
          end
          sleep 10
        end

        daily_chapter_index += 1
      end
    rescue => e
      puts "[ERROR] Daily message check failed: #{e}"
    end
    sleep daily_check_interval
  end
end

bot.run
=end
