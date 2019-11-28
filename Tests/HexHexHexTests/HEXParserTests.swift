import XCTest
import HexHexHex

final class HEXParserTests: XCTestCase {
  func testParseEndOfFileRecord() throws {
    let parser = HEXParser(text: ":00000001FF\n")
    let records = try parser.parse()
    XCTAssertEqual(records, [.endOfFile])
  }

  func testParseDataRecord() throws {
    let parser = HEXParser(text: ":0201FE00FF0FF1\n")
    let records = try parser.parse()
    XCTAssertEqual(records, [.data(0x01fe, [0xff, 0x0f])])
  }

  func testInvalidChecksumThrows() throws {
    let parser = HEXParser(text: ":00000001FE\n")
    XCTAssertThrowsError(try parser.parse()) { error in
      XCTAssertEqual((error as? HEXParser.Error)?.kind, .invalidChecksum)
    }
  }

  func testParseExtendedLinearAddressRecord() throws {
    let parser = HEXParser(text: ":020000040000FA\n")
    let records = try parser.parse()
    XCTAssertEqual(records, [.extendedLinearAddress(upperBits: 0x0000)])
  }

  func testMultipleRecords() throws {
    let hex = """
      :020000040000FA
      :1000000025001C0C0200080C06006306590AE306D2
      :100010000A0A0E0A3006590A3005110A3006200A6B
      :0C00B000590A000C3000070C2600030069
      :0400BC000008000830
      :021FFE00EF0FE3
      :00000001FF
      """
    let parser = HEXParser(text: hex)
    let records = try parser.parse()
    XCTAssertEqual(records, [
      .extendedLinearAddress(upperBits: 0x0000),
      .data(0x0000, [0x25, 0x00, 0x1C, 0x0C, 0x02, 0x00, 0x08, 0x0C, 0x06, 0x00, 0x63, 0x06, 0x59, 0x0A, 0xE3, 0x06]),
      .data(0x0010, [0x0A, 0x0A, 0x0E, 0x0A, 0x30, 0x06, 0x59, 0x0A, 0x30, 0x05, 0x11, 0x0A, 0x30, 0x06, 0x20, 0x0A]),
      .data(0x00b0, [0x59, 0x0A, 0x00, 0x0C, 0x30, 0x00, 0x07, 0x0C, 0x26, 0x00, 0x03, 0x00]),
      .data(0x00bc, [0x00, 0x08, 0x00, 0x08]),
      .data(0x1ffe, [0xEF, 0x0F]),
      .endOfFile,
    ])
  }
}
