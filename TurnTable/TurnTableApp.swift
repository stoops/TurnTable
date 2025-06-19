//
//  TurnTableApp.swift
//  TurnTable
//
//  Created by jon on 2025-06-18.
//

import SwiftUI

@main
struct TurnTableApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }.windowStyle(.hiddenTitleBar)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        let wlen = NSApp.windows.count
        if (wlen > 1) {
            if let tempWindow = NSApp.windows.last {
                tempWindow.close()
            }
        }
        if let mainWindow = NSApp.windows.first {
            mainWindow.delegate = self
            mainWindow.backgroundColor = NSColor(Color.init(red:0.17, green:0.17, blue:0.17, opacity:0.97))
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        let wlen = NSApp.windows.count
        if (wlen > 1) {
            if let tempWindow = NSApp.windows.last {
                tempWindow.close()
            }
        }
        print("DEBUG","MAIN",wlen,flag)
        if let mainWindow = NSApp.windows.first {
            /*if flag {
                mainWindow.orderFront(nil)
            } else {
                mainWindow.makeKeyAndOrderFront(nil)
            }*/
            if let savedFrame = UserDefaults.standard.string(forKey: "WindowFrame") {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.5))
                    mainWindow.setFrame(from: savedFrame)
                    mainWindow.makeKeyAndOrderFront(nil)
                }
            }
            mainWindow.makeKeyAndOrderFront(nil)
            return false
        }
        return true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        let wlen = NSApp.windows.count
        if (wlen > 1) {
            if let tempWindow = NSApp.windows.last {
                tempWindow.close()
            }
        }
        if let mainWindow = NSApp.windows.first {
            UserDefaults.standard.set(mainWindow.frameDescriptor, forKey: "WindowFrame")
            mainWindow.orderOut(nil)
        }
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        /* no-op */
    }
}
