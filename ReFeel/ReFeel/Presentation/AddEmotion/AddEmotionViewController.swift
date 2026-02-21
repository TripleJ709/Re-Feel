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
    
    private lazy var saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(saveBtnTapped))
        button.isEnabled = false
        return button
    }()
    
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
        addView.textView.delegate = self
        bindViewModel()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addView.textView.becomeFirstResponder()
    }
    
    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.tintColor = .white
        navigationItem.rightBarButtonItem = saveButton
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func bindViewModel() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.addView.activityIndicator.startAnimating()
                    self?.saveButton.isEnabled = false
                    self?.addView.textView.isEditable = false
                } else {
                    self?.addView.activityIndicator.stopAnimating()
                    self?.addView.textView.isEditable = true
                }
            }
            .store(in: &cancellables)
        
        viewModel.didCreateEmotion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellables)
    }
    
    @objc private func saveBtnTapped() {
        view.endEditing(true)
//        viewModel.text = addView.textView.text
        viewModel.submit()
    }
}

extension AddEmotionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.text = textView.text
        addView.placeholderLabel.isHidden = !textView.text.isEmpty
        saveButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
