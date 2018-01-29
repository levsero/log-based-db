class IndexedLog
  def initialize(filename = 'indexed-log-database')
    @filename = filename
    @index = {}
  end

  def db_set(key, value)
    File.open(@filename, 'a') do |file|
      file.puts(value)
      @index[key] = file.pos - (value.length + 1)
    end
  end

  def db_get(key)
    File.open(@filename, 'r') do |file|
      file.seek(@index[key])
      p file.readline.strip
    end
  end
end
