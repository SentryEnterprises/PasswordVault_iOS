//
//  EntryTableViewCell.swift
//  GateKeeper
//

import UIKit

class EntryTableViewCell: UITableViewCell {
    let iconImageView = UIImageView()
    let titleLabel = UILabel()

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = UIColor(hex: 0xEFEFEF)
            } else {
                backgroundColor = nil
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Icon image view

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(iconImageView)
        NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal, toItem: iconImageView, attribute: .height, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: iconImageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 10.0).isActive = true
        NSLayoutConstraint(item: iconImageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: -10.0).isActive = true
        NSLayoutConstraint(item: iconImageView, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 10.0).isActive = true

        // Title label

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(titleLabel)
        NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .left, relatedBy: .equal, toItem: iconImageView, attribute: .right, multiplier: 1.0, constant: 20.0).isActive = true
        NSLayoutConstraint(item: titleLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: -10.0).isActive = true
    }

    func setIcon(iconName: String, tintColor: UIColor) {
        iconImageView.image = UIImage(named: iconName)?.tint(with: tintColor)
    }
}
