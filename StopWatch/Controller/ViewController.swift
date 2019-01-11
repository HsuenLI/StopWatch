//
//  ViewController.swift
//  StopWatch
//
//  Created by Hsuen-Ju Li on 2019/1/11.
//  Copyright © 2019 Hsuen-Ju Li. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    //Variables
    var isStart = false
    var timer = Timer()
    var timeCount = 0
    var times = [Time]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    //Outlets
    let timeLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 60)
        label.text = "00:00"
        label.textAlignment = .center
        return label
    }()

    let startButton : UIButton = {
        let button = UIButton(type: .system)
        button.customButton(title: "Start")
        return button
    }()
    
    let resetButton : UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.customButton(title: "Reset")
        button.tintColor = .red
        return button
    }()
    
    let saveButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.backgroundColor = UIColor.lightGray
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    var stackView : UIStackView = {
        let sv = UIStackView()
        sv.distribution = .fillEqually
        sv.spacing = 20
        sv.axis = .horizontal
        return sv
    }()
    
    lazy var tableView : UITableView = {
        let tv = UITableView()
        tv.delegate = self
        tv.dataSource = self
        return tv
    }()
    
    let cellId = "cellId"
    
    fileprivate func setupTimeLabel() {
        timeLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 150)
    }
    
    fileprivate func setupButtonsTarget() {
        startButton.addTarget(self, action: #selector(handleStartButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(handleResetButton), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
    }
    
    fileprivate func setupStackView() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(resetButton)
        stackView.addArrangedSubview(startButton)
        
        stackView.anchor(top: timeLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 30, paddingBottom: 0, paddingRight: 30, width: 0, height: 100)
    }
    
    fileprivate func setupSaveButton() {
        view.addSubview(saveButton)
        saveButton.anchor(top: stackView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true
        saveButton.isEnabled = false
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        tableView.anchor(top: saveButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 20, paddingRight: 20, width: 0, height: 0)
        tableView.register(TableCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 40
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(timeLabel)
        setupTimeLabel()
        setupButtonsTarget()
        
        setupStackView()
        
        setupSaveButton()
        
        setupTableView()
        
        loadData()
    }
    
    @objc func handleStartButton(){
        if isStart == false{
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleUpdateTimer), userInfo: nil, repeats: true)
            startButton.setTitle("Pause", for: .normal)
        }else{
            timer.invalidate()
            startButton.setTitle("Start", for: .normal)
            saveButton.isEnabled = true
            resetButton.isEnabled = true
        }
        isStart = !isStart
    }
    
    @objc func handleUpdateTimer(){
        timeCount += 1
        let (minute,second) = secondsToHoursMinutesSeconds(seconds: timeCount)
        timeLabel.text = String(format: "%02d:%02d", minute , second)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    @objc func handleResetButton(){
        resetUI()
        startButton.setTitle("Start", for: .normal)
    }
    
    @objc func handleSaveButton(){
        let time = Time(context: context)
        time.date = Date()
        time.timeLabel = timeLabel.text
        times.append(time)
        saveData()
        resetUI()
    }
    
    func resetUI(){
        isStart = false
        timeLabel.text = "00:00"
        timeCount = 0
        timer.invalidate()
        saveButton.isEnabled = false
        resetButton.isEnabled = false
    }

}

//TableView data source
extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TableCell
        cell.time = times[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completion) in
            self.context.delete(self.times[indexPath.item])
            self.times.remove(at: indexPath.item)
            self.saveData()
            completion(true)
        }
        
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
}


//Core Save and load
extension ViewController{
    func saveData(){
        do{
            try context.save()
        }catch{
            print("Failed to save data in core data")
        }
        
        tableView.reloadData()
    }
    
    func loadData(){
        let request : NSFetchRequest<Time> = Time.fetchRequest()
        let sortDiscriptor = [NSSortDescriptor(key: "date", ascending: true)]
        request.sortDescriptors = sortDiscriptor
        
        do{
            times = try context.fetch(request)
        }catch{
            print("Failed to load data")
        }
        
        tableView.reloadData()
    }
}



extension UIButton{
    func customButton(title: String){
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 30)
        tintColor = UIColor.darkGray
    }
}




