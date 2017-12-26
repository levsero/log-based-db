class IndexedLog
  def initialize
    @index = {}
  end

  def db_set(filename, key, value)
    File.open(filename, 'a') do |file|
      file.puts(value)
      @index[key] = file.pos - (value.length + 1)
    end
  end

  def db_get(filename, key)
    File.open(filename, 'r') do |file|
      file.seek(@index[key])
      p file.readline.strip
    end
  end
end
