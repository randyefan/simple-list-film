//
//  EndPoint.swift
//  MNCPictures
//
//  Created by Randy Efan Jayaputra on 27/03/21.
//

import Foundation

protocol Endpoint {
    var baseUrl: String { get }
    var urlParameters: [URLQueryItem] { get }
}

extension Endpoint {
    var urlComponent: URLComponents {
        var urlComponent = URLComponents(string: baseUrl)
        urlComponent?.queryItems = urlParameters
        
        return urlComponent!
    }
    
    var request: URLRequest {
        return URLRequest(url: urlComponent.url!)
    }
}

enum KlaklikEndpoint: Endpoint {
    case listFilm(offset: Int, limit: Int)
    
    var baseUrl: String {
        return "https://dvl.klaklik.com/gateway/novel-list-detail/7"
    }
    
    var urlParameters: [URLQueryItem] {
        switch self {
        case .listFilm(let offset, let limit):
            return [
                URLQueryItem(name: "offset", value: String(offset)),
                URLQueryItem(name: "limit", value: String(limit)),
            ]
        }
    }
    
}
