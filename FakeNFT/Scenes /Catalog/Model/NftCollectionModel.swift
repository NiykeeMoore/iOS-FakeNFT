//
//  NftCollectionModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import Foundation

struct NftCollectionModel: Decodable {
    let name: String
    let cover: String
    let nfts: [String]
    let id: String
    let description: String
    let author: String
    var count: Int {
        nfts.count
    }
}
