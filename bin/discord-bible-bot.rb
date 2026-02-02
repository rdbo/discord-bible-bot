require_relative '../lib/discord_bible'

token = ENV["DISCORD_API_TOKEN"] || raise("Missing 'DISCORD_API_TOKEN' environment variable!")
bot = DiscordBible::Bot.new(token, 'assets/bible.json', 'cache/cache.json')
bot.run
