//
//  TextFieldView.swift
//  FakeNFT
//
//  Created by Артем Кривдин on 29.03.2025.
//

import UIKit

final class TextFieldWithPadding: UITextField {
    var textPadding = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}

final class TextFieldView: UIView {
    
    private var isTextView: Bool = false
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = UIColor(named: "appBlackDynamic")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(named: "appLightGrayDynamic")
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.clearButtonMode = .whileEditing
        textField.layer.cornerRadius = 12
        textField.layer.masksToBounds = true
        return textField
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor(named: "appLightGrayDynamic")
        textView.font = .systemFont(ofSize: 17, weight: .regular)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
        textView.layer.cornerRadius = 12
        textView.layer.masksToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        textView.isScrollEnabled = false
        return textView
    }()
    
    // MARK: - Initialization
    
    init(
        title: String? = nil,
        placeholder: String? = nil,
        initialValue: String? = nil,
        keyboardType: UIKeyboardType = .default,
        isTextView: Bool = false
    ) {
        super.init(frame: .zero)
        self.isTextView = isTextView
        titleLabel.text = title
        
        if isTextView {
            textView.text = initialValue
            textView.keyboardType = keyboardType
        } else {
            textField.placeholder = placeholder
            textField.text = initialValue
            textField.keyboardType = keyboardType
        }
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        
        if isTextView {
            addSubview(textView)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                textView.leadingAnchor.constraint(equalTo: leadingAnchor),
                textView.trailingAnchor.constraint(equalTo: trailingAnchor),
                textView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            addSubview(textField)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                
                textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                textField.leadingAnchor.constraint(equalTo: leadingAnchor),
                textField.trailingAnchor.constraint(equalTo: trailingAnchor),
                textField.bottomAnchor.constraint(equalTo: bottomAnchor),
                textField.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
    
    func getValue() -> String {
        return isTextView ? textView.text : textField.text ?? ""
    }
}
