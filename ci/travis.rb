#!/usr/bin/env ruby

class Runner
  def initialize(tasks)
    @tasks = tasks
    @results = {}
  end

  def run!
    header "FuzzBert CI started."
    puts "Ruby version:"
    system "ruby -v"
    @tasks.each do |t|
      cmd = "bundle exec rake #{t.to_s} --trace"
      @results[t] = system(cmd)
    end
  end

  def evaluate
    failed = @results.select { |k,v| v == false }
    puts
    if failed.empty?
      echo_success "The build was successful."
      echo_success "All tasks have completed successfully."
      exit(true)
    else
      echo_failure "The build has failed."
      echo_failure "Failed tasks: #{failed.keys.join(', ')}"
      exit(false)
    end
  end

  private

  def header(msg)
    puts "\n\e[1;34m#{msg}\e[m\n"
  end

  def echo_failure(msg)
    puts "\n\e[1;31m#{msg}\e[m\n"
  end

  def echo_success(msg)
    puts "\n\e[1;32m#{msg}\e[m\n"
  end
end

r = Runner.new [:spec]
r.run!
r.evaluate
