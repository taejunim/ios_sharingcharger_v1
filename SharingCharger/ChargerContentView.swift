//
//  ChargerContentView.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/06.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import RealmSwift

class ChargerContentView: UIView {

    var chargerId: Int?
    var chargerName = UILabel()
    var chargerAddress = UILabel()
    var chargingFee = UILabel()
    
    let chargingFeeText = "충전 요금 : 시간당 "
    
    var selectedChargingPeriodBar = UIView()
    var chargingPeriod = UILabel()
    
    var availableTimeText = UILabel()
    var line = UIView()
    
    var availablePeriodBar = UIView()
    var availableChargingPeriod = UILabel()
    var availableChargingPeriodText = UILabel()
    
    var favoriteButton = UIImageView()
    
    let bigFont = UIFont.boldSystemFont(ofSize: 22)
    let mediumFont = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.light)
    let smallFont = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.light)
    let starOnImage = UIImage(named: "star_on")
    let starOffImage = UIImage(named: "star_off")

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

        chargerName.translatesAutoresizingMaskIntoConstraints = false
        chargerName.text = "test1 test2"
        chargerName.textAlignment = .left
        chargerName.textColor = .darkText
        chargerName.font = bigFont
        
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.backgroundColor = .white
        favoriteButton.image = starOffImage
        
        let favoriteButtonGesture = UITapGestureRecognizer(target: self, action: #selector(self.addFavorite(_:)))
        favoriteButton.isUserInteractionEnabled = true
        favoriteButton.addGestureRecognizer(favoriteButtonGesture)
        
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
        self.addSubview(favoriteButton)
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
            
            favoriteButton.leftAnchor.constraint(equalTo: chargerName.rightAnchor, constant: 20),
            favoriteButton.widthAnchor.constraint(equalToConstant: 30),
            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
            favoriteButton.centerYAnchor.constraint(equalTo: chargerName.centerYAnchor),
            
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
    
    public func changeValue(chargerNameText: String?, chargerId: Int?, chargerAddressText: String?, rangeOfFeeText: String?) {
        chargerName.text = chargerNameText
        self.chargerId = chargerId
        chargerAddress.text = chargerAddressText
        
        if let fee = rangeOfFeeText {
            chargingFee.text = chargingFeeText + fee + "원"
        } else {
            chargingFee.text = chargingFeeText + "- 원"
        }
        
        setStarImage(chargerId: self.chargerId!)
    }
    
    private func setStarImage(chargerId: Int?) {
        
        let originFavorite = getFavoriteObject(chargerId: chargerId)
        
        if originFavorite != nil {
            
            favoriteButton.image = starOnImage
            
        } else {
            
            favoriteButton.image = starOffImage
        }
    }
    
    @objc func addFavorite(_ sender: UITapGestureRecognizer) {
        
        let realm = try! Realm()
        
        let originFavorite = getFavoriteObject(chargerId: self.chargerId!)
        
        //즐겨찾기 추가된것을 삭제
        if originFavorite != nil {
            
            try! realm.write {
                realm.delete(originFavorite!)
            }
            
            favoriteButton.image = starOffImage
        }
        
        //즐겨찾기 추가
        else {
            
            let favorite = FavoriteObject()
            
            favorite.chargerId = self.chargerId!
            favorite.chargerName = self.chargerName.text!
            favorite.chargerAddress = self.chargerAddress.text!
            
            try! realm.write {
                realm.add(favorite)
            }
            
            favoriteButton.image = starOnImage
        }
    }
    
    private func getFavoriteObject(chargerId: Int?) -> Results<FavoriteObject>? {
        
        let realm = try! Realm()
        
        let favoriteObject = realm.objects(FavoriteObject.self).filter("chargerId == \(chargerId!)")
        
        if favoriteObject.first?.chargerId != nil {
            return favoriteObject
        } else {
            return nil
        }
    }
}
