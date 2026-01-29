//
//  SettingViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/25/26.
//

import UIKit
import Combine

final class SettingViewController: UIViewController {
    private let viewModel = SettingViewModel()
    private let settingView = SettingView()
    private var cancellables = Set<AnyCancellable>()
    
    override func loadView() {
        view = settingView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingView.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        bindViewModel()
    }
    
    private func setupController() {
        title = "설정"
        settingView.tableView.delegate = self
        settingView.tableView.dataSource = self
    }
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.settingView.activityIndicator.startAnimating()
                    self?.view.isUserInteractionEnabled = false
                } else {
                    self?.settingView.activityIndicator.stopAnimating()
                    self?.view.isUserInteractionEnabled = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.$alertMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }
            .store(in: &cancellables)
        
        viewModel.didLinkGoogleAccount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.settingView.tableView.reloadData()
                
                let alert = UIAlertController(title: "성공", message: "Google 계정과 성공적으로 연동되었습니다!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
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
            let status = viewModel.checkCurrentProvider()
            cell.textLabel?.text = "현재 계정: \(status)"
            
            if status == "익명 로그인 사용자" {
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.text = "Google 계정 연동하기"
                cell.textLabel?.textColor = .systemBlue
                cell.selectionStyle = .default
            } else {
                cell.accessoryType = .checkmark
                cell.textLabel?.textColor = .label
                cell.selectionStyle = .none
            }
        } else {
            cell.textLabel?.text = indexPath.row == 0 ? "버전 정보" : "문의하기"
            cell.textLabel?.textColor = .label
            cell.accessoryType = indexPath.row == 1 ? .disclosureIndicator : .none
            cell.selectionStyle = indexPath.row == 1 ? .default : .none
            
            if indexPath.row == 0 {
                let versionLabel = UILabel()
                versionLabel.text = "1.0.0"
                versionLabel.textColor = .secondaryLabel
                versionLabel.sizeToFit()
                cell.accessoryView = versionLabel
            } else {
                cell.accessoryView = nil
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let status = viewModel.checkCurrentProvider()
            if status == "익명 로그인 사용자" {
                viewModel.linkGoogleAccount(presenting: self)
            }
        }
    }
}
