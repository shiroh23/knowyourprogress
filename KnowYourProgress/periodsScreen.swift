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
import EventKit

struct idszak
{
    var id: Int16 = 0
    var desc: String = ""
    var start: String = ""
    var end: String = ""
}

struct idszak2
{
    var id: Int16 = 0
    var desc: String = ""
    var start: Date = Date()
    var end: Date = Date()
}

class periodsScreen: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let backgroundImage = UIImage(named: "489812_Pannonia.jpg")
    var periodResults = [NSManagedObject]()
    var currentPeriods = [String]()
    var periodcount: Int = 0
    var index: IndexPath = []
    
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
    }

    // MARK: Naptárba exportálás
    
    func addEventToCalendar(completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        var kezdoIdo = idszak2()
        var vegeIdo = idszak2()
        
        for period in periodResults as [NSManagedObject]
        {
            if (period.value(forKey: "id") as! Int16 == Int16(self.index.row))
            {
                kezdoIdo.id = period.value(forKey: "id") as! Int16
                vegeIdo.id = period.value(forKey: "id") as! Int16
                kezdoIdo.desc = period.value(forKey: "desc") as! String
                vegeIdo.desc = period.value(forKey: "desc") as! String
                let start = period.value(forKey: "start")
                let end = period.value(forKey: "end")
                kezdoIdo.start = Datum.parse(dateStr: start as! String, format: "yyyy.MM.dd") as Date
                kezdoIdo.end = Datum.parse(dateStr: start as! String, format: "yyyy.MM.dd") as Date
                vegeIdo.start = Datum.parse(dateStr: end as! String, format: "yyyy.MM.dd") as Date
                vegeIdo.end = Datum.parse(dateStr: end as! String, format: "yyyy.MM.dd") as Date
                break
            }
        }
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                let event2 = EKEvent(eventStore: eventStore)
                
                event.title = kezdoIdo.desc
                event.startDate = kezdoIdo.start
                event.endDate = kezdoIdo.end
                event.notes = "Itt kezdődik az időszak"
                event.calendar = eventStore.defaultCalendarForNewEvents
                
                event2.title = vegeIdo.desc
                event2.startDate = vegeIdo.start
                event2.endDate = vegeIdo.end
                event2.notes = "Eddig tart az időszak"
                event2.calendar = eventStore.defaultCalendarForNewEvents
                
                do {
                    try eventStore.save(event, span: .thisEvent)
                    try eventStore.save(event2, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                completion?(true, nil)
            } else {
                completion?(false, error as NSError?)
            }
        })
    }
    
    
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
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
     {
        self.index = indexPath
        let idoszak = self.getPeriod(id: Int16(indexPath.row)+1)
        tableView.deselectRow(at: indexPath, animated: true)
        self.alert(msg1: "A kiválasztott időszak \(idoszak.start)-tól \(idoszak.end)-ig tart\nExportálod a naptárba?")
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
        alert.addAction(UIAlertAction(title: "Exportálás", style: UIAlertActionStyle.default, handler: { action in self.addEventToCalendar()}))
        self.present(alert, animated: true, completion: nil)
    }
    
}
