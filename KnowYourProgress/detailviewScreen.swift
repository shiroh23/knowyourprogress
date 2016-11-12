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
    var elvegzett: Bool = false
}

class detailviewScreen: UIViewController {
    
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var kreditLbl: UILabel!
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var targykodLbl: UILabel!
    @IBOutlet weak var tanarNevLbl: UILabel!
    @IBOutlet weak var tanarErtekLbl: UILabel!
    @IBOutlet weak var completedBtn: UIButton!
    
    
    var subject: Dictionary<String, AnyObject> = [:]
    var tutor = Oktato()
    var tantargy = Tantargy()
    var path = IndexPath()
    var fromWhere: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        completedBtn.isEnabled = true
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
        
        tanarNevLbl.adjustsFontSizeToFitWidth = true
        tanarNevLbl.minimumScaleFactor = 0.5
        
        tanarNevLbl.text = tutor.name
        tanarErtekLbl.text = String(tutor.review)
        
    }
    
    @IBAction func finishSubject(_ sender: Any)
    {
        //hozzáadás a teljesített tárgyakhoz
        //megkérdezni a felhasználót hogy értékeli e az oktatót
        self.alert2(msg1: "Gratulálok!\nSzeretnéd értékelni az oktatót?")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segueback") {
            let destination = segue.destination as! main
            destination.index = path
        }
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func alert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert2(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Nem", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Igen", style: UIAlertActionStyle.destructive, handler: { action in
            let ertek: Int = Int((alert.textFields?.first?.text)!)!
            print(ertek)
            if (ertek > 0 && ertek <= 10)
            {
                self.tutor.review = Int16(ertek)
                self.alert(msg1: "Sikeres értékelés")
                self.completedBtn.isEnabled = false
            }
            else
            {
                self.alert(msg1: "1 és 10 között add meg az értéket!")
            }
        } ))

        alert.addTextField { (textField) in
            textField.adjustsFontSizeToFitWidth = true
            textField.keyboardType = UIKeyboardType.numberPad
            textField.textAlignment = .center
            textField.placeholder = "adj meg egy szamot 1-10 között"
        }

        self.present(alert, animated: true, completion: nil)
    }
    
}
