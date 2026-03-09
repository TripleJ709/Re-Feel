//
//  LoginLoadingViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/21/26.
//

import UIKit

final class LoginLoadingViewController: UIViewController {
    var onRetryButtonTapped: (() -> Void)?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.startAnimating()
        return indicator
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "접속 중입니다..."
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var retryButton: UIButton = {
        let btn = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "다시 시도"
        config.image = UIImage(systemName: "arrow.clockwise")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(red: 0.48, green: 0.38, blue: 0.93, alpha: 1) // #7C61ED
        config.baseForegroundColor = .white
        
        btn.configuration = config
        btn.isHidden = true 
        btn.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(activityIndicator)
        view.addSubview(messageLabel)
        view.addSubview(retryButton)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func showFailureState(errorDescription: String) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        
        messageLabel.text = "서버 연결에 실패했습니다.\n(\(errorDescription))\n\n네트워크 상태를 확인해주세요."
        retryButton.isHidden = false
    }
    
    func showLoadingState() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        messageLabel.text = "접속 중입니다..."
        retryButton.isHidden = true
    }
    
    @objc private func retryTapped() {
        showLoadingState()
        onRetryButtonTapped?()
    }
}

