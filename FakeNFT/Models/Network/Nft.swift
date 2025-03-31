import Foundation

struct Nft: Decodable {
    let id: String
    let images: [URL]
    let rating: Int
    let description: String
    let price: Float
    let author: String
    let name: String
}
