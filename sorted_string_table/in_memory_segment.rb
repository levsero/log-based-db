class InMemorySegment
  def initialize(filename: 'database', max_segment_size: 100)
    @segment_size = 0
    @max_segment_size = max_segment_size
    @data = {}
  end

  def space?(size)
    @max_segment_size - @segment_size > size
  end

  def set(key, value)
    @segment_size += (key.size + value.size + 2)
    @data[key] = value
  end

  def get(key)
    @data[key]
  end

  def key?(key)
    @data.key?(key)
  end

  def sorted_values
    @data.sort_by { |k, v| k }
  end
end
