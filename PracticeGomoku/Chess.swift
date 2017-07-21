//
//  Chess.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import Foundation

enum Color {
    case black, white, none
}

class Chess
{
    var chessColor: Color
    
    var username: String
    
    init() {
        self.chessColor = Color.none
        username = ""
    }
    
    init(c: Color, username: String) {
        self.chessColor = c
        self.username = username
    }
}
