module DiscordBible
  module Commands
    class BooksCommand < DiscordBible::Command
      attr_reader :name, :description

      def initialize
        super
        @name = :books
        @description = 'Get a list of the books in the Bible'
        # The books never change, so no need
        # to compute over and over again
        @books_cache = nil
      end

      def setup(_cmd, context)
        @books_cache = context.bible.books.map(&:name).join("\n")
      end

      def execute(event, _context)
        event.respond(content: @books_cache, ephemeral: true)
      end
    end

    class RandomCitationCommand < DiscordBible::Command
      attr_reader :name, :description

      def initialize
        super
        @name = :random_citation
        @description = 'Get a random citation from the Bible'
      end

      def setup(_cmd, _context) end

      def execute(event, context)
        book = context.bible.books.sample
        chapter_index = Random.rand(0...book.chapters.length)
        chapter = book.chapters[chapter_index]
        versicles = chapter.versicles
        versicle_count = Random.rand(0..2) # versicle notation is [inclusive, inclusive]
        versicle_start = Random.rand(0...versicles.keys.length)
        versicle_end = versicle_start + versicle_count

        message = DiscordBible::Utils.citation(context.bible, book.name, chapter_index + 1, versicle_start, versicle_end)
        event.respond(content: message)
      end
    end

    class CitationCommand < DiscordBible::Command
      attr_reader :name, :description

      def initialize
        super
        @name = :citation
        @description = 'Get a specific citation from the Bible'
      end

      def setup(cmd, _context)
        cmd.string('book', 'The book to get the citation from', required: true)
        cmd.integer('chapter', 'The chapter from the book', required: true)
        cmd.integer('versicle_start', 'The first versicle of the citation', required: true)
        cmd.integer('versicle_end', 'The last versicle of the citation', required: false)
      end

      def execute(event, context)
        book = event.options['book']
        chapter = event.options['chapter']
        versicle_start = event.options['versicle_start']
        versicle_end = event.options['versicle_end']
        event.respond(content: DiscordBible::Utils.citation(context.bible, book, chapter, versicle_start, versicle_end))
      end
    end

    class SetDailyMessageChannelCommand < DiscordBible::Command
      attr_reader :name, :description

      def initialize
        super
        @name = :daily_message_channel
        @description = 'Set/unset the daily message channel'
      end

      def setup(cmd, _context)
        cmd.channel('channel', 'The channel that will receeive daily updates from this bot', required: false)
      end

      def execute(event, context)
        server_id = event.server_id
        channel = event.options['channel']
        context.cache.set_daily_message_channels_entry(server_id, channel)
        if channel
          event.respond(content: "Daily message channel updated successfully for server <#{server_id}>: channel <#{channel}>", ephemeral: true)
        else
          event.respond(content: "Unset daily message channel for server <#{server_id}>", ephemeral: true)
        end
      end
    end

    def self.all_commands
      [BooksCommand.new, RandomCitationCommand.new, CitationCommand.new, SetDailyMessageChannelCommand.new]
    end
  end
end
