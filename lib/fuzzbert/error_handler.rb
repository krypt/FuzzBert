
module FuzzBert::Handler

  module ConsoleHelper
    def info(error_data)
      status = error_data[:status]

      crashed = status.termsig

      if crashed
        puts "The data caused a hard crash."
      else
        puts "The data caused an uncaught error."
      end
    end
  end

  class FileOutput
    include FuzzBert::Handler::ConsoleHelper

    def initialize(dir=nil)
      @dir = dir
      if @dir && !@dir.end_with?("/")
        @dir << "/"
      end
    end

    def handle(error_data)
      id = error_data[:id]
      data = error_data[:data]
      status = error_data[:status]
      pid = error_data[:pid]

      crashed = status.termsig
      prefix = crashed ? "crash" : "bug"

      filename = "#{dir_prefix}#{prefix}#{pid}"
      while File.exists?(filename)
        filename << ('a'..'z').to_a.sample
      end
      File.open(filename, "wb") { |f| f.print(data) }

      puts "#{id} failed. Data was saved as #{filename}."
      info(error_data)
    end

    private

      def dir_prefix
        return "./" unless @dir
        @dir
      end
  end

  class Console
    include FuzzBert::Handler::ConsoleHelper

    def initialize
      $stdout.sync = true
    end

    def handle(error_data)
      puts "#{error_data[:id]} failed. Data: #{error_data[:data].inspect}"
      info(error_data)
    end
  end
  
end


