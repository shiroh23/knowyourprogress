//
//  periodsScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 12..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct idszak
{
    var id: Int16 = 0
    var desc: String = ""
    var start: String = ""
    var end: String = ""
}

class periodsScreen: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let backgroundImage = UIImage(named: "489812_Pannonia.jpg")
    var periodResults = [NSManagedObject]()
    var currentPeriods = [String]()
    var periodcount: Int = 0
    var index: IndexPath = []
    //var toolBtn = UIBarButtonItem(title: "Naptárba mentés", style: .plain, target: self, action: #selector(someSelector))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //background beállítása
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.05
        self.tableView.backgroundView = imageView
        
        periodcount = self.getPeriods()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectRow(at: self.index, animated: true)
        //super.viewWillAppear(animated);
        //self.navigationController?.setToolbarHidden(false, animated: animated)
        //self.navigationController?.toolbar.setItems([toolBtn], animated: true)
    }
    /*
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    func someSelector ()
    {
        
    }*/
    
    // MARK: TableView beállítása
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periodcount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        }
        cell?.backgroundColor = .clear
        let row = indexPath.row
        cell?.textLabel?.text = currentPeriods[row]
        cell!.detailTextLabel?.text = "2016,30,30"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
     {
        self.index = indexPath
        let idoszak = self.getPeriod(id: Int16(indexPath.row)+1)
        tableView.deselectRow(at: indexPath, animated: true)
        self.alert(msg1: "A kiválasztott időszak \(idoszak.start)-tól \(idoszak.end)-ig tart")
     }
    
    // MARK: CoreData időszakok kigyűjtése
    
    func getPeriods () -> Int {
        
        let fetchRequest: NSFetchRequest<Period> = Period.fetchRequest()
        
        do
        {
            periodResults = try getContext().fetch(fetchRequest)
            
            print ("találatok száma = \(periodResults.count)")
            
            for period in periodResults as [NSManagedObject]
            {
                print("\(period.value(forKey: "desc")!)")
                currentPeriods.append(period.value(forKey: "desc") as! String)
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
        return periodResults.count
    }
    
    // MARK: CoreData egy időszak kiszedése
    
    func getPeriod (id: Int16) -> idszak {
        
        let fetchRequest: NSFetchRequest<Period> = Period.fetchRequest()
        var joperiod = idszak()
        
        do
        {
            periodResults = try getContext().fetch(fetchRequest)
            
            for period in periodResults as [NSManagedObject]
            {
                if (period.value(forKey: "id") as! Int16 == id)
                {
                    joperiod.desc = period.value(forKey: "desc") as! String
                    joperiod.id = period.value(forKey: "id") as! Int16
                    joperiod.start = period.value(forKey: "start") as! String
                    joperiod.end = period.value(forKey: "end") as! String
                    break
                }
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
        return joperiod
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: Gombok akciói
    
    @IBAction func back(_ sender: Any)
    {
        self.openNewPage(name: "main")
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: AlertView-k beállítása
    
    func alert(msg1: String)
    {
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}
