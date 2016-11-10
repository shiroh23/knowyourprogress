//
//  register.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 04..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit

class register: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var jelszoField: UITextField!
    @IBOutlet weak var jelszo2Field: UITextField!
    @IBOutlet weak var registerBtn: UIButton!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        registerBtn.isEnabled = false
        emailField.delegate = self
        jelszoField.delegate = self
        jelszo2Field.delegate = self
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
        if (emailField.text != "" && jelszo2Field.text != "" && jelszoField.text != "")
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
            if (jelszoField.text != "" && jelszo2Field.text != "" && emailField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        else if (textField.viewWithTag(2) != nil)
        {
            jelszoField.resignFirstResponder()
            jelszo2Field.becomeFirstResponder()
            if (emailField.text != "" && jelszo2Field.text != "" && jelszoField.text != "")
            {
                registerBtn.isEnabled = true
            }
        }
        else if (textField.viewWithTag(3) != nil)
        {
            jelszo2Field.resignFirstResponder()
            if (emailField.text != "" && jelszoField.text != "" && jelszo2Field.text != "")
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
    
    @IBAction func register(_ sender: Any)
    {
        //e-mail regexp
        let emailRegEx: NSString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        if((emailField.text == "") || (jelszoField.text == "" || jelszo2Field.text == "")){
            
            self.alert(msg1: "Minden mezőt ki kell töltened!")
            
        } else if (emailTest.evaluate(with: self.emailField.text) == false) {
            
            //if the e-mail format isn't good
            self.alert(msg1: "Kérlek valós e-mail címet adj meg!")
            emailField.text = ""
            
        } else if ((jelszoField.text != "") && jelszo2Field.text != "" && !(emailField.text!.isEmpty) &&
            !(emailTest.evaluate(with: self.emailField.text) == false)) {
            if (jelszo2Field.text == jelszoField.text)
            {
                //adatmentés databasebe
                print("adatmentés")
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
    
    
    
    
    @IBAction func back(_ sender: UISwipeGestureRecognizer)
    {
        self.navigationController!.popViewController(animated: true)
    }
    
}
