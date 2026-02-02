require 'time'

module DiscordBible
  class Config
    attr_reader :is_initialized, :last_time_check, :daily_message_channels, :chapter_counter

    def initialize(file_path)
      @file_path = file_path
      if File.exist?(file_path)
        content = JSON.load_file(file_path)
        @chapter_counter = content["chapter_counter"] || 0
        @last_time_check = content["last_time_check"].then{|s| Time.parse(s)} || nil
        @daily_message_channels = content["daily_message_channels"] || raise("Bad configuration file!")
        @is_initialized = true
      else
        @is_initialized = false
        @chapter_counter = 0
        @last_time_check = nil
        @daily_message_channels = {}
      end
    end

    def to_hash
      {
        chapter_counter: @chapter_counter,
        last_time_check: @last_time_check,
        daily_message_channels: @daily_message_channels
      }
    end

    def set_last_time_check(time_check)
      @last_time_check = time_check
      self.save
    end

    def set_daily_message_channels_entry(server, channel)
      @daily_message_channels[server.to_s] = channel
      self.save
    end

    def set_chapter_counter(count)
      @chapter_counter = count
      self.save
    end

    def to_json(*args, **kwargs)
      self.to_hash.to_json(*args, **kwargs)
    end

    def save
      File.write(@file_path, self.to_json)
    end
  end
end
