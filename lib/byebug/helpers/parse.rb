module Byebug
  module Helpers
    #
    # Utilities to assist command parsing
    #
    module ParseHelper
      #
      # Parses +str+ of command +cmd+ as an integer between +min+ and +max+.
      #
      # If either +min+ or +max+ is nil, that value has no bound.
      #
      def get_int(str, cmd, min = nil, max = nil)
        if str !~ /\A[0-9]+\z/
          err = pr('parse.errors.int.not_number', cmd: cmd, str: str)
          return nil, errmsg(err)
        end

        int = str.to_i
        if min && int < min
          err = pr('parse.errors.int.too_low', cmd: cmd, str: str, min: min)
          return min, errmsg(err)
        elsif max && int > max
          err = pr('parse.errors.int.too_high', cmd: cmd, str: str, max: max)
          return max, errmsg(err)
        end

        int
      end

      #
      # @return true if code is syntactically correct for Ruby, false otherwise
      #
      def syntax_valid?(code)
        return true unless code

        without_stderr do
          begin
            RubyVM::InstructionSequence.compile(code)
            true
          rescue SyntaxError
            false
          end
        end
      end

      #
      # Temporarily disable output to $stderr
      #
      def without_stderr
        stderr = $stderr
        $stderr.reopen(IO::NULL)

        yield
      ensure
        $stderr.reopen(stderr)
      end

      #
      # @return +str+ as an integer or 1 if +str+ is empty.
      #
      def parse_steps(str, cmd)
        return 1 unless str

        steps, err = get_int(str, cmd, 1)
        return nil, err unless steps

        steps
      end
    end
  end
end