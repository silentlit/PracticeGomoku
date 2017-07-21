//
//  Black.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import Foundation

class Black: Chess
{
    init(username: String) {
        super.init(c: Color.black, username: "b\(username)")
    }
}
