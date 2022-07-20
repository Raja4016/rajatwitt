//
//  TabbarVC.swift
//  Raja
//
//  Created by HTS-MAC on 11/06/22.
//

import UIKit

let ownUserDetatil: NSDictionary = UserDefaults.standard.value(forKey: "ownProfileDetatils") as! NSDictionary

class TabbarVC: UITabBarController {
    
    var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarSetup()
    }
    
    func tabBarSetup(){
        self.navigationController?.isNavigationBarHidden = true
        self.tabBar.backgroundColor = .white
        let edge = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.tabBarController?.navigationController?.navigationBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.delegate = self
        
        let homeObj = homePageVC()
        homeObj.tabBarItem = UITabBarItem.init(title: nil, image: #imageLiteral(resourceName: "home-unSel").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "home-sel").withRenderingMode(.alwaysOriginal))
        homeObj.tabBarItem.imageInsets = edge
        
        let search = ExploreVC()
        search.tabBarItem = UITabBarItem.init(title: nil, image: #imageLiteral(resourceName: "search-unSel").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "search-Sel").withRenderingMode(.alwaysOriginal))
        search.tabBarItem.imageInsets = edge
        
        let temp = homePageVC()
        temp.tabBarItem = UITabBarItem.init(title: nil, image: #imageLiteral(resourceName: "not").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "not").withRenderingMode(.alwaysOriginal))
        temp.tabBarItem.imageInsets = edge
        
        let temp1 = homePageVC()
        temp1.tabBarItem = UITabBarItem.init(title: nil, image: #imageLiteral(resourceName: "mail").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "mail").withRenderingMode(.alwaysOriginal))
        temp1.tabBarItem.imageInsets = edge
        self.viewControllers = [homeObj,search,temp,temp1]
    }
    
}

//MARK:- TabbarVC Delegate
extension TabbarVC: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex >= 2{
            self.selectedIndex = self.currentIndex
        } else{
            self.currentIndex = tabBarController.selectedIndex
        }
    }
}
