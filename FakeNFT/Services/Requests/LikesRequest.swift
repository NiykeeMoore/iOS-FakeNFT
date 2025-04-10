//
//  LikesRequest.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 10.04.2025.
//

import Foundation

struct LikesRequest: NetworkRequest {
    var dto: (any Dto)?
    let httpMethod: HttpMethod
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
}
