//
//  AudioTopVC.swift
//  Healo
//
//  Created by Joe Kletz on 17/08/2017.
//  Copyright © 2017 Joe Kletz. All rights reserved.
//

import UIKit
import Firebase

class AudioTopVC: UIViewController {
    
    struct Section {
        var name = ""
        var paths = 0
    }
    
    var sections:[Section] = []{
        didSet{
            tableView.reloadData()
        }
    }
    
    @IBOutlet var headerInfo:UIStackView!
        
    var logoImage = UIImageView()
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet var topView:UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        setupNavBar()
        addViewAboveHeader()
        
        observeSections()
    }
    
    override func viewDidLayoutSubviews() {
        styleTopView()
        
    }
    
    
    
    func styleTopView() {
        let colorA = #colorLiteral(red: 1, green: 0.6714072976, blue: 0.4237738794, alpha: 1).cgColor
        topView.addGradient(color1: colorA, color2: UIColor.universalA().cgColor)
        topView.bringSubview(toFront: headerInfo)

        topView.layer.shadowColor = UIColor.black.cgColor
        topView.layer.shadowOpacity = 0.5
        topView.layer.shadowOffset = CGSize(width: 2, height: 2)
        topView.layer.shadowRadius = 5
    }
    
    func setupNavBar() {
        
        
        barButton1()

        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.title = "Self Therapy"
        self.navigationController?.navigationBar.tintColor = UIColor.white
        

        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = UIColor.universalA()
        navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Karla", size: 20)!]

    }
    
    func barButton1() {
        //Left button
        let button = UIButton.init(type: .custom)
        button.setImage(#imageLiteral(resourceName: "back1"), for: UIControlState.normal)
        button.addTarget(self, action:#selector(back), for: UIControlEvents.touchUpInside)
        button.setupNavBarConstraints()
        let barButton = UIBarButtonItem.init(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func addViewAboveHeader() {
        
        let headerHeight = 200
        
        let v = UIView(frame: CGRect(x: 0, y: -headerHeight, width: Int(view.frame.width), height: headerHeight))
        v.backgroundColor = UIColor.turquiseDark
        
        let logoHeight = 100
        let logoWidth = 200
        
        logoImage.frame = CGRect(x: Int(view.frame.width/2) - (logoWidth/2), y: headerHeight - logoHeight, width: logoWidth, height: logoHeight)
        logoImage.contentMode = .scaleAspectFit
        logoImage.image = #imageLiteral(resourceName: "logoWhite1")
        v.addSubview(logoImage)
        
        tableView.addSubview(v)
    }
    
    func back() {
        dismiss(animated: true, completion: nil)
    }
    
    func observeSections() {
        Database.database().reference().child("audio_sections").observe(.childAdded, with: {snapshot in
            let pathCount = snapshot.childrenCount
            let section = Section(name: snapshot.key, paths: Int(pathCount))
            
            self.sections.append(section)
            
        })
    }
}

extension AudioTopVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row > 0{
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "Routes") as! PathsVC
            
            vc.section = sections[indexPath.row - 1].name
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0{
            return 100
        }else{
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count + 1///categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.separatorStyle = .none
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "RI_A", for: indexPath)
            cell.selectionStyle = .none
            return cell
        } else{
            
            return cellDetails(tableView, cellForRowAt: indexPath)
        }
    }
    
    func cellDetails(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> AudioCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SectionCell", for: indexPath) as! AudioCell
        cell.selectionStyle = .none
        cell.mainLabel.text = sections[indexPath.row - 1].name.capitalized
        
        cell.detailLabel.text = String(sections[indexPath.row - 1].paths) + " Paths"
        
        return cell
    }
}

class AudioTopCell: UITableViewCell {
    @IBOutlet weak var labelA:UILabel!
}

class BuySubscriptionCell: UITableViewCell {
    @IBOutlet weak var purchaseButton:UIButton!
}

class AudioCell:UITableViewCell{
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var mainLabel:UILabel!
    @IBOutlet var detailLabel:UILabel!
    
    override func didMoveToSuperview() {
        mainView.layer.cornerRadius = 6
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOpacity = 0.1
        mainView.layer.shadowOffset = CGSize(width: 2, height: 2)
        mainView.layer.shadowRadius = 0
    }
}
