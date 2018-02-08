//
//  Utils.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/4/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation
import UIKit

struct Utilities {
    static let typeConversion = TypeConversionUtilities()
    static let queues = QueueUtilities()
    static let fileStorage = FileStorageUtilities()
}

struct TypeConversionUtilities{
    
    private var dateFormatter = DateFormatter()
    
    static let ISO8601 = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    
    func getDateFormatter(format: String = "yyyy-MM-dd HH:mm:ss")->DateFormatter{
        dateFormatter.dateFormat = format
        return dateFormatter
    }
    
    func getDateFromString(dateString: String?, dateFormatter: DateFormatter) -> Date? {
        if dateString != nil {
            return dateFormatter.date(from: dateString!)
        }
        return nil
    }
    
}

class QueueUtilities {
    let asyncQueue: OperationQueue
    init() {
        self.asyncQueue = OperationQueue()
        self.asyncQueue.name = "Async"
    }
}

class CommonUtilities {
    static func getStringFromMainBundle(key: String) -> String? {
        if let infoPlist = Bundle.main.infoDictionary {
            if let apiURL = infoPlist[key] as? String {
                return apiURL
            }
        }
        return nil
    }
    static func getStringFromBundle(filename: String, key: String) -> String? {
        if let path = Bundle.main.path(forResource: filename, ofType: "plist"){
            
            if let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
                if let value = dict[key] as? String {
                    return value
                }
            }
        }
        
        return nil
    }
}


struct ImageUtilities {
    static func getImage(path: String)->UIImage?{
        var image: UIImage?
        if let imageData = Utilities.fileStorage.getFile(path: path) {
            image = UIImage(data: imageData as Data)
        }
        return image
    }
}

class FileStorageUtilities {
    
    static let storageBasePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
    
    @discardableResult func saveFile(data: Data, path: String) -> Bool {
        let fileManager = FileManager.default
        
        do {
            //create a direcory
            let directory = (path as NSString).deletingLastPathComponent
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        } 
        return fileManager.createFile(atPath: path, contents: data as Data, attributes: nil)
    }
    
    func getFile(path: String) -> Data? {
        let url = URL(fileURLWithPath: path)
        let data = try? Data(contentsOf: url)
        return data
    }
    
    func fileExists(path: String) -> Bool {
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }
    
    func removeFile(path: String) -> Bool {
        var ok = false
        let fileManager = FileManager.default
        do {
            //create a direcory
            try fileManager.removeItem(atPath: path)
            ok = true
        } catch  {
            
        } 
        return ok
    }
    
    
     @discardableResult func removeDirectoryContent(path: String) -> Bool {
        
        
        var ok = false
        let fileManager = FileManager.default
        
        
        do {
            //create a direcory
            let filelist = try fileManager.contentsOfDirectory(atPath: path)
            if filelist.count == 0 {
                ok = true
            } else {
                for filename in filelist {
                    let filePath = Config.StorageFilePaths.fileWithBasePath(file: filename, basePath: path)
                    ok = true && self.removeFile(path: filePath)
                }
            }
        } catch let error {
            print(error)
        }
        return ok
    }
    
}
