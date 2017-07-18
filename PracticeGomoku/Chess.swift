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
    
    init() {
        self.chessColor = Color.none
    }
    
    init(c: Color) {
        self.chessColor = c
    }
}
