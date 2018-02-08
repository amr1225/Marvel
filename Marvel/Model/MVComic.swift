//
//  MVComic.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

struct MVComic{
    var id: Int
    var thumbnailURI: URL
}
func ==(a: MVComic, b: MVComic) -> Bool {
    return a.hashValue == b.hashValue
}
extension MVComic: Hashable{
    
    private static let hashPrefix = "Comic"
    var hashValue: Int {
        return "\(MVComic.hashPrefix)\(id)".hashValue
    }
}

class MVComicMapper: MVBaseMapper<MVComic>{
    
    private static let dataKey = "data"
    private static let resultsKey = "results"
    private static let idKey = "id"
    private static let thumbnailKey = "thumbnail"
    private static let pathKey = "path"
    private static let extensionKey = "extension"
    
    override class func createObjectFrom(dictionary: Dictionary<String, Any> ) -> MVComic?{
        
        if let id = dictionary[idKey] as? Int{
            if let thumbnailDict = dictionary[thumbnailKey] as? Dictionary<String, Any>{
                if let thumbnailPath = thumbnailDict[pathKey] as? String{
                    if let ext = thumbnailDict[extensionKey] as? String{
                        
                        let thumbnailURI =
                            URL(fileURLWithPath: thumbnailPath)
                        let thumbnailURIWithExtension = thumbnailURI.appendingPathExtension(ext)
                            return MVComic(id: id, thumbnailURI: thumbnailURIWithExtension)
                
                    }
                }
            }
        }
        
        return super.createObjectFrom(dictionary: dictionary)
    }
    
    override class func getRoot(dictionary: Dictionary<String, Any> ) -> Any?{
        if let dataDict = dictionary[dataKey]  as? Dictionary<String, Any>{
            if let arrayDict = dataDict[resultsKey] as? Array<Any> {
                return arrayDict
            }
        }
        return super.getRoot(dictionary: dictionary)
    }
}
