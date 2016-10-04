//
//  register.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 04..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class register: UIViewController {
   
    override func viewDidLoad() {
        super.viewDidLoad()
     
    }
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UISwipeGestureRecognizer)
    {
        print("goingbackwards")
        self.navigationController!.popViewController(animated: true)
    }
    
}
