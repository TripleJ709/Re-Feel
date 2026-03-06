//
//  HomeView.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import UIKit

final class HomeView: UIView {
    let tableView = UITableView()
    
    let addViewButton: UIButton = {
        let btn = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.title = "감정 기록"
        config.image = UIImage(systemName: "pencil.line")
        config.imagePadding = 8
        config.cornerStyle = .capsule
        config.baseBackgroundColor = UIColor(red: 0.48, green: 0.38, blue: 0.93, alpha: 1) // #7C61ED
        config.baseForegroundColor = .white
        
        btn.configuration = config
        btn.layer.shadowColor = UIColor(red: 0.48, green: 0.38, blue: 0.93, alpha: 1).cgColor
        btn.layer.shadowOpacity = 0.5
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 10
        
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setSpaceGradientBackground()
        addTwinklingStars()
    }
    
    private func setupUI() {
        tableView.backgroundColor = .clear
        tableView.register(HomeEmotionCell.self, forCellReuseIdentifier: HomeEmotionCell.identifier)
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    }
    
    private func setupLayout() {
        addSubview(tableView)
        addSubview(addViewButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addViewButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            addViewButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            addViewButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
            addViewButton.widthAnchor.constraint(equalToConstant: 140),
            addViewButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
