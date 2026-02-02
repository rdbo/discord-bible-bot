module DiscordBible
  class Context
    attr_reader :bot, :bible, :cache, :ordered_chapters

    def initialize(bot, bible, cache, ordered_chapters)
      @bot = bot
      @bible = bible
      @cache = cache
      @ordered_chapters = ordered_chapters
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
    def name
      raise NotImplementedError, "#{self.class} must implement #name"
    end

    def execute(context)
      raise NotImplementedError, "#{self.class} must implement #execute"
    end

    def interval_secs
      3600 * 24 # Daily
    end
  end
end
