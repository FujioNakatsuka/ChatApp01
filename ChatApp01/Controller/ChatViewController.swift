//
//  ChatViewController.swift
//  ChatApp01
//
//  Created by 中塚富士雄 on 2020/05/27.
//  Copyright © 2020 中塚富士雄. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase
class ChatViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    //UITextFieldDelegateはTextFieldの操作に関するプロトコル
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    let screensize = UIScreen.main.bounds.size
    
    var chatArray = [Message]()
    //Message.swiftを作成した事で、sender,messageを保持できる。もしMessage .swifが無ければ？sender,messageの値を都度取得できない？
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        //このselfはChatViewControllerを指す
        
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier:"Cell")
            tableView.rowHeight = UITableView.automaticDimension

        tableView.estimatedRowHeight = 75
        
        //＃キーボードの管理
        //キーボードを出す。keyboardWillShowNotificationが呼ばれる時にkeyboardWillShow メソッドが選ばれる
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        //キーボードを閉じる
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
         
        //Firebaseからデータをfetch(取得)
        fetchChatData()
      
        
        tableView.separatorStyle = .none
        
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification){
        //引数としてNSNotification型が取れる、#selectorはobjective C の名残なので@objcが文頭に必要
        
        
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        
        messageTextField.frame.origin.y = screensize.height -  keyboardHeight - messageTextField.frame.height
       
    }
    
    @objc func keyboardWillHide(_ notification:NSNotification){
        
        messageTextField.frame.origin.y = screensize.height - messageTextField.frame.height
        
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
        
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]as? TimeInterval else{return}
        
        UIView.animate(withDuration: duration){
            
            let transform = CGAffineTransform(translationX: 0, y: 0)
            
            self.view.transform = transform
        
    }
    
}
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
    
    messageTextField.resignFirstResponder()
    
    }
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        
        textField.resignFirstResponder()
        
        return true
        
         }
    
    func tableView(_ tableView: UITableView, numberOfRowsInsection section: Int) -> Int{
        
        return chatArray.count
        //メッセージの数、クラスMessageの中のsenderはUserNameで良いのか？
    
    
    }
        
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
        
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)as! CustomCell
        
        cell.messageLabel.text = chatArray[indexPath.row].Message
        
        cell.userNameLabel.text = chatArray[indexPath.row].sender
        cell.iconimageView.image = UIImage(named: "dogAvatarImage")
        
        if cell.userNameLabel.text == Auth.auth().currentUser?.email as! String{
            
            cell.messageLabel.backgroundColor = UIColor.flatGreen()
            cell.messageLabel.layer.cornerRadius = 20
            cell.messageLabel.layer.masksToBounds = true
            
            
        }else{
        
            cell.messageLabel.backgroundColor = UIColor.flatBlue()
    
    }
        
        return cell
        
    }

    @IBAction func sendAction(_ sender: Any) {
        
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        if messageTextField.text!.count > 15{
            
            print("15文字以上です")
            
            return
            
        }
        
        
        let chatDB = Database.database().reference().child("chats")
        
        let messageInfo = ["sender": Auth.auth().currentUser?.email,"message":messageTextField.text!]
        //キーバリュー型（Dictionary型：キーとバリューの値を同時に持つ）で内容を送信
                
        chatDB.childByAutoId().setValue(messageInfo){(error, result) in
            //chatDBに入れる
            
            if error != nil{
                print(error)
                
        }else{
            
            print(" 送信完了")
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
        
        }
        
        
        
    }
    
    func fetchChatData(){
        
        let fetchDataRef = Database.database().reference().child("chats")
        //データベースのある場所（url）を指定
        
        fetchDataRef.observe(.childAdded){(snapShot) in
            //更新があった時だけ更新
            
            let snapShotData = snapShot.value as! AnyObject
            let text = snapShot.value(forKey: "message")
            let sender = snapShot.value(forKey: "sender")
            //forekeyでmessage,senderから値を取ってくる
            
            let message = Message()
            message.Message = text as! String
            message.sender = sender as! String
            self.chatArray.append(message)
            self.tableView.reloadData()
            
        }
        
        
    }
    
    
    
}

}
