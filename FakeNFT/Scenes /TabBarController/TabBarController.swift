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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let catalogAssembly = CatalogAssembly(servicesAssembly: servicesAssembly)
        let catalogController = catalogAssembly.build()
        let catalogNavigationController = UINavigationController(rootViewController: catalogController)
        catalogNavigationController.tabBarItem = catalogTabBarItem
        
        
        viewControllers = [catalogNavigationController]
        
        view.backgroundColor = UIColor(named: "appWhiteDynamic")
        tabBar.barTintColor = UIColor(named: "appWhiteDynamic")
        tabBar.unselectedItemTintColor = UIColor(named: "appBlackDynamic")
        tabBar.isTranslucent = false
    }
}
