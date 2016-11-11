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
    var currSem: Int = 0
    var finiSem: Int = 0
    var password: String = ""
    var szak: String = ""
}

class profileScreen: UIViewController {
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var currSemLbl: UILabel!
    @IBOutlet weak var majorLbl: UILabel!
    
    var searchResults = [NSManagedObject]()
    var felh = Felhasznalo()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserData()
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
                    felh.currSem = users.value(forKey: "currentSemester") as! Int
                    felh.finiSem = users.value(forKey: "finishedSemester") as! Int
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
    }
    @IBAction func semesterChange(_ sender: Any)
    {
        print("semesterChange")
    }
    @IBAction func passwordChange(_ sender: Any)
    {
        print("passwordChange")
    }
    @IBAction func majorChange(_ sender: Any)
    {
        print("majorChange")
    }
    
    @IBAction func doneAndUpdate(_ sender: Any)
    {
        //adatok mentése ha módosultak
        self.navigationController!.popViewController(animated: true)
    }
    @IBAction func logOut(_ sender: Any)
    {
        //logged változó értékét visszalőni false-ra
        self.alert2(msg1: "Biztos ki szeretnél jelentkezni?")
    }
    
    func logoutUser (email: String) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let context = getContext()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            print ("update találatok száma = \(searchResults.count)")
            
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
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    func alert2(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Mégse", style: UIAlertActionStyle.destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Kijelentkezés", style: UIAlertActionStyle.destructive, handler: { action in self.someHandler() } ))
        self.present(alert, animated: true, completion: nil)
    }
    func someHandler()
    {
        self.logoutUser(email: felh.email)
        self.openNewPage(name: "welcome")
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
