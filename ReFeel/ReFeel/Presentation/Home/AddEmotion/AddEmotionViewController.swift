//
//  AddEmotionViewController.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import UIKit

final class AddEmotionViewController: UIViewController {
    
    var onEmotionAdded: ((Emotion) -> Void)?
    
    let testButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장하기", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray5
        title = "Re:Feel - Add emotion"
        
        view.addSubview(testButton)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        testButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    @objc func saveButtonTapped() {
        let emotion = Emotion(id: UUID(), content: "새로 추가된 감정", createdAt: Date())
        onEmotionAdded?(emotion)
        navigationController?.popViewController(animated: true)
    }
}
