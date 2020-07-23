//
//  ListVC.swift
//  AudioPlayer
//
//  Created by Nitin on 05/06/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit

struct AudioAssests {
    let url : String
    let name : String
    var isPlaying = false
}

class ListVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var data : [AudioAssests] = [AudioAssests]()
    var oldSelectedCell = -1

    @IBOutlet weak var audioAssetsCollectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getAllFiles()
    }
    
    //Mark:- table view delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! audioAssestsCell
        cell.lblTitle.text = data[indexPath.row].name
        
        if ( data[indexPath.row].isPlaying ) {
            cell.btnPlay.isHidden = false
        } else {
            cell.btnPlay.isHidden = true
        }
        
        return cell
    }
    
    //Mark:-  get all audio files
    func getAllFiles(){
       let docsPath = Bundle.main.resourcePath! + "/audioFiles"
       let fileManager = FileManager.default

       do {
           let docsArray = try fileManager.contentsOfDirectory(atPath: docsPath)
            
        for item in docsArray {
            let name = (item.components(separatedBy: "=").count > 1 ? item.components(separatedBy: "=").last : item)
            let audio = AudioAssests(url: docsPath+"/"+item, name: name!.trimmingCharacters(in: .whitespaces))
            self.data.append(audio)
        }
        data.sort(by: {$0.name < $1.name})
        audioAssetsCollectionTableView.reloadData()
       } catch {
           print(error)
       }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let selectedIndexPath = audioAssetsCollectionTableView.indexPathForSelectedRow
        let desti = segue.destination as! ViewController
        desti.filePath = data[(selectedIndexPath?.row)!].url
        
        data[selectedIndexPath!.row].isPlaying = true
        
        //to stop previous running audio, else it will play previous and current audio all together
        NotificationCenter.default.post(name:Notification.Name("stopMusic"),object: nil)
        
        if ( oldSelectedCell >= 0 ) {
            data[oldSelectedCell].isPlaying = false

            if  let cell = audioAssetsCollectionTableView.cellForRow(at: IndexPath(row:oldSelectedCell,section: 0)) as? audioAssestsCell {
                cell.btnPlay.isHidden = true
            }
        }
        
        let cell = audioAssetsCollectionTableView.cellForRow(at: selectedIndexPath!) as! audioAssestsCell
        cell.btnPlay.isHidden = false
        oldSelectedCell = selectedIndexPath!.row
    }

}
