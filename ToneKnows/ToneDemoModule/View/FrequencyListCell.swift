//
//  FrequencyListCell.swift
//  ToneDemo
//
//  Created by Balan iOS on 21/02/25.
//

import UIKit

class FrequencyListCell: UITableViewCell {
    
    private let frequencyLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondary
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .containerBackground
        
        contentView.addSubview(frequencyLabel)
        NSLayoutConstraint.activate([
            frequencyLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            frequencyLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            frequencyLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with frequency: String) {
        frequencyLabel.text = frequency
    }
}
