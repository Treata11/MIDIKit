//
//  ConnectedThru.swift
//  MIDIKit
//
//  Created by Steffan Andrews on 2021-02-21.
//

// Apple CoreMIDI play-through connection documentation:
// https://developer.apple.com/documentation/coremidi/midi_thru_connection
//
// Thru connections are observable in:
// ~/Library/Preferences/ByHost/com.apple.MIDI.<UUID>.plist
// but you can't manually modify the plist file.

import Foundation
import CoreMIDI
@_implementationOnly import OTCore

extension MIDIIOManager {
	
	/// CoreMIDI play-through connection.
	///
	/// CoreMIDI MIDI thru connections can have transforms applied to them.
	///
	/// They can be client-owned (auto-destroyed when app quits) or persistent (continues even after app quits).
	public class ConnectedThru {
		
		public private(set) var thruConnectionRef: MIDIThruConnectionRef? = nil
		
		public private(set) var sources: [MIDIEndpointRef] = []
		
		public private(set) var destinations: [MIDIEndpointRef] = []
		
		public private(set) var persistentOwnerID: String? = nil
		
		public private(set) var params: MIDIThruConnectionParams? = nil
		
		/// - Parameters:
		///   - sources: One or more source endpoints. Maximum 8 endpoints.
		///   - destinations: One or more source endpoints. Maximum 8 endpoints.
		///   - persistentOwnerID: Reverse-DNS domain string; usually the application's bundle ID. If this is `nil`, the connection will be created as non-persistent.
		internal init(sources: [MIDIEndpointRef],
					  destinations: [MIDIEndpointRef],
					  persistentOwnerID: String? = nil,
					  params: MIDIThruConnectionParams? = nil) {
			
			// truncate arrays to 8 members or less;
			// CoreMIDI thru connections can only have up to 8 sources and 8 destinations
			
			self.sources = Array(sources.prefix(8))
			self.destinations = Array(destinations.prefix(8))
			self.persistentOwnerID = persistentOwnerID
			self.params = params
			
		}
		
		deinit {
			
			_ = try? dispose()
			
		}
		
	}
	
}

extension MIDIIOManager.ConnectedThru {
	
	public func create(context: MIDIIOManager) throws {
		
		var result = noErr
		
		var newConnection = MIDIThruConnectionRef()
		
		let cfPersistentOwnerID: CFString? = persistentOwnerID as CFString?
		
		var params = self.params ?? {
			// set up default parameters if params were not supplied
			// (parameters can be altered later using MIDIThruConnectionSetParams on the thruConnectionRef reference)
			
			var newParams = MIDIThruConnectionParams()
			
			MIDIThruConnectionParamsInitialize(&newParams) // fill with defaults
			
			// MIDIThruConnectionParams Properties:
			//	.sources
			//		MIDIThruConnectionEndpoint tuple (initial size: 8). All MIDI generated by these sources is
			//		routed into this connection for processing and distribution to destinations.
			//	.numSources
			//		The number of valid sources in the .sources tuple.
			//	.destinations
			//		MIDIThruConnectionEndpoint tuple (initial size: 8). All MIDI output from the connection is
			//		routed to these destinations.
			//	.numDestinations
			//		The number of valid sources in the .destinations tuple.
			//	(many more properties available including filters)
			
			newParams.filterOutSysEx = 0		// 0 or 1
			newParams.filterOutMTC = 0			// 0 or 1
			newParams.filterOutBeatClock = 0	// 0 or 1
			newParams.filterOutTuneRequest = 0	// 0 or 1
			newParams.filterOutAllControls = 0	// 0 or 1
			
			return newParams
		}()
		
		// Source(s) and destination(s).
		// These expect tuples, so we have to perform some weirdness.
		// Rather than initialize MIDIThruConnectionEndpoint objects,
		// just access the .endpointRef property.
		// All 8 are pre-initialized MIDIThruConnectionEndpoint objects.
		
		for srcEP in 0..<sources.count {
			switch srcEP {
			case 0: params.sources.0.endpointRef = sources[0]
			case 1: params.sources.1.endpointRef = sources[1]
			case 2: params.sources.2.endpointRef = sources[2]
			case 3: params.sources.3.endpointRef = sources[3]
			case 4: params.sources.4.endpointRef = sources[4]
			case 5: params.sources.5.endpointRef = sources[5]
			case 6: params.sources.6.endpointRef = sources[6]
			case 7: params.sources.7.endpointRef = sources[7]
			default: break // ignores more than 8 endpoints
			}
		}
		
		params.numSources = UInt32(sources.count)
		
		for destEP in 0..<destinations.count {
			switch destEP {
			case 0: params.destinations.0.endpointRef = destinations[0]
			case 1: params.destinations.1.endpointRef = destinations[1]
			case 2: params.destinations.2.endpointRef = destinations[2]
			case 3: params.destinations.3.endpointRef = destinations[3]
			case 4: params.destinations.4.endpointRef = destinations[4]
			case 5: params.destinations.5.endpointRef = destinations[5]
			case 6: params.destinations.6.endpointRef = destinations[6]
			case 7: params.destinations.7.endpointRef = destinations[7]
			default: break // ignores more than 8 endpoints
			}
		}
		
		params.numDestinations = UInt32(destinations.count)
		
		// prepare params
		let pLen = MIDIThruConnectionParamsSize(&params)
		
		let paramsData = withUnsafePointer(to: &params) { ptr in
			NSData(bytes: ptr, length: pLen)
		}
		
		// MIDIThruConnectionCreate parameters:
		// - inPersistentOwnerID: CFString?
		//   If null, then the connection is marked as owned by the client and will be automatically disposed with the client. if it is non-null, then it should be a unique identifier, e.g. "com.mycompany.MyApp".
		// - inConnectionParams: CFData
		//   A MIDIThruConnectionParams contained in a CFDataRef.
		// - outConnection: UnsafeMutablePointer<MIDIThruConnectionRef>
		//   On successful return, a reference to the newly-created connection.
		
		result = MIDIThruConnectionCreate(
			cfPersistentOwnerID,
			paramsData,
			&newConnection
		)
		
		guard result == noErr else {
			throw MIDIIOManager.OSStatusResult(rawValue: result)
		}
		
		thruConnectionRef = newConnection
		
		switch persistentOwnerID {
		case .none:
			Log.debug("MIDI: Thru Connection: Successfully formed non-persistent connection.")
		case .some(let persOwnerID):
			Log.debug("MIDI: Thru Connection: Successfully formed persistent connection with ID \(persOwnerID.quoted).")
		}
		
	}
	
	/// Disposes of the the thru connection if it's already been created in the system via the `create()` method.
	///
	/// Errors thrown can be safely ignored and are typically only useful for debugging purposes.
	public func dispose() throws {
		
		guard let thruConnectionRef = self.thruConnectionRef else { return }
		
		let result = MIDIThruConnectionDispose(thruConnectionRef)
		
		guard result == noErr else {
			throw MIDIIOManager.OSStatusResult(rawValue: result)
		}
		
		self.thruConnectionRef = nil
		
	}
	
}

extension MIDIIOManager.ConnectedThru: CustomStringConvertible {
	
	public var description: String {
		
		let thruConnectionRef = "\(self.thruConnectionRef, ifNil: "nil")"
		
		let persistence = persistentOwnerID != nil
			? "persistentOwnerID: \(persistentOwnerID, ifNil: "nil")"
			: "persistent: false"
		
		return "ConnectedThru(thruConnectionRef: \(thruConnectionRef), sources: \(sources), destinations: \(destinations), \(persistence)"
		
	}
	
}
