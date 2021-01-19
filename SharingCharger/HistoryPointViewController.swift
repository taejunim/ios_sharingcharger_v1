//
//  HistoryPointViewController.swift
//  SharingCharger
//
//  Created by chihong an on 2020/08/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialBottomSheet
import Alamofire
import Toast_Swift

class HistoryPointViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SearchingPointConditionProtocol {
    
    func searchingPointConditionDelegate(data: SearchingHistoryConditionObject) {
        NotificationCenter.default.post(name: .updatePointSearchingCondition, object: data, userInfo: nil)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var utils                     : Utils?
    var activityIndicator         : UIActivityIndicatorView?
    
    let rightMenuOrigin           : UIImage!  = UIImage(named: "menu_list")
    var rightMenuImage            : UIImage?
    
    let dateFormatter                         = DateFormatter()
    let calendar                              = Calendar.current
    var date                                  = Date()
    
    let myUserDefaults                        = UserDefaults.standard
    
    let ColorE74C3C              : UIColor!   = UIColor(named: "Color_E74C3C")
    let Color3498DB              : UIColor!   = UIColor(named: "Color_3498DB")

    
    
    var startDate                             = ""
    var endDate                               = ""
    var sort                                  = ""
    
    let size                                  = 10
    var page                                  = 1
    var pointUsedType                         = "ALL"
    
    var moreLoadFlag                          = false
    
    
    var arr:[PointHistoryObject.InnerItem]    = []
    
    let menuSize                              = CGSize(width:25, height:25)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.locale        = Locale(identifier: "ko")
        dateFormatter.dateFormat    = "yyyy-MM-dd"
        
        startDate = dateFormatter.string(from : calendar.date(byAdding: .month,value: -1, to: date)!)
        endDate   = dateFormatter.string(from: date)
        sort      = "DESC"
        
        let renderer = UIGraphicsImageRenderer(size: menuSize)
        rightMenuImage = renderer.image {_ in rightMenuOrigin.draw(in: CGRect(origin: .zero, size: menuSize))}

        let rightBarButton = UIBarButtonItem.init(image: rightMenuImage ,style: .done , target: self, action: #selector(rightMenu))
        
        NotificationCenter.default.addObserver(self, selector: #selector(updatePointSearchingCondition(_:)), name: .updatePointSearchingCondition, object: nil)
        
        //로딩 뷰
        utils             = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        
        getChargingHistoryData()
        
        navigationItem.rightBarButtonItem   = rightBarButton
        
        self.tableView.delegate             = self
        self.tableView.dataSource           = self
        self.tableView.allowsSelection      = false
        
        self.tableView.separatorInset       = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)         //table view margin 제거
    }
    
    @objc func updatePointSearchingCondition(_ notification: Notification) {
        
        let data = notification.object as! SearchingHistoryConditionObject
        
        startDate       = data.startDate
        endDate         = data.endDate
        sort            = data.sort
        pointUsedType   = data.pointUsedType
        
        arr.removeAll()
        
        page      = 1
        getChargingHistoryData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
                
        super.viewWillAppear(animated)
    }

    @objc func rightMenu() {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SearchingPointHistoryCondition") else { return }
            
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: tableView.frame.size.width, height: tableView.frame.size.height)
        
        let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
        
        present(bottomSheet, animated: true, completion: nil)
            
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = self.arr[indexPath.section]
        let Cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for:indexPath) as! HistoryPointTableCell
        
        if(row.type != nil){
            
            switch row.type {
            case "PURCHASE" : Cell.pointStateNm?.text = "구매"
            case "USED"     : Cell.pointStateNm?.text = "사용"
            case "REFUND"   : Cell.pointStateNm?.text = "부분 환불"
            case "CANCEL"   : Cell.pointStateNm?.text = "예약 취소"
            default: break
                        
            }
        } else {
            
            Cell.pointStateNm?.text = "포인트 사용 상태가 유효하지 않습니다."
        }
        
        var pointDate = String(row.created!).replacingOccurrences(of: "T", with: " ")
        
        let firstIndex = pointDate.index(pointDate.startIndex, offsetBy: 0)
        let lastIndex = pointDate.index(pointDate.startIndex, offsetBy: 16)
        pointDate = "\(pointDate[firstIndex..<lastIndex])"
        
        if(row.created != nil){
            Cell.pointDate?.text   = pointDate
        } else {
            Cell.pointDate?.text   = "포인트 이력 날짜가 유효하지 않습니다."
        }
        
        
        if(row.point != nil){
            
            if(row.point! >= 0){
                
                Cell.usePoint?.text = "+ \(row.point!)"
                Cell.usePoint?.textColor = Color3498DB
            }else{
                Cell.usePoint?.textColor = ColorE74C3C
                Cell.usePoint?.text = "\(row.point!)"
            }
           
        } else {
            Cell.usePoint?.text =  "포인트 사용 정보가 없습니다."
        }
            
        if(indexPath[0] == arr.count-1 && moreLoadFlag){
            
            getChargingHistoryData()
        }
        
        
        return Cell
    }
    func getChargingHistoryData(){

        var code: Int!  = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        let url         = "http://211.253.37.97:8101/api/v1/point/users/\(userId)/history"
        
        let parameters: Parameters = [
            "sort"      :sort,
            "page"      :page,
            "size"      :size,
            "startDate" :startDate,
            "endDate"   :endDate,
            "pointUsedType" : pointUsedType
        ]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
 
            switch response.result {
            
                case .success(let obj):
                
                do {
      
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(PointHistoryObject.self, from: JSONData)
                    
                    if instanceData.numberOfElements != self.size {
                        
                        self.moreLoadFlag = false
                        
                    }else {
                        
                        self.moreLoadFlag = true
                        
                    }
                    
                    for content in instanceData.content {
                        
                        self.arr.append(content)
                      
                    }
                    self.tableView.dataSource = self
                    
                    DispatchQueue.main.async {
                            
                        self.tableView.delegate             = self
                        self.tableView.dataSource           = self
                        self.tableView.allowsSelection      = false
                        self.tableView.reloadData()
                    }
                    
                    if(self.moreLoadFlag == false){
                        
                        self.activityIndicator!.stopAnimating()
                        self.activityIndicator!.isHidden = true
                        return
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
            self.activityIndicator!.isHidden = true
        })
        
    }
    
}
extension Notification.Name {
    static let updatePointSearchingCondition = Notification.Name("updatePointSearchingCondition")
}
