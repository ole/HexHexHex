/// A 16-bit address.
public struct Address16: RawRepresentable, Hashable, Codable {
  public var rawValue: UInt16

  public init(rawValue: UInt16) {
    self.rawValue = rawValue
  }
}

extension Address16: ExpressibleByIntegerLiteral {
  public init(integerLiteral literal: UInt16) {
    self.rawValue = literal
  }
}

extension Address16: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    "0x\(rawValue.hex(padTo: 2, uppercase: true))"
  }

  public var debugDescription: String {
    "<Address16: \(description)>"
  }
}

/// A 32-bit address.
public struct Address32: RawRepresentable, Hashable, Codable {
  public var rawValue: UInt32

  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
}

extension Address32: ExpressibleByIntegerLiteral {
  public init(integerLiteral literal: UInt32) {
    self.rawValue = literal
  }
}

extension Address32: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    "0x\(rawValue.hex(padTo: 4, uppercase: true))"
  }

  public var debugDescription: String {
    "<Address32: \(description)>"
  }
}
