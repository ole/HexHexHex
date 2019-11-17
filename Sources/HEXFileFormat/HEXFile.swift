public struct HEXFile {
  public var records: [Record]

  public init(text: String) throws {
    let parser = HEXParser(text: text)
    self.records = try parser.parse()
  }

  public init<C: Collection>(bytes: C) throws where C.Element == UInt8 {
    let text = String(decoding: bytes, as: UTF8.self)
    try self.init(text: text)
  }
}
