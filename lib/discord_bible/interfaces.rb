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
      raise NotImplementedError, "#{self.class} must implement #name"
    end

    def description
      raise NotImplementedError, "#{self.class} must implement #description"
    end

    def setup(cmd)
      raise NotImplementedError, "#{self.class} must implement #setup"
    end

    def execute(event, context)
      raise NotImplementedError, "#{self.class} must implement #execute"
    end
  end

  class PeriodicTask
    def execute(context)
      raise NotImplementedError, "#{self.class} must implement #execute"
    end

    def interval_secs
      3600 * 24 # Daily
    end
  end
end
