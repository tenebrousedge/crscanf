# scanf

This is a Crystal wrapper around the C function `scanf`, specifically `sscanf`. It reads numeric and string data types from other strings. Usefully for Crystal users, it returns scanned data as a tuple with specific types, rather than an array of union types.

## Installation

This project will likely be released as a Crystal shard shortly.

## Usage

This provides a global `scanf` macro, which takes a format string as an input, and returns a lambda. The lambda takes a string input, and the return type is dependent on the format string.
Some examples:
```crystal
a = scanf("%3s %d").call("abc 123")
puts a #=> {"abc", 123}
puts typeof(a) #=> Tuple(String, Int32)

lam = scanf("%f -- %c")
b = lam.call("1234 -- q2")
puts b #=> {1234.0, "q"}
puts typeof(b) #=> Tuple(Float32, String)
```
The format string specification is documented in a number of places, [here](http://www.cplusplus.com/reference/cstdio/scanf/) being one example.

Some specifiers were not implemented. The `p` specifier does not work, and it probably does not make sense to try to make it work. The `j`, `z`, and `t` length specifiers are not implemented, and they should not be necessary. The `L` length specifier is not implemented, because Crystal doesn't have `Float128`. The `c` specifier is treated exactly the same as `s`.

Various versions of the C `scanf` function may be used to read directly from IO objects. This is deliberately not implemented.

### Warning

`scanf` is a dangerous tool. It can easily result in [undefined behavior](https://en.wiktionary.org/wiki/nasal_demon). Test your format strings carefully.

## Development

This shard requires no special libraries, aside from the Crystal compiler. Bugs should be reported via the GitHub issues list.

## Contributing

1. Fork it (<https://github.com/your-github-user/scanf/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Kai Leahy](https://github.com/tenebrousedge) - creator and maintainer
