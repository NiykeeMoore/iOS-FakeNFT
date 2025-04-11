//
//  LikesRequest.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 10.04.2025.
//

import Foundation

struct LikesRequest: NetworkRequest {
    let httpMethod: HttpMethod
    let dto: (any Dto)?
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/1")
    }
    
    init(httpMethod: HttpMethod, nftsIds: [String]? = nil) {
        self.httpMethod = httpMethod
        self.dto = (nftsIds != nil && !nftsIds!.isEmpty)
        ? LikesRequestDto(nftsIds: nftsIds!)
        : nil
    }
}

struct LikesRequestDto: Dto {
    let nftsIds: [String]
    
    func asDictionary() -> [String: String] {
        let nftsString = nftsIds.joined(separator: ",")
        return ["nfts": nftsString]
    }
}
