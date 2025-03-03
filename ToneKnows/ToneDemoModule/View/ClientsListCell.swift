//
//  ClientsListCell.swift
//  ToneDemo
//
//  Created by Balan iOS on 20/02/25.
//

import UIKit

class ClientsListCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .containerBackground
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var clientImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 35
        imageView.clipsToBounds = true
        imageView.backgroundColor = .containerBackground
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .secondary
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [clientImageView, nameLabel])
        view.axis = .horizontal
        view.spacing = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.tintColor = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .containerBackground
        
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        containerView.addSubview(separatorView)
        clientImageView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            // Container View Constraints
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            // Image Constraints
            clientImageView.widthAnchor.constraint(equalToConstant: 70),
            clientImageView.heightAnchor.constraint(equalToConstant: 70),
            
            // Activity Indicator Constraints
            activityIndicator.centerXAnchor.constraint(equalTo: clientImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: clientImageView.centerYAnchor),
            
            // StackView Constraints
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            
            // Separator Constraints
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -5),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with client: Client, isSelected: Bool) {
        nameLabel.text = client.name
        activityIndicator.startAnimating()
        
        if let remoteImageURL = client.logo, !remoteImageURL.isEmpty {
            clientImageView.setImage(from: .azureImageURL(basePath: .LOGO, fileName: remoteImageURL)) { result in
                if let result, result {
                    print("------------ success ::::: \(result) -----------")
                } else {
                    if let localImagePath = client.logoData, !localImagePath.isEmpty,
                       let image = self.loadImageFromPath(localImagePath) {
                        self.clientImageView.image = image
                        self.activityIndicator.stopAnimating()
                    } else {
                        self.clientImageView.image = UIImage(named: "placeholder")
                    }
                }
            }
        }
        
        activityIndicator.stopAnimating()
        updateAppearance(isSelected: isSelected)
    }
    
    private func loadImageFromPath(_ path: String) -> UIImage? {
        let fileURL = URL(fileURLWithPath: path)
        if let imageData = try? Data(contentsOf: fileURL) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func updateAppearance(isSelected: Bool) {
        let isDarkMode = checkSystemDarkModeOnOrOff()
        
        let backgroundColor: UIColor = isSelected == isDarkMode ? .clientWhiteBack : .clientDarkBack
        let textColor: UIColor = isSelected == isDarkMode ? .clientDarkBack : .clientWhiteBack
        
        containerView.backgroundColor = backgroundColor
        stackView.backgroundColor = backgroundColor
        nameLabel.textColor = textColor
    }
    
    func checkSystemDarkModeOnOrOff() -> Bool {
        return traitCollection.userInterfaceStyle == .dark
    }
}
