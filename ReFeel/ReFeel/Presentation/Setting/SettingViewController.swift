//
//  SettingViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/25/26.
//

import UIKit
import Combine
import AuthenticationServices
import MessageUI

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
        setupFooter()
    }
    
    private func setupController() {
        title = "설정"
        settingView.tableView.delegate = self
        settingView.tableView.dataSource = self
        
        settingView.tableView.register(SettingLoginCell.self, forCellReuseIdentifier: SettingLoginCell.identifier)
        settingView.tableView.register(SettingToggleCell.self, forCellReuseIdentifier: SettingToggleCell.identifier)
        settingView.tableView.register(SettingTimeCell.self, forCellReuseIdentifier: SettingTimeCell.identifier)
        settingView.tableView.register(SettingSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: SettingSectionHeaderView.identifier)
    }
    
    private func setupFooter() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100))
        
        let versionLabel = UILabel()
        versionLabel.text = "Re:Feel v1.0.0"
        versionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        versionLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        versionLabel.textAlignment = .center
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "당신의 감정을 기록하는 우주"
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        subtitleLabel.textAlignment = .center
        
        footerView.addSubview(versionLabel)
        footerView.addSubview(subtitleLabel)
        
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            versionLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            versionLabel.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 40),
            
            subtitleLabel.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 8)
        ])
        
        settingView.tableView.tableFooterView = footerView
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
}

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let status = viewModel.checkCurrentProvider()
            if status == "익명 로그인 사용자" || status == "익명 사용자" {
                return 2
            } else {
                return 3
            }
        }
        if section == 1 {
            return viewModel.isNotificationOn ? 2 : 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SettingSectionHeaderView.identifier) as? SettingSectionHeaderView else { return nil }
        
        if section == 0 {
            header.configure(iconName: "person", title: "계정 관리")
        } else if section == 1 {
            header.configure(iconName: "bell", title: "알림")
        } else {
            header.configure(iconName: "info.circle", title: "정보 및 문의")
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let status = viewModel.checkCurrentProvider()
            if status == "익명 로그인 사용자" || status == "익명 사용자" {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingLoginCell.identifier, for: indexPath) as? SettingLoginCell else { return UITableViewCell() }
                if indexPath.row == 0 {
                    cell.configure(type: "Apple")
                } else {
                    cell.configure(type: "Google")
                }
                return cell
            } else {
                if indexPath.row == 0 {
                    let cell = SettingBaseCell(style: .default, reuseIdentifier: nil)
                    let label = UILabel()
                    label.text = "연동된 계정: \(status)"
                    label.textColor = .white
                    label.font = .systemFont(ofSize: 16, weight: .bold)
                    
                    let checkIcon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
                    checkIcon.tintColor = .systemGreen
                    
                    cell.containerView.addSubview(checkIcon)
                    cell.containerView.addSubview(label)
                    
                    checkIcon.translatesAutoresizingMaskIntoConstraints = false
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        checkIcon.leadingAnchor.constraint(equalTo: cell.containerView.leadingAnchor, constant: 20),
                        checkIcon.centerYAnchor.constraint(equalTo: cell.containerView.centerYAnchor),
                        checkIcon.widthAnchor.constraint(equalToConstant: 24),
                        checkIcon.heightAnchor.constraint(equalToConstant: 24),
                        
                        label.leadingAnchor.constraint(equalTo: checkIcon.trailingAnchor, constant: 12),
                        label.centerYAnchor.constraint(equalTo: cell.containerView.centerYAnchor),
                        
                        cell.containerView.heightAnchor.constraint(equalToConstant: 64)
                    ])
                    return cell
                } else if indexPath.row == 1 {
                    let cell = SettingBaseCell(style: .default, reuseIdentifier: nil)
                    let label = UILabel()
                    label.text = "로그아웃"
                    label.textColor = UIColor(red: 1.0, green: 0.3, blue: 0.3, alpha: 1.0)
                    label.font = .systemFont(ofSize: 16, weight: .medium)
                    
                    cell.containerView.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: cell.containerView.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: cell.containerView.centerYAnchor),
                        cell.containerView.heightAnchor.constraint(equalToConstant: 50)
                    ])
                    return cell
                } else {
                    let cell = SettingBaseCell(style: .default, reuseIdentifier: nil)
                    let label = UILabel()
                    label.text = "회원 탈퇴"
                    label.textColor = .systemGray
                    label.font = .systemFont(ofSize: 14, weight: .medium)
                    
                    cell.containerView.addSubview(label)
                    label.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        label.centerXAnchor.constraint(equalTo: cell.containerView.centerXAnchor),
                        label.centerYAnchor.constraint(equalTo: cell.containerView.centerYAnchor),
                        cell.containerView.heightAnchor.constraint(equalToConstant: 50)
                    ])
                    return cell
                }
            }
        }
        
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingToggleCell.identifier, for: indexPath) as? SettingToggleCell else { return UITableViewCell() }
                cell.configure(title: "일기 알림", subtitle: "매일 정해진 시간에 알림을 받아보세요", isOn: viewModel.isNotificationOn)
                cell.toggleSwitch.addTarget(self, action: #selector(didToggleSwitch(_:)), for: .valueChanged)
                return cell
            } else {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTimeCell.identifier, for: indexPath) as? SettingTimeCell else { return UITableViewCell() }
                cell.configure(title: "알림 시간", time: viewModel.notificationTime)
                cell.datePicker.addTarget(self, action: #selector(didChangeTime(_:)), for: .valueChanged)
                return cell
            }
        }
        
        if indexPath.section == 2 {
            let cell = SettingBaseCell(style: .default, reuseIdentifier: nil)
            
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 16, weight: .medium)
            
            let chevronIcon = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevronIcon.tintColor = .systemGray
            
            cell.containerView.addSubview(label)
            cell.containerView.addSubview(chevronIcon)
            
            label.translatesAutoresizingMaskIntoConstraints = false
            chevronIcon.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: cell.containerView.leadingAnchor, constant: 20),
                label.centerYAnchor.constraint(equalTo: cell.containerView.centerYAnchor),
                
                chevronIcon.trailingAnchor.constraint(equalTo: cell.containerView.trailingAnchor, constant: -20),
                chevronIcon.centerYAnchor.constraint(equalTo: cell.containerView.centerYAnchor),
                chevronIcon.widthAnchor.constraint(equalToConstant: 12),
                chevronIcon.heightAnchor.constraint(equalToConstant: 16),
                
                cell.containerView.heightAnchor.constraint(equalToConstant: 56)
            ])
            
            if indexPath.row == 0 {
                label.text = "앱 문의하기"
            } else {
                label.text = "개인정보처리방침"
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let status = viewModel.checkCurrentProvider()
            if status == "익명 로그인 사용자" || status == "익명 사용자" {
                if indexPath.row == 0 {
                    if let window = self.view.window {
                        viewModel.linkApple(window: window)
                    }
                } else {
                    viewModel.linkGoogle(presenting: self)
                }
            } else {
                if indexPath.row == 1 {
                    let alert = UIAlertController(title: "로그아웃", message: "정말 로그아웃 하시겠습니까?", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                    alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { [weak self] _ in
                        self?.viewModel.signOut()
                    }))
                    self.present(alert, animated: true)
                } else if indexPath.row == 2 {
                    let alert = UIAlertController(title: "회원 탈퇴", message: "정말 탈퇴하시겠습니까?\n모든 기록과 데이터가 삭제되며 복구할 수 없습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                    alert.addAction(UIAlertAction(title: "탈퇴하기", style: .destructive, handler: { [weak self] _ in
                        self?.viewModel.deleteAccount()
                    }))
                    self.present(alert, animated: true)
                }
            }
        }
        
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                sendEmail()
            } else if indexPath.row == 1 {
                if let url = URL(string: "https://vaulted-danthus-a6c.notion.site/Re-Feel-231269ec6fca80df9d6de8bc3642fbad") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }
    
    private func sendEmail() {
        let email = "ijn9907@gmail.com"
        let alert = UIAlertController(title: "문의하기", message: "원하시는 문의 방식을 선택해주세요.", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "웹 폼으로 문의하기", style: .default, handler: { _ in
            if let url = URL(string: "https://forms.gle/MsVn67tpMbdjYG5g8") {
                UIApplication.shared.open(url)
            }
        }))
    
        alert.addAction(UIAlertAction(title: "이메일 앱 열기", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            
            if MFMailComposeViewController.canSendMail() {
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                composeVC.setToRecipients([email])
                composeVC.setSubject("[Re:Feel] 앱 관련 문의")
                
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "알 수 없음"
                let osVersion = UIDevice.current.systemVersion
                let deviceModel = UIDevice.current.model
                
                let messageBody = """
                
                -------------------
                아래에 문의 내용을 작성해 주세요.
                
                
                
                -------------------
                App Version: \(appVersion)
                OS Version: \(osVersion)
                Device: \(deviceModel)
                """
                composeVC.setMessageBody(messageBody, isHTML: false)
                self.present(composeVC, animated: true, completion: nil)
            } else {
                UIPasteboard.general.string = email
                let copyAlert = UIAlertController(title: "메일 복사 완료", message: "메일 앱이 연동되어 있지 않습니다. 개발자 이메일 주소(\(email))가 복사되었습니다. 사용하시는 메일 앱에서 문의를 보내주세요.", preferredStyle: .alert)
                copyAlert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(copyAlert, animated: true)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didToggleSwitch(_ sender: UISwitch) {
        viewModel.toggleNotification(isOn: sender.isOn)
    }
    
    @objc private func didChangeTime(_ sender: UIDatePicker) {
        viewModel.updateNotificationTime(date: sender.date)
    }
}

extension SettingViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Custom Views
final class SettingSectionHeaderView: UITableViewHeaderFooterView {
    static let identifier = "SettingSectionHeaderView"
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = UIColor(red: 0.48, green: 0.38, blue: 0.93, alpha: 1) // #7C61ED
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 8),
            titleLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(iconName: String, title: String) {
        iconImageView.image = UIImage(systemName: iconName)
        titleLabel.text = title
    }
}

class SettingBaseCell: UITableViewCell {
    let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

final class SettingLoginCell: SettingBaseCell {
    static let identifier = "SettingLoginCell"
    
    private let appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
        button.cornerRadius = 8
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let googleButtonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let googleIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "GoogleLogo")
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let googleTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in with Google"
        label.textColor = .black
        label.font = .systemFont(ofSize: 19, weight: .medium)
        return label
    }()
    
    private lazy var googleStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [googleIconImageView, googleTitleLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.backgroundColor = .clear
        containerView.layer.borderWidth = 0
        
        containerView.addSubview(appleButton)
        containerView.addSubview(googleButtonView)
        googleButtonView.addSubview(googleStackView)
        
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        googleButtonView.translatesAutoresizingMaskIntoConstraints = false
        googleIconImageView.translatesAutoresizingMaskIntoConstraints = false
        googleStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Apple Button
            appleButton.topAnchor.constraint(equalTo: containerView.topAnchor),
            appleButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            appleButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            appleButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            appleButton.heightAnchor.constraint(equalToConstant: 50),
            
            googleButtonView.topAnchor.constraint(equalTo: containerView.topAnchor),
            googleButtonView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            googleButtonView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            googleButtonView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            googleButtonView.heightAnchor.constraint(equalToConstant: 50),
            
            googleIconImageView.widthAnchor.constraint(equalToConstant: 18),
            googleIconImageView.heightAnchor.constraint(equalToConstant: 18),
            
            googleStackView.centerXAnchor.constraint(equalTo: googleButtonView.centerXAnchor),
            googleStackView.centerYAnchor.constraint(equalTo: googleButtonView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(type: String) {
        if type == "Google" {
            appleButton.isHidden = true
            googleButtonView.isHidden = false
        } else {
            appleButton.isHidden = false
            googleButtonView.isHidden = true
        }
    }
}

final class SettingToggleCell: SettingBaseCell {
    static let identifier = "SettingToggleCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    let toggleSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = UIColor(red: 0.48, green: 0.38, blue: 0.93, alpha: 1) // #7C61ED
        return sw
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .leading
        
        containerView.addSubview(stackView)
        containerView.addSubview(toggleSwitch)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            toggleSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            toggleSwitch.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, subtitle: String, isOn: Bool) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        toggleSwitch.isOn = isOn
    }
}

final class SettingTimeCell: SettingBaseCell {
    static let identifier = "SettingTimeCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        dp.datePickerMode = .time
        dp.preferredDatePickerStyle = .compact
        dp.overrideUserInterfaceStyle = .dark
        dp.tintColor = UIColor(red: 0.48, green: 0.38, blue: 0.93, alpha: 1) // #7C61ED
        return dp
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(datePicker)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            datePicker.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            datePicker.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: 64)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(title: String, time: Date) {
        titleLabel.text = title
        datePicker.date = time
    }
}
