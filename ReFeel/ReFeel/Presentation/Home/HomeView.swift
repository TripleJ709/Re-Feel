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
        if self.layer.sublayers?.first(where: {$0.name == "starLayer"}) == nil {
            addTwinklingStars()
        }
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
    
    private func addTwinklingStars() {
        let starCount = 30
        
        for _ in 0..<starCount {
            let starSize = CGFloat.random(in: 2...5)
            let star = UIView()
            star.backgroundColor = .white
            star.layer.cornerRadius = starSize / 2
            star.clipsToBounds = true
            star.alpha = 0.3
            star.layer.name = "starLayer"
            
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            let randomX = CGFloat.random(in: 0...screenWidth)
            let randomY = CGFloat.random(in: 0...screenHeight)
            
            star.frame = CGRect(x: randomX, y: randomY, width: starSize, height: starSize)
            
            self.insertSubview(star, at: 1)
            
            animateStar(star)
        }
    }
    
    private func animateStar(_ star: UIView) {
        let duration = Double.random(in: 1.5...3.0)
        let delay = Double.random(in: 0.0...1.5)
        
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction],
            animations: {
                star.alpha = 1.0
                star.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            },
            completion: nil
        )
    }
}
