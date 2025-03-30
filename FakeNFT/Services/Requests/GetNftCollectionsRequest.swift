//
//  GetNftCollectionsRequest.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 26.03.2025.
//

import Foundation

struct GetNftCollectionsRequest: NetworkRequest {
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/collections")
    }
    var httpMethod: HttpMethod = .get
    var dto: Encodable?
    var httpBody: String?
}
