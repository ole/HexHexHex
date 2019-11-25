public enum Record: Equatable {
  case data(Address16, [UInt8])
  case endOfFile
  case extentedSegmentAddress(Address16)
  case startSegmentAddress(codeSegment: Address16, instructionPointer: Address16)
  case extendedLinearAddress(upperBits: Address16)
  case startLinearAddress(Address32)
 
  public var kind: Record.Kind {
    switch self {
    case .data: return .data
    case .endOfFile: return .endOfFile
    case .extentedSegmentAddress: return .extendedSegmentAddress
    case .startSegmentAddress: return .startSegmentAddress
    case .extendedLinearAddress: return .extendedLinearAddress
    case .startLinearAddress: return .startLinearAddress
    }
  }
}

extension Record {
  /// https://en.wikipedia.org/wiki/Intel_HEX#Record_types
  public enum Kind: Int {
    /// Contains data and a 16-bit starting address for the data.
    /// The byte count specifies number of data bytes in the record.
    case data = 0x00
    /// Must occur exactly once per file in the last line of the file.
    /// The data field is empty (thus byte count is 00) and the address field is typically 0000.
    case endOfFile = 0x01
    /// The data field contains a 16-bit segment base address (thus byte count is always 02)
    /// compatible with 80x86 real mode addressing. The address field (typically 0000) is ignored.
    /// The segment address from the most recent 02 record is multiplied by 16 and added to each
    /// subsequent data record address to form the physical starting address for the data.
    /// This allows addressing up to one megabyte of address space.
    case extendedSegmentAddress = 0x02
    /// For 80x86 processors, specifies the initial content of the CS:IP registers
    /// (i.e., the starting execution address). The address field is 0000, the byte count is
    /// always 04, the first two data bytes are the CS value, the latter two are the IP value.
    case startSegmentAddress = 0x03
    /// Allows for 32 bit addressing (up to 4GiB). The record's address field is ignored
    /// (typically 0000) and its byte count is always 02. The two data bytes (big endian) specify
    /// the upper 16 bits of the 32 bit absolute address for all subsequent type 00 records;
    /// these upper address bits apply until the next 04 record. The absolute address for a
    /// type 00 record is formed by combining the upper 16 address bits of the most recent 04 record
    /// with the low 16 address bits of the 00 record. If a type 00 record is not preceded by any
    /// type 04 records then its upper 16 address bits default to 0000.
    case extendedLinearAddress = 0x04
    /// The address field is 0000 (not used) and the byte count is always 04. The four data bytes
    /// represent a 32-bit address value (big-endian). In the case of 80386 and higher CPUs,
    /// this address is loaded into the EIP register.
    case startLinearAddress = 0x05
  }
}
