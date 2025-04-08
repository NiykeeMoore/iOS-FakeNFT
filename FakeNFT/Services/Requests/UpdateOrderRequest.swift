//
//  UpdateOrderRequest.swift
//  FakeNFT
//
//  Created by Niykee Moore on 08.04.2025.
//

import Foundation

struct UpdateOrderDto: Dto {
    let nfts: [String]
    
    func asDictionary() -> [String : String] {
        ["nfts": nfts.joined(separator: ",")]
    }
}

struct UpdateOrderRequest: NetworkRequest {
    var dto: Dto?
    
    init(nftIds: [String]) {
        self.dto = UpdateOrderDto(nfts: nftIds)
    }
    
    let orderId = "1"
    
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
    
    var httpMethod: HttpMethod = .put
}
