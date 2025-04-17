//
//  ProfileModel.swift
//  FakeNFT
//
//  Created by Никита Соловьев on 11.04.2025.
//

import Foundation

struct Profile: Decodable {
    let name: String
    let avatar: String
    let description: String
    let website: String
    let nfts: [String]
    let likes: [String]
    let id: String
}
