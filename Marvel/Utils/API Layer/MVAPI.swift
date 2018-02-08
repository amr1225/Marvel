//
//  MVAPI.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/4/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation
import UIKit

class MVAPI {
    
    func getMultipleObjects<T>(request: URLRequest, mapperType: MVBaseMapper<T>.Type, completionHandler: @escaping (_ ok:Bool, _ objects:[T]?, _ error:Error?) -> Void) {
        URLSession.shared.dataTask(with: request as URLRequest) {
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
    
    
    func downloadImage(url: URL?, storageFilePaths: String, saveLocally: Bool = true, completionHandler: @escaping (_ image:UIImage?) -> Void){
        if(url != nil){
            let request = URLRequest(url: url! as URL)
            
            var image: UIImage?
            
        
            URLSession.shared.downloadTask(with: request, completionHandler: {
                (url: URL?, response: URLResponse?, error: Error?) -> Void in
                var data: Data? = nil
                if error == nil && url != nil {
                    data = try? Data(contentsOf: url!)
                    if (data != nil) {
                        if (saveLocally) {
                            //save user photo in the storage
                            Utilities.fileStorage.saveFile(data: data! as Data, path: storageFilePaths)
                        }
                        //create image
                        image = UIImage(data: data! as Data)
                        
                    }
                }
                completionHandler(image)
                
            }).resume()
    
        }
    }
    
    
}
