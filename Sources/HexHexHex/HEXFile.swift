/// A value representing the contents of an Intel Hexadecimal Object File Format (.hex).
///
/// - SeeAlso: https://en.wikipedia.org/wiki/Intel_HEX
public struct HEXFile {
  /// The records the file contains. Each line in the .hex file corresponds to one record.
  public var records: [Record]

  /// Initializes a `HEXFile` value with the text contents of a .hex file.
  ///
  /// - Parameter text: A string containing the contents of a .hex file.
  ///   Example of a .hex file containing one data record and one end-of-file record:
  ///
  ///       :10010000214601360121470136007EFE09D2190140
  ///       :00000001FF
  ///
  /// - Throws: Throws a `HEXParser.Error` if `text` does not contain a valid .hex file
  ///   or the string cannot be parsed.
  public init(text: String) throws {
    let parser = HEXParser(text: text)
    self.records = try parser.parse()
  }

  /// Initializes a `HEXFile` value with a collection of ASCII bytes.
  ///
  /// - Parameter bytes: A collection of bytes containing the contents of a .hex file.
  ///   The bytes must be an ASCII-encoded string.
  ///
  /// - Throws: Throws a `HEXParser.Error` if `bytes` does not contain a valid .hex file
  ///   or the string cannot be parsed.
  public init<C: Collection>(bytes: C) throws where C.Element == UInt8 {
    let text = String(decoding: bytes, as: UTF8.self)
    try self.init(text: text)
  }
}

extension HEXFile: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    "HEXFile (\(records.count) records)"
  }

  public var debugDescription: String {
    """
    HEXFile (\(records.count) records)
      \(records.map(String.init(describing:)).joined(separator: "\n  "))
    """
  }
}
