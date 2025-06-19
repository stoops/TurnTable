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
                .onAppear(perform:{
                        print(Date(),"DEBUG","MAIN","init")
                        NSWindow.allowsAutomaticWindowTabbing = false
                    })
        }.windowStyle(.hiddenTitleBar)
            .commands(content:{
                CommandGroup(replacing:.newItem) { /* no-op */ }
            })
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
            if let savedFrame = UserDefaults.standard.string(forKey:"WindowFrame") {
                mainWindow.setFrame(from:savedFrame)
                mainWindow.makeKeyAndOrderFront(nil)
            } else {
                mainWindow.makeKeyAndOrderFront(nil)
            }
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        let wlen = NSApp.windows.count
        if (wlen > 1) {
            if let tempWindow = NSApp.windows.last {
                tempWindow.close()
            }
        }
        print(Date(),"DEBUG","WIND",wlen,flag)
        if let mainWindow = NSApp.windows.first {
            if let savedFrame = UserDefaults.standard.string(forKey:"WindowFrame") {
                mainWindow.setFrame(from:savedFrame)
                mainWindow.makeKeyAndOrderFront(nil)
            } else {
                mainWindow.makeKeyAndOrderFront(nil)
            }
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
            UserDefaults.standard.set(mainWindow.frameDescriptor, forKey:"WindowFrame")
            mainWindow.orderOut(nil)
        }
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        let wlen = NSApp.windows.count
        if (wlen > 1) {
            if let tempWindow = NSApp.windows.last {
                tempWindow.close()
            }
        }
        if let mainWindow = NSApp.windows.first {
            UserDefaults.standard.set(mainWindow.frameDescriptor, forKey:"WindowFrame")
            mainWindow.orderOut(nil)
        }
    }

    @MainActor func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        return true
    }

}
