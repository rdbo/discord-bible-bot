module DiscordBible
  module Utils
    def self.citation(bible, book_name, chapter_num, versicle_start, versicle_end=nil, decorate: true)
      cit = bible.citation(book_name, chapter_num, versicle_start, versicle_end)

      versicles = if decorate
                    cit.versicles.map{|k, v| "#{k}: “#{v}”"}
                  else
                    cit.versicles.map{|_k, v| v}
                  end

      "**#{cit.header}**\n#{versicles.join("\n")}"
    end
  end
end
