//
//  CreatorProfileViewController.swift
//  Travelear
//
//  Created by Nicholas Culpin on 11/11/18.
//  Copyright © 2018 thetravelear. All rights reserved.
//

import UIKit

class CreatorProfileViewController: TravelearViewController, UITableViewDelegate, UITableViewDataSource {
    
    var userID = String()
    var tracks = [Track]()
    var firstName = String()
    var profileImage = String()
    var bio = String()
    var joined = Date()
    var cellTitleId = "listTitleCell"
    var cellTracksId = "listTracksCell"

    lazy var CreatorTableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .white
        tv.delegate = self
        tv.dataSource = self
        tv.register(CreatorProfileTitleTableViewCell.self, forCellReuseIdentifier: cellTitleId)
        tv.register(CreatorProfileTracksTableViewCell.self, forCellReuseIdentifier: cellTracksId)
        return tv
    }()
    
    lazy var cancelButton: UIButton = {
        let sb = UIButton()
        let image = UIImage(named: "min-button") as UIImage?
        sb.setImage(image, for: .normal)
        sb.contentHorizontalAlignment = .center
        sb.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        sb.isAccessibilityElement = true
        sb.accessibilityLabel = "Minimize Button"
        return sb
    }()
    
    lazy var titleStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = NSLayoutConstraint.Axis.horizontal
        stack.spacing = 0
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        API.download{ (list) -> () in
            self.tracks = list.filter({ (Track) -> Bool in
                return Track.author!.contains(self.userID)
            })
            DispatchQueue.main.async {
                self.CreatorTableView.reloadData()
            }
        }
        
        API.getCreator(authorID: userID) { (user) in
            self.firstName = user.firstName ?? ""
            self.bio = user.bio ?? ""
            self.profileImage = user.profileImage ?? ""
            self.joined = user.joined ?? Date()
        }
        
        setUpView()
    }
    
    func setUpView(){
        self.view.backgroundColor = UIColor.white
        self.view.addSubview(cancelButton)
        self.view.addSubview(titleStackView)
        self.view.addSubview(CreatorTableView)
        
        cancelButton.anchor(self.view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: CreatorTableView.topAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, topConstant: 22, leftConstant: 8, bottomConstant: 0, rightConstant: 22, widthConstant: 44, heightConstant: 44)
        CreatorTableView.anchor(nil, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 22, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        CreatorTableView.reloadData()
        CreatorTableView.allowsMultipleSelection = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(dismissView), name: NSNotification.Name(rawValue: "dismiss"), object: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let Cell = CreatorTableView.dequeueReusableCell(withIdentifier: cellTitleId, for: indexPath) as! CreatorProfileTitleTableViewCell
            Cell.popOverTitleLabel.text = "\(firstName)"
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            dateFormatter.locale = Locale(identifier: "en_US")
            Cell.joinedDate.text = "Member since \(dateFormatter.string(from:joined))"
            Cell.bioLabel.text = "\(bio)"
            
            if profileImage != ""{
                let url = URL(string: profileImage)
                Cell.trackImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "welcomescreen"), completed: nil)
            } else {
                Cell.trackImageView.image = UIImage.init(contentsOfFile: "lockscreen-default.png")
            }
            
            return Cell
        case 1:
            let Cell = CreatorTableView.dequeueReusableCell(withIdentifier: cellTracksId, for: indexPath) as! CreatorProfileTracksTableViewCell
            Cell.tracks.removeAll(keepingCapacity: false)
            Cell.tracks = self.tracks
            DispatchQueue.main.async {
                Cell.listCollectionView.reloadData()
            }
            return Cell
        default: break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return UITableView.automaticDimension
        case 1:
            var itemWidth = CGFloat()
            var itemHeight = CGFloat()
            if UIDevice.current.userInterfaceIdiom == .phone {
                itemWidth = ((CreatorTableView.bounds.size.width - 44) / CGFloat(3.0)).rounded(.down)
                itemHeight = (CGFloat(tracks.count) * itemWidth) / 2.5
            } else {
                itemWidth = ((CreatorTableView.bounds.size.width - 44) / CGFloat(9.0)).rounded(.down)
                itemHeight = (CGFloat(tracks.count) * itemWidth) / 4
            }
            return CGFloat(itemHeight)
        default:
            return 95.0
        }
    }
    
}
