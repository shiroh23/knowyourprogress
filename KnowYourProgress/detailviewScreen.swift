//
//  detailviewScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 10..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Tantargy {
    var nev: String = ""
    var kredit: String = ""
    var felev: String = ""
    var targykod: String = ""
}

class detailviewScreen: UIViewController {
    
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var kreditLbl: UILabel!
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var targykodLbl: UILabel!
    
    var subject: Dictionary<String, AnyObject> = [:]
    var tantargy = Tantargy()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tantargy.felev = subject["felev"] as! String
        tantargy.kredit = subject["kredit"] as! String
        tantargy.nev = subject["nev"] as! String
        tantargy.targykod = subject["targykod"] as! String
      
        subjectName.adjustsFontSizeToFitWidth = true
        subjectName.minimumScaleFactor = 0.5
        
        subjectName.text = tantargy.nev
        kreditLbl.text = tantargy.kredit
        felevLbl.text = "A \(tantargy.felev). félévben csinálhatod a tárgyat:"
        targykodLbl.text = tantargy.targykod
        
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
