//
//  SettingViewModel.swift
//  ReFeel
//
//  Created by 장주진 on 1/29/26.
//

import Foundation
import Combine
import FirebaseAuth
import UIKit
import FirebaseFirestore

final class SettingViewModel {
    @Published var isLoading: Bool = false
    @Published var alertMessage: String?
    @Published var isNotificationOn: Bool = false
    @Published var notificationTime: Date = Date()
    
    private let kIsNotificationOn = "isNotificationOn"
    private let kNotificationTime = "notificationTime"
    private var cancellables = Set<AnyCancellable>()
    
    let didLinkAccount = PassthroughSubject<Void, Never>()
    
    init() {
        loadNotificationSettings()
    }
    
    func linkGoogle(presenting: UIViewController) {
        isLoading = true
        
        AuthService.shared.linkGoogle(presenting: presenting)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.alertMessage = "구글 연동 실패: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] user in
                self?.didLinkAccount.send(())
            }
            .store(in: &cancellables)
    }
    
    func linkApple(window: UIWindow) {
        isLoading = true
        
        AuthService.shared.linkApple(window: window)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.alertMessage = "애플 연동 실패: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] user in
                self?.didLinkAccount.send(())
            }
            .store(in: &cancellables)
    }
    
    func checkCurrentProvider() -> String {
        guard let user = Auth.auth().currentUser else { return "로그인 안됨" }
        if user.isAnonymous {
            return "익명 로그인 사용자"
        } else {
            if let provider = user.providerData.first?.providerID {
                if provider == "google.com" { return "Google 계정" }
                if provider == "apple.com" { return "Apple 계정" }
            }
            return "이메일 계정(없음)"
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                    sceneDelegate.showLoginScreen()
                }
            }
        } catch {
            alertMessage = "로그아웃 실패: \(error.localizedDescription)"
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        isLoading = true
        
        Firestore.firestore().collection("users").document(user.uid).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error {
                print("Firestore 유저 문서 삭제 실패: \(error.localizedDescription)")
            }
            
            user.delete { [weak self] error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error {
                    let errCode = (error as NSError).code
                    if errCode == AuthErrorCode.requiresRecentLogin.rawValue {
                        self.alertMessage = "보안을 위해 다시 한 번 로그아웃 후 로그인한 뒤 탈퇴를 진행해주세요."
                    } else {
                        self.alertMessage = "회원 탈퇴 실패: \(error.localizedDescription)"
                    }
                } else {
                    self.alertMessage = "회원 탈퇴가 완료되었습니다. 이용해 주셔서 감사합니다."
                    DispatchQueue.main.async {
                        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                            sceneDelegate.showLoginScreen()
                        }
                    }
                }
            }
        }
    }
    
    private func loadNotificationSettings() {
        self.isNotificationOn = UserDefaults.standard.bool(forKey: kIsNotificationOn)
        
        if let savedTime = UserDefaults.standard.object(forKey: kNotificationTime) as? Date {
            self.notificationTime = savedTime
        } else {
            var components = DateComponents()
            components.hour = 21
            components.minute = 0
            self.notificationTime = Calendar.current.date(from: components) ?? Date()
        }
    }
    
    func toggleNotification(isOn: Bool) {
        isNotificationOn = isOn
        UserDefaults.standard.set(isOn, forKey: kIsNotificationOn)
        
        if isOn {
            NotificationManager.shared.requestAuthorization { [weak self] granted in
                guard let self else { return }
                if granted {
                    NotificationManager.shared.scheduleNotification(at: self.notificationTime)
                } else {
                    self.isNotificationOn = false
                    self.alertMessage = "알림 권한이 필요합니다. 설정 앱에서 권한을 허용해주세요."
                }
            }
        } else {
            NotificationManager.shared.removeNotification()
        }
    }
    
    func updateNotificationTime(date: Date) {
        notificationTime = date
        UserDefaults.standard.set(date, forKey: kNotificationTime)
        
        if isNotificationOn {
            NotificationManager.shared.scheduleNotification(at: date)
        }
    }
}
