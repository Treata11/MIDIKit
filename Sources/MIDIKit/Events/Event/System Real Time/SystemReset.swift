//
//  SystemReset.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.Event {
    
    /// System Real Time: System Reset
    ///
    /// - remark: MIDI 1.0 Spec:
    ///
    /// "System Reset commands all devices in a system to return to their initialized, power-up condition. This message should be used sparingly, and should typically be sent by manual control only. It should not be sent automatically upon power-up and under no condition should this message be echoed."
    public struct SystemReset: Equatable, Hashable {
        
        /// UMP Group (0x0...0xF)
        public var group: MIDI.UInt4 = 0x0
        
    }
    
    /// System Real Time: System Reset
    ///
    /// - remark: MIDI 1.0 Spec:
    ///
    /// "System Reset commands all devices in a system to return to their initialized, power-up condition. This message should be used sparingly, and should typically be sent by manual control only. It should not be sent automatically upon power-up and under no condition should this message be echoed."
    ///
    /// - Parameters:
    ///   - group: UMP Group (0x0...0xF)
    public static func systemReset(group: MIDI.UInt4 = 0x0) -> Self {
        
        .systemReset(
            .init(group: group)
        )
        
    }
    
}

extension MIDI.Event.SystemReset {
    
    public func midi1RawBytes() -> [MIDI.Byte] {
        
        [0xFF]
        
    }
    
    public static let umpMessageType: MIDI.Packet.UniversalPacketData.MessageType = .systemRealTimeAndCommon
    
    public func umpRawWords() -> [MIDI.UMPWord] {
        
        let mtAndGroup = (Self.umpMessageType.rawValue.uInt8Value << 4) + group
        
        let word = MIDI.UMPWord(mtAndGroup,
                                0xFF,
                                0x00, // pad empty bytes to fill 4 bytes
                                0x00) // pad empty bytes to fill 4 bytes
        
        return [word]
        
    }
    
}