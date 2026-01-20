//
//  AddEmotionViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import UIKit
import Combine

final class AddEmotionViewController: UIViewController {
    private let viewModel: AddEmotionViewModel
    private let addView = AddEmotionView()
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: AddEmotionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = addView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Re:Feel - addView"
        setupAction()
        bindViewModel()
    }
    
    private func setupAction() {
        addView.saveButton.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.didCreateEmotion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func saveBtnTapped() {
        viewModel.text = addView.emotionTextView.text
        viewModel.submit()
    }
}
