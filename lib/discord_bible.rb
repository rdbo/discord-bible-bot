module DiscordBible
  class Context
    attr_reader :bot, :bible

    def initialize(bot, bible)
      @bot = bot
      @bible = bible
    end
  end

  class Command
    def name
      raise NotImplementedError, "#{self.class} must implement #description"
    end

    def description
      raise NotImplementedError, "#{self.class} must implement #description"
    end

    def execute(event, context)
      raise NotImplementedError, "#{self.class} must implement #execute"
    end
  end

  class TimeEvent
    def execute(context)
      raise NotImplementedError, "#{self.class} must implement #execute"
    end

    def interval_secs
      3600 * 24 # Daily
    end
  end

  class Bot
    def initialize(token, bible_json_path, time_check_interval_secs: 3600)
      @time_check_interval_secs = time_check_interval_secs
      @last_time_check = nil
      @bible = BibleGen::Bible.from_hash(JSON.load_file(bible_json_path, symbolize_names: true))

      # Set up bot
      @bot = Discordrb::Bot.new(token: token, intents: [:server_messages])

      # Create context
      @context = Context.new(@bot, @bible)

      # Register commands
      commands = [Command.new]
      for command in commands
        bot.register_application_command(command.name, command.description)
        bot.application_command(command.name) do |event|
          cmd.execute(event, @context)
        rescue => e
          puts "[ERROR] Failed to execute command '#{command.name}': #{e}"
          event.respond(content: "Something bad happened :(", ephemeral: true)
        end
      end

      # Time events
      time_events = [TimeEvent.new]
      @time_event_thread = Thread.new do
        loop do
          begin
            for time_event in time_events
              now = Time.now
              if @last_time_check and (now - @last_time_check) < time_event.interval_secs
                continue
              end

              time_event.execute(@context)
            end
            @last_time_check = Time.now
          rescue => e
            puts "[ERROR] Time event check failed: #{e}"
          end
          sleep @time_check_interval_secs
        end
      end

    end

    def run
      @bot.run
    end

    def stop
      @bot.stop
    end
  end
end
