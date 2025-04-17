//
//  ProfileNFT.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 06.04.2025.
//

struct ProfileNFT: Codable {
    let createdAt: String
    let name: String
    let images: [String]
    let rating: Int
    let description: String
    let price: Double
    let author: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case createdAt
        case name
        case images
        case rating
        case description
        case price
        case author
        case id
    }
    
    var formattedPrice: String {
        return String(format: "%.2f", price)
            .replacingOccurrences(of: ".", with: ",") + " ETH"
    }
}
