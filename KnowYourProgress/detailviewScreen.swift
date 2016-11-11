//
//  detailviewScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 10..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit

class detailviewScreen: UIViewController {
    
    @IBOutlet weak var subjectName: UILabel!
    var subject: Dictionary<String, AnyObject> = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("megjöttünk")
      
        subjectName.text = subject["nev"] as? String
        
    }
    @IBAction func back(_ sender: Any)
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
}
