//
//  White.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import Foundation

class White: Chess
{
//    var location = [String: White]()
    
    init(username: String) {
        super.init(c: Color.white, username: "w\(username)")
    }
}
