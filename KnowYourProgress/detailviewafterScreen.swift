//
//  detailviewafterScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 15..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class detailviewafterScreen: UIViewController {
    
    @IBOutlet weak var subjectName: UILabel!
    @IBOutlet weak var kreditLbl: UILabel!
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var targykodLbl: UILabel!
    @IBOutlet weak var tanarNevLbl: UILabel!
    @IBOutlet weak var tanarErtekLbl: UILabel!
    @IBOutlet weak var completedBtn: UIButton!
    
    var teacherResults = [NSManagedObject]()
    var subject: Dictionary<String, AnyObject> = [:]
    var tutor = Oktato()
    var tantargy = Tantargy()
    var path = IndexPath()
    
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
        self.alert2(msg1: "Szeretnéd értékelni az oktatót?")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segueback") {
            let destination = segue.destination as! mainAfter
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
                self.updateTeacher(nev: self.tutor.name, ertek: self.tutor.review)
                self.alert(msg1: "Sikeres értékelés")
                self.completedBtn.isHidden = true
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
    
    // MARK: CoreData update teacher
    
    func updateTeacher (nev: String, ertek: Int16) {
        
        let fetchRequest: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        let context = getContext()
        
        do
        {
            teacherResults = try getContext().fetch(fetchRequest)
            
            for t in teacherResults as [NSManagedObject]
            {
                if (t.value(forKey: "name") as! String == nev)
                {
                    t.setValue(ertek, forKey: "review")
                    break
                }
            }
            
            try context.save()
            print("updated review!")
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
}
