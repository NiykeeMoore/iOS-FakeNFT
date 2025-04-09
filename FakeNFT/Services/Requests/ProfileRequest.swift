import Foundation

struct ProfileRequest: NetworkRequest {
    let id: String
    let httpMethod: HttpMethod
    var endpoint: URL? {
        URL(string: "\(RequestConstants.baseURL)/api/v1/profile/\(id)")
    }
    var dto: Dto?
}

struct ProfileDtoObject: Dto {
    let name: String?
    let avatar: String?
    let description: String?
    let website: String?
    let nfts: [String]?
    let likes: [String]?
    
    func asDictionary() -> [String: String] {
        [
            "name": name ?? "",
            "avatar": avatar ?? "",
            "description": description ?? "",
            "website": website ?? "",
            "nfts": nfts?.joined(separator: ",") ?? "[]",
            "likes": likes?.joined(separator: ",") ?? "[]"
        ]
    }
}
