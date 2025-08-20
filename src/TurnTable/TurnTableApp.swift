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

    func closeMulti() {
        if (NSApp.windows.count > 1) {
            if let tempWindow = NSApp.windows.last {
                tempWindow.close()
            } else {
                //break
            }
        }
    }

    func savePref(name:String) -> Bool {
        if let mainWindow = NSApp.windows.first {
            mainWindow.delegate = self
            if let savedFrame = UserDefaults.standard.string(forKey:"WindowFrame") {
                print(Date(),"INFO","save",name,savedFrame)
                mainWindow.setFrame(from:savedFrame)
                mainWindow.makeKeyAndOrderFront(nil)
            } else {
                mainWindow.makeKeyAndOrderFront(nil)
            }
            return false
        }
        return true
    }

    func hideWind(name:String) -> Bool {
        if let mainWindow = NSApp.windows.first {
            print(Date(),"INFO","hide",name,mainWindow.frameDescriptor)
            UserDefaults.standard.set(mainWindow.frameDescriptor, forKey:"WindowFrame")
            NSApplication.shared.hide(nil)
            //mainWindow.orderOut(nil)
        }
        return false
    }

    @objc func willStop(_ notification:Notification) {
        let furl = FileManager.default.temporaryDirectory.appendingPathComponent("tt").appendingPathExtension("text")
        do {
            try "\n".write(to:furl, atomically:true, encoding:.utf8)
            print(Date(),"INFO","stop",furl.path)
        } catch {
            print(Date(),"ERRO","stop",furl.path)
        }
    }

    @objc func doneWake(_ notification:Notification) {
        let furl = FileManager.default.temporaryDirectory.appendingPathComponent("tt").appendingPathExtension("text")
        let exis = FileManager.default.fileExists(atPath:furl.path)
        if (exis) {
            do {
                try FileManager.default.removeItem(at:furl)
                print(Date(),"INFO","wake",furl.path)
            } catch {
                print(Date(),"ERRO","wake",furl.path)
            }
        } else {
            /* no-op */
        }
    }

    func applicationDidFinishLaunching(_ notification:Notification) {
        closeMulti()
        let _ = savePref(name:"PEXE")
        doneWake(Notification.init(name:NSWorkspace.didWakeNotification))
        NSWorkspace.shared.notificationCenter.addObserver(self, selector:#selector(willStop(_:)), name:NSWorkspace.willSleepNotification, object:nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector:#selector(doneWake(_:)), name:NSWorkspace.didWakeNotification, object:nil)
    }

    func applicationShouldHandleReopen(_ sender:NSApplication, hasVisibleWindows flag:Bool) -> Bool {
        closeMulti()
        return savePref(name:"REXE")
    }

    func windowShouldClose(_ sender:NSWindow) -> Bool {
        closeMulti()
        return hideWind(name:"HIDE")
    }

    func applicationWillTerminate(_ notification:Notification) {
        closeMulti()
        let _ = hideWind(name:"TERM")
    }

    @MainActor func validateMenuItem(_ menuItem:NSMenuItem) -> Bool {
        return true
    }

}
