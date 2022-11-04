//
//  HUISwitchProtocol.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2022 Steffan Andrews • Licensed under MIT License
//

import Foundation

public protocol HUISwitchProtocol {
    /// HUI zone and port constant for the switch.
    var zoneAndPort: HUIZoneAndPort { get }
}