require 'fuzzbert'
require 'rake'
require 'rake/tasklib'

class FuzzBert::RakeTask < ::Rake::TaskLib
  include ::Rake::DSL if defined?(::Rake::DSL)

  # Name of task.
  #
  # default:
  #   :fuzz
  attr_accessor :name

  # Glob pattern to match files.
  #
  # default:
  #   'fuzz/**/fuzz_*.rb'
  attr_accessor :pattern

  # Command line options to pass to ruby.
  #
  # default:
  #   nil
  attr_accessor :ruby_opts

  # Path to FuzzBert
  #
  # default:
  #   'fuzzbert'
  attr_accessor :fuzzbert_path

  # Command line options to pass to fuzzbert.
  #
  # default:
  #   nil
  attr_accessor :fuzzbert_opts

  def initialize(*args)
    #configure the rake task
    setup_ivars(args)
    yield self if block_given?

    desc "Run FuzzBert random test suite" unless ::Rake.application.last_comment

    task name do
      run_task
    end
  end

  def setup_ivars(*args)
    @name = args.shift || :fuzz
    @ruby_opts, @fuzzbert_opts = nil, nil
    @fuzzbert_path = 'fuzzbert'
    @pattern = 'fuzz/**/fuzz_*.rb'
  end

  def run_task
    begin
      system(command)
    rescue
      #silent, user could have interrupted a permanent session
    end
  end

  private

    def command
      cmd_parts = []
      cmd_parts << RUBY
      cmd_parts << ruby_opts
      cmd_parts << "-S" << fuzzbert_path
      cmd_parts << fuzzbert_opts
      cmd_parts << pattern
      cmd_parts.flatten.reject(&blank).join(" ")
    end

    def blank
      lambda {|s| s.nil? || s == ""}
    end

end

