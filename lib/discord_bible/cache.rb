require 'time'

module DiscordBible
  class Cache
    attr_reader :is_initialized, :last_runs, :daily_message_channels, :chapter_counter

    def initialize(file_path)
      @file_path = file_path
      if File.exist?(file_path)
        content = JSON.load_file(file_path)
        @chapter_counter = content["chapter_counter"] || 0
        @last_runs = content["last_runs"]&.map{|k, v| [k, Time.parse(v)]}.to_h || nil
        @daily_message_channels = content["daily_message_channels"] || raise("Bad cache file!")
        @is_initialized = true
      else
        @is_initialized = false
        @chapter_counter = 0
        @last_runs = {}
        @daily_message_channels = {}
      end
    end

    def to_hash
      {
        chapter_counter: @chapter_counter,
        last_runs: @last_runs,
        daily_message_channels: @daily_message_channels
      }
    end

    def set_last_run(task_name, time)
      @last_runs[task_name] = time
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
