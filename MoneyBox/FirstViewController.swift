//
//  FirstViewController.swift
//  MoneyBox
//
//  Created by Андрей Закржевский on 09.07.2018.
//  Copyright © 2018 Андрей Закржевский. All rights reserved.
//

import UIKit
import SQLite

var list = ["Buy milk", "Run 5 miles", "Get Peter", "Plant my new plants"]
var databaseGlobal: Connection!
var goals = Table("goals")
var id = Expression<Int>("id")
var goalName = Expression<String>("goalName")
var goalSum = Expression<String>("goalSum")
var currentSum = Expression<String>("currentSum")
var isDone = Expression<Bool>("isDone")
var isDeleted = Expression<Bool>("isDeleted")
var priority = Expression<Int>("priority")
var goalsDict = [String : String]()

var goalsNameList = [String]()
var goalsSumList = [String]()

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var addCoinButton: UIBarButtonItem!
    
    @IBOutlet weak var mainListTabBarItem: UITabBarItem!
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        myTableView.reloadData()
        if goalsNameList.count > 0 {
            addCoinButton.isEnabled = true
            mainListTabBarItem.badgeValue = String(goalsNameList.count)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //goalsList = ["1","2","3","4"]
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory , in: .userDomainMask , appropriateFor: nil, create: true )
            let fileUrl = documentDirectory.appendingPathComponent("GOALS").appendingPathExtension("sqlite3")
            let database =  try Connection(fileUrl.path)
            databaseGlobal = database
            
            let createTable = goals.create { (table) in
                table.column(id, primaryKey: true)
                table.column(goalName, unique: true)
                table.column(goalSum)
                table.column(currentSum)
                table.column(isDone)
                table.column(isDeleted)
                table.column(priority)
            }
            //try database.run(goals.drop()) //Dropping table for recreation
            try databaseGlobal.run(createTable)
            print("Created GOALS.sqlite3" )
            
        } catch {
            print(error)
        }
        
        do {
//            let query = goals.select(goalName)            SELECT "goalName" FROM "goals"
//                        .filter(isDeleted != true)        WHERE "isDeleted" IS NOT TRUE
            let selectedGoals = try databaseGlobal.prepare(goals.select(*).filter(isDeleted != true).order(priority))
            
            for goal in selectedGoals {
                
                goalsDict[goal[goalName]] = goal[goalSum]
                
                //goalsList.append(goal[goalName])
                print("Goal ID: \(goal[id]), Goal Name: \(goal[goalName]), Goal Sum: \(goal[goalSum]), Goal Priority: \(goal[priority]), Deleted: \(goal[isDeleted])")
            }
        } catch {
            print(error)
        }
        myTableView.reloadData()
        if goalsNameList.count > 0 {
            addCoinButton.isEnabled = true
            mainListTabBarItem.badgeValue = String(goalsNameList.count)
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (goalsDict.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        for (key, value) in goalsDict {
            goalsNameList.append(key)
            goalsSumList.append(value)
            //cell.textLabel?.text = key + value
        }
        cell.textLabel?.text = goalsNameList[indexPath.row]
        
//        let cellIdentifier = "cell"
//
//        var cell : UITableViewCell
//
//        cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! UITableViewCell
//        cell.textLabel?.text = "text"
//        cell.textLabel?.textAlignment = .right
//
//        let image : UIImage = UIImage(named: "doneAims")!
//        print("The loaded image: \(image)")
//        cell.imageView?.image = image
        
        return(cell)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            let goal = goals.filter(goalName == goalsNameList[indexPath.row])
            let deleteGoal = goal.update(isDeleted <- true);
            do {
                try databaseGlobal.run(deleteGoal)
            } catch {
                print(error)
            }
            goalsNameList.remove(at: indexPath.row)
            
            myTableView.reloadData()
            mainListTabBarItem.badgeValue = String(Int(mainListTabBarItem.badgeValue!)! - 1)
        }
        if goalsNameList.count == 0 {
            addCoinButton.isEnabled = false
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


