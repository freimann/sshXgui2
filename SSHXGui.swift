//
//  SSHXGui.swift
//  sshXgui2
//
//  Created by Peter Freimann on 22.02.2025.
//

import Foundation

import Cocoa

class SSHXGui: NSObject {
    // MARK: - Properties
    
    @objc dynamic var arrayQuickForward: [String] = []
    @objc dynamic var arraySessions: [[String: Any]] = []
    @objc dynamic var strRegOwner: String = ""
    @objc dynamic var strRegEmail: String = ""
    @objc dynamic var strRegCode: String = ""
    @objc dynamic var stringQuickSessionNameValue: String = ""
    var receivedData: NSMutableData?
    var downloadUrl: String?
    var tabbedTerminal: Bool = false
    var closeOnLaunch: Bool = false
    var prefCheckForUpgrade: Bool = false
    var lastTabOpen: Int = 0
    
    // MARK: - UI Elements (Assumed to be connected via storyboard or created programmatically)
    
    @IBOutlet weak var txtQuickHostname: NSTextField!
    @IBOutlet weak var txtQuickUsername: NSTextField!
    @IBOutlet weak var txtQuickPort: NSTextField!
    @IBOutlet weak var txtSshKeyPath: NSTextField!
    @IBOutlet weak var btnQuickX11Forward: NSButton!
    @IBOutlet weak var btnQuickKeepAlive: NSButton!
    @IBOutlet weak var btnQuickForwardAllowRemote: NSButton!
    @IBOutlet weak var btnQuickTabbedTerminal: NSButton!
    @IBOutlet weak var btnCloseOnLaunch: NSButton!
    @IBOutlet weak var btnCheckForUpgradePref: NSButton!
    @IBOutlet weak var txtQuickSessionName: NSTextField!
    @IBOutlet weak var txtQuickForwardSourcePort: NSTextField!
    @IBOutlet weak var txtQuickForwardDestination: NSTextField!
    @IBOutlet weak var optQuickForwardRemoteLocal: NSMatrix!
    @IBOutlet weak var tableQuickForward: NSTableView!
    @IBOutlet weak var tableSessionsList: NSTableView!
    @IBOutlet weak var tabSessionsQuick: NSTabView!
    @IBOutlet weak var tabSessions: NSTabViewItem!
    @IBOutlet weak var tabQuickConnect: NSTabViewItem!
    @IBOutlet weak var btnQuickConnect: NSButton!
    @IBOutlet weak var btnQuickSaveSession: NSButton!
    @IBOutlet weak var btnRemoveSession: NSButton!
    @IBOutlet weak var btnSessionConnect: NSButton!
    @IBOutlet weak var btnLoadQuickSession: NSButton!
    @IBOutlet weak var btnQuickForwardRemove: NSButton!
    @IBOutlet weak var winSshXGui: NSWindow!
    @IBOutlet weak var winPreferences: NSWindow!
    @IBOutlet weak var txtPrefsOwner: NSTextField!
    @IBOutlet weak var txtPrefsEmail: NSTextField!
    @IBOutlet weak var txtPrefsCode: NSTextField!
    @IBOutlet weak var lblRegister: NSTextField!
    @IBOutlet weak var btnRegistration: NSButton!
    @IBOutlet weak var optOpenTabOnLaunch: NSMatrix!
    @IBOutlet weak var imgEasterEgg: NSImageView!
    @IBOutlet weak var btnPrefRegSave: NSButton!
    
    // MARK: - SSH Connection
    
    func sshConnect(hostname: String, username: String, port: Int, sshKeyPath: String, x11Forward: Bool, tcpKeepAlive: Bool, forwardAllowRemote: Bool, forwardings: [String], tabbedTerminal: Bool) {
        var sshArguments = NSMutableString()
        
        if port != 22 {
            sshArguments.appendFormat(" -p %ld", port)
        }
        
        if x11Forward {
            sshArguments.append(" -X")
        }
        
        if forwardAllowRemote {
            sshArguments.append(" -g")
        }
        
        if tcpKeepAlive {
            sshArguments.append(" -o TCPKeepAlive=yes")
        }
        
        if !sshKeyPath.isEmpty {
            sshArguments.appendFormat(" -i \"%@\"", sshKeyPath)
        }
        
        for forwarding in forwardings {
            sshArguments.appendFormat(" %@", forwarding)
        }
        
        let sshCommand = String(format: "ssh%@ \"%@@%@\"", sshArguments, username, hostname)
        let appleScriptSafeCommand = sshCommand.replacingOccurrences(of: "\"", with: "\\\"")
        
        let appleScriptTabbedTerminal: String
        if tabbedTerminal {
            appleScriptTabbedTerminal = """
            tell application "Terminal"
                activate
                delay 0.2 -- Wait for Terminal to activate
                tell application "System Events"
                    keystroke "t" using command down -- New tab
                    delay 0.1 -- Wait for tab to open
                    keystroke "k" using command down -- Clear screen
                    delay 0.1 -- Wait for clear to complete
                end tell
                do script "\(appleScriptSafeCommand); exit" in front window
            end tell
            """
        } else {
            appleScriptTabbedTerminal = """
            tell application "Terminal"
                activate
                delay 0.2 -- Wait for Terminal to activate
                tell application "System Events"
                    keystroke "n" using command down -- New window
                    delay 0.1 -- Wait for window to open
                    keystroke "k" using command down -- Clear screen
                    delay 0.1 -- Wait for clear to complete
                end tell
                do script "\(appleScriptSafeCommand); exit" in front window
            end tell
            """
        }
        
        let sshAppleScript = """
        tell application "System Events"
            if not (exists process "Terminal") then
                tell application "Terminal"
                    activate
                    delay 0.5 -- Wait for Terminal to launch and be ready
                    do script "\(appleScriptSafeCommand); exit" in front window
                end tell
            else
                \(appleScriptTabbedTerminal)
            end if
        end tell
        """
        
        if let script = NSAppleScript(source: sshAppleScript) {
            var errorInfo: NSDictionary?
            script.executeAndReturnError(&errorInfo)
            if let error = errorInfo {
                print("AppleScript Error: \(error)")
            }
        } else {
            print("Failed to create AppleScript object")
        }
    }
    
    func sshConnect_migrated(hostname: String, username: String, port: Int, sshKeyPath: String, x11Forward: Bool, tcpKeepAlive: Bool, forwardAllowRemote: Bool, forwardings: [String], tabbedTerminal: Bool) {
        var sshArguments = NSMutableString()
        
        if port != 22 {
            sshArguments.appendFormat(" -p %ld", port)
        }
        
        if x11Forward {
            sshArguments.append(" -X")
        }
        
        if forwardAllowRemote {
            sshArguments.append(" -g")
        }
        
        if tcpKeepAlive {
            sshArguments.append(" -o TCPKeepAlive=yes")
        }
        
        if !sshKeyPath.isEmpty {
            sshArguments.appendFormat(" -i \"%@\"", sshKeyPath)
        }
        
        for forwarding in forwardings {
            sshArguments.appendFormat(" %@", forwarding)
        }
        
        let sshCommand = String(format: "ssh%@ \"%@@%@\"", sshArguments, username, hostname)
        let appleScriptSafeCommand = sshCommand.replacingOccurrences(of: "\"", with: "\\\"")
        
        let appleScriptTabbedTerminal: String
        if tabbedTerminal {
            appleScriptTabbedTerminal = """
            tell application "Terminal"
                activate
                tell application "System Events"
                    keystroke "t" using command down -- New tab
                    keystroke "k" using command down -- Clear screen
                end tell
                delay 0.5
                do script "\(appleScriptSafeCommand); exit" in front window
            end tell
            """
        } else {
            appleScriptTabbedTerminal = """
            tell application "Terminal"
                activate
                tell application "System Events"
                    keystroke "n" using command down -- New window
                    keystroke "k" using command down -- Clear screen
                end tell
                delay 0.5
                do script "\(appleScriptSafeCommand); exit" in front window
            end tell
            """
        }
        
        let sshAppleScript = """
        tell application "System Events"
            if not (exists process "Terminal") then
                tell application "Terminal"
                    activate
                    delay 0.5
                    do script "\(appleScriptSafeCommand); exit" in front window
                end tell
            else
                \(appleScriptTabbedTerminal)
            end if
        end tell
        """
        
        if let script = NSAppleScript(source: sshAppleScript) {
            var errorInfo: NSDictionary?
            script.executeAndReturnError(&errorInfo)
            if let error = errorInfo {
                print("AppleScript Error: \(error)")
            }
        } else {
            print("Failed to create AppleScript object")
        }
    }
    
    func sshConnect_old(hostname: String, username: String, port: Int, sshKeyPath: String, x11Forward: Bool, tcpKeepAlive: Bool, forwardAllowRemote: Bool, forwardings: [String], tabbedTerminal: Bool) {
        var sshArguments = ""
        
        if port != 22 {
            sshArguments += " -p \(port)"
        }
        
        if x11Forward {
            sshArguments += " -X"
        }
        
        if forwardAllowRemote {
            sshArguments += " -g"
        }
        
        if tcpKeepAlive {
            sshArguments += " -o TCPKeepAlive=yes"
        }
        
        if !sshKeyPath.isEmpty {
            sshArguments += " -i \"\(sshKeyPath)\""
        }
        
        for forwarding in forwardings {
            sshArguments += " \(forwarding)"
        }
        
        let sshCommand = "ssh\(sshArguments) \(username)@\(hostname)"
        let appleScriptSafeCommand = sshCommand.replacingOccurrences(of: "\"", with: "\\\"")
        
        let appleScript: String
        if tabbedTerminal {
            appleScript = """
            tell application "Terminal"
                activate
                delay 0.1
                set newTab to (do script "\(appleScriptSafeCommand); exit")
            end tell
            """
        } else {
            appleScript = """
            tell application "Terminal"
                activate
                delay 0.1
                do script "\(appleScriptSafeCommand); exit"
            end tell
            """
        }
        
        let fullScript = """
        tell application "Terminal"
            if not (running) then
                activate
                delay 0.1
                do script "\(appleScriptSafeCommand); exit"
            else
                \(appleScript)
            end if
        end tell
        """
        
        if let script = NSAppleScript(source: fullScript) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript Error: \(error)")
            }
        }
    }
    
    // MARK: - Registration Key Generation
    
    func getKey(owner: String, email: String) -> String {
        let sshXguiVersion = "sshXgui.app v1"
        var total = 42
        let fullString = "\(sshXguiVersion)\(owner)\(email)"
        
        for (i, char) in fullString.enumerated() {
            let charValue = Int(char.unicodeScalars.first!.value)
            total += charValue * charValue + i
        }
        
        total = total + (total / 2) * 514
        if total < 0 { total = -total }
        
        let totalStr = String(total)
        let digits = totalStr.map { Int(String($0))! }
        
        let num1 = digits[0]
        let num2 = digits[1]
        let num3 = digits[2]
        let num4 = digits[3]
        let num5 = digits[4]
        let num6 = digits[5]
        let num7 = digits[6]
        let num8 = digits[7]
        
        let numT1 = num1 * 10 + num8 * 2 * 13
        let numT2 = num2 * 10 + num7 * 3 * 15
        let numT3 = num3 * 10 + num6 * 4 * 17
        let numT4 = num4 * 10 + num5 * 5 * 19
        let numT5 = num1 * 10 + num5 * 6 * 21
        
        return "\(numT4)-\(numT2)-\(numT1)-\(numT3)-\(numT5)"
    }
    
    func checkRegCode(regOwner: String, regEmail: String, regCode: String) -> Bool {
        if !regOwner.isEmpty && !regEmail.isEmpty && !regCode.isEmpty {
            return regCode == getKey(owner: regOwner, email: regEmail)
        }
        return false
    }
    
    // MARK: - Instance Methods
    
    //func sortArraySessions() {
    //    arraySessions.sort { ($0["SessionName"] as? String ?? "") < ($1["SessionName"] as? String ?? "") }
    //}
    
    func sortArraySessions() {
        arraySessions.sort { ($0["SessionName"] as? String ?? "").caseInsensitiveCompare($1["SessionName"] as? String ?? "") == .orderedAscending }
    }
    
    func saveSettings() {
        let prefs = UserDefaults.standard
        sortArraySessions()
        
        prefs.set(strRegOwner, forKey: "RegOwner")
        prefs.set(strRegEmail, forKey: "RegEmail")
        prefs.set(strRegCode, forKey: "RegCode")
        prefs.set(optOpenTabOnLaunch.selectedRow, forKey: "OpenTabOnLaunch")
        prefs.set(tabbedTerminal, forKey: "TabbedTerminal")
        prefs.set(closeOnLaunch, forKey: "CloseOnLaunch")
        prefs.set(lastTabOpen, forKey: "LastTabOpen")
        prefs.set(prefCheckForUpgrade, forKey: "CheckForUpgradeAtStartup")
        prefs.set(arraySessions, forKey: "Connections")
        prefs.synchronize()
    }
    
    // MARK: - NSTabViewDelegate
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let tabViewItem = tabViewItem else { return }
        if tabViewItem.label == tabSessions.label {
            lastTabOpen = 0
        } else if tabViewItem.label == tabQuickConnect.label {
            lastTabOpen = 1
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func btnQuickTabbedTerminal(_ sender: NSButton) {
        tabbedTerminal = sender.state == .on
    }
    
    @IBAction func btnCloseOnLaunch(_ sender: NSButton) {
        closeOnLaunch = sender.state == .on
    }
    
    @IBAction func btnCheckForUpgradePref(_ sender: NSButton) {
        prefCheckForUpgrade = sender.state == .on
    }
    
    @IBAction func btnQuickConnect(_ sender: NSButton) {
        if txtQuickPort.intValue == 0 {
            txtQuickPort.intValue = 22
        }
        
        sshConnect(
            hostname: txtQuickHostname.stringValue,
            username: txtQuickUsername.stringValue,
            port: Int(txtQuickPort.intValue),
            sshKeyPath: txtSshKeyPath.stringValue,
            x11Forward: btnQuickX11Forward.state == .on,
            tcpKeepAlive: btnQuickKeepAlive.state == .on,
            forwardAllowRemote: btnQuickForwardAllowRemote.state == .on,
            forwardings: arrayQuickForward,
            tabbedTerminal: tabbedTerminal
        )
        
        if closeOnLaunch {
            NSApp.terminate(nil)
        }
    }
    
    @IBAction func btnSessionConnect(_ sender: NSButton) {
        let selectedRow = tableSessionsList.selectedRow
        guard selectedRow != -1 else { return }
        let session = arraySessions[selectedRow]
        
        sshConnect(
            hostname: session["HostName"] as! String,
            username: session["UserName"] as! String,
            port: session["Port"] as! Int,
            sshKeyPath: session["SSHKeyPath"] as! String,
            x11Forward: session["X11Forward"] as! Bool,
            tcpKeepAlive: session["TCPKeepAlive"] as! Bool,
            forwardAllowRemote: session["ForwardAllowRemote"] as! Bool,
            forwardings: session["PortForwarding"] as! [String],
            tabbedTerminal: tabbedTerminal
        )
        
        if closeOnLaunch {
            NSApp.terminate(nil)
        }
    }
    
    // Add remaining IBActions here...
    
    @IBAction func mnuPreferences(_ sender: Any) {
        winSshXGui.beginSheet(winPreferences, completionHandler: nil)
    }

    @IBAction func btnQuickForwardRemove(_ sender: Any) {
        let selectedRow = tableQuickForward.selectedRow
        if selectedRow != -1 {
            arrayQuickForward.remove(at: selectedRow)
            tableQuickForward.reloadData()
            tableQuickForward.deselectAll(nil)
        }
    }

    @IBAction func btnQuickForwardAdd(_ sender: Any) {
        if !txtQuickForwardSourcePort.stringValue.isEmpty && !txtQuickForwardDestination.stringValue.isEmpty {
            let sshForwardRule = optQuickForwardRemoteLocal.selectedRow == 0 ?
                "-L \(txtQuickForwardSourcePort.stringValue):\(txtQuickForwardDestination.stringValue)" :
                "-R \(txtQuickForwardSourcePort.stringValue):\(txtQuickForwardDestination.stringValue)"
            
            arrayQuickForward.append(sshForwardRule)
            txtQuickForwardSourcePort.stringValue = ""
            txtQuickForwardDestination.stringValue = ""
            tableQuickForward.reloadData()
        }
    }

    @IBAction func btnRemoveSession(_ sender: Any) {
        let selectedRow = tableSessionsList.selectedRow
        if selectedRow != -1 {
            arraySessions.remove(at: selectedRow)
            tableSessionsList.reloadData()
            tableSessionsList.deselectAll(self)
            saveSettings()
        }
    }

    @IBAction func btnQuickSaveSession(_ sender: Any) {
        if txtQuickSessionName.stringValue.isEmpty {
            txtQuickSessionName.stringValue = "\(txtQuickUsername.stringValue)@\(txtQuickHostname.stringValue)"
        }
        
        if txtQuickPort.intValue == 0 {
            txtQuickPort.intValue = 22
        }
        
        let dictSession: [String: Any] = [
            "SessionName": txtQuickSessionName.stringValue,
            "HostName": txtQuickHostname.stringValue,
            "UserName": txtQuickUsername.stringValue,
            "SSHKeyPath": txtSshKeyPath.stringValue,
            "Port": Int(txtQuickPort.intValue),
            "X11Forward": btnQuickX11Forward.state == .on,
            "TCPKeepAlive": btnQuickKeepAlive.state == .on,
            "ForwardAllowRemote": btnQuickForwardAllowRemote.state == .on,
            "PortForwarding": arrayQuickForward
        ]
        
        arraySessions.append(dictSession)
        saveSettings()
        tableSessionsList.reloadData()
        tableSessionsList.selectRowIndexes(IndexSet(integer: arraySessions.count - 1), byExtendingSelection: false)
        tabSessionsQuick.selectTabViewItem(tabSessions)
        btnQuickClearFields(nil)
    }

    @IBAction func btnExit(_ sender: Any) {
        NSApp.terminate(nil)
    }

    @IBAction func btnLoadQuickSession(_ sender: Any) {
        let selectedRow = tableSessionsList.selectedRow
        guard selectedRow != -1 else { return }
        let dictSession = arraySessions[selectedRow]
        
        txtQuickHostname.stringValue = dictSession["HostName"] as? String ?? ""
        txtQuickUsername.stringValue = dictSession["UserName"] as? String ?? ""
        txtQuickPort.integerValue = dictSession["Port"] as? Int ?? 22
        txtSshKeyPath.stringValue = dictSession["SSHKeyPath"] as? String ?? ""
        btnQuickX11Forward.state = (dictSession["X11Forward"] as? Bool ?? false) ? .on : .off
        btnQuickKeepAlive.state = (dictSession["TCPKeepAlive"] as? Bool ?? false) ? .on : .off
        btnQuickForwardAllowRemote.state = (dictSession["ForwardAllowRemote"] as? Bool ?? false) ? .on : .off
        
        optQuickForwardRemoteLocal.selectCell(atRow: 0, column: 0)
        arrayQuickForward.removeAll()
        if let portForwarding = dictSession["PortForwarding"] as? [String] {
            arrayQuickForward.append(contentsOf: portForwarding)
        }
        
        txtQuickForwardSourcePort.stringValue = ""
        txtQuickForwardDestination.stringValue = ""
        txtQuickSessionName.stringValue = dictSession["SessionName"] as? String ?? ""
        stringQuickSessionNameValue = dictSession["SessionName"] as? String ?? ""
        
        tableQuickForward.reloadData()
        winSshXGui.makeFirstResponder(txtQuickHostname)
        btnQuickConnect.isEnabled = true
        btnQuickSaveSession.isEnabled = true
        tabSessionsQuick.selectTabViewItem(at: 1)
    }

    @IBAction func btnClosePreferences(_ sender: Any) {
        winPreferences.orderOut(nil)
        winSshXGui.endSheet(winPreferences)
        saveSettings()
    }

    @IBAction func btnSshKeyBrowse(_ sender: Any) {
        let openDlg = NSOpenPanel()
        openDlg.canChooseFiles = true
        openDlg.canChooseDirectories = false
        openDlg.allowsMultipleSelection = false
        openDlg.directoryURL = URL(fileURLWithPath: "~/.ssh", isDirectory: true)
        
        openDlg.beginSheetModal(for: winSshXGui) { response in
            if response == .OK {
                if let selectedFile = openDlg.urls.first {
                    self.txtSshKeyPath.stringValue = selectedFile.path
                }
            }
        }
    }

    @IBAction func btnQuickClearFields(_ sender: Any?) {
        txtQuickHostname.stringValue = ""
        txtQuickUsername.stringValue = ""
        txtQuickPort.intValue = 22
        txtSshKeyPath.stringValue = ""
        btnQuickX11Forward.state = .off
        btnQuickKeepAlive.state = .off
        optQuickForwardRemoteLocal.selectCell(atRow: 0, column: 0)
        btnQuickForwardAllowRemote.state = .off
        arrayQuickForward.removeAll()
        txtQuickForwardSourcePort.stringValue = ""
        txtQuickForwardDestination.stringValue = ""
        txtQuickSessionName.stringValue = ""
        tableQuickForward.reloadData()
        winSshXGui.makeFirstResponder(txtQuickHostname)
        btnQuickConnect.isEnabled = false
        btnQuickSaveSession.isEnabled = false
    }

    @IBAction func btnPrefRegSave(_ sender: Any) {
        if txtPrefsCode.stringValue != "************************" {
            strRegOwner = txtPrefsOwner.stringValue
            strRegEmail = txtPrefsEmail.stringValue
            strRegCode = txtPrefsCode.stringValue
            
            if checkRegCode(regOwner: strRegOwner, regEmail: strRegEmail, regCode: strRegCode) {
                let labelText = strRegEmail.isEmpty ?
                    "Registered to: \(strRegOwner)" :
                    "Registered to: \(strRegOwner) (\(strRegEmail))"
                lblRegister.stringValue = labelText
                lblRegister.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
                txtPrefsCode.stringValue = "************************"
                winSshXGui.title = "sshXgui"
                btnRegistration.isEnabled = false
            } else {
                let attrStr = NSMutableAttributedString(string: "Unregistered!")
                let range = NSRange(location: 0, length: attrStr.length)
                attrStr.addAttribute(.font, value: NSFont(name: "Lucida Grande", size: 13)!, range: range)
                attrStr.addAttribute(.link, value: URL(string: "http://www.sshxgui.org/")!, range: range)
                attrStr.addAttribute(.foregroundColor, value: NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.9), range: range)
                lblRegister.attributedStringValue = attrStr
                winSshXGui.title = "sshXgui - Unregistered!"
                btnRegistration.isEnabled = true
            }
            saveSettings()
        }
    }

    
    // Add this inside the SSHXGui class
    
    @IBAction func checkForNewVersion(_ sender: Any) {
        let url = URL(string: "http://www.sshxgui.org/version.xml")!
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60.0)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Version check failed: \(error)")
                return
            }
            
            guard let data = data else { return }
            self.receivedData = NSMutableData(data: data)
            
            guard let dataString = String(data: data, encoding: .ascii),
                  let productVersionDict = dataString.propertyList() as? [String: String] else {
                print("Problem parsing version data")
                return
            }
            
            let latestVersionNumber = productVersionDict["sshXgui.app"]
            self.downloadUrl = productVersionDict["DownloadUrl"]
            
            guard let currentVersionNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
                  let latestVersion = latestVersionNumber else {
                print("Problem getting latest version number")
                return
            }
            
            let currentVersion = Double(currentVersionNumber) ?? 0.0
            let latestVersionDouble = Double(latestVersion) ?? 0.0
            
            if currentVersion == latestVersionDouble {
                print("Version is up to date!")
            } else if currentVersion < latestVersionDouble {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "New version is available"
                    alert.informativeText = "A new version of sshXgui.app is available. Click 'Download' to get it."
                    alert.addButton(withTitle: "OK")
                    alert.addButton(withTitle: "Download")
                    alert.beginSheetModal(for: self.winSshXGui!) { response in
                        if response == .alertSecondButtonReturn {
                            if let url = self.downloadUrl, let downloadURL = URL(string: url) {
                                NSWorkspace.shared.open(downloadURL)
                            }
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let prefs = UserDefaults.standard
        
        //let domainName = "com.freimann.sshXgui2"
        //if let domainPrefs = prefs.persistentDomain(forName: domainName) {
        //    print("Explicit domain \(domainName): \(domainPrefs)")
        //} else {
        //    print("No data found for domain: \(domainName)")
        //}
        
        tabbedTerminal = prefs.bool(forKey: "TabbedTerminal")
        btnQuickTabbedTerminal.state = tabbedTerminal ? .on : .off
        
        closeOnLaunch = prefs.bool(forKey: "CloseOnLaunch")
        btnCloseOnLaunch.state = closeOnLaunch ? .on : .off
        
        prefCheckForUpgrade = prefs.bool(forKey: "CheckForUpgradeAtStartup")
        btnCheckForUpgradePref.state = prefCheckForUpgrade ? .on : .off
        
        lastTabOpen = prefs.integer(forKey: "LastTabOpen")
        
        if let connections = prefs.array(forKey: "Connections") as? [[String: Any]] {
            arraySessions = connections
        } else {
            lastTabOpen = 1
        }
        
        strRegOwner = prefs.string(forKey: "RegOwner") ?? ""
        txtPrefsOwner.stringValue = strRegOwner
        strRegEmail = prefs.string(forKey: "RegEmail") ?? ""
        txtPrefsEmail.stringValue = strRegEmail
        strRegCode = prefs.string(forKey: "RegCode") ?? ""
        
        setupRegistrationUI()
        
        optOpenTabOnLaunch.selectCell(atRow: prefs.integer(forKey: "OpenTabOnLaunch"), column: 0)
        if prefs.integer(forKey: "OpenTabOnLaunch") > 0 {
            lastTabOpen = prefs.integer(forKey: "OpenTabOnLaunch") - 1
        }
        
        tabSessionsQuick.selectTabViewItem(at: lastTabOpen)
        tableSessionsList.doubleAction = #selector(btnSessionConnect(_:))
        btnQuickConnect.isEnabled = false
        btnQuickSaveSession.isEnabled = false
        tableSessionsList.reloadData()
        tableSessionsList.deselectAll(nil)
    }
    
    private func setupRegistrationUI() {
        if checkRegCode(regOwner: strRegOwner, regEmail: strRegEmail, regCode: strRegCode) {
            let labelText = strRegEmail.isEmpty ? "Registered to: \(strRegOwner)" : "Registered to: \(strRegOwner) (\(strRegEmail))"
            lblRegister.stringValue = labelText
            lblRegister.textColor = NSColor(calibratedRed: 0, green: 0, blue: 0, alpha: 0.5)
            txtPrefsCode.stringValue = "************************"
            winSshXGui.title = "sshXgui"
            btnRegistration.isEnabled = false
        } else {
            let attrStr = NSMutableAttributedString(string: "Unregistered!")
            let range = NSRange(location: 0, length: attrStr.length)
            attrStr.addAttribute(.font, value: NSFont(name: "Lucida Grande", size: 13)!, range: range)
            attrStr.addAttribute(.link, value: URL(string: "http://www.sshxgui.org/")!, range: range)
            attrStr.addAttribute(.foregroundColor, value: NSColor(calibratedRed: 0, green: 0, blue: 1, alpha: 0.9), range: range)
            lblRegister.attributedStringValue = attrStr
            winSshXGui.title = "sshXgui - Unregistered!"
            btnRegistration.isEnabled = true
        }
    }
}

// MARK: - NSTableViewDataSource & NSTableViewDelegate

extension SSHXGui: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == tableQuickForward {
            return arrayQuickForward.count
        } else if tableView == tableSessionsList {
            return arraySessions.count
        }
        return 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableView == tableQuickForward {
            return arrayQuickForward[row]
        } else if tableView == tableSessionsList {
            return arraySessions[row]["SessionName"]
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let tableView = notification.object as? NSTableView else { return }
        if tableView == tableSessionsList {
            let hasSelection = tableSessionsList.selectedRow > -1
            btnRemoveSession.isEnabled = hasSelection
            btnSessionConnect.isEnabled = hasSelection
            btnLoadQuickSession.isEnabled = hasSelection
        } else if tableView == tableQuickForward {
            btnQuickForwardRemove.isEnabled = tableQuickForward.selectedRow > -1
        }
    }
}

// MARK: - NSApplicationDelegate

extension SSHXGui: NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if prefCheckForUpgrade {
            checkForNewVersion(self)
        }
    }
}
