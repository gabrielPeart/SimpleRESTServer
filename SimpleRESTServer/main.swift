//
//  main.swift
//  SimpleRestServer
//
//  Created by Francis Dierick on 09/12/15.
//  Copyright © 2015 Francis Dierick. All rights reserved.
//


import Foundation


#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

let environment = NSProcessInfo.processInfo().environment
var port = environment["PORT"]
if port == nil || port!.isEmpty {
    port = "8080"
}
let portInt = UInt16(port!)

let http = REST(port: portInt!)
http.start()