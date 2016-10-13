//
//  ViewController.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 03..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import UIKit
import RealmSwift

class welcome: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    //var categories = []
    let realm = try! Realm()
    lazy var categories: Results<database> = { self.realm.objects(database.self) }()
    
    func populateDefaultCategories() {
        
        if categories.count == 0 { // 1
            
            try! realm.write() { // 2
                
                let defaultCategories = ["Birds", "Mammals", "Flora", "Reptiles", "Arachnids" ] // 3
                
                for category in defaultCategories { // 4
                    let newCategory = database()
                    newCategory.name = category
                    self.realm.add(newCategory)
                }
            }
            
            categories = realm.objects(database.self) // 5
        }
    }
    
    var emailAddress: String = ""
    var password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDefaultCategories()
        
        print(Realm.Configuration.defaultConfiguration.fileURL)
        
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
            
            //if the e-mail format isn't good
            self.alert(msg1: "Kérlek valós e-mail címet adj meg!")
            emailField.text = ""
            
        } else if ((passwordField.text != "") && !(emailField.text!.isEmpty) &&
            !(emailTest.evaluate(with: self.emailField.text) == false)) {
            
            emailAddress = emailField.text!
            password = passwordField.text!
            //if everything's format is right...
            //save the data which has been typed to the textfields
            
            self.openNewPage(name: "register")
        }
        
    }

}

