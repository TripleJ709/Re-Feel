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
        view.backgroundColor = .tertiarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .regular)
        tv.textColor = .label
        tv.tintColor = .systemBlue
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        tv.isScrollEnabled = true
        return tv
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 하루는 어떠셨나요?\n솔직한 감정을 털어놓아 보세요."
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .tertiaryLabel
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        return label
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
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
    
    private func setupUI() {
        backgroundColor = .systemBackground
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
            textContainerView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            textContainerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            textContainerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            textContainerView.heightAnchor.constraint(equalToConstant: 300),
            
            textView.topAnchor.constraint(equalTo: textContainerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: textContainerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textContainerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: textContainerView.bottomAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 20), // textView inset top과 동일하게
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 20), // textView inset left와 비슷하게 보정
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -20),
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
