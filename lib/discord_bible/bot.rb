module DiscordBible
  class Bot
    def initialize(token, bible_json_path, commands=DiscordBible::Commands.all_commands, periodic_tasks=[], time_check_interval_secs: 3600)
      @time_check_interval_secs = time_check_interval_secs
      @last_time_check = nil
      @bible = BibleGen::Bible.from_hash(JSON.load_file(bible_json_path, symbolize_names: true))

      # Set up bot
      @bot = Discordrb::Bot.new(token: token, intents: [:server_messages])

      # Create context
      @context = Context.new(@bot, @bible)

      # Register commands
      commands.each { |command|
        puts "Registering command '/#{command.name}'..."
        @bot.register_application_command(command.name, command.description) do |cmd|
          command.setup(cmd, @context)
        end

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
          begin
            periodic_tasks.each { |periodic_task|
              now = Time.now
              if @last_time_check and (now - @last_time_check) < periodic_task.interval_secs
                continue
              end

              periodic_task.execute(@context)
            }
            @last_time_check = Time.now
          rescue => e
            puts "[ERROR] Time event check failed: #{e}"
          end
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
      @periodic_task_thread.exit
      @bot.stop
    end
  end
end
