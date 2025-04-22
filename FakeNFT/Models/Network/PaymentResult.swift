//
//  PaymentResult.swift
//  FakeNFT
//
//  Created by Niykee Moore on 20.04.2025.
//

import Foundation

struct PaymentResult: Decodable {
    let success: Bool
    let orderId: String
    let id: String
}
