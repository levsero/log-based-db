require 'set'
class Segment
  def initialize(filename: 'database', max_segment_size: 100)
    @segment_size = 0
    @max_segment_size = max_segment_size
    @filename = filename
    @hash_index = {}
  end

  def has_space?(size)
    p "size #{size}"
    p "segment_size: #{@segment_size}, max_segment_size: #{@max_segment_size}"
    p @max_segment_size - @segment_size > size
  end

  def has_key?(key)
    @hash_index.key?(key)
  end

  def keys
    @hash_index.keys
  end

  def set(key, value)
    File.open(@filename, 'a') do |file|
      file.puts(value)
      size = value.length + 1

      # store index
      @hash_index[key] = file.pos - (value.length + 1)
    end
    @segment_size += value.size
  end

  def get(key)
    File.open(@filename, 'r') do |file|
      file.seek(@hash_index[key])
      p file.readline.strip
    end
  end
end

class CompactedSegmentionLog
  def initialize(base_filename: 'compact-database')
    @segment_hashes = create_segments
    @base_filename = base_filename
    @compactions = 0
  end

  def current_segment
    @segment_hashes[-1]
  end

  def db_set(key, value, segment = current_segment)
    segment = create_new_segment unless segment.has_space?(value.size)
    segment.set(key, value)
  end

  def db_get(key, segments = @segment_hashes)
    segments.reverse.each do |segment|
      return segment.get(key) if segment.key?(key)
    end
    nil
  end

  def compact
    keys = @segment_hashes.reduce(Set.new) do |memo, segment|
      memo.merge segment.keys
    end

    old_segments = @segment_hashes
    @compactions += 1
    @segment_hashes = create_segments

    keys.each do |key|
      db_get(key, old_segments)
      db_set(key)
    end

    old_segments.each(&:delete)
  end

  private

  def create_segments
    [create_new_segment]
  end

  def create_new_segment
    @segment_hashes << Segment.new(filename: "#{@base_filename}-#{@segment_hashes.size}-#{@compactions}")
  end
end
