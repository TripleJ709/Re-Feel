//
//  AuthService.swift
//  ReFeel
//
//  Created by 장주진 on 2/5/26.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

enum AuthError: Error {
    case googleLoginFailed
    case appleLoginFailed
    case firebaseLinkFailed
    case unknown
}

final class AuthService: NSObject {
    static let shared = AuthService()
    
    fileprivate var currentNonce: String?
    private var linkCompletion: ((Result<User, Error>) -> Void)?
    private override init() {}
    
    func linkGoogle(presenting: UIViewController) -> AnyPublisher<User, Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
                if let error {
                    promise(.failure(error))
                    return
                }
                
                guard let user = result?.user,
                      let idToken = user.idToken?.tokenString else {
                    promise(.failure(AuthError.googleLoginFailed))
                    return
                }
                
                let accessToken = user.accessToken.tokenString
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                self.linkToFirebase(credential: credential, provider: "google", email: user.profile?.email, promise: promise)
            }
        }.eraseToAnyPublisher()
    }
    
    func linkApple(window: UIWindow) -> AnyPublisher<User, Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            
            let nonce = CryptoUtils.randomNonceString()
            self.currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = CryptoUtils.sha256(nonce)
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            
            self.linkCompletion = promise
            controller.performRequests()
        }.eraseToAnyPublisher()
    }
    
    private func linkToFirebase(credential: AuthCredential, provider: String, email: String?, promise: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().currentUser?.link(with: credential) { authResult, error in
            if let error {
                promise(.failure(error))
                return
            }
            
            guard let user = authResult?.user else {
                promise(.failure(AuthError.firebaseLinkFailed))
                return
            }
            
            let db = Firestore.firestore()
            let data: [String: Any] = [
                "provider": provider,
                "email": email ?? user.email ?? "비공개"
            ]
            db.collection("users").document(user.uid).setData(data, merge: true)
            promise(.success(user))
        }
    }
}

extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:

            guard let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                
                linkCompletion?(.failure(AuthError.appleLoginFailed))
                return
            }
            
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: nil
            )
            
            linkToFirebase(credential: credential,
                           provider: "apple",
                           email: appleIDCredential.email,
                           promise: linkCompletion!)
            
        default:
            linkCompletion?(.failure(AuthError.unknown))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        linkCompletion?(.failure(error))
    }
}
