//
//  DetailViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/26/26.
//

import UIKit
import Combine

final class DetailViewController: UIViewController {
    private let viewModel: DetailViewModel
    private let detailView = DetailView()
    private var cancellabels = Set<AnyCancellable>()
    
    init(viewModel: DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = detailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindViewModel()
        detailView.configure(with: viewModel.emotion)
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        let deleteButton = UIBarButtonItem(image: UIImage(systemName: "trash"), style: .plain, target: self, action: #selector(deleteButtonTapped))
        deleteButton.tintColor = .systemRed
        navigationItem.rightBarButtonItem = deleteButton
    }
    
    private func bindViewModel() {
        viewModel.didDeleteEmotion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellabels)
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "기록 삭제", message: "이 감정 기록을 완전히 지우시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteEmotion()
        }))
        
        present(alert, animated: true)
    }
}
