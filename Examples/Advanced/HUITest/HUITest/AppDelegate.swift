//
//  AppDelegate.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import Cocoa
import SwiftUI
import MIDIKitIO

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var huiHostWindow: NSWindow!
    var huiSurfaceWindow: NSWindow!
    
    private let midiManager = MIDIManager(
        clientName: "HUISurface",
        model: "HUISurface",
        manufacturer: "Orchetect",
        notificationHandler: nil
    )
    
    func applicationDidFinishLaunching(_: Notification) {
        do {
            try midiManager.start()
        } catch {
            Logger.debug("Error setting up MIDI.")
        }
        
        generateHUISurfaceWindow()
        generateHUIHostWindow()
        
        // bring all windows to the front; sometimes they don't all show with SwiftUI
        orderAllWindowsFront()
    }
    
    let huiHostWidth = 300
    let huiHostHeight = 400
    
    func generateHUIHostWindow() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = HUIHostView(midiManager: midiManager)
        
        // Create the window and set the content view.
        huiHostWindow = NSWindow(
            contentRect: NSRect(
                x: 100,
                y: 100 + ((huiSurfaceHeight - huiHostWidth) / 2),
                width: huiHostWidth,
                height: huiHostHeight
            ),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        huiHostWindow.title = "HUI Host"
        huiHostWindow.isReleasedWhenClosed = true
        // huiSurfaceWindow.center()
        // window.setFrameAutosaveName("HUI Host Window")
        huiHostWindow.contentView = NSHostingView(rootView: contentView)
        huiHostWindow.makeKeyAndOrderFront(self)
    }
    
    let huiSurfaceWidth = 1180
    let huiSurfaceHeight = 920
    
    func generateHUISurfaceWindow() {
        // Create the SwiftUI view that provides the window contents.
        let contentView = HUIClientView(midiManager: midiManager)
        
        // Create the window and set the content view.
        huiSurfaceWindow = NSWindow(
            contentRect: NSRect(
                x: 100 + huiHostWidth + 100,
                y: 100,
                width: huiSurfaceWidth,
                height: huiSurfaceHeight
            ),
            styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        huiSurfaceWindow.title = "HUI Surface"
        huiSurfaceWindow.isReleasedWhenClosed = true
        // huiSurfaceWindow.center()
        // window.setFrameAutosaveName("HUI Surface Window")
        huiSurfaceWindow.contentView = NSHostingView(rootView: contentView)
        huiSurfaceWindow.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_: Notification) {
        // Insert code here to tear down your application
    }
    
    func orderAllWindowsFront() {
        NSApp.windows.forEach { $0.makeKeyAndOrderFront(self) }
    }
}
