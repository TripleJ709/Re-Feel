//
//  MainTabBarController.swift
//  ReFeel
//
//  Created by 장주진 on 1/25/26.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupTabs()
    }
    
    private func setupStyle() {
        tabBar.backgroundColor = .systemBackground
        tabBar.tintColor = .label
        tabBar.unselectedItemTintColor = .systemGray
    }
    
    // MARK: - todo: SceneDelegate에서 탭바 만들 때 VC들을 넣어서 보내주는 방식으로 우선 하는 중
    private func setupTabs() {
        
    }
}
