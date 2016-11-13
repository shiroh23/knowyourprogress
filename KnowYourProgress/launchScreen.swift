//
//  launchScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 03..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Date {
    
    class func from(year:Int, month:Int, day:Int) -> NSDate {
        let c = NSDateComponents()
        c.year = year
        c.month = month
        c.day = day
        
        let gregorian = NSCalendar(identifier:NSCalendar.Identifier.gregorian)
        let date = gregorian!.date(from: c as DateComponents)
        return date! as NSDate
    }
    
    class func parse(dateStr:String, format:String="yyyy.MM.dd") -> NSDate {
        let dateFmt = DateFormatter()
        dateFmt.timeZone = NSTimeZone.default
        dateFmt.dateFormat = format
        return dateFmt.date(from: dateStr)! as NSDate
    }
}

class launchScreen: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextLbl: UILabel!
    
    var teacherResults = [NSManagedObject]()
    var periodResults = [NSManagedObject]()
    let IDs = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    let Names = ["Teiermayer Attila","Medvegy Tibor","Görbe Péter","Dr. Pituk Mihály","Dr. Simon Gyula","Dr. Heckl István","Dr. Leitold Adrien Ilona","Dr. Hartung Ferenc","Székelyné Kovács Katalin","Hegyháti Máté","Dr. Pituk Mihály","Harmat István","Dr. Hartung Ferenc","Dr. Vassányi István","Piglerné dr. Lakner Rozália","Dr. Mihálykóné dr. Orbán Éva","Dr. Vassányi István","Dulai Tibor","Katonáné dr. Tömördi Katalin","Dr. Süle Zoltán","Dr. Simon Gyula","Dr. Vörösházi Zsolt","Dr. Bertók Ákos Botond"]
    let review = 0
    let subjects = ["Fizika I.","Fizika I.","Bevezetés a számítástechnikába","Matematikai analízis I.","Programozás alapjai","Programozás I.","Lineáris algebra","Az informatika logikai és algebrai alapjai","Közgazdaságtan","A digitális számítás elmélete","Matematikai analízis II.","Számítógépes perifériák","Diszkrét matematika","Digitális technika I.","Mesterséges intelligencia","Valószínűségszámítás és matematikai statisztika","Digitális technika II.","Számítógép-hálózatok I.","Elektromosságtan","Adatstruktúrák és algoritmusok","Operációs rendszerek","Digitális rendszerek és számítógép architektúrák","Korszerű programozási technikák"]
    
    let idoszakDesc = ["Előzetes tárgyjelentkezés", "Kurzusjelentkezési időszak", "Végleges tárgyjelentkezés", "Jegybeírási időszak", "Bejelentkezési időszak", "Szorgalmi Időszak", "Megajánlott jegy beírási időszak", "Vizsgaidőszak"]
    let idoszakStart = ["2016.06.20", "2016.06.20", "2016.09.05", "2016.09.05", "2016.09.06", "2016.09.12", "2016.12.05", "2016.12.19"]
    let idoszakEnd = ["2016.07.10", "2016.07.10", "2016.09.12", "2017.01.31", "2016.09.12", "2016.12.17", "2016.12.18", "2017.01.27"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tanarcount = getTeachers()
        let periodcount = getPeriods()
        if (tanarcount == 0 && periodcount == 0)
        {
            for i in (0..<23)
            {
                saveTeacher(id: IDs, nev: Names, subject: subjects, review: review, index: i)
            }
            for j in (0..<8)
            {
                savePeriod(id: IDs, desc: idoszakDesc, start: idoszakStart, end: idoszakEnd, index: j)
            }
            UIView.animate(withDuration: 3, animations: { () -> Void in
                self.progressView.setProgress(1.0, animated: true)
            })
            
            UIView.animate(withDuration: 4) {
                self.nextLbl.alpha = 1.0
            }
        }
        else
        {
            UIView.animate(withDuration: 3, animations: { () -> Void in
                self.progressView.setProgress(1.0, animated: true)
            })
            
            UIView.animate(withDuration: 4) {
                self.nextLbl.alpha = 1.0
            }
        }
        
        
    }
    // MARK: CoreData tanárok feltöltése
    
    func saveTeacher(id: [Int], nev: [String], subject: [String], review: Int, index: Int)
    {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Teacher", in: context)
        
        let tanar = NSManagedObject(entity: entity!, insertInto: context)
        
        print("hozzaadom őtet:")
        print("\(id[index]) \(nev[index]) \(subject[index]) \(review) index értéke: \(index)")
        
        tanar.setValue(id[index], forKey: "id")
        tanar.setValue(nev[index], forKey: "name")
        tanar.setValue(subject[index], forKey: "subject")
        tanar.setValue(review, forKey: "review")
        
        
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
    
    // MARK: CoreData időszakok feltöltése
    
    func savePeriod (id: [Int], desc: [String], start: [String], end: [String], index: Int)
    {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Period", in: context)
        
        let period = NSManagedObject(entity: entity!, insertInto: context)
        
        print("hozzaadom őtet:")
        print("\(id[index]) \(desc[index]) \(start[index]) \(end[index]) index értéke: \(index)")
        
        let sdate = start[index]
        let edate = end[index]
        
        print("\(sdate)-tól -> \(edate)-ig")
        
        period.setValue(id[index], forKey: "id")
        period.setValue(desc[index], forKey: "desc")
        period.setValue(sdate, forKey: "start")
        period.setValue(edate, forKey: "end")
        
        
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
    
    // MARK: CoreData tanárok kigyűjtése
    
    func getTeachers () -> Int {
        
        let fetchRequest: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        
        do
        {
            teacherResults = try getContext().fetch(fetchRequest)
            
            print ("találatok száma = \(teacherResults.count)")
            
            for teacher in teacherResults as [NSManagedObject]
            {
                print("\(teacher.value(forKey: "id")!) - \(teacher.value(forKey: "name")!)")
            }
            
            
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
        return teacherResults.count
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
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
        return periodResults.count
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: Gombok akciói
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer)
    {
        self.openNewPage(name: "welcome")
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name) 
        navigationController?.pushViewController(vc, animated: true)
    }
}
