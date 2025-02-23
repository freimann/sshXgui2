//
//  AppDelegate.swift
//  sshXgui2
//
//  Created by Peter Freimann on 22.02.2025.
//

import Foundation

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let sshXGui = SSHXGui()

    func applicationDidFinishLaunching(_ notification: Notification) {
        sshXGui.applicationDidFinishLaunching(notification)
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Optional: Add termination logic if needed
    }
}
