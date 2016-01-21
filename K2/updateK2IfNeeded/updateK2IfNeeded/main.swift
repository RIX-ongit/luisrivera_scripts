#!/usr/bin/env xcrun swift

//  updateK2IfNeeded
//  Created by Luis Rivera on 1/21/16.
//  This script should receive the following parameter
//  $4 - The current version of K2 available

import Foundation

let currentVersion = Process.arguments[Process.arguments.count - 1]
let plistPath = "/Library/KeyAccess/KeyAccess.app/Contents/Info.plist"

let task = NSTask()
task.launchPath = "/usr/local/bin/jamf"
task.arguments = ["policy", "-event", "needsK2"]

if NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
    print("Found \(plistPath)")
    
    if let plistData = NSDictionary(contentsOfFile: plistPath) {
        let installedVersion = String(plistData["CFBundleShortVersionString"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        print("Version \(installedVersion) is installed.")
        print("Checking against \(currentVersion).")
        if currentVersion.compare(installedVersion, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending {
            print("An update is required.")
            task.launch()
        }
        else {
            print("An update is not required.")
        }
    }
    else {
        print("Error: Check \(plistPath) for errors!")
        exit(1)
    }
}
else {
    print("K2 is not installed")
    task.launch()
}

exit(0)
