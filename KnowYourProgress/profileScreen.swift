//
//  profileScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 11..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Felhasznalo
{
    var email: String = ""
    var currSem: Int16 = 0
    var finiSem: Int16 = 0
    var password: String = ""
    var szak: String = ""
}

class profileScreen: UIViewController {
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var currSemLbl: UILabel!
    @IBOutlet weak var majorLbl: UILabel!
    
    var searchResults = [NSManagedObject]()
    var finalResults = [NSManagedObject]()
    var subjectResults = [NSManagedObject]()
    var felh = Felhasznalo()
    var ofelh = Felhasznalo()
    
    var oldEmail: String = ""
    var modosultak: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserData()
        
        //biztonsági mentés, labelek visszaállításához
        ofelh.email = felh.email
        ofelh.currSem = felh.currSem
        ofelh.finiSem = felh.finiSem
        ofelh.password = felh.password
        ofelh.szak = felh.szak
        modosultak = false
        
        emailLbl.text = felh.email
        passwordLbl.text = felh.password
        currSemLbl.text = String(felh.currSem)
        majorLbl.text = felh.szak
    }
    
    func getUserData () {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            print ("találatok száma = \(searchResults.count)")
            
            for users in searchResults as [NSManagedObject]
            {
                if (users.value(forKey: "logged") as! Bool == true)
                {
                    print("megtalalta")
                    felh.email = users.value(forKey: "email") as! String
                    felh.currSem = users.value(forKey: "currentSemester") as! Int16
                    felh.finiSem = users.value(forKey: "finishedSemester") as! Int16
                    felh.password = users.value(forKey: "password") as! String
                    felh.szak = users.value(forKey: "major") as! String
                    break
                }
            }
            
        }
        catch
        {
            print("Error with request: \(error)")
        }

    }
    @IBAction func emailChange(_ sender: Any)
    {
        print("emailchange")
        self.emailAlert(msg1: "Add meg az új e-mail címed!")
    }
    @IBAction func semesterChange(_ sender: Any)
    {
        print("semesterChange")
        self.semesterAlert(msg1: "Add meg hol tartasz most!")
    }
    @IBAction func passwordChange(_ sender: Any)
    {
        print("passwordChange")
        self.passwordAlert(msg1: "Add meg az új jelszavad!")
    }
    @IBAction func majorChange(_ sender: Any)
    {
        print("majorChange")
        self.majorAlert(msg1: "Add meg az új szakodat!\n1 - mérnökinformatikus\n2 - programtervező informatikus\n3 - gazdasági informatikus")
    }
    
    @IBAction func doneAndUpdate(_ sender: Any)
    {
        //adatok megváltoztak-e?
        if (modosultak == true)
        {
            //adatok mentése
            self.finalAlert(msg1: "Biztosan meg szeretnéd változtatni az adataidat? A választás végleges és kijelentkeztetést von majd maga után!!")
            //self.finalafterAlert(msg1: "Sikeres módosítás")
        }
        else
        {
            self.openNewPage(name: "main")
        }
    }
    @IBAction func logOut(_ sender: Any)
    {
        //logged változó értékét visszalőni false-ra
        self.logoutAlert(msg1: "Biztos ki szeretnél jelentkezni?")
    }
    
    @IBAction func deleteUser(_ sender: Any)
    {
        self.deleteAlert(msg1: "Biztos törölni szeretnéd a profilodat?")
    }
    
    // MARK: CoreData User profil törlése
    
    func deleteUser (email: String) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let context = getContext()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            for felhasznalo in searchResults as [NSManagedObject]
            {
                if (felhasznalo.value(forKey: "logged") as! Bool == true)
                {
                    self.deleteSubjects(email: email)
                    context.delete(felhasznalo)
                    break
                }
            }
            
            try context.save()
            print("updated!")
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    
    // MARK: CoreData Userhez tartozott tárgyak törlése
    
    func deleteSubjects (email: String) {
        
        let fetchRequest: NSFetchRequest<DoneSubj> = DoneSubj.fetchRequest()
        let context = getContext()
        
        do
        {
            subjectResults = try getContext().fetch(fetchRequest)
            
            for subject in subjectResults as [NSManagedObject]
            {
                if (subject.value(forKey: "userEmail") as! String == email)
                {
                    print("töröl")
                    context.delete(subject)
                }
            }
            
            try context.save()
            print("deleted all subject from user!")
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    
    // MARK: CoreData adatkinyerés a felhasználóhoz
    
    func logoutUser (email: String) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let context = getContext()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            for felhasznalo in searchResults as [NSManagedObject]
            {
                if (felhasznalo.value(forKey: "email") as! String == email)
                {
                    felhasznalo.setValue(false, forKey: "logged")
                    print("felhasznalo megtalalva")
                    break
                }
            }
            
            try context.save()
            print("updated!")
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    
    // MARK: CoreData felhasználó update
    
    func updateUser (email: String) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let context = getContext()
        
        do
        {
            finalResults = try getContext().fetch(fetchRequest)
            
            for felhasznalo in finalResults as [NSManagedObject]
            {
                if (felhasznalo.value(forKey: "logged") as! Bool == true)
                {
                    print("itt most dolgok történnek")
                    felhasznalo.setValue(self.felh.email, forKey: "email")
                    felhasznalo.setValue(self.felh.currSem, forKey: "currentSemester")
                    felh.finiSem = felh.currSem-1
                    felhasznalo.setValue(self.felh.finiSem, forKey: "finishedSemester")
                    felhasznalo.setValue(self.felh.password, forKey: "password")
                    felhasznalo.setValue(self.felh.szak, forKey: "major")
                    felhasznalo.setValue(false, forKey: "logged")
                    print("idáig történtek")
                    break
                }
            }
            
            try context.save()
            print("user updated sucessfully!")
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
    
    // MARK: AlertView-k az adatok bekérésére
    
    func simpleOKAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func logoutAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Kijelentkezés", style: UIAlertActionStyle.destructive, handler: { action in self.logoutHandler() } ))
        self.present(alert, animated: true, completion: nil)
    }
    func logoutHandler()
    {
        self.logoutUser(email: felh.email)
        self.openNewPage(name: "welcome")
    }
    
    func emailAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.destructive, handler: { action in self.modosultak = false}))
        alert.addAction(UIAlertAction(title: "Módosít", style: UIAlertActionStyle.destructive, handler: { action in
            let ertek: String = (alert.textFields?.first?.text)!
            print(ertek)
            let emailRegEx: NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if (!(emailTest.evaluate(with: ertek) == false))
            {
                self.felh.email = ertek
                self.emailLbl.text = ertek
                self.modosultak = true
            }
            else
            {
                self.simpleOKAlert(msg1: "Valós e-mail címed adj meg!")
            }
        } ))
        
        alert.addTextField { (textField) in
            textField.adjustsFontSizeToFitWidth = true
            textField.keyboardType = UIKeyboardType.emailAddress
            textField.textAlignment = .center
            textField.placeholder = "e-mail cím"
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func semesterAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.destructive, handler: { action in self.modosultak = false}))
        alert.addAction(UIAlertAction(title: "Módosít", style: UIAlertActionStyle.destructive, handler: { action in
            let ertek: Int16 = Int16((alert.textFields?.first?.text)!)!
            print(ertek)
            if (ertek > 0 && ertek <= 12)
            {
                self.felh.currSem = ertek
                self.currSemLbl.text = String(ertek)
                self.modosultak = true
            }
            else
            {
                self.simpleOKAlert(msg1: "1 és 12 között add meg az értéket!")
            }
        } ))
        
        alert.addTextField { (textField) in
            textField.adjustsFontSizeToFitWidth = true
            textField.keyboardType = UIKeyboardType.numberPad
            textField.textAlignment = .center
            textField.placeholder = "add meg a jelenlegi féléved számát"
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func passwordAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.destructive, handler: { action in self.modosultak = false}))
        alert.addAction(UIAlertAction(title: "Módosít", style: UIAlertActionStyle.destructive, handler: { action in
            let ertek: String = (alert.textFields?.first?.text)!
            let ertek2: String = (alert.textFields?.last?.text)!
            print(ertek)
            print(ertek2)
            if (ertek == ertek2)
            {
                self.felh.password = ertek
                self.passwordLbl.text = ertek
                self.modosultak = true
            }
            else
            {
                self.simpleOKAlert(msg1: "Ugyanazt a jelszót add meg!")
            }
        } ))
        
        alert.addTextField { (textField) in
            textField.adjustsFontSizeToFitWidth = true
            textField.keyboardType = UIKeyboardType.default
            textField.isSecureTextEntry = true
            textField.textAlignment = .center
            textField.placeholder = "jelszó"
        }
        alert.addTextField { (textField) in
            textField.adjustsFontSizeToFitWidth = true
            textField.keyboardType = UIKeyboardType.default
            textField.isSecureTextEntry = true
            textField.textAlignment = .center
            textField.placeholder = "jelszó újra"
        }
        
        self.present(alert, animated: true, completion: nil)
    }

    func majorAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.destructive, handler: { action in self.modosultak = false}))
        alert.addAction(UIAlertAction(title: "Módosít", style: UIAlertActionStyle.destructive, handler: { action in
            let ertek: Int = Int((alert.textFields?.first?.text)!)!
            print(ertek)
            
            if (ertek == 1)
            {
                self.felh.szak = "mernokinfoData"
                self.majorLbl.text = "mérnökinformatikus"
                self.modosultak = true
            }
            else if (ertek == 2)
            {
                self.felh.szak = "proginfoData"
                self.majorLbl.text = "programtervező informatikus"
                self.modosultak = true
            }
            else if (ertek == 3)
            {
                self.felh.szak = "gazdinfoData"
                self.majorLbl.text = "gazdasági informatikus"
                self.modosultak = true
            }
            else
            {
                self.simpleOKAlert(msg1: "Csak a megadott értékek közül válassz!")
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
    
    func finalAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Módosít és kijelentkezik", style: UIAlertActionStyle.destructive, handler: { action in self.finalHandler()
        } ))
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.default, handler: { action in self.emailLbl.text = self.ofelh.email
            self.currSemLbl.text = String(self.ofelh.currSem)
            self.majorLbl.text = self.ofelh.szak
            self.passwordLbl.text = self.ofelh.password
            self.modosultak = false
        } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func finalHandler()
    {
        self.updateUser(email: self.oldEmail)
        self.finalafterAlert(msg1: "Sikeres módosítás")
    }
    
    func finalafterAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in self.openNewPage(name: "welcome")
        } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Törlés", style: UIAlertActionStyle.destructive, handler: { action in self.deleteHandler()
        } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func afterDeleteAlert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in self.openNewPage(name: "welcome")
        } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteHandler()
    {
        self.deleteUser(email: ofelh.email)
        self.afterDeleteAlert(msg1: "Sikeres módosítás")
    }

    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
