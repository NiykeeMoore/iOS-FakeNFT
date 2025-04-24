//
//  ProfileDataModel.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 27.03.2025.
//

import Foundation

struct ProfileData: Codable {
    var id: String?
    var avatar: String?
    var name: String?
    var description: String?
    var website: String?
    var nfts: [String]?
    var likes: [String]?
}
