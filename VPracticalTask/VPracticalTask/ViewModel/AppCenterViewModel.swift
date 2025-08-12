//
//  AppCenterViewModel.swift
//  VPracticalTask
//
//  Created by Hardik Bhalgamiya on 13/08/25.
//

import Foundation

class AppCenterViewModel {
    
    private var allApps : [sub_category] = []
    var filteredApp: [sub_category] = []
    
    var onDataUpdated: (() -> Void )?
    
    
    func fetchApps(urlString:String){
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            
            guard let data = data, error == nil else { return}
            
            do{
                
                let response = try JSONDecoder().decode(AppCenterResponse.self, from: data)
                
                self.allApps = response.app_center.first?.sub_category ?? [sub_category]()

                self.filteredApp = self.allApps.filter({!$0.banner.isEmpty})
                
                DispatchQueue.main.async {
                    self.onDataUpdated?()
                }
            }
            catch{
                print("Error in decoding data :  \(error)")
            }
            
        }
        task.resume()
    }
}
