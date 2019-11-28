extension UnsignedInteger {
  /// Formats the number as a string of hexadecimal digits,
  /// with optional padding with "0".
  ///
  /// - Parameter length: The total length the returned string should have.
  ///   If the converted number is shorter than `length`, the string will be
  ///   left-padded with zeros. If the converted number is longer than `length`,
  ///   the full length will be returned. If `length` is `nil`, no padding
  ///   will be applied.
  public func hex(padTo length: Int? = nil, uppercase: Bool = false) -> String {
    let hex = String(self, radix: 16, uppercase: uppercase)
    if let length = length, hex.count < length {
      return String(repeating: "0", count: length - hex.count) + hex
    } else {
      return hex
    }
  }

  /// Formats the number as a string of binary digits,
  /// with optional padding with "0".
  ///
  /// - Parameter length: The total length the returned string should have.
  ///   If the converted number is shorter than `length`, the string will be
  ///   left-padded with zeros. If the converted number is longer than `length`,
  ///   the full length will be returned. If `length` is `nil`, no padding
  ///   will be applied.
  public func binary(padTo length: Int? = nil) -> String {
    let binary = String(self, radix: 2)
    if let length = length, binary.count < length {
      return String(repeating: "0", count: length - binary.count) + binary
    } else {
      return binary
    }
  }
}
