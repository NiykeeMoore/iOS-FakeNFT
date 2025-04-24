//
//  GetOrderRequest.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

struct GetOrderRequest: NetworkRequest {
    var dto: (any Dto)? // не нужен
    
    let orderId = "1" // хардкод

    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/orders/\(orderId)")
    }
}
