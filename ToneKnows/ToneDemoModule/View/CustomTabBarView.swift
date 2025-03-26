//
//  CustomTabBarView.swift
//  ToneDemo
//
//  Created by Balan iOS on 24/02/25.
//

import UIKit

class CustomTabBarView: UIView {
    
    weak var delegate: CustomTabBarDelegate?
    
    lazy var clientsButton  : UIButton = createTabButton(title: "Clients", imageName: "person.2", tag: 0)
    lazy var tryItButton    : UIButton = createTabButton(title: "Try It", imageName: "play", tag: 1)
    lazy var frequencyButton: UIButton = createTabButton(title: "Frequency", imageName: "waveform", tag: 2)
    
    lazy var buttonStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [clientsButton, tryItButton, frequencyButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI() {
        backgroundColor = .containerBackground
        addSubview(buttonStack)
        
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.topAnchor.constraint(equalTo: topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        [clientsButton, tryItButton, frequencyButton].forEach { button in
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
        }
        
        updateSelectedTab(.clientsVC)
    }
    
    func createTabButton(title: String, imageName: String, tag: Int) -> UIButton {
        let button = UIButton()
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.filled()
            config.title = title
            config.image = UIImage(systemName: imageName)
            config.imagePlacement = .top
            config.imagePadding = 5
            config.baseForegroundColor = .secondary
            config.background.backgroundColor = .clear
            
            button.configuration = config
        } else {
            button.setTitle(title, for: .normal)
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = .secondary
            button.titleLabel?.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentVerticalAlignment = .center
            button.titleEdgeInsets = UIEdgeInsets(top: 35, left: -30, bottom: 0, right: 0)
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: -button.titleLabel!.frame.width)
        }
        
        button.tag = tag
        return button
    }
    
    @objc func tabButtonTapped(_ sender: UIButton) {
        let selectedTab: ViewControllers
        switch sender.tag {
        case 0: selectedTab = .clientsVC
        case 1: selectedTab = .tryItVC
        case 2: selectedTab = .frequencyVC
        default: return
        }
        updateSelectedTab(selectedTab)
        delegate?.didSelectTab(selectedTab)
    }
    
    func updateSelectedTab(_ selectedTab: ViewControllers) {
        let selectedButton: UIButton
        switch selectedTab {
        case .clientsVC: selectedButton = clientsButton
        case .tryItVC: selectedButton = tryItButton
        case .frequencyVC: selectedButton = frequencyButton
        }
        
        [clientsButton, tryItButton, frequencyButton].forEach { button in
            button.tintColor = (button == selectedButton) ? .tabtint : .secondary
            if #available(iOS 15.0, *) {
                button.configuration?.baseForegroundColor = (button == selectedButton) ? .tabtint : .secondary
            }
        }
    }
}
