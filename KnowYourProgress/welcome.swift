//
//  ViewController.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 03..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import UIKit
import CoreData

class welcome: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var searchResults = [NSManagedObject]()
    
    var emailAddress: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailField.text = ""
        passwordField.text = ""
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if ((textField.viewWithTag(1)) != nil)
        {
            passwordField.becomeFirstResponder()
        }
        else if (textField.viewWithTag(2) != nil)
        {
            passwordField.resignFirstResponder()
            
        }
        return true
    }
    
    func alert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func bejelentkezes(sender: UIButton)
    {
        //e-mail regexp
        let emailRegEx: NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        if((emailField.text == "") && (passwordField.text == "")){
            
            self.alert(msg1: "Minden mezőt ki kell töltened!")
            
        } else if (emailTest.evaluate(with: self.emailField.text) == false) {
            
            self.alert(msg1: "Kérlek valós e-mail címet adj meg!")
            emailField.text = ""
            
        } else if ((passwordField.text != "") && !(emailField.text!.isEmpty) &&
            !(emailTest.evaluate(with: self.emailField.text) == false)) {
            
            //ellenőrzés a CoreData-ban
            var volt: Bool = false
            emailAddress = emailField.text!
            password = passwordField.text!
            self.getUsers()
            
            for felh in searchResults as [NSManagedObject]
            {
                let e_mail=felh.value(forKey: "email") as! String
                let jelszo=felh.value(forKey: "password") as! String
                if (e_mail == emailField.text! && jelszo == passwordField.text!)
                {
                    volt = true
                }
            }
            
            
            if (volt == true)
            {
                //bejelentkezés ha minden stimmel
                self.loginUser(email: emailAddress)
                self.openNewPage(name: "main")
            }
            else
            {
                //hibaüzenet ha nem stimmelnek az adatok
                self.alert(msg1: "Nem található a felhasználó!")
                emailField.text = ""
                passwordField.text = ""
            }
        }
        
    }
    
    func getUsers () {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            //print ("találatok száma = \(searchResults.count)")
            
            for felhasznalo in searchResults as [NSManagedObject]
            {
                print("\(felhasznalo.value(forKey: "email"))")
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
    }
    
    func loginUser (email: String) {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let context = getContext()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            //print ("update találatok száma = \(searchResults.count)")
            
            for felhasznalo in searchResults as [NSManagedObject]
            {
                if (felhasznalo.value(forKey: "email") as! String == email)
                {
                    felhasznalo.setValue(true, forKey: "logged")
                    //print("felhasznalo megtalalva")
                    break
                }
            }
            
            try context.save()
            //print("updated!")
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
    
    @IBAction func regisztracio(_ sender: Any)
    {
        self.openNewPage(name: "register")
    }

}

