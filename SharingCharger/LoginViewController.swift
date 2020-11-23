//
//  LoginViewController.swift
//  SharingCharger
//
//  Created by tjlim on 2020/07/27.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire
import Toast_Swift
import CoreLocation

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!
    
    var utils: Utils?
    var activityIndicator: UIActivityIndicatorView?
    
    var activeTextField: UITextField?   //현재 포커싱인 textField
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //로딩 뷰
        utils = Utils(superView: self.view)
        activityIndicator = utils!.activityIndicator
        self.view.addSubview(activityIndicator!)
        self.activityIndicator!.hidesWhenStopped = true
        
        loginEmail.delegate = self
        loginPassword.delegate = self
        
        setKeyboard()
        
        locationManager.requestWhenInUseAuthorization() //위치 권한
    }
    
    //로그인 버튼
    @IBAction func loginButton(_ sender: Any) {
        login()
    }
    
    //로그인 API
    private func login() {
        
        //빈칸 체크
        if checkBlank(position: .center) {
        
            self.activityIndicator!.startAnimating()
            let mainViewController = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "Main") as! MainViewController
            let navigationController = UINavigationController(rootViewController: mainViewController)
            
            var code: Int! = 0
            
            let url = "http://211.253.37.97:8101/api/v1/login"
            
            let parameters: Parameters = [
                "loginId": loginEmail.text!,
                "password": loginPassword.text!
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, interceptor: Interceptor(indicator: activityIndicator!)).validate().responseJSON(completionHandler: { response in
                
                code = response.response?.statusCode
                
                switch response.result {
                
                case .success(let obj):
                    
                    print("obj : \(obj)")
                    
                    if code == 200 {
                        do {
                            
                            let JSONData = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                            
                            let instanceData = try JSONDecoder().decode(JoinObject.self, from: JSONData)
                            
                            self.view.makeToast("환영합니다!", duration: 0.5, position: .bottom) {didTap in
                                
                                UserDefaults.standard.set(true, forKey: "isLogin")
                                UserDefaults.standard.set(instanceData.id, forKey: "userId")
                                UserDefaults.standard.set(instanceData.name, forKey: "name")
                                UserDefaults.standard.set(instanceData.email, forKey: "email")
                                UserDefaults.standard.set(instanceData.password, forKey: "password")
                                
                                if didTap {
                                    print("tap")
                                    
                                    UIApplication.shared.windows.first?.rootViewController = navigationController
                                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                                } else {
                                    print("without tap")
                                    
                                    UIApplication.shared.windows.first?.rootViewController = navigationController
                                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                                }
                            }
                            
                        } catch {
                            print("error : \(error.localizedDescription)")
                            print("서버와 통신이 원활하지 않습니다. 고객센터로 문의주십시오. code : \(code!)")
                        }
                    } else if code == 204 {
                        self.view.makeToast("일치하는 회원이 존재하지 않습니다.\n다시 확인하여 주십시오", duration: 2.0, position: .bottom)
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
    private func checkBlank(position: ToastPosition) -> Bool{
        
        if loginEmail.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("이메일을 입력하여주십시오", duration: 2.0, position: position)
            return false
        } else if loginPassword.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.view.makeToast("비밀번호를 입력하여주십시오", duration: 2.0, position: position)
            return false
        }
        
        return true
    }
    
    //keyboard 설정
    func setKeyboard() {
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))   //뷰 터치시 키보드 내리기
        view.addGestureRecognizer(tap)
    }
    
    //다음 버튼 누르면 아래 텍스트 필드로 포커스 이동, 마지막 텍스트 필드에서 return 누르면 키보드 내려감
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let textFieldTag:Int = textField.tag
        
        if let nextTextField = self.view.viewWithTag(textFieldTag + 1) as? UITextField {
            nextTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            login()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        activeTextField = nil
    }
    
    @IBAction func joinButton(_ sender: Any) {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "Join") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @IBAction func passwordInitButton(_ sender: Any) {
        
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PasswordInit") else { return }
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.tintColor = UIColor.black  //백버튼 검은색으로
        self.navigationController?.navigationBar.backItem?.title = ""       //백버튼 텍스트 제거
        self.navigationController?.navigationBar.barTintColor = .white      //navigationBar 배경 흰색으로
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        super.viewWillAppear(animated)
    }
}
