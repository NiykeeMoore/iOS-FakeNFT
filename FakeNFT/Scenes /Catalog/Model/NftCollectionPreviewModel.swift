//
//  NftCollectionPreviewModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 25.03.2025.
//

import Foundation

struct NftCollectionPreviewModel: Decodable {
    let nfts: [String]
    let name: String
    let cover: String
    var count: Int { nfts.count }
}
