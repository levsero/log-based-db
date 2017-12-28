require 'set'
require_relative 'segment'
require_relative 'in_memory_segment'

class SSTable
  def initialize(base_filename: 'compact-database')
    @base_filename = base_filename
    @compactions = 0
    @written_segments = []
    @in_memory_segment = InMemorySegment.new
  end

  def db_set(key, value)
    unless @in_memory_segment.space?(value.size + key.size + 2)
      segment = create_new_segment(@written_segments.size)
      segment.persist(@in_memory_segment.sorted_values)
      @written_segments << segment
      @in_memory_segment = InMemorySegment.new
    end

    @in_memory_segment.set(key, value)
  end

  def db_get(key, segments = combined_segments)
    segments.reverse.each do |segment|
      return segment.get(key) if segment.key?(key)
    end
    nil
  end

  def compact!
    old_segments = @written_segments
    @compactions += 1
    @written_segments = [create_new_segment(0)]

    files = old_segments.map(&:io_stream)
    next_key_values = files.map{ |file| file.readline.strip.split(':', 2) }

    while next_key_values.any?
      p keys = next_key_values.map{|key, val| key }
      p next_key = keys.compact.sort[0]
      key, value = '', ''

      keys.each_index do |i|
        if keys[i] == next_key
          key, value = next_key_values[i]
          begin
            p "next: #{i} next_key: #{next_key} keys[i]: #{keys[i]}"
            next_key_values[i] = files[i].readline.strip.split(':', 2)
          rescue EOFError
            next_key_values[i] = nil
          end
        end
      end

      compaction_set(key, value)
    end

    files.each(&:close)
    old_segments.each(&:destroy!)
  end

  private

  def compaction_set(key, value)
    p "compaction_set #{key} #{value}"
    segment = @written_segments[-1]
    unless segment.space?(value.size + key.size + 2)
      segment = create_new_segment(@written_segments.size)
      @written_segments << segment
    end

    segment.set(key, value)
  end

  def combined_segments
    @written_segments.concat([@in_memory_segment])
  end

  def create_new_segment(file_number)
    Segment.new(filename: "#{@base_filename}-#{file_number}-#{@compactions}")
  end

  def current_segment
    @segments[-1]
  end
end
