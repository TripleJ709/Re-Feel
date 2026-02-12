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
        
        viewModel.$isNotificationOn
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isOn in
                self?.settingView.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.didLinkAccount
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                self.settingView.tableView.reloadData()
                
                let alert = UIAlertController(title: "성공", message: "계정이 성공적으로 연동되었습니다!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func showLinkAccountActionSheet() {
        let alert = UIAlertController(title: "계정 연동", message: "데이터를 안전하게 보관할 계정을 선택하세요.", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Google로 계속하기", style: .default, handler: { _ in
            self.viewModel.linkGoogle(presenting: self)
        }))
        alert.addAction(UIAlertAction(title: "Apple로 계속하기", style: .default, handler: { _ in
            if let window = self.view.window {
                self.viewModel.linkApple(window: window)
            }
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        
        present(alert, animated: true)
    }
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 {
            return viewModel.isNotificationOn ? 2 : 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor.white.withAlphaComponent(0.6)
        header.textLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "계정 관리" : (section == 1 ? "알림 설정" : "앱 정보")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        cell.selectedBackgroundView = selectedView
        cell.textLabel?.textColor = .white
        cell.tintColor = .white
        cell.accessoryView = nil
        cell.accessoryType = .none
        
        if indexPath.section == 0 {
            let status = viewModel.checkCurrentProvider()
            
            if status == "익명 사용자" {
                cell.textLabel?.text = "계정 연동하기"
                cell.textLabel?.textColor = UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            } else {
                cell.textLabel?.text = "현재 계정: \(status)"
                cell.textLabel?.textColor = .white
                cell.accessoryType = .checkmark
                cell.selectionStyle = .none
            }
            return cell
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "일기 작성 알림"
                
                let switchControl = UISwitch()
                switchControl.isOn = viewModel.isNotificationOn
                switchControl.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
                switchControl.onTintColor = .systemPurple
                cell.accessoryView = switchControl
                cell.selectionStyle = .none
                
            } else {
                cell.textLabel?.text = "알림 시간"
                
                let datePicker = UIDatePicker()
                datePicker.datePickerMode = .time
                datePicker.preferredDatePickerStyle = .compact
                datePicker.date = viewModel.notificationTime
                datePicker.addTarget(self, action: #selector(didChangeTime(_:)), for: .valueChanged)
                datePicker.overrideUserInterfaceStyle = .dark
                datePicker.tintColor = .systemPurple
                cell.accessoryView = datePicker
                cell.selectionStyle = .none
            }
            return cell
        }
        
        if indexPath.section == 2 {
            cell.textLabel?.text = indexPath.row == 0 ? "버전 정보" : "문의하기"
            
            if indexPath.row == 0 {
                let versionLabel = UILabel()
                versionLabel.text = "1.0.0"
                versionLabel.textColor = .lightGray
                versionLabel.font = .systemFont(ofSize: 16)
                versionLabel.sizeToFit()
                cell.accessoryView = versionLabel
            } else {
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            }
            return cell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let status = viewModel.checkCurrentProvider()
            if status == "익명 로그인 사용자" {
                showLinkAccountActionSheet()
            }
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            // 문의하기 클릭 시 동작 (이메일 보내기 등 추후 구현)
            print("문의하기 클릭됨")
        }
    }
    
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        viewModel.toggleNotification(isOn: sender.isOn)
    }
    
    @objc private func didChangeTime(_ sender: UIDatePicker) {
        viewModel.updateNotificationTime(date: sender.date)
    }
}
