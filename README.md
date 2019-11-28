# HexHexHex

A parser for the [Intel Hexadecimal Object File Format (.hex)](https://en.wikipedia.org/wiki/Intel_HEX), written in Swift.

![](https://github.com/ole/HexHexHex/workflows/macOS/badge.svg) ![](https://github.com/ole/HexHexHex/workflows/Linux/badge.svg)

## Usage

### Add HexHexHex as a Swift Package Manager dependency

```
dependencies: [
  .package(url: "https://github.com/ole/HexHexHex.git", from: "0.1.0"),
],
```

### Code

Creating a [`HEXFile`](Sources/HexHexHex/HEXFile.swift) value from the text of a .hex file:

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

The `HEXFile` value contains an array of [`Record`](Sources/HexHexHex/Record.swift) values that represent the records in the .hex file:

```swift
debugPrint(hexFile)
/*
HEXFile (4 records)
  04 extended linear address – 0000
  00 data – address: 0000, data: 25 00 1C 0C 02 00 08 0C 06 00 63 06 59 0A E3 06
  00 data – address: 00B0, data: 59 0A 00 0C 30 00 07 0C 26 00 03 00
  01 end of file
 */

// Get all data records in the file
let dataRecords = hexFile.records.filter { $0.kind == .data }
print(dataRecords)

// Print out the addresses of all data records in the file
for case .data(let address, _) in hexFile.records {
  print(address)
}
```

## Author

Ole Begemann, [oleb.net](https://oleb.net).

## License

MIT. See [LICENSE.txt](LICENSE.txt).
