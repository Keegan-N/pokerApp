//import UIKit
//
//var numbers: [Int] = [1,8,9,3,2,2,2]
//var suits: [String] = ["d","s","s","s","s","d","s"]
//
//public func fullHouse(numbers: [Int])->Bool{
//    var three = false
//    var two = false
//    var amount: [Int:Int] = [2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
//    for num in 0..<7{
//        amount[numbers[num]]! = amount[numbers[num]]! + 1
//    }
//    for num in 2..<15{
//        if(amount[num]! >= 3){
//            if (three == true){
//                two = true
//            } else {
//                three = true
//            }
//        }
//        if(amount[num]! == 2){
//            two = true
//        }
//        
//    }
//    if(two && three){
//        return true
//    } else {
//        return false
//    }
//}
//
//print(fullHouse(numbers: numbers))
