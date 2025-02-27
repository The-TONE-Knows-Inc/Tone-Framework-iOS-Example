//
//  HeaderView.swift
//  ToneDemo
//
//  Created by Balan iOS on 21/02/25.
//

import UIKit

class HeaderView: UIView {
    
    weak var delegate: BackButtonDelegate?
    
    lazy var backImageView: UIImageView = {
        let view = UIImageView()
        view.image = traitCollection.userInterfaceStyle == .dark ? .backIcon : .backIconBlack
        view.tintColor = .secondary
        view.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        view.addGestureRecognizer(tapGesture)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondary
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .containerBackground
        
        addSubview(backImageView)
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            backImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15),
            backImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backImageView.widthAnchor.constraint(equalToConstant: 30),
            backImageView.heightAnchor.constraint(equalToConstant: 30),
            
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func backButtonTapped() {
        delegate?.backButtonAction()
    }
    
    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}

import UIKit

class SearchTextFieldView: UIView {
    
    lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search Clients"
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.returnKeyType = .done
        textField.textColor = .secondary
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var clearButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.contentMode = .scaleAspectFit
        button.isHidden = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .containerBackground
        layer.cornerRadius = 6
        layer.borderWidth = 0.8
        layer.borderColor = UIColor.lightGray.cgColor
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayout()
    }

    private func setupLayout() {
        addSubview(searchTextField)
        addSubview(clearButton)

        NSLayoutConstraint.activate([
            searchTextField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            searchTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: clearButton.leadingAnchor, constant: -10),
            
            clearButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            clearButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 40),
            clearButton.heightAnchor.constraint(equalToConstant: 40),
            
            heightAnchor.constraint(equalToConstant: 45)
        ])
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        clearButton.isHidden = textField.text?.isEmpty ?? true
    }
}
