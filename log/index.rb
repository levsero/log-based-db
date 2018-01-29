def db_set(key, value, filename = 'basic-log-database')
  File.open(filename, 'a') do |file|
    file.puts("#{key}:#{value}")
    offset = file.pos - (value.length + key.length + 1)
  end
end

def db_get(key, filename = 'basic-log-database')
  File.open(filename, 'r') do |file|
    file.readlines().select { |line| line.start_with?(key) }[-1].strip.split(':', 2)[1]
  end
end
