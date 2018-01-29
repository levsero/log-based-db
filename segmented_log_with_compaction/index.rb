require 'set'
class Segment
  def initialize(filename:, max_segment_size: 150)
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
    puts @filename
    File.open(@filename, 'a') do |file|
      file.puts("#{key}:#{value}")
      size = value.length + 1

      @hash_index[key] = file.pos - (value.length + key.length + 2)
    end
    @segment_size += (value.length + key.length + 2)
  end

  def get(key)
    File.open(@filename, 'r') do |file|
      file.seek(@hash_index[key])
      file.readline.strip.split(':', 2)[1]
    end
  end
end

class CompactedSegmentionLog
  def initialize(base_filename: 'compact-database')
    @base_filename = base_filename
    @compactions = 0
    @segments = [create_new_segment(0)]
  end

  def segments
    @segments
  end

  def current_segment
    @segments[-1]
  end

  def db_set(key, value, segment = current_segment)
    unless segment.space?(value.size)
      segment = create_new_segment(@segments.size)
      @segments << segment
    end

    segment.set(key, value)
  end

  def db_get(key, segments = @segments)
    segments.reverse.each do |segment|
      return segment.get(key) if segment.key?(key)
    end
    nil
  end

  def compact!
    keys = @segments.reduce(Set.new) do |memo, segment|
      memo.merge segment.keys
    end

    old_segments = @segments
    @compactions += 1
    @segments = [create_new_segment(0)]

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
