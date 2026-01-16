//
//  HomeViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import UIKit

final class HomeViewController: UIViewController {
    private var emotions: [Emotion] = [
        Emotion(id: UUID(), content: "오늘 너무 피곤하다", createdAt: Date()),
        Emotion(id: UUID(), content: "그래도 앱 하나 만들었다", createdAt: Date()),
        Emotion(id: UUID(), content: "조금은 뿌듯한 하루", createdAt: Date())
    ]
    
    private lazy var addEmotionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("감정 추가하기", for: .normal)
        button.addTarget(self, action: #selector(addEmotionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private var tableView: UITableView = {
        let tv = UITableView()
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        title = "Re:Feel"
        tableView.dataSource = self
        tableView.register(EmotionCell.self, forCellReuseIdentifier: EmotionCell.identifier)
        
        setUpAutoLayout()
    }
    
    private func setUpAutoLayout() {
        view.addSubview(addEmotionButton)
        view.addSubview(tableView)
        addEmotionButton.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            addEmotionButton.widthAnchor.constraint(equalToConstant: 100),
            addEmotionButton.heightAnchor.constraint(equalToConstant: 50),
            addEmotionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addEmotionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addEmotionButton.topAnchor, constant: -10)
        ])
    }
    
    @objc private func addEmotionButtonTapped() {
        let vc = AddEmotionViewController()
        vc.onEmotionAdded = { [weak self] emotion in
            self?.emotions.insert(emotion, at: 0)
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        emotions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EmotionCell.identifier, for: indexPath) as? EmotionCell else { return UITableViewCell() }
        cell.configure(with: emotions[indexPath.row])
        return cell
    }
}
