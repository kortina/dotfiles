#!/usr/bin/env xcrun swift

import Cocoa

var count = CommandLine.argc

print("Number of arguments is \(count)")
print("\(CommandLine.arguments)");

let app = NSWorkspace.sharedWorkspace().frontmostApplication
print("\(app.name)")


