//
//  PerformPaymentRequest.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

struct PerformPaymentRequest: NetworkRequest {
    let currencyId: String

    var endpoint: URL? {
        guard let baseURL = URL(string: RequestConstants.baseURL) else {
            assertionFailure("Failed to create base URL")
            return nil
        }

        return baseURL.appendingPathComponent("api/v1/orders/1/payment/\(currencyId)")
    }

    var httpMethod: HttpMethod { .get }
    var dto: (any Dto)?
}
