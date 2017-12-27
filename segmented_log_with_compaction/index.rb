require 'set'
class Segment
  def initialize(filename: 'database', max_segment_size: 100)
    @segment_size = 0
    @max_segment_size = max_segment_size
    @filename = filename
    @hash_index = {}
  end

  def space?(size)
    @max_segment_size - @segment_size > size
  end

  def key?(key)
    @hash_index.key?(key)
  end

  def keys
    @hash_index.keys
  end

  def destroy!
    File.delete(@filename)
  end

  def set(key, value)
    File.open(@filename, 'a') do |file|
      file.puts(value)
      size = value.length + 1

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
    @base_filename = base_filename
    @compactions = 0
    @segment_hashes = [create_new_segment(0)]
  end

  def current_segment
    @segment_hashes[-1]
  end

  def db_set(key, value, segment = current_segment)
    unless segment.space?(value.size)
      segment = create_new_segment(@segment_hashes.size)
      @segment_hashes << segment
    end

    segment.set(key, value)
  end

  def db_get(key, segments = @segment_hashes)
    segments.reverse.each do |segment|
      return segment.get(key) if segment.key?(key)
    end
    nil
  end

  def compact!
    keys = @segment_hashes.reduce(Set.new) do |memo, segment|
      memo.merge segment.keys
    end

    old_segments = @segment_hashes
    @compactions += 1
    @segment_hashes = [create_new_segment(0)]

    keys.each do |key|
      value = db_get(key, old_segments)
      db_set(key, value)
    end

    old_segments.each(&:destroy!)
  end

  private

  def create_new_segment(file_number)
    Segment.new(filename: "#{@base_filename}-#{file_number}-#{@compactions}")
  end
end
