class Segment
  def initialize(filename: 'segmented-database', max_segment_size: 150)
    @segment_size = 0
    @max_segment_size = max_segment_size
    @filename = filename
    @hash_index = {}
  end

  def has_space?(size)
    @max_segment_size - @segment_size > size
  end

  def has_key?(key)
    @hash_index.key?(key)
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

class SegmentedLog
  def initialize(base_filename: 'segmented-database')
    @base_filename = base_filename
    @segments=[Segment.new]
  end

  def segments
    @segments
  end

  def current_segment
    @segments[-1]
  end

  def db_set(key, value)
    if(!current_segment.has_space?(value.size))
      create_new_segment
    end
    current_segment.set(key, value)
  end

  def db_get(key)
    @segments.reverse.each do |segment|
      return segment.get(key) if segment.has_key?(key)
    end
    nil
  end

  private

  def create_new_segment
    @segments << Segment.new(filename: "#{@base_filename}-#{@segments.size}")
  end
end
