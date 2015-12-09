//
//  http.swift
//  SimpleRestServer
//
//  Created by Francis Dierick on 09/12/15.
//  Copyright © 2015 Francis Dierick. All rights reserved.
//
//  Liberally Inspired by https://github.com/huytd/swift-http
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public class REST {
    var   serverSocket : Int32 = 0
    var  serverAddress : sockaddr_in?
    var     bufferSize : Int = 1024
    
    func sockaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
        return UnsafeMutablePointer<sockaddr>(p)
    }
    
    func echo(socket: Int32, _ output: String) {
        output.withCString { (bytes) in
            send(socket, bytes, Int(strlen(bytes)), 0)
        }
    }
    
    init(port: UInt16) {
        #if os(Linux)
            serverSocket = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
        #else
            serverSocket = socket(AF_INET, Int32(SOCK_STREAM), 0)
        #endif
        if (serverSocket > 0) {
            print("Socket init: OK")
        }
        
        #if os(Linux)
            serverAddress = sockaddr_in(
                sin_family: sa_family_t(AF_INET),
                sin_port: port.htons(),
                sin_addr: in_addr(s_addr: in_addr_t(0)),
                sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
            )
        #else
            serverAddress = sockaddr_in(
                sin_len: __uint8_t(sizeof(sockaddr_in)),
                sin_family: sa_family_t(AF_INET),
                sin_port: port.htons(),
                sin_addr: in_addr(s_addr: in_addr_t(0)),
                sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
            )
        #endif
        
        setsockopt(serverSocket, SOL_SOCKET, SO_RCVBUF, &bufferSize, socklen_t(sizeof(Int)))
        
        let serverBind = bind(serverSocket, sockaddr_cast(&serverAddress), socklen_t(UInt8(sizeof(sockaddr_in))))
        if (serverBind >= 0) {
            print("Server started at port \(port)")
        }
    }
    
    func start() {
        while (true) {
            

            if (listen(serverSocket, 10) < 0) {
                exit(1)
            }
            
            let clientSocket = accept(serverSocket, nil, nil)
            if (clientSocket < 0) {
                break;
            }
            
            
            let f = fdopen(clientSocket, "a+")
            
            let myString : UnsafeMutablePointer<Int8> = UnsafeMutablePointer.alloc(100)
            fgets(myString, 100, f)
            
        
            let request:String? = String.fromCString(myString)
            
            var filePath:String
            var filePathWithoutRoot:String
            
            if let actualRequest = request {

                let chunks = actualRequest.componentsSeparatedByString(" ")
                if (3 == chunks.count) {
                    
                    if ("GET" == chunks[0]) {
                        
                        filePath = chunks[1]
                        filePathWithoutRoot = String(filePath.characters.dropFirst())
                        
                        
                    } else {
                        
                        break;
                        
                    }
                    
                    
                } else {
                    
                    break;
                    
                }
                
            } else {
             
                break;
                
            }
                
            let jsonString = readJSON(filePathWithoutRoot)
            let errorString = "Not Found"
            
            if (nil != jsonString) {
                
                let contentLength = jsonString!.utf8.count
                echo(clientSocket, "HTTP/1.1 200 OK\n")
                echo(clientSocket, "Server: Swift SimpleRESTServer\n")
                echo(clientSocket, "Content-length: \(contentLength)\n")
                echo(clientSocket, "Content-type: text-plain\n")
                echo(clientSocket, "\r\n")
                echo(clientSocket, jsonString!)
                
            } else {
                
                let contentLength = errorString.utf8.count
                echo(clientSocket, "HTTP/1.1 404 Not Found\n")
                echo(clientSocket, "Server: Swift SimpleRESTServer\n")
                echo(clientSocket, "Content-length: \(contentLength)\n")
                echo(clientSocket, "Content-type: text-plain\n")
                echo(clientSocket, "\r\n")
                echo(clientSocket, errorString)
                
            }
            
            close(clientSocket)

        }
    }
    
    

    
}


extension CUnsignedShort {
    func htons() -> CUnsignedShort { return (self << 8) + (self >> 8); }
}


/*
    READ JSON FROM STRING
*/
func readJSON (filepath:String ) -> String? {
    
    // Check if file exists at given file path
    if let dir : NSString = NSFileManager.defaultManager().currentDirectoryPath {
        let path = dir.stringByAppendingPathComponent(filepath);

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


/*
    VALIDATE JSON
    Using Foundation (NSData) instead of e.g. JSON CocoaPods to keep it simple.
    All we care about is if the JSON is valid or not.
*/
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

