module DiscordBible
  class Bot
    def initialize(token, bible_json_path, cache_path, commands=DiscordBible::Commands.all_commands, periodic_tasks=DiscordBible::Tasks.all_tasks, time_check_interval_secs: 3600)
      @time_check_interval_secs = time_check_interval_secs
      puts "Loading Bible..."
      @bible = BibleGen::Bible.from_hash(JSON.load_file(bible_json_path, symbolize_names: true))
      puts "Loading cache..."
      @cache = Cache.new(cache_path)

      # Set up bot
      @bot = Discordrb::Bot.new(token: token, intents: [:server_messages])

      # Create context
      @ordered_chapters = @bible.books.map do |book|
        book.chapters.map.with_index do |chapter, index|
          Utils.citation(@bible, book.name, index + 1, 1, chapter.versicles.length - 1, decorate: false)
        end
      end.flatten
      @ordered_chapters = @ordered_chapters.map do |s|
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
      @context = Context.new(@bot, @bible, @cache, @ordered_chapters)

      # Register commands
      commands.each { |command|
        # if not @cache.is_initialized
        puts "Registering command '/#{command.name}'..."
        @bot.register_application_command(command.name, command.description) do |cmd|
          command.setup(cmd, @context)
        end
        # end

        @bot.application_command(command.name) do |event|
          command.execute(event, @context)
        rescue => e
          puts "[ERROR] Failed to execute command '#{command.name}': #{e}"
          event.respond(content: "Something bad happened :(", ephemeral: true)
        end
      }

      # Periodic tasks
      puts "Setting up perioding tasks thread..."
      @periodic_task_thread = Thread.new do
        loop do
          periodic_tasks.each { |periodic_task|
            begin
              now = Time.now
              last_time_check = @cache.last_time_check
              if last_time_check and (now - last_time_check) < periodic_task.interval_secs
                next
              end

              puts "Executing task: #{periodic_task.name}"
              periodic_task.execute(@context)
            rescue => e
              puts "[ERROR] Time event check failed for task '#{periodic_task.name}': #{e}"
            end
          }
          puts "Finished periodic task check"
          @cache.set_last_time_check(Time.now)
          sleep @time_check_interval_secs
        end
      end

      puts "Discord Bible Bot initialized successfully"
    end

    def run
      puts "Discord Bible Bot running..."
      @bot.run
    end

    def stop
      puts "Discord Bible Bot stopped"
      @cache.save
      @periodic_task_thread.exit
      @bot.stop
    end
  end
end
