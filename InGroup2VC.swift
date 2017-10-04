//
//  InGroup2VC.swift
//  Healo
//
//  Created by Joe Kletz on 13/05/2017.
//  Copyright © 2017 Joe Kletz. All rights reserved.
//

import UIKit
import Firebase
import BonMot

class InGroup2VC: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet var myTableView: UITableView!
    
    @IBOutlet var highlightLeadingConstraint:NSLayoutConstraint!
    
    @IBOutlet var searchButton:UIButton!
    
    var message:String = " "

    var group:String!
    
    var members:[Member] = []
    
    var journalUids:[String] = []
    
    var spinner: Spinner?
    
    enum Tab {
        case memberConnect
        case groupChat
    }
    
    var currTab:Tab = .memberConnect
    
    var picker = UIPickerView()
    var pickerOKButton = UIButton()
    var pickerHidden = true
    

    
    // MARK: - MAIN FUNCS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        
        createMembersTableView()
        
        changeTab()
                
        spinner = Spinner(view: view)
        spinner?.showSpinner(show: true)
        
        newFetchUser()
        
        observeMessages()
        
        currTab = .memberConnect
        
        setupSearchButton()
        
        setupPicker()
    }
    
    func setupSearchButton() {
        searchButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        searchButton.layer.shadowColor = UIColor.black.cgColor
        searchButton.layer.shadowOpacity = 0.4
        searchButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        searchButton.layer.shadowRadius = 2
    }

    override func viewDidAppear(_ animated: Bool) {
        setupComplete = true
    }
    
    func setupNavBar() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        barBtn1()
        barBtn2()
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func barBtn1() {
        //Left button
        let button = UIButton.init(type: .custom)
        button.setImage(#imageLiteral(resourceName: "back1"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(self.dismissVC), for: UIControlEvents.touchUpInside)
        button.setupNavBarConstraints()
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func barBtn2() {
        //Right button
        let btn1 = UIButton(type: .custom)
        btn1.setImage(#imageLiteral(resourceName: "more"), for: .normal)
        btn1.setupNavBarConstraints()
        btn1.addTarget(self, action: #selector(showAlertList), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setRightBarButtonItems([item1], animated: true)
    }

    
    func createMembersTableView() {

        myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.register(UINib(nibName: "JournalCell", bundle: nil), forCellReuseIdentifier: "journalCell")
    }
    
    
    func toMemberRequest(index:Any) {
        
        var i:Int = 0
        var memberDetails = ("","")
        
        if index is Int{
            i = index as! Int
            memberDetails = (members[i].name,members[i].uid)
        }
        
        self.performSegue(withIdentifier: "sendRequest", sender: memberDetails)
    }

    
    func showAlertList() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        alert.addAction(UIAlertAction(title: "Change status", style: .default, handler: { (a) in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "tagsVC") as! TagsVC
            vc.editMode = true
            self.navigationController?.pushViewController(vc, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    func leaveGroup()  {
        
        spinner?.showSpinner(show: true)
        
        let uid = (Auth.auth().currentUser?.uid)!
        
        Database.database().reference().child("Users").child(uid).child("groups").child(group).removeValue { (error, ref) in
            if error != nil {
                print("error")
            } else{
                self.dismissVC()
            }
        }
        
        //Remove from Groups -
        Database.database().reference().child("Groups").child(group).child(uid).removeValue { (error, ref) in
            if error != nil {
                print("error \(String(describing: error))")
            }else{
                self.spinner?.showSpinner(show: false)
            }
            
        }
    }
    
    @IBAction func search(){
        switch currTab {
        case .groupChat:
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WriteEntry") as? JournalEntryVC
            {
                present(vc, animated: true, completion: nil)
            }
        case .memberConnect:
            showPicker()
        }
    }
    

    func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "sendRequest"){
            let newVC = segue.destination as! RequestVC
            let details = sender as! (String,String)
            
            //Set message
            RequestVC.message = "Hi " + details.0 + ", I would like to understand more about what you are going through.\nIt might help to talk."
            
            //Ver 1
            //It would be great if we could have a chat. It might be helpful
            newVC.toName = details.0
            newVC.toUid = details.1
        }
        
        if(segue.identifier == "toEntry"){
            let newVC = segue.destination as! JournalInspectVC
            newVC.id = sender as! String            
        }
    }
    
    func profileString(name:String,sex:String,age:Int) -> NSMutableAttributedString {
        
        let nameString = NSMutableAttributedString(
            string: name,
            attributes: [NSFontAttributeName:UIFont(
                name: "Karla-Bold",
                size: 22.0)!])
        let sexString = NSMutableAttributedString(
            string: "  " + sex + ", ",
            attributes: [NSFontAttributeName:UIFont(
                name: "Karla",
                size: 19.0)!])
        let ageString = NSMutableAttributedString(
            string: age.returnAgeBracket(),
            attributes: [NSFontAttributeName:UIFont(
                name: "Karla",
                size: 19.0)!])
        
        let completeString = NSMutableAttributedString()
        completeString.append(nameString)
        completeString.append(sexString)
        completeString.append(ageString)
        
        return completeString
    }

    // MARK: - TableView setup
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch currTab {
        case .memberConnect:
            toMemberRequest(index: indexPath.row)
        case .groupChat:
            break
        default:
            break
        }

        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currTab {
        case .memberConnect:
            return members.count
        case .groupChat:
            return self.journalUids.count//journalEntries.count
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch currTab {
        case .memberConnect:
            var hoo = members[indexPath.row].status.height(withConstrainedWidth: view.frame.width, font: UIFont(name: "Karla", size: 18)!)
            
            if hoo > 110 {
                hoo = 115
            }else if hoo > 40{
                hoo += 20
            }
            
            return hoo + 50
        case .groupChat:
            //let height = journalEntries[indexPath.row].message.height(withConstrainedWidth: view.frame.width - 50, font: UIFont(name: "Karla", size: 18)!)
            return 160
        default:
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch currTab {
        case .memberConnect:
            cell = memberCell(tableView, cellForRowAt: indexPath) as! UITableViewCell
        case .groupChat:
            cell = journalCell(tableView, cellForRowAt: indexPath) as! JournalCell
        default:
            break
        }
        
        return cell
        
    }
    
    // MARK: - Switching tabs
    
    @IBAction func connectButton() {
        currTab = .memberConnect
        changeTab()
    }
    
    @IBAction func shareButton() {
        currTab = .groupChat
        changeTab()
    }
    
    var setupComplete = false
    
    
    func changeTab() {
        
        switch currTab {
        case .memberConnect:
            myTableView.isHidden = false
            searchButton.setImage(#imageLiteral(resourceName: "search"), for: .normal)
            searchButton.backgroundColor = UIColor.turquiseDark
            
        case .groupChat:
            searchButton.setImage(#imageLiteral(resourceName: "monitorWhite"), for: .normal)
            searchButton.backgroundColor = UIColor.universalA()
        }
        
        if setupComplete {
            animateHighlight(tab: currTab)
        }
        
        
        myTableView.reloadData()
    }
    
    func animateHighlight(tab:Tab) {
        
        print(self.highlightLeadingConstraint.constant)
        
        let halfWidth = self.view.frame.width/2
        
        
        switch tab {
        case .groupChat:
            if self.highlightLeadingConstraint.constant < halfWidth - 1{
                UIView.animate(withDuration: 0.2, animations: {
                    self.highlightLeadingConstraint.constant.add(halfWidth)
                    self.view.layoutIfNeeded()
                })
           }
        case .memberConnect:
            if self.highlightLeadingConstraint.constant > 1 {
                UIView.animate(withDuration: 0.2, animations: {
                    self.highlightLeadingConstraint.constant.subtract(halfWidth)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    
    // MARK: - Firebase
    
    
    func newFetchUser() {
        
        members = []
        
        Database.database().reference().child("Groups").child(group).queryLimited(toLast: 40).observe(.childAdded, with: { (snapshot) in
            
            //uses snapshot.key
            Database.database().reference().child("Users").child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    
                    let member = Member()
                    
                    if dictionary["lastOnline"] != nil{
                        member.lastOnline = dictionary["lastOnline"] as! Int
                    }
                    
                    member.name = dictionary["name"] as! String
                    
                    if dictionary["age"] != nil{
                        member.age = dictionary["age"] as! Int
                    }
                    
                    if let status = dictionary["currStatus"]{
                        member.status = status as! String
                    }
                    
                    if let gender = dictionary["gender"]{
                        member.gender = gender as! String
                        
                    }
                    
                    //Check if new
                    
                    if let creationDate = dictionary["accountCreation"]{
                        
                        let dateNow = Int(NSDate().timeIntervalSince1970)
                        
                        let _creationDate = creationDate as! Int
                        
                        let secsSinceJoined = dateNow - _creationDate
                        
                        if secsSinceJoined < 170000{ // 170000 Approx 2 days
                            member.new = true
                        }
                    }
                    
                    member.uid = dictionary["uid"] as! String
                    
                    if member.uid != Auth.auth().currentUser?.uid{
                        
                        self.members.append(member)
            
                        self.timer?.invalidate()
                        
                        self.timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (t) in
                            self.handleReloadTable()
                        })
                    }
                }
            })
        })
    }
    
    var timer: Timer?
    
    func handleReloadTable() {
        
        spinner?.showSpinner(show: false)
        
        //Sorts by lastOnline timestamp
        self.members.sort (by: {$0.lastOnline > $1.lastOnline})
        
        DispatchQueue.main.async {
            self.myTableView.reloadData()
        }
        
    }

    
    func observeMessages() {
        
        let userGroupRef = Database.database().reference().child("journal_entries").queryOrdered(byChild: "timestamp").queryLimited(toLast: 20)
        
        userGroupRef.observe(.childAdded, with: { (snapshot) in
            
            guard let entry = snapshot.value as? [String:Any] else {return}
            
            let uid = entry["uid"] as! String
            //let timestamp = entry["timestamp"]

            var _share = false
            if let share = entry["share"] as? Bool{
                _share = share
            }

            if !_share{return}

            
            //The rest is handled in the custom cell
            if !(self.journalUids.contains(uid)){
                self.journalUids.append(uid)
            }
            
            /*
            DispatchQueue.main.async {
                self.reloadMessages()
            }*/
            
            self.myTableView.reloadData()
        })
    }
    
//    func reloadMessages() {
//        journalEntries.sort (by: {$0.timestamp > $1.timestamp})
//        
//        DispatchQueue.main.async {
//            self.myTableView.reloadData()
//        }
//    }
    
    
}

// MARK: Journal tab
extension InGroup2VC{
    func journalCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! JournalCell
        
        cell.selectionStyle = .none
        
        cell.uid = self.journalUids[indexPath.row]
        
        cell.vc = self
        
        return cell
    }

    func memberCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCell")
        
        let index = indexPath.row
        
        cell.textLabel?.textColor = UIColor.universalA()
        cell.textLabel?.attributedText = profileString(name: members[index].name, sex: members[index].gender, age: members[index].age)

        
        cell.detailTextLabel?.text = members[index].status
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.font = UIFont(name: "Karla", size: 18)
        cell.detailTextLabel?.numberOfLines = 5
        cell.selectionStyle = .none
        
        cell.backgroundColor = UIColor.white
        
        
        if members[index].new {
            //Create NEW badge
            let newHeight = 18
            let newWidth = 55
            let new = UILabel(frame: CGRect(x: Int(view.frame.width) - newWidth  + 10, y: 0, width: newWidth, height: newHeight))
            new.text = "  New"
            new.font = UIFont(name: "Karla-Bold", size: 15)
            new.textColor = UIColor.white
            new.layer.backgroundColor = UIColor.lightOrange2().cgColor
            
            cell.addSubview(new)
            
        }
        
        return cell

    }
}

extension InGroup2VC: UIPickerViewDelegate, UIPickerViewDataSource, UIToolbarDelegate{
    
    func showPicker() {
        
        
        if picker.isHidden {
            picker.isHidden = false
            pickerOKButton.isHidden = false
        }else{
            picker.isHidden = true
            pickerOKButton.isHidden = true
        }
    }
    
    func pickTag(){
        
        let row = picker.selectedRow(inComponent: 0)

        group = GroupsData.groups[row]
        
        spinner?.showSpinner(show: true)
        
        newFetchUser()
        
        showPicker()
    }
    
    func setupPicker() {

        let pickerHeight:CGFloat = 250
        picker = UIPickerView(frame: CGRect(x: 0, y: view.frame.height - pickerHeight, width: view.frame.width, height: pickerHeight))
        picker.backgroundColor = UIColor.turquiseDark
        picker.showsSelectionIndicator = true
        picker.delegate = self
        picker.dataSource = self
        
        view.addSubview(picker)
        
        setupPickerButton(pickerHeight)
        
        picker.isHidden = true
        
    }
    
    func setupPickerButton(_ height:CGFloat){
        pickerOKButton = UIButton(frame: CGRect(x: 0, y: view.frame.height - height, width: view.frame.width, height: 60))
        pickerOKButton.setTitle("OK", for: .normal)
        pickerOKButton.titleLabel?.font = UIFont(name: "Karla-Bold", size: 23)
        pickerOKButton.backgroundColor = UIColor.turquoise()
        pickerOKButton.isUserInteractionEnabled = true
        pickerOKButton.addTarget(self, action: #selector(pickTag), for: .touchUpInside)
        view.addSubview(pickerOKButton)
        pickerOKButton.isHidden = true
        
        let pickerCloseButton = UIButton(frame: CGRect(x: 10, y: 0, width: 60, height: 60))
        pickerCloseButton.setTitle("Cancel", for: .normal)
        pickerOKButton.addSubview(pickerCloseButton)
        pickerCloseButton.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        
    }

    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        
        if (pickerLabel == nil)
        {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = NSTextAlignment.center
        }
        
        let tag = GroupsData.groups[row]
        
        
        pickerLabel?.attributedText = tag.styled(with:
            StringStyle.Part.font(UIFont(name: "Karla", size: 24)!),
                                                    StringStyle.Part.color(.white)
        )
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GroupsData.groups.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

  }

