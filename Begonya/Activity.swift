//
//  Activity.swift
//  Begonya
//
//  Created by Metin Atac on 24.08.18.
//  Copyright © 2018 Metin Atac. All rights reserved.
//

import Foundation

struct Activity {
    
   
    let date: String?
    
    let event: [String]?
    
    init(dic : [String: Any]) {
      
        self.date = dic["date"] as? String
        self.event = dic["event"] as? [String]
        
    }
    
}
    

