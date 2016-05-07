def assert feature, &function
  function.call.tap do |passing|
    puts "\e[#{passing ? 32 : 31}m#{feature}\e[0m"
  end
end
