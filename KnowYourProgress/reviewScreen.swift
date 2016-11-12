//
//  reviewScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 12..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class reviewScreen: UIViewController {
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    @IBAction func makeReview(_ sender: Any)
    {
        self.alert2(msg1: "Elküldöd az értékelést?")
    }
    
    func alert2(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Nem", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Igen", style: UIAlertActionStyle.destructive, handler: { action in self.someHandler() } ))
        self.present(alert, animated: true, completion: nil)
    }
    func someHandler()
    {
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "detailview")
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromBottom
        self.navigationController!.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
