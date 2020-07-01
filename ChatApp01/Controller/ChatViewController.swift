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
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    //スクリーンの上げ下げ
    let screensize = UIScreen.main.bounds.size
    //chatArrayの中にmessageの数とsenderの数が入る
    var chatArray = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //selfはChatViewController
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier:"Cell")
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        
        //キーボード,Selectorはどのメソッドを呼ぶか決める
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
         
        //Firebaseからデータを取得（fetch）
        fetchChatData()
        tableView.separatorStyle = .none
    }

    @objc func keyboardWillShow(_ notification:NSNotification){
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        messageTextField.frame.origin.y = screensize.height -  keyboardHeight - messageTextField.frame.height
        
    }
    
        @objc func keyboardWillHide(_ notification:NSNotification){
        messageTextField.frame.origin.y = screensize.height - messageTextField.frame.height
            
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey]as? TimeInterval else{return}
    
//⭐️関数の中にクロージャーを使う関数UIViewanimateがあり、その中で値を受け取るのでself?
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
    
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    //メッセージの数(⭐️送信者の数はどこへ？)
      return chatArray.count
  
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)as! CustomCell
        cell.messageLabel.text = chatArray[indexPath.row].message
        cell.userNameLabel.text = chatArray[indexPath.row].sender
        cell.iconimageView.image = UIImage(named: "dogAvatarImage")
        
        if cell.userNameLabel.text == Auth.auth().currentUser?.email{
        
            cell.messageLabel.backgroundColor = UIColor.flatGreen()
            cell.messageLabel.layer.cornerRadius = 20
            cell.messageLabel.layer.masksToBounds = true
            
        }else{
            
            cell.messageLabel.backgroundColor = UIColor.flatBlue()}
            
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
        
        //キーバリュー型で内容を送信
        let messageInfo = ["sender": Auth.auth().currentUser?.email,"message":messageTextField.text!]
        
        //キー値chatsをchatDBに入れる+if以下の処理はクロージャ/
        //childByAutoIdはFirebaseで自動的に割り当てられるID、AutoIdでsenderを識別しmessageも確定する
        chatDB.childByAutoId().setValue(messageInfo){(error, result) in
       
            if error != nil{
                print(error as Any)
                
        }else{
            print(" 送信完了")
            self.messageTextField.isEnabled = true
            self.sendButton.isEnabled = true
            self.messageTextField.text = ""
        }
      }
    }
        
        //fetchは引っ張ってくる（受信）
        func fetchChatData(){
        let fetchDataRef = Database.database().reference().child("chats")
            
        //新しく更新があった時だけ取得したい+クロージャ
        fetchDataRef.observe(.childAdded){(snapShot) in
            let snapShotData = snapShot.value as AnyObject
            let text = snapShot.value(forKey: "message")
            let sender = snapShot.value(forKey: "sender")
            let message = Message()
            message.message = text as! String
            message.sender = sender as! String
            self.chatArray.append(message)
            self.tableView.reloadData()
           }
        }
    
}

//rect/snapshotDataは初期化が使われていない？
