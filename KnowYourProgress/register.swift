//
//  register.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 04..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class register: UIViewController, UITextFieldDelegate, UIPickerViewDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var jelszoField: UITextField!
    @IBOutlet weak var jelszo2Field: UITextField!
    @IBOutlet weak var felevField: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var szakvalasztoField: UITextField!
    
    var searchResults = [NSManagedObject]()
   
    var pickOption = ["mérnökinformatikus", "programtervező informatikus", "gazdasági informatikus"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBtn.isEnabled = false
        emailField.delegate = self
        jelszoField.delegate = self
        jelszo2Field.delegate = self
        felevField.delegate = self
        
        let pickerView = UIPickerView()
        
        pickerView.tag = 1
        pickerView.delegate = self
        szakvalasztoField.inputView = pickerView

        let toolBar = UIToolbar()
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        toolBar.barStyle = UIBarStyle.default
        toolBar.tintColor = UIColor.purple
        toolBar.backgroundColor = UIColor.white
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: Selector(("donePressed:")))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        
        toolBar.setItems([flexSpace,flexSpace,flexSpace,doneButton], animated: true)

        
        szakvalasztoField.inputAccessoryView = toolBar

    }
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        self.view.endEditing(true)
        if (emailField.text != "" && jelszo2Field.text != "" && jelszoField.text != "" && felevField.text != "")
        {
            registerBtn.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        if ((textField.viewWithTag(1)) != nil)
        {
            jelszoField.becomeFirstResponder()
            if (jelszoField.text != "" && jelszo2Field.text != "" && emailField.text != "" && felevField.text != "" && szakvalasztoField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        else if (textField.viewWithTag(2) != nil)
        {
            jelszoField.resignFirstResponder()
            jelszo2Field.becomeFirstResponder()
            if (emailField.text != "" && jelszo2Field.text != "" && jelszoField.text != "" && felevField.text != "" && szakvalasztoField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        else if (textField.viewWithTag(3) != nil)
        {
            jelszo2Field.resignFirstResponder()
            szakvalasztoField.becomeFirstResponder()
            if (emailField.text != "" && jelszoField.text != "" && jelszo2Field.text != "" && felevField.text != "" && szakvalasztoField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        else if (textField.viewWithTag(4) != nil)
        {
            szakvalasztoField.resignFirstResponder()
            felevField.becomeFirstResponder()
            if (emailField.text != "" && jelszoField.text != "" && jelszo2Field.text != "" && felevField.text != "" && szakvalasztoField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        else if (textField.viewWithTag(5) != nil)
        {
            felevField.resignFirstResponder()
            if (emailField.text != "" && jelszoField.text != "" && jelszo2Field.text != "" && felevField.text != "" && szakvalasztoField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        registerBtn.isEnabled = false
    }
    
    func alert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func alert2(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in self.someHandler() } ))
        self.present(alert, animated: true, completion: nil)
    }
    func someHandler()
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func register(_ sender: Any)
    {
        //e-mail regexp
        let emailRegEx: NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        if((emailField.text == "") || (jelszoField.text == "" || jelszo2Field.text == "") || felevField.text == "" || szakvalasztoField.text == ""){
            
            self.alert(msg1: "Minden mezőt ki kell töltened!")
            
        } else if (emailTest.evaluate(with: self.emailField.text) == false) {
            
            //if the e-mail format isn't good
            self.alert(msg1: "Kérlek valós e-mail címet adj meg!")
            emailField.text = ""
            
        } else if ((jelszoField.text != "") && jelszo2Field.text != "" && felevField.text != "" && szakvalasztoField.text != "" && !(emailField.text!.isEmpty) &&
            !(emailTest.evaluate(with: self.emailField.text) == false)) {
            if (jelszo2Field.text == jelszoField.text)
            {
                var volt: Bool = false
                //mentés előtt ellenőrizni kell, volt-e már ugyanilyen regisztrálva
                self.getUsers()
                for felh in searchResults as [NSManagedObject]
                {
                    let e_mail=felh.value(forKey: "email") as! String
                    if (e_mail == emailField.text!)
                    {
                        volt = true
                    }
                }
                if (volt == false)
                {
                    //adatmentés database-be
                    print("adatmentés")
                    let intFelev = Int(felevField.text!)
                    self.saveUser(email: emailField.text!, jelszo: jelszoField.text!, felev: intFelev!, szak: szakvalasztoField.text!)
                    alert2(msg1: "Sikeres regisztráció!")
                }
                else
                {
                    //más email címmel való regisztráció
                    alert(msg1: "Ezzel az e-mail címmel már regisztráltak!")
                    emailField.text = ""
                }
            }
            else
            {
                alert(msg1: "A két jelszó nem egyezik!")
                jelszoField.text = ""
                jelszo2Field.text = ""
            }
            
            
            self.openNewPage(name: "welcome")
        }
    }
    
    
    func saveUser(email: String, jelszo: String, felev: Int, szak: String)
    {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "User", in: context)
        
        let felhasznalo = NSManagedObject(entity: entity!, insertInto: context)
        
        felhasznalo.setValue(email, forKey: "email")
        felhasznalo.setValue(jelszo, forKey: "password")
        felhasznalo.setValue(felev, forKey: "currentSemester")
        let elvegzett = felev - 1
        felhasznalo.setValue(elvegzett, forKey: "finishedSemester")
        felhasznalo.setValue(false, forKey: "logged")
        felhasznalo.setValue(szak, forKey: "major")
        
        do
        {
            try context.save()
            print("saved!")
        } catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {
            print("Error with: \(error)")
        }
    }
    
    func getUsers () {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            print ("találatok száma = \(searchResults.count)")
            
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
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    
    @IBAction func back(_ sender: UISwipeGestureRecognizer)
    {
        self.navigationController!.popViewController(animated: true)
    }
    
    func donePressed(sender: UIBarButtonItem)
    {
        szakvalasztoField.resignFirstResponder()
        felevField.becomeFirstResponder()
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            szakvalasztoField.text = pickOption[row]
    }
    
}
