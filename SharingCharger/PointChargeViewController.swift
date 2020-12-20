//
//  PointChargeViewController.swift
//  SharingCharger
//
//  Created by 조유영 on 2020/12/02.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import Alamofire
class PointChargeViewController : UIViewController , UITextFieldDelegate{
    
    
    @IBOutlet var pointView: UIView!
    @IBOutlet var cardVIew: UIView!
    
    @IBOutlet var currentPoint: UILabel!
    @IBOutlet var chargePoint: UITextField!
    
    @IBOutlet var firstCardNumber: UITextField!
    @IBOutlet var secondCardNumber: UITextField!
    @IBOutlet var thirdCardNumber: UITextField!
    @IBOutlet var fourthCardNumber: UITextField!
    
    @IBOutlet var validMonth: UITextField!
    @IBOutlet var validYear: UITextField!
    
    @IBOutlet var password: UITextField!
    
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var confirmButton: UIButton!
    
    
    let myUserDefaults = UserDefaults.standard
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    let numberSeperateFormatter = NumberFormatter()
    let numberNoSeperateFormatter = NumberFormatter()
    
    override func viewDidLoad() {
        
        print("PointChargeViewController - viewDidLoad")
        
        super.viewDidLoad()
        viewWillInitializeObjects()
        
    }
    
    private func viewWillInitializeObjects() {
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        
        self.activityIndicator!.startAnimating()
        getPoint()
        setKeyboard()
        
        pointView.layer.cornerRadius = 10
        cardVIew.layer.cornerRadius = 10

        
        cancelButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(self.confirm), for: .touchUpInside)
        
        chargePoint.setRightPaddingPoints(15)
        
        chargePoint.delegate = self
        
        firstCardNumber.delegate = self
        secondCardNumber.delegate = self
        thirdCardNumber.delegate = self
        fourthCardNumber.delegate = self
        
        validMonth.delegate = self
        validYear.delegate = self
        
        password.delegate = self
        
    }
    
    private func getPoint() {
        
        var code: Int! = 0
        
        let userId = myUserDefaults.integer(forKey: "userId")
        let url = "http://211.253.37.97:8101/api/v1/point/users/\(userId)"
        
        AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
                
                self.activityIndicator!.stopAnimating()
                
                if code == 200 {
                    
                    let point: Int = obj as! Int
                    
                    self.currentPoint.text = self.setComma(value: point)
                    
                } else {
                    self.currentPoint.text = "-"
                }
                
            case .failure(let err):
                
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("Unknown Error")
                    
                } else {
                    print("Unknown Error")
                }
                
                self.currentPoint.text = "-"
                self.activityIndicator!.stopAnimating()
            }
        })
    }
    
    private func setComma(value: Int) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))!
        
        return result
    }
    
    func pointCharge(){
        
        let pointText = chargePoint.text?.replacingOccurrences(of: ",", with: "")
        let point = Int(pointText!)
        
        self.activityIndicator!.startAnimating()
        
        let url = "http://211.253.37.97:8101/api/v1/point"
        let userId = myUserDefaults.integer(forKey: "userId")
        
        let parameters: Parameters = [
            "point" : point!,
            "pointUsedType" : "PURCHASE",
            "userId" : userId
        ]
        
        var code: Int! = 0
        
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default,headers: ["Content-Type":"application/json"], interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
            
            code = response.response?.statusCode
            
            switch response.result {
            
            case .success(let obj):
               
                do {
        
                    let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                    let instanceData = try JSONDecoder().decode(PointHistoryObject.InnerItem.self, from: JSONData)
                    print(instanceData)
                    self.activityIndicator!.stopAnimating()
                    
                    self.showAlert(title: "포인트 충전 완료", message: "포인트 충전이 완료되었습니다.", positiveTitle: "확인", negativeTitle: nil, textField: nil)
                    
                } catch {
                    print("error : \(error.localizedDescription)")
                    print("서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)")
                    
                    self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil, textField: nil)
                    return
                }
                
            //실패
            case .failure(let err):
                
                print("response : \(response)")
                print("error is \(String(describing: err))")
                
                if code == 400 {
                    print("실패")
                } else {
                    print("Unknown Error")
                }
                
                self.activityIndicator!.stopAnimating()
                self.showAlert(title: "서버 에러", message: "서버와 통신이 원활하지 않습니다.\n문제가 지속될 시 고객센터로 문의주십시오. code : \(code!)", positiveTitle: "확인", negativeTitle: nil, textField: nil)
                return
            }
        })
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
               
        
        if var text = textField.text {
            
            if !string.isEmpty {                // not backspace
                text += string
            }else{                              // backspace
                text = String(text.dropLast())
            }
            
            switch textField {
        
                case chargePoint :
            
                    if(text.count > 0) {
                    
                        text = text.replacingOccurrences(of: ",", with: "")
                        text = setComma(value: Int(text)!)
                    }
                
                    textField.text = text
            
                case firstCardNumber ,
                     secondCardNumber ,
                     thirdCardNumber ,
                     fourthCardNumber ,
                     validYear ,
                     validMonth ,
                     password :

                    var length = 4
                    
                    if textField == validYear || textField == validMonth || textField == password {
                        
                        length = 2
                        
                    }
                    
                    textField.text = text
                    
                    if text.count == length {
                        
                        let textFieldTag:Int = textField.tag
                        
                        if let textFieldNext = self.view.viewWithTag(textFieldTag + 1) as? UITextField {
                            textFieldNext.becomeFirstResponder()
                        } else {
                            textField.resignFirstResponder()
                        }
                    }
                    
            default : break;
        
            }
        }
        
        return false
    }
    
    @objc func cancel(sender : UIButton!){
        
        print("cancel Tapped")
        goToParent()
        
    }
    
    @objc func confirm(sender : UIButton!){
        
        print("confirm Tapped")
        
        if chargePoint.text == "" {
            
            self.showAlert(title: "확인", message: "충전하실 포인트를 입력하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: chargePoint)
            return
            
        } else if firstCardNumber.text!.count < 4 {
            
            self.showAlert(title: "확인", message: "카드 번호를 확인하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: firstCardNumber)
            return
            
        } else if secondCardNumber.text!.count < 4 {
           
           self.showAlert(title: "확인", message: "카드 번호를 확인하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: secondCardNumber)
           return
            
       } else if thirdCardNumber.text!.count < 4 {
        
            self.showAlert(title: "확인", message: "카드 번호를 확인하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: thirdCardNumber)
            return
         
       } else if fourthCardNumber.text!.count < 4 {
        
            self.showAlert(title: "확인", message: "카드 번호를 확인하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: fourthCardNumber)
            return
         
       } else if validMonth.text!.count < 2 || Int(validMonth.text!)! < 1 || Int(validMonth.text!)! > 12 {
            
            self.showAlert(title: "확인", message: "날짜 형식(MM)을 확인하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: validMonth)
            return
        
       } else if validYear.text!.count < 2 {
        
            self.showAlert(title: "확인", message: "날짜 형식(YY)을 확인하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: validYear)
            return
    
       } else if password.text!.count < 2 {
        
            self.showAlert(title: "확인", message: "카드 비밀번호를 입력하여 주십시오.", positiveTitle: "확인", negativeTitle : nil, textField: password)
            return
        
       } else if let pointText = chargePoint.text?.replacingOccurrences(of: ",", with: ""){
           
           let point = Int(pointText)
           
           if point! < 1000 {
               
               self.showAlert(title: "확인", message: "포인트 충전은 1,000 포인트부터 가능합니다.", positiveTitle: "확인", negativeTitle : nil, textField: chargePoint)
               return
           }
            
            self.showAlert(title: "포인트 충전 진행", message: "총 \(String(describing: chargePoint.text!)) 포인트를 충전됩니다. 계속 진행하시겠습니까?", positiveTitle: "충전", negativeTitle: "취소", textField: nil)
       }

    }
    
    func setPointer(textField : UITextField){
            
        textField.becomeFirstResponder()

    }
        
    func goToParent(){
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func showAlert(title: String?, message: String?, positiveTitle: String?, negativeTitle: String?, textField: UITextField?) {
        
        let refreshAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        if positiveTitle != nil {
            
            if title == "포인트 충전 진행" {
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    self.pointCharge()
                    
                }))
                
            } else if title == "확인" {
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    self.dismiss(animated: true, completion: {self.setPointer(textField: textField!)})
                    
                }))
                
            } else if title == "포인트 충전 완료" {
                
                refreshAlert.addAction(UIAlertAction(title: positiveTitle, style: .default,  handler: { (action: UIAlertAction!) in
                    
                    self.goToParent()
                    
                }))
                
            }
        }
        
        if negativeTitle != nil {
            refreshAlert.addAction(UIAlertAction(title: negativeTitle, style: .cancel, handler: { (action: UIAlertAction!) in
                self.dismiss(animated: true, completion: nil)
            }))
        }
    
        present(refreshAlert, animated: true, completion: nil)
    }

    //keyboard 설정
    func setKeyboard() {
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))   //뷰 터치시 키보드 내리기
        view.addGestureRecognizer(tap)
    }
    
}
extension UITextField {
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
