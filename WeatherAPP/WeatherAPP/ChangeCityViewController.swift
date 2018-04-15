//
//  ChangeCityViewController.swift
//  WeatherAPP
//
//  Created by Mac for gu on 2018/4/13.
//  Copyright © 2018年 Mac for gu. All rights reserved.
//

import UIKit

protocol City {
    func city(cityName: String)
}

class ChangeCityViewController: UIViewController {
    
    
    @IBOutlet weak var cityTextField: UITextField!
    var cityDelegate: City?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cityTextField.becomeFirstResponder()
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnButton(_ sender: UIButton) {
        cityTextField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func okButton(_ sender: UIButton) {
        cityTextField.endEditing(true)
        if cityTextField.text != "" {
            guard let newCity = cityTextField.text else { return }
            cityDelegate?.city(cityName: newCity)
            self.dismiss(animated: true, completion: nil)
        }
//        self.dismiss(animated: true) {
//            self.cityDelegate?.city(cityName: self.cityTextField.text!)
//        }
   }
    
}
