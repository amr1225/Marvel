//
//  MVRequest.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/4/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import UIKit


class MVRequest{
    
    typealias CompletionHandlerCharacters = (_ ok: Bool, _ objects: [MVCharacter]?, _ error: Error?) -> Void
    typealias CompletionHandlerComics = (_ ok: Bool, _ objects: [MVComic]?, _ error: Error?) -> Void
    
    
    private let privateKey: String
    private let publicKey: String
    private let baseUrl: String
    
    private static let apiKey = "apikey"
    private static let hashKey = "hash"
    private static let timestampKey = "ts"
    
    private static let limitKey = "limit"
    private static let offsetKey = "offset"
    
    private static let nameStartsWithKey = "nameStartsWith"
    
    init(baseUrl: String, privateKey: String, publicKey: String){
        self.baseUrl = baseUrl
        self.privateKey = privateKey
        self.publicKey = publicKey
    }
    
    func  getCharachterIndex(limit: Int, offset: Int, completionHandler: @escaping CompletionHandlerCharacters){
        var params = getDeafultParams()
        params[MVRequest.limitKey] = limit as Any
        params[MVRequest.offsetKey] = offset as Any
        
        if let url = URL(string:baseUrl+"characters")?.URLByAppendingQueryParams(params: params){
            let request =  URLRequest(url: url)
            MVAPI().getMultipleObjects(request: request, mapperType: MVCharacterMapper.self, completionHandler: completionHandler)
        }
        
    }
    
    func  getCharachterSearch(text: String, limit: Int, offset: Int, completionHandler: @escaping CompletionHandlerCharacters){
        var params = getDeafultParams()
        params[MVRequest.limitKey] = limit as Any
        params[MVRequest.offsetKey] = offset as Any
        params[MVRequest.nameStartsWithKey] = text as Any
        
        if let url = URL(string:baseUrl+"characters")?.URLByAppendingQueryParams(params: params){
            let request =  URLRequest(url: url)
            MVAPI().getMultipleObjects(request: request, mapperType: MVCharacterMapper.self, completionHandler: completionHandler)
        }
        
    }
    
    func  getComic(url: URL, completionHandler: @escaping CompletionHandlerComics){
        let request =  URLRequest(url: url.URLByAppendingQueryParams(params: getDeafultParams()))
        MVAPI().getMultipleObjects(request: request, mapperType: MVComicMapper.self, completionHandler: completionHandler)
    }
    
    
    static func getCharacterThumbnail(character: MVCharacter, saveLocally: Bool = true, completionHandler: @escaping (_ image:UIImage?) -> Void) -> UIImage? {
        
        let path = Config.StorageFilePaths.characterThumbnailPath(name: String(character.hashValue))
        let url = character.thumbnailURI
        
        if let image = ImageUtilities.getImage(path: path){ //get user photo from the storage if present
            return image
        }else{   //download user photo
            MVAPI().downloadImage(url: url as URL, storageFilePaths: path, saveLocally: saveLocally, completionHandler: completionHandler)
            return nil
        }
        
    }
    
    private func getDeafultParams() -> [String: Any]{
        let ts = Date().timeIntervalSince1970.description
        let hash = "\(ts)\(privateKey)\(publicKey)".md5()
        let params: [String: Any] = [MVRequest.apiKey: publicKey, MVRequest.hashKey: hash!, MVRequest.timestampKey:ts]
        return params
    }
    
    private func getMultipleObjects<T>(request: URLRequest, mapperType: MVBaseMapper<T>.Type, completionHandler: @escaping (_ ok:Bool, _ objects:[T]?, _ error:Error?) -> Void) {
        URLSession.shared.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            var objects: [T]?
            var ok = false
            
            if let dictionary = data?.toDictionary(){
                if let dataDict = mapperType.getRoot(dictionary: dictionary) as? Array<Any> {
                    objects = mapperType.createArrayFrom(dictionaryArray: dataDict)
                    ok = (objects != nil)
                }
            }
            
            completionHandler(ok, objects, error)
            }.resume()
    }
    
    private func downloadImage(url: URL?, storageFilePaths: String, saveLocally: Bool = true, completionHandler: @escaping (_ image:UIImage?) -> Void){
        if(url != nil){
            let request = URLRequest(url: url!)
            
            var image: UIImage?
            
            URLSession.shared.downloadTask(with: request, completionHandler: {
                (url: URL?, response: URLResponse?, error: Error?) -> Void in
                var data: Data? = nil
                if error == nil && url != nil {
                    data = try? Data(contentsOf: url!)
                    if (data != nil) {
                        if (saveLocally) {
                            //save user photo in the storage
                           
                            Utilities.fileStorage.saveFile(data: data!, path: storageFilePaths)
                        }
                        //create image
                        image = UIImage(data: data!)
                        
                    }
                }
                completionHandler(image)
                
                
                
            } ).resume()
            
            
        }
    }
    
}
