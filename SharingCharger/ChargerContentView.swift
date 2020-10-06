//
//  ChargerContentView.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/06.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit

class ChargerContentView: UIView {

    var chargerName = UILabel()
    var chargerAddress = ""
    var chargingFee = "충전 요금 시간당 "
    var fee = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setView() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white

        //let label = UILabel()
        chargerName.translatesAutoresizingMaskIntoConstraints = false
        chargerName.text = "test1 test2"
        chargerName.textAlignment = .center
        chargerName.textColor = .darkText
        self.addSubview(chargerName)

        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .white
        borderView.alpha = 0.4
        self.addSubview(borderView)

        NSLayoutConstraint.activate([
            chargerName.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            chargerName.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            chargerName.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            borderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 2),
            borderView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    public func changeValue(chargerNameText: String?) {
        chargerName.text = chargerNameText
        
    }
}
