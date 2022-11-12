//
//  Model.swift
//  SwiftBetaDALLE
//
//  Created by Home on 10/11/22.
//

import Foundation

struct DataResponse: Decodable {
    let url: String
}

struct ModelResponse: Decodable {
    let data: [DataResponse]
}
