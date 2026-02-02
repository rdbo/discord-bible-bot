module DiscordBible
  module Tasks
    class DailyBibleChapterTask < DiscordBible::PeriodicTask
      attr_reader :name

      def initialize
        @name = "Daily Bible Chapter"
      end

      def execute(context)
        channels = context.cache.daily_message_channels.values
        ordered_chapters = context.ordered_chapters
        daily_chapter_index = context.cache.chapter_counter

        for channel in channels
          puts "CHANNEL: #{channel}"
          continue unless channel
          puts "[DailyBibleChapterTask] Sending daily chapter to channel: #{channel}"
          for block in ordered_chapters[daily_chapter_index]
            context.bot.send_message(channel, block)
            sleep 1
          end
          sleep 10
        end

        context.cache.set_chapter_counter(daily_chapter_index + 1)
      end
    end

    def self.all_tasks
      [DailyBibleChapterTask.new]
    end
  end
end
