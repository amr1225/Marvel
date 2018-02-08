//
//  DataExtension.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

extension Data {
    func toDictionary() -> [String: Any]? {
        let jsonError: NSError?
        do{
            if let dict = try JSONSerialization.jsonObject(with: self, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, Any> {
                return dict
            }
        }catch let error as NSError {
            jsonError = error
            print(jsonError as Any)
        }
        return nil
    }
}
