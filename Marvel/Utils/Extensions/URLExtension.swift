//
//  URLExtension.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/5/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

extension URL{
    func URLByAppendingQueryParams(params:[String: Any])->URL{
        if var components=URLComponents(url: self, resolvingAgainstBaseURL: true){
            
            var queryItems=[URLQueryItem]()
            for (key, value) in params {
                let stringValue = "\(value)"
                let queryItem=URLQueryItem(name: key, value: stringValue)
                queryItems.append(queryItem)
            }
            components.queryItems=queryItems
            if let url=components.url{
                return url
            }
        }
        return self
    }
    
    static func fromString(urlString: String?) -> URL? {
        if urlString != nil {
            return URL(string: urlString!)
        }
        return nil
    }
}
