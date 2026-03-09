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
        
        //try? Auth.auth().signOut() // 로그인관련 테스트 로그아웃 코드

        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        let loadingVC = LoginLoadingViewController()
        loadingVC.onRetryButtonTapped = { [weak self] in
            print("로그인 재시도 버튼 탭")
            self?.checkLoginFlow()
        }
        window.rootViewController = loadingVC
        window.makeKeyAndVisible()
        
        checkLoginFlow()
    }
    
    func restartLoginFlow() {
        let loadingVC = LoginLoadingViewController()
        loadingVC.onRetryButtonTapped = { [weak self] in
            self?.checkLoginFlow()
        }
        guard let window = self.window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = loadingVC
        }, completion: { [weak self] _ in
            self?.checkLoginFlow()
        })
    }
    
    private func checkLoginFlow() {
        if let user = Auth.auth().currentUser {
            print("기존 유저 - UID: \(user.uid)")
            
            user.reload { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    let errCode = (error as NSError).code
                    
                    if errCode == AuthErrorCode.userNotFound.rawValue || errCode == AuthErrorCode.userTokenExpired.rawValue {
                        print("유저가 삭제되었거나 만료됨. 강제 로그아웃 후 익명 로그인 재시도")
                        try? Auth.auth().signOut()
                        self.signInAnonymously()
                    } else {
                        print("유저 갱신 실패 (기타 에러): \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.changeRootToHome(userId: user.uid)
                        }
                    }
                } else {
                    print("유저 상태 갱신 성공 (정상 유저)")
                    DispatchQueue.main.async {
                        self.changeRootToHome(userId: user.uid)
                    }
                }
            }
        } else {
            print("유저 정보 없음 (첫 진입 등). 익명 로그인 시도")
            signInAnonymously()
        }
    }
    
    func showLoginScreen() {
        DispatchQueue.main.async {
            guard let window = self.window else { return }
            let loginVC = LoginViewController()
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.rootViewController = loginVC
            }, completion: nil)
        }
    }

    private func signInAnonymously() {
        Auth.auth().signInAnonymously { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                print("로그인 실패 \(error.localizedDescription)")
                DispatchQueue.main.async {
                    if let loadingVC = self.window?.rootViewController as? LoginLoadingViewController {
                        loadingVC.showFailureState(errorDescription: error.localizedDescription)
                    }
                }
                return
            }
            
            if let user = authResult?.user {
                print("익명 로그인 성공 - UID: \(user.uid)")
                DispatchQueue.main.async {
                    self.changeRootToHome(userId: user.uid)
                }
            }
        }
    }
    
    func changeRootToHome(userId: String) {
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

