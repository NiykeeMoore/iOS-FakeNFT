//
//  NftCollectionCellModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 03.04.2025.
//

import Foundation

struct NftCollectionCellModel {
    let image: URL
    let name: String
    let rating: Int
    let price: Double
    let isLiked: Bool
    var isAddedToCart: Bool
    var id: String
}
