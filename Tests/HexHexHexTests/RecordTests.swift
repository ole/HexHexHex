import HexHexHex
import XCTest

final class RecordTests: XCTestCase {
  func testDataDescription() {
    let record = Record.data(0xabcd, [0x12, 0xef, 0xc7])
    XCTAssertEqual(String(describing: record), "00 data – address: ABCD, data: 12 EF C7")
  }

  func testEndOfFileDescription() {
    let record = Record.endOfFile
    XCTAssertEqual(String(describing: record), "01 end of file")
  }

  func testExtendedSegmentAddressDescription() {
    let record = Record.extendedSegmentAddress(0xabcd)
    XCTAssertEqual(String(describing: record), "02 extended segment address – ABCD")
  }

  func testStartSegmentAddressDescription() {
    let record = Record.startSegmentAddress(codeSegment: 0xabcd, instructionPointer: 0xcd12)
    XCTAssertEqual(String(describing: record), "03 start segment address – CS: ABCD, IP: CD12")
  }

  func testExtendedLinearAddressDescription() {
    let record = Record.extendedLinearAddress(upperBits: 0xabcd)
    XCTAssertEqual(String(describing: record), "04 extended linear address – ABCD")
  }

  func testStartLinearAddressDescription() {
    let record = Record.startLinearAddress(0xab3400ff)
    XCTAssertEqual(String(describing: record), "05 start linear address – AB3400FF")
  }
}
