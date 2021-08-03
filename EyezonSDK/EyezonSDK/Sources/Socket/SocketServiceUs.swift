//
//  SocketServiceUs.swift
//  EyezonSDK
//
//  Created by Denis Borodavchenko on 04.08.2021.
//

import Foundation

final class SocketServiceUs: BaseSocketServiceImpl {
    static let instance = SocketServiceUs()
    
    private override init() { }
    
    override func makeBaseUrl() -> URL {
        return URL(string: UrlConstants.RELEASE_BASE_URL_US)!
    }
}
