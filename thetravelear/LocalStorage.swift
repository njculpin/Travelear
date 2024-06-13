//
//  LocalStorage.swift
//  Travelear
//
//  Created by Nicholas Culpin on 9/4/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import Foundation

final class LocalStorageManager {
    
    static func isLocal(_ file:String)->Bool {
        let url = URL(string: file)
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent((url?.lastPathComponent)!)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            return true
        }
        return false
    }
    
    static func localFilePathForUrl(_ file: URL) -> URL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let fullPath = documentsPath.appendingPathComponent(file.lastPathComponent)
        return URL(fileURLWithPath: fullPath)
    }
    
}
