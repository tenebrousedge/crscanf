require "./lib_c"
module Scanf
  VERSION = "0.1.0"
end

macro scanf(fmt)
  # format string elements contain the following subelements:
  # %     : start of sequence
  # *     : (optional) if the asterisk is present, the value will not be returned
  # 0-9+  : (optional) width (number of characters captured by this element)
  # hh    : (optional) length (what size of integer to store the result in)
  # i     : specifier (what type of data is being captured by this element)
  #
  #        1  2    3           4                          5
  {% r = /^%(\*?)(\d*)(hh|h|ll|l|j|z|t|L?)(i|d|u|o|x|f|e|g|a|c|s|p|n|%|\[.*\])$/ %}
  # the following line of code is O(n^2), and no I'm not sorry
  # the alternative is very hard to code in macro-land currently
  {% tokens = (0...fmt.size).map { |i| (0...fmt.size)
       .to_a
       .reject { |j| i >= j }.map { |j| fmt[i..j] } }
       .reduce([] of String) { |m, e| m + e }
       .select { |ss| ss =~ r } %}
  {% defaults = {
       /^%\*?\d*[din]$/          => LibC::Int,
       /^%\*?\d*[uox]$/          => LibC::UInt,
       /^%\*?\d*[fega]$/         => LibC::Float,
       /^%\*?\d*l?(c|s|\[\*\])$/ => String, # note: can't actually use String
       /^%\*?\d*hh[din]$/        => LibC::Char,
       /^%\*?\d*hh[uox]$/        => LibC::UChar,
       /^%\*?\d*h[din]$/         => LibC::Short,
       /^%\*?\d*h[uox]$/         => LibC::UShort,
       /^%\*?\d*l[din]$/         => LibC::Long,
       /^%\*?\d*l[uox]$/         => LibC::ULong,
       /^%\*?\d*l[fega]$/        => LibC::Double,
       /^%\*?\d*ll[din]$/        => LibC::LongLong,
       /^%\*?\d*ll[uox]$/        => LibC::ULongLong,
     } %}
  # the following *will* blow up for malformed keys
  {% types = tokens.map { |t| defaults[defaults.keys.find { |k| t =~ k }] } %}
  -> (s : String) {
    {% for idx in (0...types.size) %}
      {% if types[idx] != String %}
        %a{idx} = uninitialized {{types[idx]}}
        # strings have to be a StaticArray
      {% else %}
        {% l = tokens[idx].gsub(/^%\*?/, "").gsub(/\d*l?\K.*/, "") %}
        {% if l.empty? %}
          # scanf will append a trailing \0, so all sizes must be 1 larger
          # than the data that is expected to be read
          %a{idx} = uninitialized StaticArray(LibC::Char, 2)
        {% elsif l[0..0] == "l" %}
          # l means 'wide character', which is implementation-dependent (AFAIK)
          %a{idx} = uninitialized StaticArray(LibC::Char, 3)
        {% else %}
          %a{idx} = uninitialized StaticArray(LibC::Char, {{l.to_i + 1}})
        {% end %}
      {% end %}
    {% end %}
    # first two arguments
    LibC.sscanf(s, {{fmt}},
      # subsequent arguments
      {% for idx in (0...types.size) %}
        {% if types[idx] == String %}
          %a{idx},
        {% else %}
          pointerof(%a{idx}),
        {% end %}
      {% end %}
    )
    {
      {% for idx in (0...types.size) %}
        {% if tokens[idx][1..1] != "*" %}
          {% if types[idx] == String %}
            String.new(%a{idx}.to_unsafe),
          {% else %}
            %a{idx},
          {% end %}
        {% end %}
      {% end %}
    }
  }
end
