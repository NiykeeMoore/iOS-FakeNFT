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
    
    private let catalogTabBarItem = UITabBarItem(
        title: NSLocalizedString("Tab.catalog", comment: ""),
        image: UIImage(systemName: "square.stack.3d.up.fill"),
        tag: 0
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
        
        viewControllers = [catalogController, cartController]
        
        tabBar.unselectedItemTintColor = UIColor(named: "appBlackDynamic")
    }
}
