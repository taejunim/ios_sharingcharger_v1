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
    var chargerAddress = UILabel()
    var chargingFee = UILabel()
    
    let chargingFeeText = "충전 요금 : 시간당 "
    var fee = ""
    
    var selectedChargingPeriodBar = UIView()
    var chargingPeriod = UILabel()
    
    var availableTimeText = UILabel()
    var line = UIView()
    
    var availablePeriodBar = UIView()
    var availableChargingPeriod = UILabel()
    var availableChargingPeriodText = UILabel()

    let bigFont = UIFont.boldSystemFont(ofSize: 22)
    let mediumFont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
    let smallFont = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)

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
        chargerName.textAlignment = .left
        chargerName.textColor = .darkText
        chargerName.font = bigFont
        
        chargerAddress.translatesAutoresizingMaskIntoConstraints = false
        chargerAddress.text = "첨단과학단지로 1003"
        chargerAddress.textAlignment = .left
        chargerAddress.textColor = .darkText
        chargerAddress.font = mediumFont
        
        chargingFee.translatesAutoresizingMaskIntoConstraints = false
        chargingFee.text = chargingFeeText
        chargingFee.textAlignment = .left
        chargingFee.textColor = .darkText
        chargingFee.font = mediumFont
        
        chargingPeriod.translatesAutoresizingMaskIntoConstraints = false
        chargingPeriod.text = "17:00 - 18:30"
        chargingPeriod.textAlignment = .center
        chargingPeriod.textColor = .darkText
        chargingPeriod.font = smallFont
        
        selectedChargingPeriodBar.translatesAutoresizingMaskIntoConstraints = false
        selectedChargingPeriodBar.backgroundColor = .red
        
        availableTimeText.translatesAutoresizingMaskIntoConstraints = false
        availableTimeText.text = "이용 가능 시간"
        availableTimeText.textAlignment = .left
        availableTimeText.textColor = .darkText
        availableTimeText.font = bigFont
        
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = UIColor(named: "Color_E0E0E0")
        
        availablePeriodBar.translatesAutoresizingMaskIntoConstraints = false
        availablePeriodBar.backgroundColor = .blue
        
        availableChargingPeriod.translatesAutoresizingMaskIntoConstraints = false
        availableChargingPeriod.text = "16:00 - 20:30"
        availableChargingPeriod.textAlignment = .center
        availableChargingPeriod.textColor = .darkText
        availableChargingPeriod.font = smallFont
        
        availableChargingPeriodText.translatesAutoresizingMaskIntoConstraints = false
        availableChargingPeriodText.text = "위 시간대에 이용이 가능합니다."
        availableChargingPeriodText.textAlignment = .center
        availableChargingPeriodText.textColor = .darkText
        availableChargingPeriodText.font = mediumFont
        
        self.addSubview(chargerName)
        self.addSubview(chargerAddress)
        self.addSubview(chargingFee)
        self.addSubview(chargingPeriod)
        self.addSubview(selectedChargingPeriodBar)
        self.addSubview(availableTimeText)
        self.addSubview(line)
        self.addSubview(availablePeriodBar)
        self.addSubview(availableChargingPeriod)
        self.addSubview(availableChargingPeriodText)

        let borderView = UIView()
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.backgroundColor = .white
        borderView.alpha = 0.4
        self.addSubview(borderView)

        NSLayoutConstraint.activate([
            chargerName.topAnchor.constraint(equalTo: self.topAnchor, constant: 15),
            chargerName.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            chargerAddress.topAnchor.constraint(equalTo: chargerName.bottomAnchor, constant: 5),
            chargerAddress.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            chargingFee.topAnchor.constraint(equalTo: chargerAddress.bottomAnchor, constant: 10),
            chargingFee.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            selectedChargingPeriodBar.topAnchor.constraint(equalTo: chargingFee.bottomAnchor, constant: 30),
            selectedChargingPeriodBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            selectedChargingPeriodBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            selectedChargingPeriodBar.heightAnchor.constraint(equalToConstant: 5),
            
            chargingPeriod.topAnchor.constraint(equalTo: selectedChargingPeriodBar.bottomAnchor, constant: 10),
            chargingPeriod.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            chargingPeriod.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            availableTimeText.topAnchor.constraint(equalTo: chargingPeriod.bottomAnchor, constant: 100),
            availableTimeText.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            
            line.topAnchor.constraint(equalTo: availableTimeText.bottomAnchor, constant: 30),
            line.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            line.heightAnchor.constraint(equalToConstant: 1),
            
            availablePeriodBar.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 30),
            availablePeriodBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            availablePeriodBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            availablePeriodBar.heightAnchor.constraint(equalToConstant: 5),
            
            availableChargingPeriod.topAnchor.constraint(equalTo: availablePeriodBar.bottomAnchor, constant: 20),
            availableChargingPeriod.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            availableChargingPeriod.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            availableChargingPeriodText.topAnchor.constraint(equalTo: availableChargingPeriod.bottomAnchor, constant: 10),
            availableChargingPeriodText.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            availableChargingPeriodText.trailingAnchor.constraint(equalTo: self.trailingAnchor),

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
