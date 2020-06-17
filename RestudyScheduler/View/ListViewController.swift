//
//  ListViewController.swift
//  RestudyScheduler
//
//  Created by Yuki Shinohara on 2020/06/15.
//  Copyright © 2020 Yuki Shinohara. All rights reserved.
//

import UIKit
import RealmSwift
import FSCalendar

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var subjectsLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var filteredStudyArray = [Study](){ //tableviewをカレンダータップごとに表示更新
        didSet {
            tableView?.reloadData()
        }
    }
    
    var num = 0
    
    var selectedDate = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        calendar.delegate = self
        calendar.dataSource = self
        calendar.appearance.borderRadius = 0
        
        selectedDate = DateUtils.stringFromDate(date: Date(), format: "yyyy/MM/dd")
        subjectsLabel.text = selectedDate
        filterTask(for: selectedDate)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = DateUtils.stringFromDate(date: date, format: "yyyy/MM/dd")
        subjectsLabel.text = selectedDate
        filterTask(for: selectedDate)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let realm = try! Realm()
//        let studies = realm.objects(Study.self)
        return filteredStudyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let realm = try! Realm()
//        let studies = realm.objects(Study.self)
//        let study = studies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredStudyArray[indexPath.row].title
        cell.detailTextLabel?.text = filteredStudyArray[indexPath.row].detail
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realm = try! Realm()
        let studies = realm.objects(Study.self)
        let study = studies[indexPath.row]
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "detail") as? DetailViewController {
            vc.study = study
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {

               let realm = try! Realm()
               let studies = realm.objects(Study.self)
               let study = studies[indexPath.row]
               guard let index = filteredStudyArray.firstIndex(of: study) else { return }
               filteredStudyArray.remove(at: index)

               try! realm.write({
                   realm.delete(study)
               })
            
               calendar.reloadData()
           }
        
       }
    
    func filterTask(for day: String){
        let realm = try! Realm()
        let filteredStudyResult = realm.objects(Study.self).filter("firstDay = '\(day)' OR secondDay = '\(day)' OR thirdDay = '\(day)' OR forthDay = '\(day)' OR fifthDay = '\(day)'")
        filteredStudyArray = Array(filteredStudyResult) //RealmのResultをArrayに変換
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int{
        let filteredDate = DateUtils.stringFromDate(date: date, format: "yyyy/MM/dd")
        filterTask(for: filteredDate)
        num = filteredStudyArray.count
        return num
    }
}