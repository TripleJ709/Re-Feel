//
//  DetailView.swift
//  ReFeel
//
//  Created by 장주진 on 1/26/26.
//

import UIKit

final class DetailView: UIView {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let gptContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let gptIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "sparkles"))
        iv.tintColor = .systemYellow
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    let transformedTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let myTextTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "나의 기록"
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }()
    
    let rawTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
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
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        [dateLabel, gptContainer, myTextTitleLabel, rawTextLabel].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        gptContainer.addSubview(gptIcon)
        gptContainer.addSubview(transformedTextLabel)
        gptIcon.translatesAutoresizingMaskIntoConstraints = false
        transformedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            gptContainer.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            gptContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            gptContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            gptIcon.topAnchor.constraint(equalTo: gptContainer.topAnchor, constant: 16),
            gptIcon.leadingAnchor.constraint(equalTo: gptContainer.leadingAnchor, constant: 16),
            gptIcon.widthAnchor.constraint(equalToConstant: 24),
            gptIcon.heightAnchor.constraint(equalToConstant: 24),
            
            transformedTextLabel.topAnchor.constraint(equalTo: gptIcon.bottomAnchor, constant: 12),
            transformedTextLabel.leadingAnchor.constraint(equalTo: gptContainer.leadingAnchor, constant: 16),
            transformedTextLabel.trailingAnchor.constraint(equalTo: gptContainer.trailingAnchor, constant: -16),
            transformedTextLabel.bottomAnchor.constraint(equalTo: gptContainer.bottomAnchor, constant: -16),
            
            myTextTitleLabel.topAnchor.constraint(equalTo: gptContainer.bottomAnchor, constant: 30),
            myTextTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            rawTextLabel.topAnchor.constraint(equalTo: myTextTitleLabel.bottomAnchor, constant: 10),
            rawTextLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            rawTextLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            rawTextLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50)
        ])
    }
    
    func configure(with emotion: Emotion) {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR")
        dateLabel.text = formatter.string(from: emotion.createdAt)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        
        transformedTextLabel.attributedText = NSAttributedString(string: emotion.transformedText, attributes: [.paragraphStyle: style, .font: UIFont.systemFont(ofSize: 18, weight: .medium)])
        rawTextLabel.attributedText = NSAttributedString(string: emotion.rawText, attributes: [.paragraphStyle: style, .font: UIFont.systemFont(ofSize: 16, weight: .regular)])
    }
}
