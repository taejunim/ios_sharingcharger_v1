//
//  SearchAddressViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/11/11.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire

protocol SearchingAddressProtocol {
    func searchingAddressDelegate(data: SelectedPositionObject)
}
class SearchingAddressViewController : UIViewController,  UITableViewDelegate ,UITableViewDataSource, UITextFieldDelegate {
    
    var utils                           : Utils?
    var activityIndicator               : UIActivityIndicatorView?
    
    var delegate                        : SearchingAddressProtocol?
    
    @IBOutlet var tableView             : UITableView!
    
    @IBOutlet var searchTextField       : UITextField!
    
    @IBOutlet var myPositionButton      : UIButton!
    @IBOutlet var mapButton             : UIButton!
    
    
    var arr                             :[SearchingAddressObject.Place]   = []
    
    var selectedPosition                : SelectedPositionObject = SelectedPositionObject()
    
    var defaultAddress                  : String                          = ""
    var mapLatitude                     : Double?
    var mapLongitude                    : Double?
    var userLatitude                    : Double?
    var userLongitude                   : Double?
    
    var page                                                              = 1
    let size                                                              = 10
    var moreLoadFlag                                                      = false
        
    let buttonBorderWidth               : CGFloat!                        = 1.0
    let ColorE0E0E0                     : UIColor!                        = UIColor(named: "Color_E0E0E0")
    let Color3498DB                     : UIColor!                        = UIColor(named: "Color_3498DB")
    let ColorWhite                      : UIColor!                        = UIColor.white
    
    let kakaoApiKey                                                       = "KakaoAK 4332dce3f2f8d3ee87e31884c5c5523d"
    
    var searchLatitude                  : Double?
    var searchLongitude                 : Double?
    
    override func viewDidLoad() {
        
        print("SearchingAddressViewController - viewDidLoad")
        
        super.viewDidLoad()
        addButton(buttonName: "close", width: 40, height: 40, top: 15, left: nil, right: -10, bottom: nil, target: self.view, targetViewController: self)
        
        //key event 통신 위한 delegate 설정
        searchTextField.delegate         = self
        
        self.tableView.delegate          = self
        self.tableView.dataSource        = self
        self.tableView.allowsSelection   = false
        
        //table view margin 제거
        self.tableView.separatorInset    = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //Main View로 선택한 위치의 좌표를 넘기기 위한 delegate 설정
        self.delegate = MainViewController()
        
        //로딩 뷰
        utils                            = Utils(superView: self.view)
        activityIndicator                = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        
        searchTextField.text = defaultAddress
                
        initializeButton()
        
    }
    func initializeButton(){
        
        myPositionButton.layer.borderWidth  = buttonBorderWidth
        mapButton.layer.borderWidth         = buttonBorderWidth
        myPositionButton.addTarget(self, action: #selector(setButton(_:)), for: .touchUpInside)
        mapButton.addTarget(self, action: #selector(setButton(_:)), for: .touchUpInside)
        
        setButton(myPositionButton)
        
    }
    @IBAction func setButton(_ sender: UIButton) {
        
        
        switch sender {
            case myPositionButton:
                myPositionButton.layer.borderColor = Color3498DB?.cgColor
                myPositionButton.layer.backgroundColor = Color3498DB?.cgColor
                myPositionButton.setTitleColor(ColorWhite, for: .normal)
                mapButton.layer.borderColor = ColorE0E0E0?.cgColor
                mapButton.layer.backgroundColor = ColorWhite?.cgColor
                mapButton.setTitleColor(ColorE0E0E0, for: .normal)
                searchLatitude = userLatitude
                searchLongitude = userLongitude
                break
            case mapButton:
                myPositionButton.layer.borderColor = ColorE0E0E0?.cgColor
                myPositionButton.layer.backgroundColor = ColorWhite?.cgColor
                myPositionButton.setTitleColor(ColorE0E0E0, for: .normal)
                mapButton.layer.borderColor = Color3498DB?.cgColor
                mapButton.layer.backgroundColor = Color3498DB?.cgColor
                mapButton.setTitleColor(ColorWhite, for: .normal)
                searchLatitude = mapLatitude
                searchLongitude = mapLongitude
                break
            default:
                break
        }
        
        arr.removeAll()
        page = 1
        getAddressList()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.arr[indexPath.section]
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath) as! AddressTableCell
        
        Cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tableViewClick)))
        if(row.place_name != nil){
            
            Cell.placeName?.text = row.place_name
            
        } else{
            
            Cell.placeName?.text = " "
            
        }
        
        if(row.category_group_code != nil){
            
            Cell.categoryGroupName?.text = checkCategory(categoryGroupCode : String(row.category_group_code!))
        } else{
            
            Cell.categoryGroupName?.text = " "
            
        }
        
        if(row.address_name != nil){
            
            Cell.addressName?.text = row.address_name
            
        } else{
            
            Cell.addressName?.text = " "
        }
        
        if(row.phone != nil){
            
            Cell.phone?.text = row.phone
            
        } else{
            
            Cell.phone?.text = " "
        }
        
        if(indexPath[0] == arr.count-1 && moreLoadFlag){
            
            getAddressList()
        }
        
        return Cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arr.count
    }

    
    func tableView(_ tableView:UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 140
    }
    
    @objc func tableViewClick(sender : UITapGestureRecognizer){
        
        let tapLocation = sender.location(in: tableView)
        let indexPath = self.tableView.indexPathForRow(at: tapLocation)
        
        if let selectedIndex = indexPath?[0] {
            
            if let x =  arr[selectedIndex].x , let y = arr[selectedIndex].y , let placeName = arr[selectedIndex].place_name{
            
                selectedPosition.longitude = Double(x)
                selectedPosition.latitude = Double(y)
                selectedPosition.place_name = placeName
                delegate?.searchingAddressDelegate(data : selectedPosition)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        //엔터 누르면 키보드 내리고 kakao api 호출
        textField.resignFirstResponder()
        
        arr.removeAll()
        page = 1
        getAddressList()
        return true
    }
    
    private func addButton(buttonName: String?, width: CGFloat?, height: CGFloat?, top: CGFloat?, left: CGFloat?, right: CGFloat?, bottom: CGFloat?, target: AnyObject, targetViewController: AnyObject) {
        
        let button = CustomButton(type: .system)
        
        self.view.addSubview(button)
        
        button.setAttributes(buttonName: buttonName, width: width, height: height, top: top, left: left, right: right, bottom: bottom, target: target, targetViewController: targetViewController)
    }
    
    @objc func closeButton(sender: UIButton!) {
    
        self.dismiss(animated: true, completion: nil)
    }
    
    func getAddressList(){
        
        var code: Int!  = 0
        let headers: HTTPHeaders = [

            "Authorization": kakaoApiKey
                ]
        
        let query = searchTextField.text!
        
        if(query == ""){
            
            self.view.makeToast("검색 조건을 입력하여 주십시오.")
            return
        }
        
        let parameters: Parameters = [
                    "query" : query,
                    "page"  : page,
                    "size"  : size,
                    "sort"  : "distance",
                    "x"     : searchLongitude!,
                    "y"     : searchLatitude!
                ]

        let url         = "https://dapi.kakao.com/v2/local/search/keyword.json"
        
        AF.request(url, method: .get ,parameters: parameters, encoding: URLEncoding.default, headers : headers,  interceptor: Interceptor(indicator: activityIndicator!) ).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
 
            switch response.result {
            
                case .success(let obj):
                
                do {
                        
                        print(parameters)
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        let instanceData = try JSONDecoder().decode(SearchingAddressObject.self, from: JSONData)
                    
                    if instanceData.documents.count != self.size {
                        
                        self.moreLoadFlag = false
                        
                    }else {
                        
                        self.moreLoadFlag = true
                        
                    }
                    
                    for content in instanceData.documents {
                      
                        self.arr.append(content)
                      
                    }
                    self.tableView.dataSource = self
                    
                    DispatchQueue.main.async {
                            
                        self.tableView.delegate             = self
                        self.tableView.dataSource           = self
                        self.tableView.allowsSelection      = false
                        self.tableView.reloadData()
                    }
                    
                    self.page += 1
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("400 Error.")
                    self.view.makeToast("400 Error", duration: 2.0, position: .bottom)

                } else {
                    print("Unknown Error")
                    self.view.makeToast("Error.", duration: 2.0, position: .bottom)
                }
            }
            
            self.activityIndicator!.stopAnimating()
        })
        
    }
    
    
    
    func checkCategory(categoryGroupCode : String) -> String{
        
        switch categoryGroupCode {
            case "MT1":
                return "대형마트"
            case "CS2":
                return "편의점"
            case "PS3":
                return "어린이집, 유치원"
            case "SC4":
                return "학교"
            case "AC5":
                return "학원"
            case "PK6":
                return "주차장"
            case "OL7":
                return "주유소, 충전소"
            case "SW8":
                return "지하철역"
            case "BK9":
                return "은행"
            case "CT1":
                return "문화시설"
            case "AG2":
                return "중개업소"
            case "PO3":
                return "공공기관"
            case "AT4":
                return "관광명소"
            case "AD5":
                return "숙박"
            case "FD6":
                return "음식점"
            case "CE7":
                return "카페"
            case "HP8":
                return "병원"
            case "PM9":
                return "약국"
            default:
                return " "
        }
    }
}
