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
    }
    
    private func setupAction() {
        homeView.addViewButton.addTarget(self, action: #selector(addViewBtnTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$emotions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeView.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    @objc func addViewBtnTapped() {
        let addViewModel = AddEmotionViewModel(transformer: viewModel.transformer, repository: viewModel.repository)
        
        addViewModel.didCreateEmotion
            .sink { [weak self] _ in
                print("새 글 등록, 목록 새로고침")
                self?.viewModel.fetchEmotions()
            }
            .store(in: &cancellables)
        
        let vc = AddEmotionViewController(viewModel: addViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.emotions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeEmotionCell.identifier, for: indexPath) as? HomeEmotionCell else { return UITableViewCell() }
        let emotion = viewModel.emotions[indexPath.row]
        cell.configure(with: emotion)
        return cell
    }
}
