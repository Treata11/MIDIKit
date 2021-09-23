//
//  Note Off.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//

extension MIDI.Event.Note {
    
    /// Channel Voice Message: Note Off
    public struct Off: Equatable, Hashable {
        
        /// Note Number
        ///
        /// If MIDI 2.0 attribute is set to Pitch 7.9, then this value holds the note index.
        public var note: MIDI.UInt7
        
        /// Velocity
        public var velocity: MIDI.Event.Note.Velocity
        
        /// Channel Number (0x0...0xF)
        public var channel: MIDI.UInt4
        
        /// MIDI 2.0 Channel Voice Attribute
        public var attribute: Attribute = .none
        
        /// UMP Group (0x0...0xF)
        public var group: MIDI.UInt4 = 0x0
        
    }
    
}

extension MIDI.Event {
    
    /// Channel Voice Message: Note Off
    ///
    /// - Parameters:
    ///   - note: Note Number (or Note Index if using MIDI 2.0 Pitch 7.9)
    ///   - velocity: Velocity
    ///   - channel: Channel Number (0x0...0xF)
    ///   - attribute: MIDI 2.0 Channel Voice Attribute
    ///   - group: UMP Group (0x0...0xF)
    public static func noteOff(_ note: MIDI.UInt7,
                               velocity: Note.Velocity,
                               channel: MIDI.UInt4,
                               attribute: Note.Attribute = .none,
                               group: MIDI.UInt4 = 0x0) -> Self {
        
        .noteOff(
            .init(note: note,
                  velocity: velocity,
                  channel: channel,
                  attribute: attribute,
                  group: group)
        )
        
    }
    
    /// Channel Voice Message: Note Off
    ///
    /// - Parameters:
    ///   - note: Note Number (or Note Index if using MIDI 2.0 Pitch 7.9)
    ///   - velocity: Velocity as a Double unit interval (0.0...1.0)
    ///   - channel: Channel Number (0x0...0xF)
    ///   - attribute: MIDI 2.0 Channel Voice Attribute
    ///   - group: UMP Group (0x0...0xF)
    public static func noteOff(_ note: MIDI.UInt7,
                               velocity: Double,
                               channel: MIDI.UInt4,
                               attribute: Note.Attribute = .none,
                               group: MIDI.UInt4 = 0x0) -> Self {
        
        .noteOff(
            .init(note: note,
                  velocity: .unitInterval(velocity),
                  channel: channel,
                  attribute: attribute,
                  group: group)
        )
        
    }
    
}

extension MIDI.Event.Note.Off {
    
    public func midi1RawBytes() -> [MIDI.Byte] {
        
        [0x80 + channel.uInt8Value,
         note.uInt8Value,
         velocity.midi1Value.uInt8Value]
        
    }
    
    public static let umpMessageType: MIDI.Packet.UniversalPacketData.MessageType = .midi1ChannelVoice
    
    public func umpRawWords(protocol midiProtocol: MIDI.IO.ProtocolVersion) -> [MIDI.UMPWord] {
        
        let mtAndGroup = (Self.umpMessageType.rawValue.uInt8Value << 4) + group
        
        switch midiProtocol {
        case ._1_0:
            let word = MIDI.UMPWord(mtAndGroup,
                                    0x80 + channel.uInt8Value,
                                    note.uInt8Value,
                                    velocity.midi1Value.uInt8Value)
            
            return [word]
            
        case ._2_0:
            #warning("> code this")
            return []
            
        }
        
    }
    
}