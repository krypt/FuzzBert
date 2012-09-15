
module FuzzBert::Handler
  class FileOutput
    def handle(id, data, pid, status)
      prefix = status.termsig ? "crash" : "bug"
      filename = "#{prefix}#{pid}"
      File.open(filename, "wb") { |f| f.print(data) }
      puts "#{id} failed. Data was saved as #{filename}."
    end
  end

  class Console
    def handle(id, data, pid, status)
      puts "#{id} failed. Data: #{data.inspect}"
    end
  end
end


