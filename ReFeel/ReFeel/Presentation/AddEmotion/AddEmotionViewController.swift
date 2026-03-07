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
        
        let hasAgreed = UserDefaults.standard.bool(forKey: "hasAgreedToAI")
        if hasAgreed {
            viewModel.submit()
        } else {
            let alert = UIAlertController(
                title: "AI 분석 데이터 제공 동의",
                message: "작성하신 일기 내용은 맞춤형 위로와 명언을 제공받기 위해 제3자(OpenAI)의 AI 서비스로 전송됩니다.\n\n해당 데이터는 AI 분석 목적으로만 사용되며 안전하게 보호됩니다. 전송에 동의하시겠습니까?",
                preferredStyle: .alert
            )
            
            let agreeAction = UIAlertAction(title: "동의 및 저장", style: .default) { [weak self] _ in
                UserDefaults.standard.set(true, forKey: "hasAgreedToAI")
                self?.viewModel.submit()
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
                self?.addView.textView.becomeFirstResponder()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(agreeAction)
            
            present(alert, animated: true)
        }
    }
}

extension AddEmotionViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.text = textView.text
        addView.placeholderLabel.isHidden = !textView.text.isEmpty
        saveButton.isEnabled = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
