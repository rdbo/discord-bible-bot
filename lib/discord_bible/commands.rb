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

    def self.all_commands
      [BooksCommand.new]
    end
  end
end
