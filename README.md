# HexHexHex

A parser for the [Intel Hexadecimal Object File Format (.hex)](https://en.wikipedia.org/wiki/Intel_HEX), written in Swift.

## Usage

### Add HexHexHex as a Swift Package Manager dependency

```
dependencies: [
  .package(url: "https://github.com/ole/HexHexHex.git", from: "0.1.0"),
],
```

### Code

Creating a `HEXFile` value from the text of a .hex file:

```swift
import HexHexHex

let hexText = """
  :020000040000FA
  :1000000025001C0C0200080C06006306590AE306D2
  :0C00B000590A000C3000070C2600030069
  :00000001FF
  """
let hexFile = try HEXFile(text: hexText)
```

The `HEXFile` value contains an array of `Record` values that represent the records in the .hex file:

```swift
print(hexFile.records)
```

## Author

Ole Begemann, [oleb.net](https://oleb.net).

## License

MIT. See [LICENSE.txt](LICENSE.txt).
