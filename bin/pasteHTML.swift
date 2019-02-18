import Cocoa
let type = NSPasteboard.PasteboardType.html
if let string = NSPasteboard.general.string(forType:type) {
  print(string)
}
else {
  print("Could not find string data of type '\(type)' on the system pasteboard")
  exit(1)
}