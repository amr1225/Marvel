//
//  MVResource.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

struct Resource{
    var available: Int
    var returned: Int
    var collectionURI: URL
    var items: [MVItem]
}

class MVResourceMapper: MVBaseMapper<Resource>{
    
    private static let returnedKey = "returned"
    private static let availableKey = "available"
    private static let collectionURIKey = "collectionURI"
    private static let itemsKey = "items"
    
    override class func createObjectFrom(dictionary: Dictionary<String, Any> ) -> Resource?{
        
        if let available = dictionary[availableKey] as? Int{
            if let returned =  dictionary[ returnedKey ] as? Int{
                 let collectionURI =  URL(fileURLWithPath: collectionURIKey)
               
                    if let itemsDictionaryArray =  dictionary[itemsKey] as? Array<Any>{
                        var items = [MVItem]()
                        for raw in itemsDictionaryArray{
                            if let itemDict = raw as? Dictionary<String, Any>{
                                if let item = MVItemMapper.createObjectFrom(dictionary: itemDict){
                                    items.append(item)
                                }
                            }
                        }
                        return Resource(available: available, returned: returned, collectionURI: collectionURI, items: items)
                    }
                
            }
        }
        
        return super.createObjectFrom(dictionary: dictionary)
    }
}
