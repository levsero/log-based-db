def db_set(filename, value)
  File.open(filename, 'a') do |file|
    file.puts(value)
    offset = file.pos - (value.length + 1)
  end
end

def db_get(filename, value)
  File.open(filename, 'r') do |file|
    file.readlines().select { |line| line.start_with?(value) }[-1].sub(value, '').strip
  end
end
