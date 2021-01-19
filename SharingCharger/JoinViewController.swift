//  회원가입 화면
//  JoinViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/08/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import MaterialComponents.MaterialBottomSheet

class JoinViewController: UIViewController, UITextFieldDelegate , PolicyProtocol {
    
    func policyDelegate(data: String) {
        NotificationCenter.default.post(name: .agreementPolicy, object: data, userInfo: nil)
    }
    
    @IBOutlet weak var nameTextField: CustomTextField!              //이름 textField
    @IBOutlet weak var phoneTextField: CustomTextField!             //전화 번호 textField
    @IBOutlet weak var emailTextField: CustomTextField!             //이메일 textField
    @IBOutlet weak var autorizationCodeTextField: CustomTextField!  //인증번호 textField
    @IBOutlet weak var passwordTextField: CustomTextField!          //패스워드 textField
    @IBOutlet weak var passwordConfirmTextField: CustomTextField!   //패스워드 확인 textField
    
    @IBOutlet var viewCollectPolicyButton: UIButton!
    @IBOutlet var viewPrivacyPolicyButton: UIButton!
    
    @IBOutlet var collectAgreementLabel: UILabel!
    @IBOutlet var privacyAgreementLabel: UILabel!
    
    @IBOutlet weak var buttonComplete: UIButton!                    //완료 버튼
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeTextField: UITextField?   //현재 포커싱인 textField
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    var authenticationNumber: Int!
    
    let ColorE0E0E0: UIColor! = UIColor(named: "Color_E0E0E0")  //회색
    let Color3498DB: UIColor! = UIColor(named: "Color_3498DB")  //파랑
    
    var collectUserDataFlag: Bool = false
    var privacyPolicyFlag: Bool = false
    
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFieldDelegate()
        
        buttonComplete.layer.cornerRadius = 7           //완료 버튼 둥글게
        buttonComplete.addTarget(self, action: #selector(joinButton), for: .touchUpInside)
        buttonComplete.backgroundColor = ColorE0E0E0
        buttonComplete.isEnabled = false
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        addAuthenticationButton()
        initializePolicyButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(agreementPolicy(_:)), name: .agreementPolicy, object: nil)
    }
    
    //인증 요청 버튼 추가
    private func addAuthenticationButton() {

        let authenticationButton = UIButton()
        
        authenticationButton.backgroundColor = Color3498DB
        authenticationButton.titleLabel?.font = UIFont.systemFont(ofSize: CGFloat(15))
        authenticationButton.setTitle("인증 요청", for: .normal)

        self.view.addSubview(authenticationButton)
        
        authenticationButton.translatesAutoresizingMaskIntoConstraints = false
        authenticationButton.centerYAnchor.constraint(equalTo: phoneTextField.centerYAnchor).isActive = true
        authenticationButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        authenticationButton.widthAnchor.constraint(equalToConstant: 70).isActive = true
        authenticationButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -25).isActive = true
        
        authenticationButton.addTarget(self, action: #selector(self.requestAuthentication), for: .touchUpInside)
    }
    
    private func initializePolicyButton(){
        
        viewCollectPolicyButton.layer.borderWidth = 1.0
        viewPrivacyPolicyButton.layer.borderWidth = 1.0
        
        viewCollectPolicyButton.layer.borderColor = ColorE0E0E0?.cgColor
        viewPrivacyPolicyButton.layer.borderColor = ColorE0E0E0?.cgColor

        viewCollectPolicyButton.layer.cornerRadius = 3.0
        viewPrivacyPolicyButton.layer.cornerRadius = 3.0
        
        viewCollectPolicyButton.addTarget(self, action: #selector(collectPolicyButton), for: .touchUpInside)
        viewPrivacyPolicyButton.addTarget(self, action: #selector(privacyPolicyButton), for: .touchUpInside)
    }
    
    @objc func collectPolicyButton(){
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PolicyView") as? PolicyViewController else { return }
        viewController.url = "http://211.253.37.97:8101/api/v1/policy/service"
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        
        let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
        
        present(bottomSheet, animated: true, completion: nil)
        
    }
    
    @objc func privacyPolicyButton(){
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PolicyView") as? PolicyViewController else { return }
        viewController.url = "http://211.253.37.97:8101/api/v1/policy/privacy"
        
        let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.preferredContentSize = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        
        let shapeGenerator = MDCCurvedRectShapeGenerator(cornerSize: CGSize(width: 15, height: 15))
        bottomSheet.setShapeGenerator(shapeGenerator, for: .preferred)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .extended)
        bottomSheet.setShapeGenerator(shapeGenerator, for: .closed)
        
        present(bottomSheet, animated: true, completion: nil)
        
    }
    
    @objc func joinButton(sender: UIButton!) {
        
        if checkBlank() {
        
            var code: Int! = 0
            
            let url = "http://211.253.37.97:8101/api/v1/join"
            
            let parameters: Parameters = [
                "name": nameTextField.text!,
                "phone": phoneTextField.text!,
                "email": emailTextField.text!,
                "password": passwordTextField.text!,
                "userType":"General",
                "collectUserDataFlag":collectUserDataFlag,
                "privacyPolicyFlag":privacyPolicyFlag
            ]
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    print("obj : \(obj)")
                    
                    do {
                        
                        let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                        
                        let instanceData = try JSONDecoder().decode(JoinObject.self, from: JSONData)
                        
                        self.view.makeToast("회원가입이 완료되어 로그인 페이지으로 이동합니다.", duration: 2.0, position: .bottom) {didTap in
                            if didTap {
                                print("tap")
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                print("without tap")
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                        
                    } catch {
                        print("error : \(error.localizedDescription)")
                        print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                    }
                    
                case .failure(let err):
                    
                    print("error is \(String(describing: err))")
                    
                    if code == 400 {
                        print("중복된 이메일이 존재합니다. 다른 이메일로 가입하여 주십시오.")
                        self.view.makeToast("중복된 이메일이 존재합니다.\n다른 이메일로 가입하여 주십시오.", duration: 2.0, position: .bottom)

                    } else {
                        print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                        self.view.makeToast("서버와 통신이 원활하지 않습니다.\n고객센터로 문의주십시오.", duration: 2.0, position: .bottom)
                    }
                }
                
                self.activityIndicator!.stopAnimating()
            })
        }
    }
    
    //빈칸 체크
    private func checkBlank() -> Bool{
        
        if nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이름을 입력하여주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이메일을 입력하여주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if !isValidEmail(emailText: emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)){
            self.view.makeToast("이메일 형식이 올바르지 않습니다.", duration: 2.0, position: .bottom)
            return false
        } else if phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("전화번호를 입력하여주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if autorizationCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("인증번호를 입력하여주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("비밀번호를 입력하여주십시오", duration: 2.0, position: .bottom)
            return false
        } else if !isValidPassword(passwordText: passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            self.view.makeToast("비밀번호는 영문, 숫자, 특수 문자 포함하여 최소 6자 이상 16자리 이하로 설정하셔야합니다.", duration: 2.0, position: .bottom)
            return false
        } else if passwordConfirmTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("비밀번호 확인을 입력하여주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != passwordConfirmTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) {
            self.view.makeToast("비밀번호가 일치하지 않습니다.", duration: 2.0, position: .bottom)
            return false
        } else if authenticationNumber == nil {
            self.view.makeToast("인증 요청 버튼을 클릭해주십시오.", duration: 2.0, position: .bottom)
            return false
        } else if autorizationCodeTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines) != String(authenticationNumber!) {
            self.view.makeToast("인증번호가 일치하지 않습니다.", duration: 2.0, position: .bottom)
            return false
        }
        
        return true
    }
    
    //이메일 체크
    func isValidEmail(emailText:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailText)
    }
    
    //전화번호 체크
    func isValidPhone(phoneText: String?) -> Bool {
        let phoneRegEx = "[0-9]{11}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return predicate.evaluate(with: phoneText)
    }

    //패스워드 체크
    func isValidPassword(passwordText:String) -> Bool {
        let passwordRegEx = "^(?=.*[a-zA-Z])(?=.*[^a-zA-Z0-9])(?=.*[0-9]).{6,16}$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return predicate.evaluate(with: passwordText)
    }
    
    //textField delegate 설정
    func setTextFieldDelegate() {
        nameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        autorizationCodeTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    //keyboard 설정
    func setKeyboard() {
        
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))   //뷰 터치시 키보드 내리기
        view.addGestureRecognizer(tap)
    }
    
    //다음 버튼 누르면 아래 텍스트 필드로 포커스 이동, 마지막 텍스트 필드에서 return 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let textFieldTag:Int = textField.tag
        
        if let textFieldNext = self.view.viewWithTag(textFieldTag + 1) as? UITextField {
            textFieldNext.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    @objc func requestAuthentication(sender: UIButton!) {
        print("JoinViewController - Button tapped")
        
        if phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("전화번호를 입력하여주십시오", duration: 2.0, position: .bottom)
        }
        
        if !isValidPhone(phoneText: phoneTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            //키보드 올라온 상태이면 내리기
            if (activeTextField != nil) {
                activeTextField?.resignFirstResponder()
            }
            
            self.view.makeToast("전화번호 형식이 올바르지 않습니다.", duration: 2.0, position: .bottom)
        }
        
        else {
            self.activityIndicator!.startAnimating()
            
            var code: Int! = 0
            
            let phoneNumber = phoneTextField.text
            let url = "http://211.253.37.97:8101/api/v1/sms/\(phoneNumber!)"
            
            print("url : \(url)")
            
            AF.request(url, method: .get, encoding: URLEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    self.activityIndicator!.stopAnimating()
                    
                    if code == 200 {
                        
                        self.authenticationNumber = (obj as! Int)
                        self.autorizationCodeTextField.becomeFirstResponder()
                    }
                    
                case .failure(let err):
                    
                    print("error is \(String(describing: err))")
                    
                    if code == 400 {
                        print("Unknown Error")
                        
                    } else {
                        print("Unknown Error")
                    }
                    
                    //self.pointLabel.text = "-"
                    self.activityIndicator!.stopAnimating()
                }
            })
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeTextField = nil
    }
    
    @objc func keyboardWillHide(_ notification : Notification?) {
        
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    @objc func keyboardWillShow(_ notification : Notification?) {
        
        guard let keyboardFrame = (notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardFrame.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // 활성화된 텍스트 필드가 키보드에 의해 가려진다면 가려지지 않도록 스크롤한다.
        // 이 부분은 상황에 따라 불필요할 수 있다.
        var rect = self.view.frame
        rect.size.height -= keyboardFrame.height
        if rect.contains(activeTextField!.frame.origin) {
            scrollView.scrollRectToVisible(activeTextField!.frame, animated: true)
        }
    }
    
    @objc func agreementPolicy(_ notification: Notification) {
        
        let data = notification.object as! String
        
        if data == "http://211.253.37.97:8101/api/v1/policy/service" {
            
            viewCollectPolicyButton.isEnabled = false
            viewCollectPolicyButton.setTitleColor(ColorE0E0E0, for: .normal)
            collectAgreementLabel.text = "동의함"
            collectUserDataFlag = true
            
        } else if data == "http://211.253.37.97:8101/api/v1/policy/privacy"{
            
            viewPrivacyPolicyButton.isEnabled = false
            viewPrivacyPolicyButton.setTitleColor(ColorE0E0E0, for: .normal)
            privacyAgreementLabel.text = "동의함"
            privacyPolicyFlag = true
        }
        
        changeButtonStatus()
    }
    
    func changeButtonStatus(){
        
        
        if !viewPrivacyPolicyButton.isEnabled && !viewCollectPolicyButton.isEnabled {
            
            buttonComplete.isEnabled = true
            buttonComplete.backgroundColor = Color3498DB
        }
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        activeTextField = nil
        notificationCenter.removeObserver(self) //  self에 등록된 옵저버 전체 제거
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setKeyboard()
    }
    
}
extension Notification.Name {
    static let agreementPolicy = Notification.Name("agreementPolicy")
}
