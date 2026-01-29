//
//  SettingViewModel.swift
//  ReFeel
//
//  Created by 장주진 on 1/29/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

// MARK: - TODO: APPLE로그인 추가할 땐 AuthService파일 따로 만들어서 관리하기(지금은 구글로그인 하나라 VM이 뚱뚱하지 않음)
final class SettingViewModel {
    @Published var isLoading: Bool = false
    @Published var alertMessage: String?
    
    let didLinkGoogleAccount = PassthroughSubject<Void, Never>()
    
    func linkGoogleAccount(presenting: UIViewController) {
        isLoading = true
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { [weak self] result, error in
            guard let self else { return }
            
            if let error {
                self.isLoading = false
                self.alertMessage = "구글 로그인 실패: \(error.localizedDescription)"
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.isLoading = false
                return
            }
            
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            Auth.auth().currentUser?.link(with: credential) { authResult, error in
                self.isLoading = false
                
                if let error {
                    self.alertMessage = "연동 실패: \(error.localizedDescription)"
                    return
                }
                
                if let user = authResult?.user, let email = user.email {
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).setData([
                        "email": email,
                        "provider": "google"
                    ], merge: true)
                }
                
                Auth.auth().currentUser?.reload { _ in
                    self.isLoading = false
                    self.didLinkGoogleAccount.send(())
                }
            }
        }
    }
    
    func checkCurrentProvider() -> String {
        guard let user = Auth.auth().currentUser else { return "로그인 안됨" }
        if user.isAnonymous {
            return "익명 로그인 사용자"
        } else {
            if let provider = user.providerData.first?.providerID, provider == "google.com" {
                return "Google 계정"
            }
            return "이메일 계정(없음)"
        }
    }
}
