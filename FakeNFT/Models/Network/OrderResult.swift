//
//  OrderResult.swift
//  FakeNFT
//
//  Created by Niykee Moore on 31.03.2025.
//

import Foundation

// Модель для ответа от /api/v1/orders/1
struct OrderResult: Decodable {
    let nfts: [String]
    let id: String
}
