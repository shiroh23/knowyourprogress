//
//  launchScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 03..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit

class launchScreen: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIView.animate(withDuration: 3, animations: { () -> Void in
            self.progressView.setProgress(1.0, animated: true)
        })
        
        UIView.animate(withDuration: 4) { 
            self.nextLbl.alpha = 1.0
        }
        
        
    }
    @IBAction func tapped(_ sender: UITapGestureRecognizer)
    {
        self.openNewPage(name: "welcome")
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name) 
        navigationController?.pushViewController(vc, animated: true)
    }
}
