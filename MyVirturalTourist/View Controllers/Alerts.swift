//
//  Alerts.swift
//  MyVirturalTourist
//
//  Created by Brittany Mason on 11/9/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit

extension collectionViewController  {
    
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
         present(alert, animated: true)

        }
    }
    
    
}
extension MapViewController  {
    
    func displayAlert(title:String, message:String?) {
        
        if let message = message {
            let alert = UIAlertController(title: title, message: "\(message)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
         present(alert, animated: true)

        }
    }
    
    
}
