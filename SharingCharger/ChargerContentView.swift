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
    
    var selectedChargingPeriodBar = UIView()    //예약 상태바 전체뷰 -> 이후 이 바에 24개의 서브뷰가 add 됨
    
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
    
    let locale = Locale(identifier: "ko")
    let dateFormatter = DateFormatter()
    let yyyyMMDDFormatter = DateFormatter()
    let calendar = Calendar.current
    
    let ColorE0E0E0: UIColor! = UIColor(named: "Color_E0E0E0")  //회색
    let Color3498DB: UIColor! = UIColor(named: "Color_3498DB")  //파랑
    let ColorE74C3C: UIColor! = UIColor(named: "Color_E74C3C")  //빨강
    
    var reservationStateBarList = Array<ReservationStateBarObject>()    //예약 상태바에 들어갈 리스트
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setView()
        
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        yyyyMMDDFormatter.locale = locale
        yyyyMMDDFormatter.dateFormat = "yyyy-MM-dd'T'"
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
        selectedChargingPeriodBar.backgroundColor = .gray
        
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
    
    //충전기명, 주소, 시간당 요금, 즐겨찾기 유/무 를 동적으로 변경
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
    
    //예약 상태바 그리기
    public func setReservationStateBar(availableTimeList: Array<AvailableTimeObject>?, reservationList: Array<CurrentReservationObject>?, countOfSelectedPeriod: Int?, selectedStartDate: String?, selectedTimePeriod: String?) {
        
        chargingPeriod.text = selectedTimePeriod!
        
        //기존에 add한 subview 들 제거
        for view in selectedChargingPeriodBar.subviews {
            view.removeFromSuperview()
        }
        
        reservationStateBarList = Array<ReservationStateBarObject>()
        
        //선택한 시작 일시
        let selectedStartDate = dateFormatter.date(from: selectedStartDate!)
        
        //선택한 시작 일시의 뷰 개수
        for i in 1...countOfSelectedPeriod! {
        
            let selectedReservationStateBarObject = ReservationStateBarObject()
            selectedReservationStateBarObject.type = "selected"
            let tag = Int(selectedStartDate!.currentTimeMillis()) + (i - 1) * 1800000
            selectedReservationStateBarObject.id = tag
            
            reservationStateBarList.append(selectedReservationStateBarObject)
        }
        
        //예약 목록으로 뷰 개수 구함
        for item in reservationList! {
            
            let startDate = dateFormatter.date(from: item.startDate!)
            let endDate = dateFormatter.date(from: item.endDate!)
            
            addUnavailableTimeList(startDate: startDate, endDate: endDate)
        }
        
        //충전기 소유주의 오픈 시간, 마감 시간에 따라 상태바 빨간색 갯수 구하기
        checkAvailableChargerTime(availableTimeList: availableTimeList)
        
        //예약 상태바의 기준점 -> 선택한 시간 - 2시간(7200000)
        let firstTag = Int(selectedStartDate!.currentTimeMillis()) - 7200000
        
        //예약 상태바 그리기
        var beforeView = UIView()

        //예약 상태바 30분 단위로 24칸 -> 선택한 시간 2시간 전부터 10시간 후까지 총 12시간까지 볼 수 있음
        for i in 1 ... 24 {
            
            let tag = firstTag + (i - 1) * 1800000
            
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.tag = tag
            view.backgroundColor = ColorE0E0E0
            
            if let j = reservationStateBarList.firstIndex(where: { $0.id == tag }) {
                
                //선택한 시간은 파란색
                if reservationStateBarList[j].type == "selected" {
                    view.backgroundColor = Color3498DB
                }
                
                //예약된 시간이나 소유주가 openTime, closeTime 을 막은 경우 빨간색
                else if reservationStateBarList[j].type == "reservation" {
                    view.backgroundColor = ColorE74C3C
                }
                
                //선택한 시간이 예약된 시간과 겹칠경우 예약 불가능한 빨간색 처리
                if let k = reservationStateBarList.lastIndex(where: { $0.id == tag }) {
                    if reservationStateBarList[j].id == reservationStateBarList[k].id && reservationStateBarList[k].type == "reservation"{
                        view.backgroundColor = ColorE74C3C
                    }
                }
            }
            
            selectedChargingPeriodBar.addSubview(view)
            
            //24개의 뷰 autolayout
            let trailingIndex: Int! = 24 - i
            let trailingConstant: CGFloat! = 0 - CGFloat(Int(selectedChargingPeriodBar.frame.width) * trailingIndex) / 24
            
            view.topAnchor.constraint(equalTo: selectedChargingPeriodBar.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: selectedChargingPeriodBar.bottomAnchor).isActive = true
            
            if i == 1 {
                view.leftAnchor.constraint(equalTo: selectedChargingPeriodBar.leftAnchor).isActive = true
            } else {
                view.leftAnchor.constraint(equalTo: beforeView.rightAnchor, constant: 0).isActive = true    //이전의 뷰 오른쪽을 현재 뷰의 왼쪽과 맞추기 위함
            }
            
            view.rightAnchor.constraint(equalTo: selectedChargingPeriodBar.rightAnchor, constant: trailingConstant).isActive = true
            
            beforeView = view   //이전의 뷰 오른쪽을 현재 뷰의 왼쪽과 맞추기 위함
        }
        
    }
    
    //충전기 소유주의 요일별 오픈 시간, 마감 시간 체크해서 list add
    private func checkAvailableChargerTime(availableTimeList: Array<AvailableTimeObject>?) {
        
        let today = yyyyMMDDFormatter.string(from: Date())
        let tomorrow = yyyyMMDDFormatter.string(from: calendar.date(byAdding: .day, value: 1, to: Date())!)
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: Date())
        
        var dayArray: [String] = []
        
        //요일별 분기 처리
        if let i = availableTimeList!.firstIndex(where: { $0.day == "SAT" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "SUN" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        } else if let i = availableTimeList!.firstIndex(where: { $0.day == "SUN" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "MON" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        } else if let i = availableTimeList!.firstIndex(where: { $0.day == "MON" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "TUE" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        } else if let i = availableTimeList!.firstIndex(where: { $0.day == "TUE" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "WED" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        } else if let i = availableTimeList!.firstIndex(where: { $0.day == "WED" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "THR" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        } else if let i = availableTimeList!.firstIndex(where: { $0.day == "THR" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "FRI" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        } else if let i = availableTimeList!.firstIndex(where: { $0.day == "FRI" }) {
            if let j = availableTimeList!.firstIndex(where: { $0.day == "SAT" }) {
                dayArray.append(availableTimeList![i].day!)
                dayArray.append(availableTimeList![j].day!)
            }
        }
        
        for index in 0..<dayArray.count {
            
            if let i = availableTimeList!.firstIndex(where: { $0.day == dayArray[index] }) {
                var availableTimeObject = AvailableTimeObject()
                availableTimeObject = availableTimeList![i]
                
                var startDate = Date()
                var endDate = Date()
                var time: String!
                
                //오픈 시간이 00:00:00 이 아니고 , 마감 시간이 23:59:59 일 때
                //ex) 03:00:00 ~ 23:59:59
                if availableTimeObject.openTime != "00:00:00" && availableTimeObject.closeTime == "23:59:59" {
                    print("ex) 03:00:00 ~ 23:59:59")
                    if index == 0 {
                        time = today + availableTimeObject.openTime!
                        startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
                    } else if index == 1 {
                        time = tomorrow + availableTimeObject.openTime!
                        startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrowDate!)!
                    }
                    
                    let startDateString = dateFormatter.string(from: startDate)
                    
                    startDate = dateFormatter.date(from: startDateString)!
                    endDate = dateFormatter.date(from: time)!
                    
                    addUnavailableTimeList(startDate: startDate, endDate: endDate)
                }
                
                //오픈 시간이 00:00:00, 마감 시간이 23:59:59 가 아닐 때
                //ex) 00:00:00 ~ 20:00:00
                else if availableTimeObject.openTime == "00:00:00" && availableTimeObject.closeTime != "23:59:59" {
                    print("ex) 00:00:00 ~ 20:00:00")
                    if index == 0 {
                        time = today + availableTimeObject.closeTime!
                        endDate = calendar.date(byAdding: .day, value: 1, to: endDate)!
                    } else if index == 1 {
                        time = tomorrow + availableTimeObject.closeTime!
                        endDate = calendar.date(byAdding: .day, value: 2, to: endDate)!
                    }
                    
                    endDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: endDate)!
                    let endDateString = dateFormatter.string(from: endDate)
                    
                    startDate = dateFormatter.date(from: time)!
                    endDate = dateFormatter.date(from: endDateString)!
                    
                    addUnavailableTimeList(startDate: startDate, endDate: endDate)
                }
                
                //오픈 시간이 00:00:00 가 아니고, 마감 시간이 23:59:59 가 아닐 때
                //ex) 03:00:00 ~ 20:00:00
                else if availableTimeObject.openTime != "00:00:00" && availableTimeObject.closeTime != "23:59:59" {
                    print("ex) 03:00:00 ~ 20:00:00")
                    for i in 0 ... 1 {
                        
                        //openTime
                        if i == 0 {
                            time = availableTimeObject.openTime
                            
                            if index == 0 {
                                
                                time = today + time
                                
                                startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
                                
                            } else if index == 1 {
                                
                                time = tomorrow + time
                                
                                startDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrowDate!)!
                            }
                            
                            let startDateString = dateFormatter.string(from: startDate)
                            startDate = dateFormatter.date(from: startDateString)!
                            
                            endDate = dateFormatter.date(from: time)!
                        }
                        
                        //closeTime
                        else if i == 1 {
                            time = availableTimeObject.closeTime
                            
                            if index == 0 {
                                
                                time = today + time
                                
                                endDate = calendar.date(byAdding: .day, value: 1, to: endDate)!
                                
                            } else if index == 1 {
                                
                                time = tomorrow + time
                                
                                endDate = calendar.date(byAdding: .day, value: 2, to: endDate)!
                            }
                            
                            startDate = dateFormatter.date(from: time)!
                            
                            endDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: endDate)!
                            let endDateString = dateFormatter.string(from: endDate)
                            
                            endDate = dateFormatter.date(from: endDateString)!
                        }
                     
                        addUnavailableTimeList(startDate: startDate, endDate: endDate)
                    }
                }
            }
        }
    }
    
    //이용 불가능한 시간을 list에 add
    private func addUnavailableTimeList(startDate: Date!, endDate: Date!) {
        
        var viewCount = 0
        
        let offsetComps = calendar.dateComponents([.hour,.minute], from:startDate, to:endDate)
        if case let (hour?, minute?) = (offsetComps.hour, offsetComps.minute) {
            
            //30분
            if hour == 0 && minute != 0 {
                viewCount = 1
            }
            
            //1시간 .. 2시간
            else if hour != 0 && minute == 0 {
                viewCount = hour * 2
            }
            
            //1시간 30분 .. 2시간 30분
            else if hour != 0 && minute != 0 {
                viewCount = hour * 2 + 1
            }
        }
        
        if viewCount > 0 {
            for i in stride(from: 1, through: viewCount, by: 1) {
            
                let reservationStateBarObject = ReservationStateBarObject()
                reservationStateBarObject.type = "reservation"
                let tag = Int(startDate.currentTimeMillis()) + (i - 1) * 1800000
                reservationStateBarObject.id = tag
                
                reservationStateBarList.append(reservationStateBarObject)
            }
        }
    }
    
    //즐겨찾기 이미지 set
    private func setStarImage(chargerId: Int?) {
        
        let originFavorite = getFavoriteObject(chargerId: chargerId)
        
        if originFavorite != nil {
            
            favoriteButton.image = starOnImage
            
        } else {
            
            favoriteButton.image = starOffImage
        }
    }
    
    //즐겨찾기 추가/삭제
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
    
    //로컬DB에서 즐겨찾기 가져오기
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

extension Date {
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
