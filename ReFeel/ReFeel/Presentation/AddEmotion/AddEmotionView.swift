//
//  AddEmotionView.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import UIKit

final class AddEmotionView: UIView {
    
    private let textContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 10
        return view
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 18, weight: .regular)
        tv.textColor = .white
        tv.tintColor = .white
        tv.textContainerInset = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        tv.isScrollEnabled = true
        tv.keyboardAppearance = .dark
        return tv
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 하루는 어떠셨나요?\n솔직한 감정을 털어놓아 보세요."
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.4)
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setSpaceGradientBackground()
        addTwinklingStars()
    }
    
    private func setupUI() {
        backgroundColor = .black
    }
    
    private func setupLayout() {
        addSubview(textContainerView)
        textContainerView.addSubview(textView)
        textContainerView.addSubview(placeholderLabel)
        addSubview(activityIndicator)
        
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            textContainerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 24),
            textContainerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -24),
            textContainerView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.45),
            
            textView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 24),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 24),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
