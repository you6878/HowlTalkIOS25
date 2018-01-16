//
//  MainViewController.swift
//  HowlTalk
//
//  Created by 유명식 on 2017. 8. 29..
//  Copyright © 2017년 swift. All rights reserved.
//

import UIKit
import SnapKit
import Firebase
import Kingfisher

class PeopleViewController: UIViewController, UITableViewDelegate,UITableViewDataSource {

    
    var array : [UserModel] = []
    var tableview : UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableview = UITableView()
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(PeopleViewTableCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableview)
        tableview.snp.makeConstraints { (m) in
            m.top.equalTo(view)
            m.bottom.left.right.equalTo(view)
            
        }
        
        
        Database.database().reference().child("users").observe(DataEventType.value, with: { (snapshot) in
            
            
            self.array.removeAll()
            
            let myUid = Auth.auth().currentUser?.uid
            
            for child in snapshot.children{
                let fchild = child as! DataSnapshot
                let userModel = UserModel()
                userModel.setValuesForKeys(fchild.value as! [String : Any])
                
                
                if(userModel.uid == myUid){
                    continue
                }
                
    
                self.array.append(userModel)
                
            }
            
            DispatchQueue.main.async {
                self.tableview.reloadData();
            }
        })
        
        
        
        

        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableview.dequeueReusableCell(withIdentifier: "Cell", for :indexPath) as! PeopleViewTableCell
        
        
        let imageview = cell.imageview!
        
        imageview.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(cell).offset(10)
            m.height.width.equalTo(50)
        }
        
        let url = URL(string: array[indexPath.row].profileImageUrl!)
        
        imageview.layer.cornerRadius = 50/2
        imageview.clipsToBounds = true
        imageview.kf.setImage(with: url)
        
        
        let label = cell.label!
        label.snp.makeConstraints { (m) in
            m.centerY.equalTo(cell)
            m.left.equalTo(imageview.snp.right).offset(20)
        }
        
        label.text = array[indexPath.row].userName
        
        let label_comment = cell.label_comment!
        label_comment.snp.makeConstraints { (m) in
            m.centerX.equalTo(cell.uiview_comment_background)
            m.centerY.equalTo(cell.uiview_comment_background)
        }
        if let comment = array[indexPath.row].comment{
            label_comment.text = comment
        }
        cell.uiview_comment_background.snp.makeConstraints { (m) in
            m.right.equalTo(cell).offset(-10)
            m.centerY.equalTo(cell)
            if let count = label_comment.text?.count{
                m.width.equalTo(count * 10)
            }else{
                m.width.equalTo(0)
            }
            m.height.equalTo(30)
        }
        cell.uiview_comment_background.backgroundColor = UIColor.gray
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let view = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as? ChatViewController
        view?.destinationUid = self.array[indexPath.row].uid
        
        self.navigationController?.pushViewController(view!, animated: true)
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

class PeopleViewTableCell :UITableViewCell{
    
    var imageview :UIImageView! = UIImageView()
    var label :UILabel! = UILabel()
    var label_comment : UILabel! = UILabel()
    var uiview_comment_background : UIView = UIView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(imageview)
        self.addSubview(label)
        self.addSubview(uiview_comment_background)
        self.addSubview(label_comment)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
