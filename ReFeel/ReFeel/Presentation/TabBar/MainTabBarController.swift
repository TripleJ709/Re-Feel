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
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.16, alpha: 0.95)
        appearance.shadowColor = nil
        appearance.shadowImage = nil
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = .white
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        tabBar.tintColor = .white
    }
    
    // MARK: - todo: SceneDelegate에서 탭바 만들 때 VC들을 넣어서 보내주는 방식으로 우선 하는 중
    private func setupTabs() {
        
    }
}
