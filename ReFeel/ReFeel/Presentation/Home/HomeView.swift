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
        btn.setTitle("감정추가하기", for: .normal)
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
        tableView.register(HomeEmotionCell.self, forCellReuseIdentifier: HomeEmotionCell.identifier)
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
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            addViewButton.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            addViewButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 15)
        ])
    }
}
