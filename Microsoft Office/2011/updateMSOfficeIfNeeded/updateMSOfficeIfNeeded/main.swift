//
//  main.swift
//  updateMSOfficeIfNeeded
//
//  Created by Luis Rivera on 1/5/16.
//
//  Uncomment the next line for this to work in JAMF
//  #!/usr/bin/env xcrun swift

import Foundation

/* This script checks to see if the currently installed version of Microsoft Office is current with the environment. It grabs $4 and $5 from the JSS.
    $4 - Should be either 2011 or 2016 depending on what version of Office you want to update.
    $5 - Should be the current version of Office, i.e. 14.5.9.
*/

// Checking to make sure 5 arguments were passed. Error if not.
if Process.arguments.count < 5 {
    print("Error: Not enough arguments were passed!")
    exit(1)
}

// Checking to see which Office should be updated. It should be either 2011 or 2016. Error if not.
let officeYear = Process.arguments[4]
switch officeYear {
    case "2011":
        print("Looking to update Microsoft Office 2011")
    case "2016":
        print("Looking to update Microsoft Office 2016")
    default:
        print("Error: Please enter either 2011 or 2016 for $4! You entered \(Process.arguments[4])")
        exit(1)
}

// Checking $5 for the current version of Office in the enviornment. Error if not.
let currentOfficeVersion = Process.arguments[5] + ".0"
print("The current version of Microsoft Office \(officeYear) is \(currentOfficeVersion)")
// Splitting the version into comparable number strings.
let splitCurrentOfficeVersion = currentOfficeVersion.componentsSeparatedByString(".")
if splitCurrentOfficeVersion.count < 2 {
    print("Error: The current version of Office should be given in the form X.Y.Z. You gave \(currentOfficeVersion)")
    exit(1)
}

// Checking to see which version of Office is installed. This will fail is no Office is installed at all.
print("Checking the installed version of Microsoft Office \(officeYear)")
let task = NSTask()
task.launchPath = "/usr/bin/defaults"
task.arguments = ["read"]

// Need to check different places for the version number depending on which Office year is to be updated.
if officeYear == "2011" {
    task.arguments?.append("/Applications/Microsoft Office 2011/Office/MicrosoftComponentPlugin.framework/Versions/14/Resources/Info")
    task.arguments?.append("CFBundleShortVersionString")
}
else if officeYear == "2016" {
    task.arguments?.append("/Applications/Microsoft Word.app/Contents/Info.plist")
    task.arguments?.append("CFBundleShortVersionString")
}

// Creating a place for the output of the version check to go.
let pipe = NSPipe()
task.standardOutput = pipe
task.launch()
// Grabbing the output of the version check.
let data = pipe.fileHandleForReading.readDataToEndOfFile()
let installedOfficeVersion = NSString(data: data, encoding: NSUTF8StringEncoding)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) + ".0"
if installedOfficeVersion == ".0" {
    print("Microsoft Office is not installed on this computer.")
    exit(0)
}
print("Microsoft Office \(officeYear) \(installedOfficeVersion) is installed.")
// Splitting the version into comparable number strings.
var splitInstalledOfficeVersion = installedOfficeVersion.componentsSeparatedByString(".")

// Take those split up strings and convert them to numbers
var numCurrentOfficeVersion = [Int]()
var numInstalledOfficeVersion = [Int]()
for index in 0..<splitCurrentOfficeVersion.count {
    numCurrentOfficeVersion.append(Int(splitCurrentOfficeVersion[index])!)
}
for index in 0..<splitInstalledOfficeVersion.count {
    numInstalledOfficeVersion.append(Int(splitInstalledOfficeVersion[index])!)
}

// Now we can compare the current and installed versions of Office.
var needsUpdate = false
// If the current major version is newer than the installed major version, needsUpdate = true.
if numCurrentOfficeVersion[0] > numInstalledOfficeVersion[0] {
    needsUpdate = true
    print("Office needs a major update.")
}
// If the major versions match but the current minor version is newer, needsUpdate = true.
else if numCurrentOfficeVersion[0] == numInstalledOfficeVersion[0] && numCurrentOfficeVersion[1] > numInstalledOfficeVersion[1] {
    needsUpdate = true
    print("Office needs a minor update.")
}
// If the major and minor versions match but the current patch is newer, needsUpdate = true.
else if numCurrentOfficeVersion[0] == numInstalledOfficeVersion[0] && numCurrentOfficeVersion[1] == numInstalledOfficeVersion[1] && numCurrentOfficeVersion[2] > numInstalledOfficeVersion[2] {
    needsUpdate = true
    print("Office needs a patch.")
}

// Runs JAMF policy specifically to update Office if an update is needed.
if needsUpdate {
    print("Office \(officeYear) \(installedOfficeVersion) should be updated to \(currentOfficeVersion)")
    let jamf = NSTask()
    jamf.launchPath = "/usr/local/bin/jamf"
    jamf.arguments = ["policy","-event","needsOffice\(officeYear)Update"]
    let pipe2 = NSPipe()
    jamf.standardOutput = pipe2
    jamf.launch()
    let data2 = pipe2.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data2, encoding: NSUTF8StringEncoding)!
    print(output)
}
else {
    print("Office \(officeYear) \(installedOfficeVersion) does not need an update.")
}

exit(0)