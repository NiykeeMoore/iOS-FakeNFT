//
//  GetPaymentMethodsRequest.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

struct GetPaymentMethodsRequest: NetworkRequest {
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/currencies")
    }
    
    var httpMethod: HttpMethod { .get }
    typealias NetworkResponse = [PaymentMethod]
    var dto: (any Dto)?
}
