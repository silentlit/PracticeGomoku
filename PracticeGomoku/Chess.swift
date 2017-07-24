//
//  Chess.swift
//  PracticeGomoku
//
//  Created by yyh on 17/7/18.
//  Copyright © 2017年 yyh. All rights reserved.
//

import Foundation
import UIKit

enum Color {
    case black, white, none
    
    func description() -> String {
        switch self {
        case .black:
            return "black"
        case .white:
            return "white"
        case .none:
            return "none"
        }
    }
}

class Chess
{
    var chessColor: Color
    
    var username: String
    
    var location = [String: UIImageView]() //字典 abs(x,y) -> UIImageView 检测落子合法性, 胜负判定
    
    var chessStack = [[String: UIImageView]]() //数组字典 [abs(x,y) -> UIImageView] 悔棋
    
    var redDotStack = [CGPoint]() //数组 (x,y) -> location 悔棋
    
    init() {
        self.chessColor = Color.none
        username = ""
    }
    
    init(c: Color, username: String) {
        self.chessColor = c
        self.username = username
    }
    
//    //将ImageView redDotLocation添加进栈中
//    func pushToStack(chessImgView: UIImageView, redDotLocation: String) {
//        chessStack.append([pointToString: chessImgView])
//    }
    
    //将ImageView redDotLocation出栈 抽象棋盘对应点设置为nil
    func popFromStack() -> (chess: UIImageView, chessAbsPointOfString: String)? {
        if chessStack.isEmpty == false {
            //当前点参数
            let chessAbsWithUIImgViewByDict = chessStack.removeLast()
            
            //将location对应点设置nil
            let keys = Array(chessAbsWithUIImgViewByDict.keys)
            let absPointOfString = keys.first!
            location[absPointOfString] = nil
            
            //将当前点的imgView
            let chessUIImgView = chessAbsWithUIImgViewByDict[absPointOfString]!
            return (chessUIImgView, absPointOfString)
        }
        return nil
    }
    
    //向栈中添加棋子 悔棋可以pop处理，向字典中加入棋子 检测可以直接point得到
    func addChess(point: (x: Int, y: Int), chess: UIImageView, redDotLocation: CGPoint) {
        let pointOfString = pointToString(point)
        chessStack.append([pointOfString: chess])
        location[pointOfString] = chess
//        print(point)
    }
    
    //将点坐标规范为String
    func pointToString(point: (x: Int, y: Int)) -> String {
        return "\(point.x),\(point.y)"
    }
    
    //将String转化为point
    func stringToPoint(pointOfString: String) -> (x: Int, y: Int) {
        var info = pointOfString.componentsSeparatedByString(",")
        let x = Int(info.removeFirst())!
        let y = Int(info.removeFirst())!
        
        return (x, y)
    }
    
    //合法性检查
    func isLegalOrNot(point: (x: Int, y: Int)) -> Bool {
        let pointOfString = pointToString(point)
        
        if point.x < 1 || point.x > 15 || point.y < 1 || point.y > 15 { //范围是否合法
            return false
        } else {
            if let _ = location[pointOfString] { //检测此处是否有棋子
                return false //有棋子
            } else {
                return true //无棋子
            }
        }
    }
    
    //胜负判定 根据4个走向搜索
    func didWinOrNot(point: (x: Int, y: Int), color: String) -> Bool {
        var count = 1
        var xi = point.x
        var yi = point.y
        
        //横向搜索
        //++横向搜索
        while true {
            if let chess = location[pointToString((++xi, yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //--横向搜索
        xi = point.x
        while true {
            if let chess = location[pointToString((--xi, yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //横向搜索完毕 判定
        if count >= 5 {
            return true
        } else {
            count = 1
            xi = point.x
            yi = point.y
        }
        
        //纵向搜索
        //++纵向搜索
        while true {
            if let chess = location[pointToString((xi, ++yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //--纵向搜索
        yi = point.y
        while true {
            if let chess = location[pointToString((xi, --yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //纵向搜索完毕 判定
        if count >= 5 {
            return true
        } else {
            count = 1
            xi = point.x
            yi = point.y
        }
        
        //对角线搜索
        //++对角线搜索
        while true {
            if let chess = location[pointToString((++xi, ++yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //--对角线搜索
        xi = point.x
        yi = point.y
        while true {
            if let chess = location[pointToString((--xi, --yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //对角线搜索完毕 判定
        if count >= 5 {
            return true
        } else {
            count = 1
            xi = point.x
            yi = point.y
        }
        
        //反对角线搜索
        //++反对角线搜索
        while true {
            if let chess = location[pointToString((++xi, --yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //--反对角线搜索
        xi = point.x
        yi = point.y
        while true {
            if let chess = location[pointToString((--xi, ++yi))] {
                if chess.image?.accessibilityIdentifier == color {
                    ++count
                } else {
                    break
                }
            } else {
                break
            }
        }
        //反对角线搜索完毕 判定
        if count >= 5 {
            return true
        } else {
            count = 1
            xi = point.x
            yi = point.y
        }
        
        return false //全部搜索完毕
    }
    
    //悔棋
    func undo() {
        
    }
}
