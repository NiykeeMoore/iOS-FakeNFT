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
    let avatar: String?
    let name: String?
    let description: String?
    let website: String?
    
    func asDictionary() -> [String: String] {
        [
            "avatar": avatar ?? "",
            "name": name ?? "",
            "description": description ?? "",
            "website": website ?? ""
        ]
    }
}
