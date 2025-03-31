//
//  NftCollectionModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import Foundation

struct NftCollectionModel: Decodable {
    let id: String
    let nfts: [String]
    let name: String
    let cover: String
    let author: String
    let description: String
    var count: Int { nfts.count }
}
