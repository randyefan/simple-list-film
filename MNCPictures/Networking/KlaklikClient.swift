//
//  KlaklikClient.swift
//  MNCPictures
//
//  Created by Randy Efan Jayaputra on 27/03/21.
//

import Foundation

class KlaklikClient: ClientAPI {
    func fetch(with endpoint: KlaklikEndpoint, completion: @escaping (Either<Results>) -> Void) {
        var request = endpoint.request
        request.httpMethod = "POST"
        get(with: request, completion: completion)
    }
}
