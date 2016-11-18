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
    @IBOutlet weak var textView: UITextView!
    
    var teacherResults = [NSManagedObject]()
    var subject: Dictionary<String, AnyObject> = [:]
    var productArray = NSArray()
    var talaltElofeltetelek = [String]()
    var tutor = Oktato()
    var felh = Felhasznalo()
    var tantargy = Tantargy()
    var path = IndexPath()
    var useableszak: String = ""
    
    func readPropertyList(szak: String)
    {
        let plistPath:String? = Bundle.main.path(forResource: szak, ofType: "plist")!
        productArray = NSArray(contentsOfFile: plistPath!)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let van: Bool = self.isthereaTeacher(nev: tutor.name)
        if (van == true && tutor.review == 0)
        {
            completedBtn.isEnabled = true
            completedBtn.isHidden = false
            switch felh.szak {
            case "mernokinfoData":
                useableszak = "mernokinfoPreCons"
                break
            case "proginfoData":
                useableszak = "proginfoPreCons"
                break
            case "gazdinfoData":
                useableszak = "gazdinfoPreCons"
                break
            default:
                useableszak = ""
                break
            }
            print(useableszak)
            readPropertyList(szak: useableszak)
            
            tantargy.felev = subject["felev"] as! String
            tantargy.kredit = subject["kredit"] as! String
            tantargy.nev = subject["nev"] as! String
            tantargy.targykod = subject["targykod"] as! String
            
            talaltElofeltetelek = self.elofeltetlek(keresettTargy: tantargy.nev)
            if (talaltElofeltetelek.count != 0)
            {
                textView.insertText("A tárgy előfeltételei:\n\n")
                
                for i in (0..<talaltElofeltetelek.count)
                {
                    print(talaltElofeltetelek[i])
                    textView.insertText(talaltElofeltetelek[i])
                    textView.insertText("\n\n")
                }
            }
            else
            {
                textView.insertText("A tárgynak nincsen előfeltétele")
                textView.insertText("\n\n")
            }
        }
        else
        {
            completedBtn.isEnabled = false
            completedBtn.isHidden = true
            textView.isHidden = true
            
            tantargy.felev = subject["felev"] as! String
            tantargy.kredit = subject["kredit"] as! String
            tantargy.nev = subject["nev"] as! String
            tantargy.targykod = subject["targykod"] as! String
        }
        
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
    
    // MARK: annak ellenőrzése, hogy van e a tárgyhoz tanár rendelve
    
    func isthereaTeacher(nev: String) -> Bool {
        
        var van: Bool = false
        
        if (nev == "nincs")
        {
            van = false
        }
        else
        {
            van = true
        }
        
        if (van == true)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // MARK: Előfeltételek kiírása
    
    func elofeltetlek(keresettTargy: String) -> [String]
    {
        var lista = [String]()
        
        var rekord: Dictionary<String, AnyObject>
        
        for i in (0..<productArray.count)
        {
            rekord = productArray.object(at: i) as! Dictionary<String, AnyObject>
            let nev = rekord["nev"] as! String
            
            if (nev == keresettTargy)
            {
                for k in (1...3)
                {
                    let elo = rekord["elofeltetel\(k)"] as? String
                    if (elo != nil)
                    {
                        lista.append(elo!)
                    }
                }
            }
        }
        print(lista.count)
        return lista
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
}
