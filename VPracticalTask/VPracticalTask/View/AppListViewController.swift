//
//  AppListViewController.swift
//  VPracticalTask
//
//  Created by Hardik Bhalgamiya on 13/08/25.
//

import UIKit
import SDWebImage

class AppListViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var appListTableview: UITableView!
    
    // Variable Declaration
    private let viewmodel = AppCenterViewModel()
    
    //MARK: Lifecycle method
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        viewmodel.fetchApps(urlString: AppConstant.apiBaseUrl)
    }
    
    func setupUI(){
        let nib = UINib(nibName: "AppRowCell", bundle: nil)
        appListTableview.register(nib, forCellReuseIdentifier: "AppRowCell")
        
        appListTableview.rowHeight = UITableView.automaticDimension
        appListTableview.estimatedRowHeight = 100
    }
    
    func bindViewModel(){
        viewmodel.onDataUpdated = { [weak self] in
            self?.appListTableview.reloadData()
        }
    }
}

extension AppListViewController :  UITableViewDataSource,UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.filteredApp.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AppRowCell", for: indexPath) as? AppRowCell else{
            return UITableViewCell()
        }
        let app = viewmodel.filteredApp[indexPath.row]
        cell.appNameLabel.text = app.name
        cell.rangeLabel.text = app.installed_range
        
        cell.iconImageview.sd_setImage(with: URL(string: app.icon) ?? URL(string: ""))
        
        cell.cosmoStartView.rating = Double(app.star) ?? 0.0
        cell.buttonDownload.tag = indexPath.row
        cell.buttonDownload.addTarget(self, action: #selector(redirectOnTap), for: .touchUpInside)
        return cell
    }
    @objc func redirectOnTap(_ sender: UIButton){
        let app = viewmodel.filteredApp[sender.tag]
        if let url = URL(string: "\(AppConstant.appLinkPrefix)\(app.app_link)"){
            print(url)
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboardView = self.storyboard?.instantiateViewController(identifier: "SpiralViewController") as! SpiralViewController as SpiralViewController
        
        self.navigationController?.pushViewController(storyboardView, animated: true)
        
        
    }
}
