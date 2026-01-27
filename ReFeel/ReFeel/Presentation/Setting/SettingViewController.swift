//
//  SettingViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/25/26.
//

import UIKit
import FirebaseAuth

final class SettingViewController: UIViewController {
    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
    }
    
    private func setupUI() {
        title = "설정"
        view.backgroundColor = .systemGroupedBackground
        tableView.backgroundColor = .systemGroupedBackground
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - todo: 로그아웃 로직 구현하기
    private func handleLogout() {
        do {
            try Auth.auth().signOut()
            print("로그아웃 성공")
        } catch  {
            print("로그아웃 실패: \(error)")
        }
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "계정 관리" : "앱 정보"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "로그아웃 / 데이터 초기화"
            cell.textLabel?.textColor = .systemRed
        } else {
            if indexPath.row == 0 {
                cell.textLabel?.text = "버전 정보"
                let versionLabel = UILabel()
                versionLabel.text = "1.0.0"
                versionLabel.textColor = .secondaryLabel
                versionLabel.sizeToFit()
                cell.accessoryView = versionLabel
            } else {
                cell.textLabel?.text = "문의하기"
                cell.accessoryType = .disclosureIndicator
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까? 익명 사용자의 경우 데이터가 사라질 수 있습니다.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
                self.handleLogout()
            }))
            present(alert, animated: true)
        }
    }
}
