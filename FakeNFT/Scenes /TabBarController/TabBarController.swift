import UIKit

final class TabBarController: UITabBarController {
    
    private let servicesAssembly: ServicesAssembly
    
    init(servicesAssembly: ServicesAssembly) {
        self.servicesAssembly = servicesAssembly
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let profileTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.profile", comment: ""),
        image: UIImage(systemName: "person.crop.circle.fill"),
        tag: 0
    )
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 1
    )
  
    private lazy var cartAssembly = CartAssembly(
        servicesAssembly: servicesAssembly
    )
    
    private lazy var cartController: UINavigationController = {
        
        let cartVC = cartAssembly.build()
        
        let navController = UINavigationController(rootViewController: cartVC)
        navController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Tab.cart", comment: ""),
            image: UIImage(named: "tabIconCart"),
            selectedImage: nil
        )
        return navController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogController = TestCatalogViewController(
            servicesAssembly: servicesAssembly
        )
        
        let profileViewModel = ProfileViewModel(
            profileService: servicesAssembly.profileService,
            nftService: servicesAssembly.nftService
        )
        let profileController = ProfileViewController(viewModel: profileViewModel)
        let profileNavController = UINavigationController(rootViewController: profileController)
        profileController.tabBarItem = profileTabBarItem

        let catalogAssembly = CatalogAssembly(servicesAssembly: servicesAssembly)
        let catalogController = catalogAssembly.build()
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        viewControllers = [profileNavController, catalogNavigationController, cartController]
        
        view.backgroundColor = UIColor(resource: .appWhiteDynamic)
        tabBar.barTintColor = UIColor(resource: .appWhiteDynamic)
        tabBar.unselectedItemTintColor = UIColor(resource: .appBlackDynamic)
        tabBar.isTranslucent = false
    }
}
