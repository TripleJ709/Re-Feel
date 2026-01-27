//
//  HomeHeaderView.swift
//  ReFeel
//
//  Created by 장주진 on 1/27/26.
//

import UIKit

class HomeHeaderView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 20
        view.layer.shadowColor = UIColor.systemBlue.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 하루는 어떠셨나요?"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "이번 달 기록: 0개"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "heart.text.square.fill"))
        iv.tintColor = .white.withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(countLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 카드 위치 (양옆 여백)
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            
            // 장식 아이콘 (오른쪽 구석에 크게)
            iconImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // 텍스트들 (왼쪽 정렬)
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            countLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24)
        ])
    }
    
    func configure(count: Int) {
        countLabel.text = "이번 달 \(count)개의 감정이 쌓였어요."
    }
}
