  # TODO: Write documentation for `Scanf`
module Scanf
  VERSION = "0.1.0"
  class Token
    def self.parse(string) # return string or regex?

    end
    delegate match, ==, =~, to: @regex
    def initialize(string : string)
      @regex = parse(string)
    end
  end
  class TokenStream
    include Iterator(Token)

    # TODO: write comments
    LENGTHS = %w{hh h ll l j z t L}

    SPECIFIERS = %w{i d u o x f e g a c s p n %}

    LS_TO_TYPE = Hash{
      "s" => String,
      "d" => Int32,
      "i" => Int32,
      "u" => UInt32,
      "o" => Int32, # octal
      "c" => Char,
      "x" => Int32 # hex
    }
    # format string elements contain the following subelements:
    # %     : start of sequence
    # *     : (optional) if the asterisk is present, the value will not be returned
    # 0-9+  : (optional) width (number of characters captured by this element)
    # hh    : (optional) length (what size of integer to store the result in)
    # i     : specifier (what type of data is being captured by this element)
    #
    #          1  2    3            4            5                5
    ELEMENT = /%(\*?)(\d*)(#{LENGTHS.join('|')}?)(#{SPECIFIERS.join('|')}|\[.*\])/

    def initialize(source)
      # consider the value of avoiding `new`
      @scanner = StringScanner.new(source)
    end

    def next
      @scanner.scan(ELEMENT) || @scanner.scan_until(/.(?=%)/) || stop
    end
  end

  def scanf(format : String)
    scanner = StringScanner.new(self)
    # we maybe need another pass
    TokenStream.new(format).reduce([] of String, Number) do |memo, token|
      memo << scanner.scan(token)
    end
  end
end

class String
  include Scanf
end
