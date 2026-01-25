//
//  SceneDelegate.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        window.rootViewController = LoginLoadingViewController()
        window.makeKeyAndVisible()
        
        checkLoginFlow()
    }
    
    private func checkLoginFlow() {
        if let user = Auth.auth().currentUser {
            print("기존 유저 - UID: \(user.uid)")
            changeRootToHome(userId: user.uid)
        } else {
            print("유저 정보 없음. 익명 로그인 시도")
            signInAnonymously()
        }
    }
    
    // MARK: - Todo: 로그인 실패시 재시도 버튼 만들기
    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            if let error {
                print("로그인 실패 \(error.localizedDescription)")
                return
            }
            
            if let user = authResult?.user {
                print("익명 로그인 성공 - UID: \(user.uid)")
                self?.changeRootToHome(userId: user.uid)
            }
        }
    }
    
    private func changeRootToHome(userId: String) {
        let repository = EmotionRepository(userId: userId)
        let transformer = GptEmotionTransformer()
        
        let homeViewModel = HomeViewModel(repository: repository, transformer: transformer)
        let homeVC = HomeViewController(viewModel: homeViewModel)
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "일기", image: UIImage(systemName: "book.fill"), tag: 0)
        
        let settingVC = SettingViewController()
        let settingNav = UINavigationController(rootViewController: settingVC)
        settingNav.tabBarItem = UITabBarItem(title: "설정", image: UIImage(systemName: "gearshape.fill"), tag: 1)
        
        let tabBarController = MainTabBarController()
        tabBarController.viewControllers = [homeNav, settingNav]
        
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarController
        }, completion: nil)
        
        
        
        
        
        
        
        
//        let repository = EmotionRepository(userId: userId)
//        let transformer = GptEmotionTransformer()
//        let homeViewModel = HomeViewModel(repository: repository, transformer: transformer)
//        let homeViewController = HomeViewController(viewModel: homeViewModel)
//        let nav = UINavigationController(rootViewController: homeViewController)
//        
//        guard let window = self.window else { return }
//        
//        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
//            window.rootViewController = nav
//        }, completion: nil)
    }
    
    
    // MARK: - secneDelegate기본 메서드
    func sceneDidDisconnect(_ scene: UIScene) {
    
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    
    }
    
    
}

