//
//  LoginViewController.swift
//  ReFeel
//
//  Created by 장주진 on 2/21/26.
//

import UIKit
import Combine
import AuthenticationServices
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Re:Feel"
        label.font = .systemFont(ofSize: 40, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "당신의 감정을 기록하는 우주"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.textAlignment = .center
        return label
    }()
    
    // Apple Button
    private let appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        button.cornerRadius = 8
        return button
    }()
    
    // Google Button
    private let googleButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let googleIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "GoogleLogo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let googleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in with Google"
        label.textColor = .black
        label.font = .systemFont(ofSize: 19.5, weight: .medium)
        return label
    }()
    
    private lazy var googleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [googleIconImageView, googleTitleLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    private lazy var anonymousButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("비회원으로 시작하기", for: .normal)
        btn.setTitleColor(UIColor.white.withAlphaComponent(0.6), for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(anonymousTapped), for: .touchUpInside)
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 1) // 홈 화면과 비슷한 어두운 배경
        
        setupLayout()
        setupActions()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        view.addSubview(appleButton)
        view.addSubview(googleButtonView)
        googleButtonView.addSubview(googleStackView)
        
        view.addSubview(anonymousButton)
        view.addSubview(activityIndicator)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButtonView.translatesAutoresizingMaskIntoConstraints = false
        googleIconImageView.translatesAutoresizingMaskIntoConstraints = false
        googleStackView.translatesAutoresizingMaskIntoConstraints = false
        anonymousButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 140),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            appleButton.bottomAnchor.constraint(equalTo: googleButtonView.topAnchor, constant: -16),
            appleButton.heightAnchor.constraint(equalToConstant: 50),
            
            googleButtonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            googleButtonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            googleButtonView.bottomAnchor.constraint(equalTo: anonymousButton.topAnchor, constant: -30),
            googleButtonView.heightAnchor.constraint(equalToConstant: 50),
            
            googleIconImageView.widthAnchor.constraint(equalToConstant: 18),
            googleIconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            googleStackView.centerXAnchor.constraint(equalTo: googleButtonView.centerXAnchor),
            googleStackView.centerYAnchor.constraint(equalTo: googleButtonView.centerYAnchor),
            
            anonymousButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            anonymousButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -60),
            anonymousButton.heightAnchor.constraint(equalToConstant: 44),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        let googleTap = UITapGestureRecognizer(target: self, action: #selector(googleTapped))
        googleButtonView.addGestureRecognizer(googleTap)
        
        appleButton.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            activityIndicator.startAnimating()
            view.isUserInteractionEnabled = false
        } else {
            activityIndicator.stopAnimating()
            view.isUserInteractionEnabled = true
        }
    }
    
    @objc private func googleTapped() {
        showLoading(true)
        AuthService.shared.linkGoogle(presenting: self)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.showLoading(false)
                if case .failure(let error) = completion {
                    self?.showError(error)
                }
            } receiveValue: { [weak self] user in
                self?.navigateToHome(userId: user.uid)
            }
            .store(in: &cancellables)
    }
    
    @objc private func appleTapped() {
        guard let window = view.window else { return }
        showLoading(true)
        AuthService.shared.linkApple(window: window)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.showLoading(false)
                if case .failure(let error) = completion {
                    self?.showError(error)
                }
            } receiveValue: { [weak self] user in
                self?.navigateToHome(userId: user.uid)
            }
            .store(in: &cancellables)
    }
    
    @objc private func anonymousTapped() {
        showLoading(true)
        Auth.auth().signInAnonymously { [weak self] result, error in
            self?.showLoading(false)
            if let error = error {
                self?.showError(error)
                return
            }
            if let user = result?.user {
                self?.navigateToHome(userId: user.uid)
            }
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "로그인 실패", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func navigateToHome(userId: String) {
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.changeRootToHome(userId: userId)
        }
    }
}
