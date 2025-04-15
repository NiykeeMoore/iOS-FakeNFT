final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    
    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
    }
    
    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    var likesService: LikesService {
        LikesService(networkClient: networkClient)
    }
    
    var orderService: OrderService {
        OrderService(networkClient: networkClient)
    }
}
