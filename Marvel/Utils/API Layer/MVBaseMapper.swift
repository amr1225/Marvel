//
//  MVBaseMapper.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/4/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

protocol Mapper {
    associatedtype T
    static func createObjectFrom(dictionary: Dictionary<String, Any> ) -> T?
    static func createArrayFrom(dictionaryArray: Array<Any> ) -> [T]?
    static func createDictionaryFrom(object: T) -> Dictionary<String, Any>
}

class MVBaseMapper<T>: Mapper {
    
    class func getRoot(dictionary: Dictionary<String, Any> ) -> Any?{
        return nil
    }
    
    class func createObjectFrom(dictionary: Dictionary<String, Any> ) -> T?{
        return nil
    }
    
    class func createArrayFrom(dictionaryArray: Array<Any> ) -> [T]?{
        var resultArray = [T]()
        
        for raw in dictionaryArray {
            var object : T?
            if let dict = raw as? Dictionary<String, Any> {
                object = createObjectFrom(dictionary: dict)
            }
            
            if object != nil {
                resultArray.append(object!)
            }
            else {
                return nil
            }
        }
        
        return resultArray
    }
    
    class func createDictionaryFrom(object: T) -> Dictionary<String, Any>{
        return [:]
    }
    
    class func createDictionaryArrayFrom(objects: [T]) -> [Dictionary<String, Any>]{
        var dictionaryArray = [Dictionary<String, Any>]()
        for object in objects{
            dictionaryArray.append(createDictionaryFrom(object: object))
        }
        return dictionaryArray
    }
    
}
