//
//  mainScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 10..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit

class main: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var productArray = NSArray()
    
    func readPropertyList(){

            let plistPath:String? = Bundle.main.path(forResource: "gazdinfoData", ofType: "plist")!
        
            productArray = NSArray(contentsOfFile: plistPath!)!
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readPropertyList()
    }
    

    //MARK: - Table View Data sources and Delegates
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    private func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tantárgyak"
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = getNev(pId: row)
        return cell
        
    }
 
    func getNev(pId: Int) -> String{
        var nev: String = ""
        var rekord: Dictionary<String, AnyObject>
        rekord = productArray.object(at: pId) as! Dictionary<String, AnyObject>
        
        nev = rekord["nev"] as! String
        
        return nev;
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
