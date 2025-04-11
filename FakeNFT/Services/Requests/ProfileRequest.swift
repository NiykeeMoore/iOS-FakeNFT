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
        var result = [:] as [String: String]
        
        if let name {
            result["name"] = name
        }
        if let avatar {
            result["avatar"] = avatar
        }
        if let description {
            result["description"] = description
        }
        if let website {
            result["website"] = website
        }
        if let likes {
            result["likes"] = likes.isEmpty ? nil : likes.joined(separator: ",")
        }
        
        return result
    }
}
