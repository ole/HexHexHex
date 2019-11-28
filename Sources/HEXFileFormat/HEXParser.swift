import Foundation

/// A parser for the Intel Hexadecimal Object File Format (.hex).
///
/// - SeeAlso: https://en.wikipedia.org/wiki/Intel_HEX
public struct HEXParser {
  var text: String

  public init(text: String) {
    self.text = text
  }

  public func parse() throws -> [Record] {
    var consumableText = text[...].utf8
    var records: [Record] = []
    while !consumableText.isEmpty {
      let record = try Self.parseRecord(in: &consumableText)
      records.append(record)
    }
    return records
  }
}

extension HEXParser {
  /// Record format:
  ///
  ///     | Record mark | Length (n)   | Address      | Type         | Data          | Checksum     |
  ///     | ----------- | ------------ | ------------ | ------------ | ------------- | ------------ |
  ///     | ':' (colon) | 2 hex digits | 4 hex digits | 2 hex digits | 2n hex digits | 2 hex digits |
  ///     |             | (1 byte)     | (2 bytes)    | (1 byte)     | (n bytes)     | (1 byte)     |
  ///
  private static func parseRecord(in text: inout Substring.UTF8View) throws -> Record {
    try parseRecordMark(in: &text)
    let byteCountIndex = text.startIndex
    let byteCount = try parseHexDigits(count: 2, in: &text)
    let addressBytes = try parseHexBytes(count: 2, in: &text)
    let recordType = try parseRecordType(in: &text)
    let dataBytes = try parseHexBytes(count: byteCount, in: &text)
    let checksumIndex = text.startIndex
    let checksum = try parseHexDigits(count: 2, in: &text)
    try parseLineBreakOrEndOfFile(in: &text)

    // Verify checksum
    let byteSum: UInt8 = UInt8(byteCount)
      &+ addressBytes.reduce(0, &+)
      &+ UInt8(recordType.rawValue)
      &+ dataBytes.reduce(0, &+)
    guard byteSum &+ UInt8(checksum) == 0 else {
      throw Error(kind: .invalidChecksum, position: checksumIndex)
    }

    switch recordType {
    case .data:
      let address = addressBytes.reduce(0) { acc, byte in acc << 8 + UInt16(byte) }
      return .data(Address16(rawValue: address), dataBytes)
    case .endOfFile:
      return .endOfFile
    case .extendedSegmentAddress:
      guard byteCount == 2 else {
        throw Error(kind: .expectedDifferentByteCount(expected: 2, actual: byteCount), position: byteCountIndex)
      }
      let address = dataBytes.reduce(0) { acc, byte in acc << 8 + UInt16(byte) }
      return .extentedSegmentAddress(Address16(rawValue: address))
    case .startSegmentAddress:
      guard byteCount == 4 else {
        throw Error(kind: .expectedDifferentByteCount(expected: 4, actual: byteCount), position: byteCountIndex)
      }
      let codeSegment = dataBytes.prefix(2).reduce(0) { acc, byte in acc << 8 + UInt16(byte) }
      let instructionPointer = dataBytes.dropFirst(2).reduce(0) { acc, byte in acc << 8 + UInt16(byte) }
      return .startSegmentAddress(codeSegment: Address16(rawValue: codeSegment), instructionPointer: Address16(rawValue: instructionPointer))
    case .extendedLinearAddress:
      guard byteCount == 2 else {
        throw Error(kind: .expectedDifferentByteCount(expected: 2, actual: byteCount), position: byteCountIndex)
      }
      let address = dataBytes.reduce(0) { acc, byte in acc << 8 + UInt16(byte) }
      return .extendedLinearAddress(upperBits: Address16(rawValue: address))
    case .startLinearAddress:
      guard byteCount == 4 else {
        throw Error(kind: .expectedDifferentByteCount(expected: 4, actual: byteCount), position: byteCountIndex)
      }
      let address = dataBytes.reduce(0) { acc, byte in acc << 8 + UInt32(byte) }
      return .startLinearAddress(Address32(rawValue: address))
    }
  }

  /// Parses the magic colon ':' at the start of a record.
  ///
  /// - Throws: Throws an error if the text doesn't start with the magic start code.
  private static func parseRecordMark(in text: inout Substring.UTF8View) throws {
    guard text.first == ASCII.colon else {
      throw Error(kind: .expectedColon, position: text.startIndex)
    }
    text = text.dropFirst()
  }

  private static func parseRecordType(in text: inout Substring.UTF8View) throws -> Record.Kind {
    let sourcePosition = text.startIndex
    let rawValue = try parseHexDigits(count: 2, in: &text)
    guard let recordType = Record.Kind(rawValue: rawValue) else {
      throw Error(kind: .invalidRecordType(rawValue), position: sourcePosition)
    }
    return recordType
  }

  private static func parseLineBreakOrEndOfFile(in text: inout Substring.UTF8View) throws {
    switch text.first {
    case nil:
      // End of file, nothing to do
      break
    case ASCII.lineFeed:
      text = text.dropFirst()
    case ASCII.carriageReturn:
      text = text.dropFirst()
      if text.first == ASCII.lineFeed {
        text = text.dropFirst()
      }
    default:
      throw Error(kind: .expectedLineBreak, position: text.startIndex)
    }
  }

  /// Parses ASCII text as a sequence of hexadecimal bytes.
  ///
  /// - Parameters:
  ///   - count: The number of bytes (2 hex digits per byte) to parse.
  ///   - text: The source text. Parsing starts at the start of the text and consumes the parsed
  ///     characters
  private static func parseHexBytes(count: Int, in text: inout Substring.UTF8View) throws -> [UInt8] {
    var bytes: [UInt8] = []
    for _ in 0 ..< count {
      try bytes.append(UInt8(parseHexDigits(count: 2, in: &text)))
    }
    return bytes
  }

  /// Parses ASCII text as one or more hexadecimal digits and returns them as an integer value.
  ///
  /// - Parameters:
  ///   - count: The number of digits (== the number of ASCII characters) to parse.
  ///   - text: The source text. Parsing starts at the start of the text and consumes the parsed
  ///     characters
  private static func parseHexDigits(count: Int, in text: inout Substring.UTF8View) throws -> Int {
    guard text.count >= count else {
      throw Error(kind: .expectedHexDigits(count: count), position: text.startIndex)
    }
    guard let digits = String(text.prefix(count)),
      let value = Int(digits, radix: 16) else {
        throw Error(kind: .expectedHexDigits(count: count), position: text.startIndex)
    }
    text = text.dropFirst(count)
    return value
  }
}

extension HEXParser {
  public struct SourcePosition: Equatable {
    var position: String.Index
  }
}

extension HEXParser {
  public struct Error: Swift.Error, Equatable {
    public var kind: Kind
    public var sourcePosition: SourcePosition

    init(kind: Kind, position: String.Index) {
      self.kind = kind
      self.sourcePosition = SourcePosition(position: position)
    }
  }
}

extension HEXParser.Error {
  public enum Kind: Equatable, CustomStringConvertible {
    case expectedColon
    case expectedHexDigits(count: Int)
    case invalidRecordType(Int)
    case expectedLineBreak
    case invalidChecksum
    case expectedDifferentByteCount(expected: Int, actual: Int)

    var errorCode: Int {
      switch self {
      case .expectedColon: return 1
      case .expectedHexDigits: return 2
      case .invalidRecordType: return 3
      case .expectedLineBreak: return 4
      case .invalidChecksum: return 5
      case .expectedDifferentByteCount: return 6
      }
    }

    public var description: String {
      switch self {
      case .expectedColon: return "expectedColon"
      case .expectedHexDigits(let count): return "expectedHexDigits: \(count)"
      case .invalidRecordType(_): return "invalidRecordType"
      case .expectedLineBreak: return "expectedLineBreak"
      case .invalidChecksum: return "invalidChecksum"
      case .expectedDifferentByteCount(let expected, let actual): return "expectedDifferentByteCount: expected: \(expected) actual: \(actual)"
      }
    }
  }
}

extension HEXParser.Error: CustomNSError {
  public static var errorDomain: String { "HEXParser.Error" }
  public var errorCode: Int { 1000 }
  public var errorUserInfo: [String : Any] {
    [NSLocalizedDescriptionKey: "HEXParser.Error: \(kind) \(sourcePosition)"]
  }
}

private enum ASCII {
  static let colon = UInt8(ascii: ":")
  static let carriageReturn = UInt8(ascii: "\r")
  static let lineFeed = UInt8(ascii: "\n")
}
