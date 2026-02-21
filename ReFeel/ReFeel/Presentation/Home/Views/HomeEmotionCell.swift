//
//  HomeEmotionCell.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import UIKit

final class HomeEmotionCell: UITableViewCell {
    static let identifier = "HomeEmotionCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 10
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .lightGray
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }
    
    private func setupLayout() {
        contentView.addSubview(containerView)
        containerView.addSubview(dateLabel)
        containerView.addSubview(contentLabel)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            
            contentLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
            contentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            contentLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with emotion: Emotion) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let attrString = NSAttributedString(string: emotion.transformedText, attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.systemFont(ofSize: 16)])
        contentLabel.attributedText = attrString
        dateLabel.text = DateFormatter.short.string(from: emotion.createdAt)
    }
}
