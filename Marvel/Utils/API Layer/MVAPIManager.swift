//
//  MVAPIManager.swift
//  Marvel
//
//  Created by Amr Mohamed on 2/4/18.
//  Copyright © 2018 Amr Mohamed. All rights reserved.
//

import Foundation

struct MVApiManager{
    static let request = MVRequest(baseUrl: Config.baseUrl, privateKey: Config.Keys.marvelPrivate, publicKey: Config.Keys.marvelPublic)
}
