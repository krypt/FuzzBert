require 'stringio'

class FuzzBert::Template
  include FuzzBert::Generation

  def initialize(template)
    @template = Parser.new(template).parse
    @callbacks = {}
  end

  def set(name, &blk)
    @callbacks[name] = blk
  end

  def to_data
    "".tap do |buf|
      @template.each { |t| buf << t.to_data(@callbacks) }
    end
  end

  private

    class Parser
      
      def initialize(template)
        @io = StringIO.new(template)
        @template = []
      end

      def parse
        @state = determine_state 
        while token = parse_token
          @template << token
        end
        @template
      end

      def parse_token
        case @state
        when :TEXT
          parse_text
        when :IDENTIFIER
          parse_identifier
        else
          nil
        end
      end

      def determine_state
        begin
          @buf = @io.readchar

          case @buf
          when '$'
            c = @io.readchar
            if c == "{"
              @buf = ""
              :IDENTIFIER
            else
              @buf << c
              :TEXT
            end
          when '\\'
            @buf = ""
            :TEXT
          else
            :TEXT
          end
        rescue EOFError
          :EOF
        end
      end

      def parse_identifier
        name = ""
        begin
          until (c = @io.readchar) == '}'
            name << c
          end

          if name.empty?
            raise RuntimeError.new("No identifier name given")
          end

          @state = determine_state
          Identifier.new(name)
        rescue EOFError
          raise RuntimeError.new("Unclosed identifier")
        end
      end

      def parse_text
        text = @buf
        begin
          loop do
            until (c = @io.readchar) == '$'
              if c == '\\'
                text << parse_escape
              else
                text << c
              end
            end

            d = @io.readchar
            if d == "{"
              @state = :IDENTIFIER
              return Text.new(text)
            else
              text << c
              text << d
            end
          end
        rescue EOFError
          @state = :EOF
          Text.new(text)
        end
      end

      def parse_escape
        begin
          @io.readchar
        rescue EOFError
          '\\'
        end
      end

    end

    class Text

      def initialize(text)
        @text = text
      end

      def to_data(callbacks)
        @text
      end

    end

    class Identifier

      def initialize(name)
        @name = name.to_sym
      end

      def to_data(callbacks)
        cb = callbacks[@name]
        raise RuntimeError.new "No callback set for :#{@name}" unless cb
        cb.call
      end

    end

end

