//
//  HomeViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import UIKit
import Combine

final class HomeViewController: UIViewController {
    private let viewModel: HomeViewModel
    private let homeView = HomeView()
    private var cancellables = Set<AnyCancellable>()
    private let headerView = HomeHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 120))
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Re:Feel"
        self.homeView.tableView.delegate = self
        self.homeView.tableView.dataSource = self
        bindViewModel()
        setupAction()
        setupUI()
        viewModel.fetchEmotions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        homeView.tableView.backgroundColor = .clear
        homeView.tableView.separatorStyle = .none
        homeView.tableView.sectionHeaderHeight = 50
        homeView.tableView.tableHeaderView = headerView
    }
    
    private func setupAction() {
        homeView.addViewButton.addTarget(self, action: #selector(addViewBtnTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$sections
            .receive(on: DispatchQueue.main)
            .sink { [weak self] sections in
                guard let self else { return }
                
                if let firstSection = sections.first {
                    let count = firstSection.items.count
                    self.headerView.configure(count: count)
                } else {
                    self.headerView.configure(count: 0)
                }
                
                if sections.isEmpty {
                    self.homeView.tableView.backgroundView = HomeEmptyView()
                    self.homeView.tableView.tableHeaderView = nil
                } else {
                    self.homeView.tableView.backgroundView = nil
                    self.homeView.tableView.tableHeaderView = self.headerView
                }
                
                self.homeView.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addViewBtnTapped() {
        if viewModel.hasDiaryForToday() {
            let alert = UIAlertController(title: "작성 제한", message: "하루에 하나의 감정만 기록할 수 있어요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            present(alert, animated: true)
            return
        }
        
        let addViewModel = AddEmotionViewModel(transformer: viewModel.transformer, repository: viewModel.repository)
        addViewModel.didCreateEmotion
            .sink { [weak self] _ in
                print("일기 작성 완료 -> 목록 갱신")
                self?.viewModel.fetchEmotions()
            }
            .store(in: &cancellables)
        
        let vc = AddEmotionViewController(viewModel: addViewModel)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .clear
        
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        let sectionDate = viewModel.sections[section].date
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        titleLabel.text = formatter.string(from: sectionDate)
        
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10)
        ])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeEmotionCell.identifier, for: indexPath) as? HomeEmotionCell else { return UITableViewCell() }
        let emotion = viewModel.sections[indexPath.section].items[indexPath.row]
        cell.configure(with: emotion)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedEmotion = viewModel.sections[indexPath.section].items[indexPath.row]
        let detailViewModel = DetailViewModel(emotion: selectedEmotion, repository: viewModel.repository)
        
        detailViewModel.didDeleteEmotion
            .sink { [weak self] _ in
                print("메모 삭제 -> 목록 새로고침")
                self?.viewModel.fetchEmotions()
            }
            .store(in: &cancellables)
        
        let detailVC = DetailViewController(viewModel: detailViewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
