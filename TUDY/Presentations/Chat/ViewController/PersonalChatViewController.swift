//
//  PersonalChatViewController.swift
//  TUDY
//
//  Created by neuli on 2022/06/13.
//

import UIKit
import SnapKit

private let reuseIdentifier = "MessageCell"

class PersonalChatViewController: UIViewController {
    
    // MARK: - Properties
    var chatInfo: ChatInfo? {
        didSet {
            configureUI()
        }
    }
    private var otherUserInfo: User!
    private var messages = [Message]()
    
    private lazy var chatinputView: ChatInputAccessoryView = {
        let iv = ChatInputAccessoryView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        iv.delegate = self
        return iv
    }()
    
    
    lazy var personalChatCV: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = .DarkGray1
        cv.register(MessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    let picker = UIImagePickerController()

    
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        personalChatCV.delegate = self
        personalChatCV.dataSource = self
        picker.delegate = self
        chatinputView.photoButton.addTarget(self, action: #selector(handlephoto), for: .touchUpInside)
        chatinputView.sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navAppear()
        tabDisappear()
    }
    
    override var inputAccessoryView: UIView? {
        get { return chatinputView }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
}

extension PersonalChatViewController {
    
    // MARK: - Methods
    private func configureUI() {
        configureNavigationBar()
        view.backgroundColor = .DarkGray1

        view.addSubview(personalChatCV)
        personalChatCV.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.backgroundColor = .DarkGray2
        navigationItem.backBarButtonItem?.title = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "초대", style: .plain, target: self, action: #selector(invitedButtonClicked))
        navigationItem.rightBarButtonItem?.tintColor = .PointBlue
    }
    
    private func getOtherUserInfo(OtherParticipantID otherparticipantid: String) {
        // 언제 가져올 지 알 수 없음
        FirebaseUser.fetchOtherUser(userID: otherparticipantid) { [weak self] user in
            self?.otherUserInfo = user
            self?.navigationItem.title = self?.otherUserInfo.nickname
        }
    }
}
// MARK: - extensions
extension PersonalChatViewController: UITextViewDelegate {
    @objc func invitedButtonClicked() {
        let invitedVC = InvitedViewController()
        invitedVC.modalPresentationStyle = .overFullScreen
        self.present(invitedVC, animated: false, completion: nil)
    }
}

extension PersonalChatViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MessageCell else {
            return UICollectionViewCell()
        }
        // dummy Data
        cell.userNameLabel.text = "호진"
        cell.textView.text = messages[indexPath.row].content
        return cell
    }
}


extension PersonalChatViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
}

extension PersonalChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handlephoto() {
        print("PHOTO")
        let alert = UIAlertController(title: "사진을 골라주세요.", message: "원하시는 버튼을 클릭해주세요.", preferredStyle: .actionSheet)
        let library = UIAlertAction(title: "사진앨범", style: .default) { (action) in self.openLibrary()
        }
        let camera = UIAlertAction(title: "카메라", style: .default) { (action) in self.openCamera()
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    func openLibrary() {
        picker.sourceType = .photoLibrary
        present(picker, animated: false, completion: nil)
    }
    
    func openCamera(){
        if(UIImagePickerController .isSourceTypeAvailable(.camera)){
            picker.sourceType = .camera
            present(picker, animated: false, completion: nil)
        } else {
            print("Camera not available")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
//            채팅 사진을 넣어주면 됨
            //            imageView.image = image
            print(info)
        }
        dismiss(animated: true, completion: nil)
    }
}

extension PersonalChatViewController: ChatInputAccessoryViewDelegate {
    @objc func sendMessage() {
//        print("SENDMESSAGE")
    }
    
    func inputView(_ inputView: ChatInputAccessoryView, wantsToSend message: String) {
        inputView.messageInputTextView.text = nil
        
        let message = Message(content: message, sender: User(), createdDate: "2021-21-21")
        messages.append(message)
        personalChatCV.reloadData()
    }
}










// MARK: - ChatProtocol
extension PersonalChatViewController: ChatProtocol {
    
}
