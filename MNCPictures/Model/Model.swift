//
//  Model.swift
//  MNCPictures
//
//  Created by Randy Efan Jayaputra on 26/03/21.
//

import Foundation

typealias Contents = [Content]

struct Results: Codable {
    let DATA: [Isi]
}

struct Isi: Codable {
    let total: Int
    let content: [Content]
}

struct Content: Codable {
    let thumbnail: URL
    let title: String
    let view: String
}
