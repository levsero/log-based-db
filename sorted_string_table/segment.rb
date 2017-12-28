class Segment
  def initialize(filename: 'database', max_segment_size: 100)
    @segment_size = 0
    @max_segment_size = max_segment_size
    @filename = filename
    @hash_index = {}
  end

  def io_stream
    File.open(@filename, 'r')
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

  def persist(key_values)
    key_values.each do |key, value|
      set(key, value)
    end
  end

  def set(key, value)
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
