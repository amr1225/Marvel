//
//  MVCharacter.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

class MVCharacter: NSObject {
    
    private static let hashPrefix = "Character"
    
    var id: Int
    var name: String
    var desc: String
    var modified: Date
    var resourceURI: URL
    var thumbnailURI: URL
    var comics: Resource
    
    override var hashValue: Int {
        return "\(MVCharacter.hashPrefix)\(id)\(name)".hashValue
    }
    
    init(id: Int, name: String, description: String, modified: Date, resourceURI: URL, thumbnailURI: URL, comics: Resource){
        self.id = id
        self.name = name
        self.desc = description
        self.modified = modified
        self.resourceURI = resourceURI
        self.thumbnailURI = thumbnailURI
        self.comics = comics
    }
    
    override var description: String{
        return self.name
    }
    
}

class MVCharacterMapper: MVBaseMapper<MVCharacter>{
    
    static let dataKey = "data"
    static let resultsKey = "results"
    
    static let idKey = "id"
    static let nameKey = "name"
    static let descriptionKey = "description"
    static let modifiedKey = "modified"
    static let resourceURIKey = "resourceURI"
    
    static let thumbnailKey = "thumbnail"
    static let pathKey = "path"
    static let extensionKey = "extension"
    
    static let comicsKey = "comics"
    
    override class func createObjectFrom(dictionary: Dictionary<String, Any> ) -> MVCharacter?{
        if let id = dictionary[idKey] as? Int{
            if let name =  dictionary[ nameKey ] as? String{
                if let description =  dictionary[ descriptionKey ] as? String{
                    
                    let modifiedString = dictionary[ modifiedKey ] as? String
                    let dateFormatter = Utilities.typeConversion.getDateFormatter(format: TypeConversionUtilities.ISO8601)
                    if let modified = Utilities.typeConversion.getDateFromString(dateString: modifiedString, dateFormatter: dateFormatter){
                        
                         let resourceURI = URL(fileURLWithPath: dictionary[resourceURIKey] as! String)
                            
                            if let thumbnailDict = dictionary[thumbnailKey] as? Dictionary<String, Any>{
                                if let thumbnailPath = thumbnailDict[pathKey] as? String{
                                    if let ext = thumbnailDict[extensionKey] as? String{
                                        let thumbnailURI =  URL(fileURLWithPath: thumbnailPath)
                                            let thumbnailURIWithExtension = thumbnailURI.appendingPathExtension(ext)
                                            
                                            if let comicsDict = dictionary[ comicsKey ]as? Dictionary<String, Any>{
                                                if let comics = MVResourceMapper.createObjectFrom(dictionary: comicsDict){
                                                    return MVCharacter(id: id, name: name, description: description, modified: modified, resourceURI: resourceURI, thumbnailURI: thumbnailURIWithExtension, comics: comics)
                                                }
                                            
                                            
                                        }
                                    }
                                }
                            
                            
                            
                        }
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
