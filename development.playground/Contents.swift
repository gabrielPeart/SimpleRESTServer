//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

func readJSON (filepath:String ) -> String? {
    
    // Check if file exists at given file path
    if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
        let path = dir.stringByAppendingPathComponent(filepath);
        print(path)
        do {
            let text = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
            
            let validJson = validateJSON(text as String)
            if (validJson) {
                // All good, return JSON as String
                return text as String
            } else {
                // File contains no valid JSON
                return nil
            }
            
        }
        catch {
            // File cannot be read
            return nil
        }
    } else {
        // File does not exist
        return nil
    }
    
}


func validateJSON(jsonString: String) -> Bool {
    
    
    let jsonData: NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding)!
    
    do {
        // Use _ because we don't actually care about the result, just that it's valid JSON
        _ = try NSJSONSerialization.JSONObjectWithData(jsonData, options: []) as! [String:AnyObject]
        return true
        
    } catch {
        
        // Invalid JSON
        return false
        
    }
    
    
}



let good = readJSON("sub/file.json")
let bad = readJSON("badfile.json")

NSFileManager.defaultManager().currentDirectoryPath





