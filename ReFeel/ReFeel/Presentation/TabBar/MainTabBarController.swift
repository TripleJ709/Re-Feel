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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 탭바 선과 그림자를 제거하여 투명하게 유지
        tabBar.layer.shadowOpacity = 0
        tabBar.layer.borderWidth = 0
    }
    
    // MARK: - TODO: 탭바 사용하면 배경 색이 바뀜
    private func setupStyle() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = .clear
        
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = .white
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold)
        ]
        
        itemAppearance.normal.iconColor = .systemGray
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.isTranslucent = true
    }
    
    // MARK: - todo: SceneDelegate에서 탭바 만들 때 VC들을 넣어서 보내주는 방식으로 우선 하는 중
    private func setupTabs() {
        
    }
}
