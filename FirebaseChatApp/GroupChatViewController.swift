//
//  GroupChatViewController.swift
//  FirebaseChatApp
//
//  Created by Ahsan Lakhani on 8/12/17.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices //for accessing camera roll
import AVKit //for playing video
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage //download images from database


class GroupChatViewController: JSQMessagesViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    var messagesPerPage = 15
    var lastKey:String?
    
    var group: Groups!
    
    var ref: DatabaseReference!
    
    private var messages = [JSQMessage]()
    
    let picker = UIImagePickerController()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showLoadEarlierMessagesHeader = true

        picker.delegate = self
        
        self.senderId = Auth.auth().currentUser?.uid
        self.senderDisplayName = currentUserName
        
        ref = Database.database().reference()
        
        loadessages()
        getMediaMessages()
        
        
        
        //self.getMessages()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId{
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.blue)
        }
        else
        {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.gray)
        }
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let name = messages[indexPath.row].senderDisplayName
        return NSAttributedString(string: name!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 30
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "userimage"), diameter: 30)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let msg = messages[indexPath.item]
        
        if msg.isMediaMessage{
            if let mediaItem = msg.media as? JSQVideoMediaItem{
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerVC = AVPlayerViewController()
                playerVC.player = player
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        self.loadessages()
    }
    //End collection view funcs
    
    //message send btn function
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        self.getMessages()
        
        let messageref = self.ref.child("messages").child(self.group.id).childByAutoId()
        let messagesdict = ["text":text,
                            "senderId":senderId,
                            "senderDisplayName":senderDisplayName,
                            "timestamp":[".sv": "timestamp"]] as [String : Any]
        
        

        messageref.updateChildValues(messagesdict)//write message to database

        //remove the text from the text field
        finishSendingMessage()
    }
    
    //image/video send btn function
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select image or video", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photos = UIAlertAction(title: "Photos", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeImage)
        })
        
        let videos = UIAlertAction(title: "Videos", style: .default, handler: { (alert: UIAlertAction) in
            self.chooseMedia(type: kUTTypeMovie)
        })
        
        alert.addAction(photos)
        alert.addAction(cancelAction)
        alert.addAction(videos)
        present(alert, animated: true, completion: nil)
    }
    
    //image picker view function
    private func chooseMedia(type: CFString)
    {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            //            let img = JSQPhotoMediaItem(image: pic)
            //            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: img))
            let data = UIImageJPEGRepresentation(pic, 0.01)
            sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName)
        }
        else if let vidURL = info[UIImagePickerControllerMediaURL] as? URL
        {
            //            let video = JSQVideoMediaItem(fileURL: vidUrl, isReadyToPlay: true)
            //            self.messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, media: video))
            sendMedia(image: nil, video: vidURL, senderID: senderId, senderName: senderDisplayName)
        }
        dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    func sendMedia(image:Data?, video:URL?, senderID:String, senderName:String){
        if image != nil {
            let storage = Storage.storage().reference()
            
            storage.child("images").child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil) {  (metadata: StorageMetadata?, err: Error?)
                in
                
                if err != nil
                {
                    //handle error
                }
                else
                {
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                }
                
            }
        }
        else if video != nil{
            let storage = Storage.storage().reference()
            storage.child("videos").child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil) { (metadata: StorageMetadata?, err: Error?)
                in
                
                if err != nil
                {
                    //handle error
                }
                else
                {
                    self.sendMediaMessage(senderID: senderID, senderName: senderID, url: String(describing: metadata!.downloadURL()!))
                }
            }
            
        }
    }
    
    func sendMediaMessage(senderID:String, senderName:String, url:String)
    {
        let key = ref.child("mediamessage").childByAutoId()
        let mediaMessage = ["senderID": senderID,
                            "senderName": senderName,
                            "url": url
            ] as [String : Any]
        
        key.updateChildValues(mediaMessage)
        
    }
    
    func loadessages(){
        if(lastKey == nil){
            let messageref = ref?.child("messages").child(self.group.id)
            messageref?.queryOrderedByKey().queryLimited(toLast: UInt(messagesPerPage)).observeSingleEvent(of: .value, with: { (snapshot) in
                if(snapshot.exists()){
                    self.lastKey=(snapshot.children.allObjects.first as! DataSnapshot).key
                    print(self.lastKey)
                    
                    var _messages:[JSQMessage]=[]
                    
                    for child in snapshot.children{
                        let _child = child as! DataSnapshot
                        let messagesDict = _child.value as? [String : AnyObject] ?? [:]
                        print(messagesDict)
                        let text = messagesDict["text"] as! String
                        let id = messagesDict["senderId"] as! String
                        let name = messagesDict["senderDisplayName"] as! String
                        
                        _messages.append(JSQMessage(senderId: id, displayName: name, text: text))
                        
                    }
                    
                    self.messages.append(contentsOf: _messages)
                    self.collectionView.reloadData()
                }
            })
        }
        else{
            
            let messageref = ref?.child("messages").child(self.group.id)
            messageref?.queryOrderedByKey().queryLimited(toLast: UInt(messagesPerPage+1)).queryEnding(atValue: self.lastKey ).observeSingleEvent(of: .value, with: { (snapshot) in
                if(snapshot.exists()){
                    print(snapshot)
                    self.lastKey=(snapshot.children.allObjects.first as! DataSnapshot).key
                    print(self.lastKey)
                    
                    var _messages:[JSQMessage]=[]
                    
                    var count = 0
                    
                    for child in snapshot.children{
                        
                        let _child = child as! DataSnapshot
                        
                        let a = Int(snapshot.childrenCount)
                        if count == a-1 {
                            break
                        }
                        count += 1
                        
                        
                        let messagesDict = _child.value as? [String : AnyObject] ?? [:]
                        print(messagesDict)
                        let text = messagesDict["text"] as! String
                        let id = messagesDict["senderId"] as! String
                        let name = messagesDict["senderDisplayName"] as! String
                        
                        _messages.append(JSQMessage(senderId: id, displayName: name, text: text))
                        
                    }
                    self.messages.insert(contentsOf: _messages, at: 0)
                    
                    self.collectionView.reloadData()
                }
            })
            
            
        }
    }

    
    //observers
    func getMessages()
    {
        let messageref = ref.child("messages").child(self.group.id)
            print(messageref)
        _ = messageref.observeSingleEvent(of: .childChanged, with: { (snapshot) in
                let messagesDict = snapshot.value as? [String : AnyObject] ?? [:]
                print(messagesDict)
                let text = messagesDict["text"] as! String
                let id = messagesDict["senderId"] as! String
                let name = messagesDict["senderDisplayName"] as! String
                
                self.messages.append(JSQMessage(senderId: id, displayName: name, text: text))
                self.collectionView.reloadData()
            })
    
    }
    
    func getMediaMessages()
    {
        if let mediamessageref = ref?.child("mediamessages") {
            print(ref)
            _ = mediamessageref.observe(DataEventType.childAdded, with: { (snapshot) in
                let mediamessagesDict = snapshot.value as? [String : AnyObject] ?? [:]
                print(mediamessagesDict)
                let id = mediamessagesDict["senderID"] as! String
                let name = mediamessagesDict["senderName"] as! String
                let url = mediamessagesDict["url"] as! String
                
                
                if let mediaURL = URL(string: url)
                {
                    do{
                        let data = try Data(contentsOf: mediaURL)
                        
                        if let _ = UIImage(data: data) //if this works then we have a image
                        {
                            let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: { (image, data, error, finished) in
                                DispatchQueue.main.async {
                                    let photo = JSQPhotoMediaItem(image: image)
                                    if id == self.senderId {
                                        photo?.appliesMediaViewMaskAsOutgoing = true
                                    }
                                    else
                                    {
                                        photo?.appliesMediaViewMaskAsOutgoing = false
                                    }
                                    self.messages.append(JSQMessage(senderId: id, displayName: name, media: photo))
                                    self.collectionView.reloadData()
                                }
                            })
                        }
                        else //if this works then we have a video
                        {
                            let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true)
                            if id == self.senderId
                            {
                                video?.appliesMediaViewMaskAsOutgoing = true
                            }
                            else
                            {
                                video?.appliesMediaViewMaskAsOutgoing = false
                            }
                            self.messages.append(JSQMessage(senderId: id, displayName: name, media: video))
                            self.collectionView.reloadData()
                            
                        }
                    }
                    catch{}
                }
                
            })
            
        }
    }
    
//    func createConversation()
//    {
//        let uuid = UUID().uuidString
//        let key = self.ref.child("conversations").child((Auth.auth().currentUser?.uid)!).child(uuid)
//        let dict = [participant.id:participant.name]
//        
//        let key2 = self.ref.child("conversations").child(participant.id).child(uuid)
//        let dict2 = [Auth.auth().currentUser!.uid:currentUserName]
//        
//        key.updateChildValues(dict)
//        key2.updateChildValues(dict2)
//        
//    }
    
    
//    func fetchConversations()
//    {
//        if let conversationref = ref?.child("conversations").child((Auth.auth().currentUser!.uid)) {
//            //            print(ref)
//            _ = conversationref.observe(DataEventType.value, with: { (snapshot) in
//                let conversationdict = snapshot.value as? [String : AnyObject] ?? [:]
//                for dict in conversationdict
//                {
//                    let c = dict.value as? [String:String]
//                    let partId = String(describing: c!.keys.first!)
//                    if(partId == self.participant.id)
//                    {
//                        let chatId = dict.key as? String
//                        self.chatId = chatId
//                        self.getMessages()
//                    }
//                    
//                }
//                
//                if(self.chatId==nil){
//                    self.createConversation()
//                }
//                
//            })
//            
//            
//        }
//    }



}
