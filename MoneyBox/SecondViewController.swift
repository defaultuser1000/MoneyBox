//
//  SecondViewController.swift
//  MoneyBox
//
//  Created by Андрей Закржевский on 09.07.2018.
//  Copyright © 2018 Андрей Закржевский. All rights reserved.
//

import UIKit
import SQLite

class SecondViewController: UIViewController {

    @IBOutlet weak var goalNameField: UITextField!
    @IBOutlet weak var goalSumField: UITextField!
    
    var prio = [Int]()
    
    @IBAction func addItem(_ sender: Any) {
        if (goalNameField.text != "" || goalSumField.text != ""){
            //list.append(input.text!)
            do {
                let priorities = try databaseGlobal.prepare(goals)
                for prior in priorities {
                    prio.append(prior[priority])
                }
            } catch {
                print(error)
            }
            var maxPrio = 0;
            for tmp in prio {
                if tmp > maxPrio {
                    maxPrio = tmp
                }
            }
            print(maxPrio)
            let insertGoal = goals.insert(goalName <- (goalNameField.text)!, goalSum <- (goalSumField.text)!, currentSum <- "0", isDone <- false, isDeleted <- false, priority <- (maxPrio + 1))
            goalNameField.text = ""
            goalSumField.text = ""
            
            do {
                
                
                
                try databaseGlobal.run(insertGoal)
                print("INSERTED GOAL")
                let selectGoals = try databaseGlobal.prepare(goals)
                for goal in selectGoals {
                    
                    print("Goal ID: \(goal[id]), Goal Name: \(goal[goalName]), Goal Sum: \(goal[goalSum]), Goal Priority: \(goal[priority]), Deleted: \(goal[isDeleted])")
                    
                }
                
            } catch {
                print(error)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

