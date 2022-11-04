//
//  MIDIPacketData.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2022 Steffan Andrews • Licensed under MIT License
//

#if !os(tvOS) && !os(watchOS)

@_implementationOnly import CoreMIDI

/// Clean consolidated data encapsulation of raw data from a Core MIDI `MIDIPacket` (MIDI 1.0).
public struct MIDIPacketData {
    let bytes: [UInt8]
    
    /// Core MIDI packet timestamp
    let timeStamp: CoreMIDITimeStamp
    
    /// The MIDI endpoint from which the packet originated.
    /// If this information is not available, it may be `nil`.
    let source: MIDIOutputEndpoint?
    
    public init(
        bytes: [UInt8],
        timeStamp: CoreMIDITimeStamp,
        source: MIDIOutputEndpoint? = nil
    ) {
        self.bytes = bytes
        self.timeStamp = timeStamp
        self.source = source
    }
}

extension MIDIPacketData {
    internal init(
        _ midiPacketPtr: UnsafePointer<MIDIPacket>,
        refCon: UnsafeMutableRawPointer?,
        refConKnown: Bool
    ) {
        self = Self.unwrapPacket(midiPacketPtr, refCon: refCon, refConKnown: refConKnown)
    }
    
    fileprivate static let midiPacketDataOffset: Int = MemoryLayout.offset(of: \MIDIPacket.data)!
    
    fileprivate static func unwrapPacket(
        _ midiPacketPtr: UnsafePointer<MIDIPacket>,
        refCon: UnsafeMutableRawPointer?,
        refConKnown: Bool
    ) -> MIDIPacketData {
        let packetDataCount = Int(midiPacketPtr.pointee.length)
        
        let source = unpackMIDIRefCon(refCon: refCon, known: refConKnown)
        
        guard packetDataCount > 0 else {
            return MIDIPacketData(
                bytes: [],
                timeStamp: midiPacketPtr.pointee.timeStamp,
                source: source
            )
        }
    
        // Access the raw memory instead of using the .pointee
        // This workaround is needed due to a variety of crashes that can occur when either the
        // thread sanitizer is on, or large/malformed MIDI packet lists / packets arrive
        let rawMIDIPacketDataPtr = UnsafeRawBufferPointer(
            start: UnsafeRawPointer(midiPacketPtr) + midiPacketDataOffset,
            count: packetDataCount
        )
    
        return MIDIPacketData(
            bytes: [UInt8](rawMIDIPacketDataPtr),
            timeStamp: midiPacketPtr.pointee.timeStamp,
            source: source
        )
    }
}

#endif