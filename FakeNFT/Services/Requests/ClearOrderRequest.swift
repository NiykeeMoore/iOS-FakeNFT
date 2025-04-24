//
//  ClearOrderRequest.swift
//  FakeNFT
//
//  Created by Niykee Moore on 24.04.2025.
//

import Foundation

struct ClearOrderRequest: NetworkRequest {
    let orderId = "1"

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
    
    var httpMethod: HttpMethod = .put
    
    var dto: (any Dto)?
}
