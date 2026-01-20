//
//  AddEmotionView.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import UIKit

final class AddEmotionView: UIView {
    let emotionTextView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.layer.cornerRadius = 8
        tv.backgroundColor = .white
        return tv
    }()
    
    let saveButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("저장", for: .normal)
        return btn
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
        backgroundColor = .systemGray5
    }
    
    private func setupLayout() {
        addSubview(emotionTextView)
        addSubview(saveButton)
        
        emotionTextView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emotionTextView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            emotionTextView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            emotionTextView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            emotionTextView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.topAnchor.constraint(equalTo: emotionTextView.bottomAnchor, constant: 20),
            saveButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}
