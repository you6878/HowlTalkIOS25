//
//  ChatRoomsViewController.swift
//  HowlTalk
//
//  Created by 유명식 on 2017. 10. 31..
//  Copyright © 2017년 swift. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ChatRoomsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var tableview: UITableView!
    
    var uid : String!
    var chatrooms : [ChatModel]! = []
    var destinationUsers : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.uid = Auth.auth().currentUser?.uid
        self.getChatroomsList()
        // Do any additional setup after loading the view.
    }
    
    func getChatroomsList(){
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value, with: {(datasnapshot) in
            
            for item in datasnapshot.children.allObjects as! [DataSnapshot]{
                self.chatrooms.removeAll()
                if let chatroomdic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatroomdic)
                    self.chatrooms.append(chatModel!)
                }
                
            }
            self.tableview.reloadData()
            
            
        })
        
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for:indexPath) as! CustomCell
        
        var destinationUid :String?
        
        for item in chatrooms[indexPath.row].users{
            if(item.key != self.uid){
                destinationUid = item.key
                destinationUsers.append(destinationUid!)
            }
        }
        Database.database().reference().child("users").child(destinationUid!).observeSingleEvent(of: DataEventType.value, with: {
            (datasnapshot) in
            
            let userModel = UserModel()
            userModel.setValuesForKeys(datasnapshot.value as! [String:AnyObject])
            
            
            cell.label_title.text = userModel.userName
            let url = URL(string:userModel.profileImageUrl!)
            
            cell.imageview.layer.cornerRadius = cell.imageview.frame.width/2
            cell.imageview.layer.masksToBounds = true
            cell.imageview.kf.setImage(with: url)
         
            
            let lastMessagekey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0>$1}
            cell.label_lastmessage.text = self.chatrooms[indexPath.row].comments[lastMessagekey[0]]?.message
            let unixTime = self.chatrooms[indexPath.row].comments[lastMessagekey[0]]?.timestamp
            cell.label_timestamp.text = unixTime?.toDayTime
            
            
            
        })
        
        
        
        
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let destinationUid = self.destinationUsers[indexPath.row]
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        view.destinationUid = destinationUid
    
        self.navigationController?.pushViewController(view, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class CustomCell: UITableViewCell{
    
    @IBOutlet weak var label_timestamp: UILabel!
    @IBOutlet weak var label_lastmessage: UILabel!
    @IBOutlet weak var label_title: UILabel!
    @IBOutlet weak var imageview: UIImageView!
}
