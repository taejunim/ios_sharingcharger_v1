//
//  Interceptor.swift
//  SharingCharger
//
//  Created by tjlim on 2020/10/10.
//  Copyright © 2020 metisinfo. All rights reserved.
//

import UIKit
import Alamofire

class Interceptor: RequestInterceptor {
    
    private let indicator: UIActivityIndicatorView
    
    init(indicator: UIActivityIndicatorView){
        self.indicator = indicator
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        
        print("interceptor adapt..")
        
        DispatchQueue.main.async {
            self.indicator.startAnimating()
            self.indicator.isHidden = false
        }
        
        completion(.success(urlRequest))
    }
}
