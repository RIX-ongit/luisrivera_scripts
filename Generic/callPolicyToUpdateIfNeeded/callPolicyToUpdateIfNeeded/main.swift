#!/usr/bin/env xcrun swift

//  callPolicyToUpdateIfNeeded
//  Created by Luis Rivera on 1/8/16.
//  This script should receive the following parameters
//  $4 - The name of the Application to be checked, i.e. Firefox
//      It is assumed that the App is in /Applications
//  $5 - The current version of the Application available

import Foundation

let app = Process.arguments[Process.arguments.count - 2]
let currentVersion = Process.arguments[Process.arguments.count - 1]
let plistPath = "/Applications/\(app).app/Contents/Info.plist"

if NSFileManager.defaultManager().fileExistsAtPath(plistPath) {
    print("Found \(plistPath)")
        
    if let plistData = NSDictionary(contentsOfFile: plistPath) {
        let installedVersion = String(plistData["CFBundleShortVersionString"]!).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        print("Version \(installedVersion) is installed.")
        print("Checking against \(currentVersion).")
        if currentVersion.compare(installedVersion, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending {
            print("An update is required.")
            let task = NSTask()
            task.launchPath = "/usr/local/bin/jamf"
            task.arguments = ["policy", "-event", "needs\(app)Update"]
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
    print("Error: \(plistPath) does not exist!")
    exit(1)
}

exit(0)
