//
//  ContentView.swift
//  pokerApp
//
//  Created by Norgard, Keegan - Student on 10/21/24.
//

import SwiftUI




struct PlayView: View {
    let startingMoney: Int
    @State var cardsPlayed: [String] = []
    // index and importance [index 0-2 flop] [index 3-4 player] [index 5-6 bot 3] [index 7-8 bot 2] [index 9-10 bot 1] [index 11 river] [index 12 turn]
    @State var animation: Bool = false
    @State var folded: [Bool] = [false,false,false,false]
    @State var raised: [Bool] = [false,false,false,false]
    @State var call: [Bool] = [false,false,false,false]
    @State var flop: Bool = false
    @State var noAnimationRiver: Bool = false
    @State var river: Bool = false
    @State var noAnimationTurn: Bool = false
    @State var turn: Bool = false
    @State var tempRaise2: Int = 0
    @State var tempRaise10: Int = 0
    @State var tempRaise20: Int = 0
    @State var whosTurn: Int = 1
    @State var currentBids: [String:Int] = ["player":0,"bot 1":50,"bot 2":0,"bot 3": 0]
    @State var thePotChips: [Int:Int] = [2:010,10:010,20:010]
    @State var thePotTotal: Int = 0
    var body: some View {
        ZStack{
            //            Image("background")
            //                .resizable()
            //                .frame(maxWidth: .infinity,maxHeight: .infinity)
            //                .aspectRatio(contentMode: .fill)
            
            VStack{
                HStack(spacing: 0){
                    bot1(cardsPlayed: $cardsPlayed, thePot : $thePotChips)
                        .frame(height: 250)
                    bot2(cardsPlayed: $cardsPlayed, thePot : $thePotChips)
                        .frame(height: 250)
                    bot3(cardsPlayed: $cardsPlayed, thePot : $thePotChips)
                        .frame(height: 250)
                    
                }
                .opacity(raised[0] ? 0.4 : 1)
                Spacer()
                HStack{
                    Spacer()
                        .frame(width: 25)
                    VStack(spacing: 0){
                        Button{
                            if (raised[0]) {
                                tempRaise2 += 1
                                raisePot(chipAmount: 1, chipValue: 2)
                            }
                        }label: {
                            
                            Image("chip 2")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(animation ? 1.2 : 1.3)
                                .onAppear(){
                                    withAnimation(.linear(duration: 3).repeatForever()){
                                        animation.toggle()
                                    }
                                }
                            
                                .onChange(of: thePotChips) {
                                    thePotTotal = 0
                                    thePotTotal += thePotChips[2]! * 2
                                    thePotTotal += thePotChips[10]! * 10
                                    thePotTotal += thePotChips[20]! * 20
                                }
                        }
                        Button{
                            if (raised[0]) {
                                tempRaise10 += 1
                                raisePot(chipAmount: 1, chipValue: 10)
                            }
                        } label: {
                            Image("chip 10")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(animation ? 1.2 : 1.3)
                        }
                        Button {
                            if (raised[0]) {
                                tempRaise20 += 1
                                raisePot(chipAmount: 1, chipValue: 20)
                            }
                        }label: {
                            Image("chip 20")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(animation ? 1.2 : 1.3)
                            
                            
                        }
                    }
                    
                    .opacity(1)
                    Spacer()
                    VStack(spacing: 50){
                        HStack{
                            Button{
                                if (raised[0]) {
                                    raisePot(chipAmount: -tempRaise2, chipValue: 2)
                                    raisePot(chipAmount: -tempRaise10, chipValue: 10)
                                    raisePot(chipAmount: -tempRaise20, chipValue: 20)
                                    tempRaise2 = 0
                                    tempRaise10 = 0
                                    tempRaise20 = 0
                                }
                            }label: {
                                thePot(thePot: thePotChips)
                                
                            }
                            .offset(x:-50)
                        }
                       
                            HStack{
                                Button{
                                    if(whosTurn == 1 && raised[0] == false && !folded[0]){
                                        raised[0] = true
                                    } else if(whosTurn == 1 && raised[0] == true && !folded[0]){
                                        raised[0] = false
                                        tempRaise2 = 0
                                        tempRaise10 = 0
                                        tempRaise20 = 0
                                        endTurn()
                                    }
                                }label: {
                                    Text("Raise")
                                        .font(.system(size: 40))
                                        .bold()
                                        .foregroundStyle(.black)
                                }
                                .frame(width: 125)
                                .buttonStyle(.bordered)
                                Spacer()
                                    .frame(width: 50)
                                Button{
                                    if(whosTurn == 1 && !folded[0] && !raised[0]){
                                        if(currentBids["player"]! >= currentBids["bot 1"]! && currentBids["player"]! >= currentBids["bot 2"]! && currentBids["player"]! >= currentBids["bot 3"]! ){
                                            endTurn()
                                        } else {
                                            currentBids["player"] = callAction()
                                            print("\(currentBids["player"] ?? 0)")
                                            endTurn()
                                        }
                                    
                                        
                                        
                                        
                                        
                                    }
                                }label: {
                                    if(currentBids["player"]! >= currentBids["bot 1"]! && currentBids["player"]! >= currentBids["bot 2"]! && currentBids["player"]! >= currentBids["bot 3"]! ){
                                        Text("Check")
                                            .font(.system(size: 40))
                                            .bold()
                                            .foregroundStyle(.black)
                                    } else {
                                        Text("Call")
                                            .font(.system(size: 40))
                                            .bold()
                                            .foregroundStyle(.black)
                                    }
                                }
                                .opacity(raised[0] ? 0.4 : 1)
                                .frame(width: 150)
                                .buttonStyle(.bordered)
                                Spacer()
                                    .frame(width: 50)
                                Button{
                                    if(whosTurn == 1 && !folded[0] && !raised[0]){
//                                        folded[0] = true
                                        endRound()
//                                        endTurn()
                                        if turn {
                                            print(evaluate(card1: cardsPlayed[3], card2: cardsPlayed[4]))
                                        }
                                        
                                    }
                                }label: {
                                    Text("Fold")
                                        .font(.system(size: 40))
                                        .bold()
                                        .foregroundStyle(.black)
                                }
                                .opacity(raised[0] ? 0.4 : 1)
                                .frame(width: 125)
                                .buttonStyle(.bordered)
                                Spacer()
                                    .frame(width: 50)
                            }
                            
                            HStack{
                                Button{
                                    print("\(evaluate(card1: cardsPlayed[1], card2: cardsPlayed[2]))")
                                }label:{
                                    Text("test button")
                                }
                                Text(" ")
                            }
                    }
                    Spacer()
                    
                    HStack(spacing: -100){
                        if(!folded[0]){
                            frontCard(cardsPlayed: $cardsPlayed)
                                .frame(width: 200)
                            frontCard(cardsPlayed: $cardsPlayed)
                                .frame(width: 200)
                        } else {
                            Image("back")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200)
                            Image("back")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200)
                        }
                    }
                    .opacity(raised[0] ? 0.4 : 1)
                    .offset(y: 200)
                    .overlay{
                        ZStack{
                            ZStack{
                                

                                
                                Image("back")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 150)
//                                first

                                    frontCard(cardsPlayed: $cardsPlayed)
                                        .frame(width: 100)
                                        .offset(x: flop ? 55 : 0,y: flop ? 155 : 0)
                                    frontCard(cardsPlayed: $cardsPlayed)
                                        .frame(width: 100)
                                        .offset(x: flop ? -55 : 0,y: flop ? 155 : 0)
                                    frontCard(cardsPlayed: $cardsPlayed)
                                        .frame(width: 100)
                                        .offset(x: flop ? -165 : 0,y: flop ? 155 : 0)
                                    Image("back")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 150)
                                        .offset(x: flop ? 110 : 0)
                                if(noAnimationRiver){
                                    //second
                                    frontCard(cardsPlayed: $cardsPlayed)
                                        .frame(width: 100)
                                        .offset(x: river ? -110 : 0)
                                    Image("back")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 150)
                                        .offset(x: river ? 110 : 0)
                                    
                                    //third
                                    if(noAnimationTurn){
                                        frontCard(cardsPlayed: $cardsPlayed)
                                            .frame(width: 100)
                                            .offset(x: turn ? -220 : 0)
                                        Image("back")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 150)
                                            .offset(x: turn ? 110 : 0)
                                    }
                                }
                                
                                
                            }
                            .offset(x: 5,y: -185)
                        }
                    }
                    Spacer()
                        .frame(width: 25)
                }
            }
        }
    }
    public func evaluate(card1: String, card2: String)->Double{
        if(cardsPlayed.count != 13){
            return 0
        } else {
        let cardsCompare: [String] = [card1,card2,cardsPlayed[0],cardsPlayed[1],cardsPlayed[2],cardsPlayed[11],cardsPlayed[12]]
            var suits: [String] = []
            var numbers: [Int] = []
            var total: Double = 0
            var type: Double = 0
            for num in 0..<7{
                switch cardsCompare[num].prefix(1){
                case "s":
                    suits.append("s")
                case "c":
                    suits.append("c")
                case "d":
                    suits.append("d")
                case "h":
                    suits.append("h")
                default:
                    continue
                }
                switch cardsCompare[num].suffix(2){
                    case "-1":
                    print(" 1 ")
                        numbers.append(14)
                    case "-2":
                    print(" 2 ")
                        numbers.append(2)
                    case "-3":
                    print(" 3 ")
                        numbers.append(3)
                    case "-4":
                    print(" 4 ")
                        numbers.append(4)
                    case "-5":
                    print(" 5 ")
                        numbers.append(5)
                    case "-6":
                    print(" 6 ")
                        numbers.append(6)
                    case "-7":
                    print(" 7 ")
                        numbers.append(7)
                    case "-8":
                    print(" 8 ")
                        numbers.append(8)
                    case "-9":
                    print(" 9 ")
                        numbers.append(9)
                    case "10":
                    print(" 10 ")
                        numbers.append(10)
                    case "11":
                    print(" 11 ")
                        numbers.append(11)
                    case "12":
                    print(" 12 ")
                        numbers.append(12)
                    case "13":
                    print(" 13 ")
                        numbers.append(13)
                default:
                    continue
                }
            }
            for num in numbers{
                print(total)
                total += Double(num)
                print(total)
            }
            total = total/100
            numbers.sort()
            if(pair(numbers: numbers)){
                type = 1
                print("pair")
            }
            if(twoPair(numbers: numbers)){
                type = 2
                print("two pair")
            }
            if(tresUnKind(numbers: numbers)){
                type = 3
                print("tres")
            }
            if(straight(numbers: numbers)){
                type = 4
                print("gay")
            }
            if(flush(suits: suits)){
                type = 5
                print("shit")
            }
            if(fullHouse(numbers: numbers)){
                type = 6
                print("full house")
            }
            if(fourOfAKind(numbers: numbers)){
                type = 7
                print("four 2s")
            }
            if(straight(numbers: numbers) && flush(suits: suits)){
                type = 8
                print("take my fucking money")
            }
            
            return type + total
        }
    }


    
    
    
    
    
    
    
    
    
    public func callAction()->Int{
        var highest = 0
        if(whosTurn == 1){
            call[0] = true
            if(currentBids["bot 1"]! > highest){
                highest = currentBids["bot 1"]!
            }
            if(currentBids["bot 2"]! > highest){
                highest = currentBids["bot 2"]!
            }
            if(currentBids["bot 3"]! > highest){
                highest = currentBids["bot 3"]!
            }
        }
        if(whosTurn == 2){
            call[1] = true
            if(currentBids["player"]! > highest){
                highest = currentBids["player"]!
            }
            if(currentBids["bot 2"]! > highest){
                highest = currentBids["bot 2"]!
            }
            if(currentBids["bot 3"]! > highest){
                highest = currentBids["bot 3"]!
            }
        }
        if(whosTurn == 3){
            call[2] = true
            if(currentBids["bot 1"]! > highest){
                highest = currentBids["bot 1"]!
            }
            if(currentBids["player"]! > highest){
                highest = currentBids["player"]!
            }
            if(currentBids["bot 3"]! > highest){
                highest = currentBids["bot 3"]!
            }
            
        }
        if(whosTurn == 4){
            call[3] = true
            if(currentBids["bot 1"]! > highest){
                highest = currentBids["bot 1"]!
            }
            if(currentBids["bot 2"]! > highest){
                highest = currentBids["bot 2"]!
            }
            if(currentBids["player"]! > highest){
                highest = currentBids["player"]!
            }
        }
        return highest
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePotChips = raise(oldPot: thePotChips, chipAmount: chipAmount, chipValue: chipValue)
    }
    public func endTurn(){
        if(whosTurn == 1 && !folded[0]){
            whosTurn += 1
        } else if(!folded[2]){
            whosTurn += 2
        } else if(!folded[3]){
            whosTurn += 3
        }
        if(whosTurn == 2 && !folded[1]){
            whosTurn += 1
        } else if(!folded[3]){
            whosTurn += 2
        } else if(!folded[0]){
            whosTurn += 3
        }
        if(whosTurn == 3 && !folded[2]){
            whosTurn += 1
        } else if(!folded[0]){
            whosTurn += 2
        } else if(!folded[1]){
            whosTurn += 3
        }
        if(whosTurn == 4 && !folded[3]){
            whosTurn += 1
        } else if(!folded[1]){
            whosTurn += 2
        } else if(!folded[2]){
            whosTurn += 3
        }
    }
    public func endRound(){
        if(river){
            noAnimationTurn = true
            withAnimation(.default) {
                turn = true
            }
        }
        if(flop){
            noAnimationRiver = true
            withAnimation(.default) {
                river = true
            }
        }
        
        withAnimation(.default) {
            flop = true
        }
    }
    
}


public func pair(numbers: [Int])->Bool{
    var pair = false
    var editNum = numbers
    for _ in 0..<7{
        let paired = editNum[0]
        editNum.remove(at: 0)
        if editNum.contains(paired){
            pair = true
        }
    }
    return pair
}
public func twoPair(numbers: [Int])->Bool{
    var currentNum = 0
    var numbersDupe = numbers
    var pair = 0
    for _ in numbers{
        currentNum = numbersDupe[0]
        numbersDupe.remove(at: 0)
        if(numbersDupe.contains(currentNum)){
            pair += 1
        }
    }
    if(pair > 1){
        return true
    } else {
        return false
    }
}
public func tresUnKind(numbers: [Int])->Bool{
    var tres = false
    var amount: [Int:Int] = [2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        amount[numbers[num]]! = amount[numbers[num]]! + 1
    }
    for num in 2..<15{
        if amount[num]! >= 3{
            tres = true
        }
    }
    return tres
}
public func straight(numbers: [Int])->Bool{
    var isItLikeLogan = true
    var numsNoRepeat: [Int] = []
    for number in numbers{
        if (!numsNoRepeat.contains(number)){
            numsNoRepeat.append(number)
        }
        print(numsNoRepeat)
    }
    numsNoRepeat.sort()
    print(numsNoRepeat)
    if(numsNoRepeat.count == 5){
        if(numsNoRepeat[0] + 1 == numsNoRepeat[1]){
            if(numsNoRepeat[1] + 1 == numsNoRepeat[2]){
                if(numsNoRepeat[2] + 1 == numsNoRepeat[3]){
                    if(numsNoRepeat[3] + 1 == numsNoRepeat[4]){
                        isItLikeLogan = false
                    }
                }
            }
        }
    } else if (numsNoRepeat.count == 6){
        for nums in 0..<2{
            if(numsNoRepeat[nums] + 1 == numsNoRepeat[nums + 1]){
                if(numsNoRepeat[nums + 1] + 1 == numsNoRepeat[nums + 2]){
                    if(numsNoRepeat[nums + 2] + 1 == numsNoRepeat[nums + 3]){
                        if(numsNoRepeat[nums + 3] + 1 == numsNoRepeat[nums + 4]){
                            isItLikeLogan = false
                        }
                    }
                }
            }
        }
    } else if (numsNoRepeat.count == 7){
        for nums in 0..<3{
            if(numsNoRepeat[nums] + 1 == numsNoRepeat[nums + 1]){
                if(numsNoRepeat[nums + 1] + 1 == numsNoRepeat[nums + 2]){
                    if(numsNoRepeat[nums + 2] + 1 == numsNoRepeat[nums + 3]){
                        if(numsNoRepeat[nums + 3] + 1 == numsNoRepeat[nums + 4]){
                            isItLikeLogan = false
                        }
                    }
                }
            }
        }
    }
    return !isItLikeLogan
}
public func flush(suits: [String])->Bool{
    var flush = false
    var s = 0
    var d = 0
    var c = 0
    var h = 0
    for suit in suits{
        switch suit{
        case "s":
            s += 1
        case "d":
            d += 1
        case "c":
            c += 1
        case "h":
            h += 1
        default:
            break
        }
    }
    if(s >= 5 || h >= 5 || c >= 5 || d >= 5){
        flush = true
    }
    return flush
}
public func fullHouse(numbers: [Int])->Bool{
    var three = false
    var two = false
    var amount: [Int:Int] = [2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        amount[numbers[num]]! = amount[numbers[num]]! + 1
    }
    for num in 2..<15{
        if(amount[num]! >= 3){
            if (three == true){
                two = true
            } else {
                three = true
            }
        }
        if(amount[num]! == 2){
            two = true
        }

    }
    if(two && three){
        return true
    } else {
        return false
    }
}
public func fourOfAKind(numbers: [Int])->Bool{
    var four = false
    var amount: [Int:Int] = [2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        amount[numbers[num]]! = amount[numbers[num]]! + 1
    }
    for num in 2..<15{
        if amount[num]! >= 4{
            four = true
        }
    }
    return four
}


















struct frontCard: View {
    @Binding var cardsPlayed: [String]
    @State var name = ""
    var body: some View {
        
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear(){
                name = randomCard()
                cardsPlayed.append(name)
                print(cardsPlayed)
            }
    }
    public func randomCard()->String{
        var number = 0
        var suit = 0
        var answer = ""
        var answerFound = false
        repeat{
            number = Int.random(in: 1...13)
            suit = Int.random(in: 1...4)
            switch suit {
            case 1: answer = "spades-\(number)"
            case 2: answer = "clubs-\(number)"
            case 3: answer = "hearts-\(number)"
            case 4: answer = "diamonds-\(number)"
            default: break
            }
            if (!cardsPlayed.contains(answer)){
                answerFound = true
            }
        } while !answerFound
        return (answer)
    }
}

















struct backCard: View {
    @Binding var cardsPlayed: [String]
    @State var name = ""
    var body: some View {
        
        Image("back")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear(){
                name = randomCard()
                cardsPlayed.append(name)
                print(cardsPlayed)
            }
    }
    public func randomCard()->String{
        var number = 0
        var suit = 0
        var answer = ""
        var answerFound = false
        repeat{
            number = Int.random(in: 1...13)
            suit = Int.random(in: 1...4)
            switch suit {
            case 1: answer = "spades-\(number)"
            case 2: answer = "clubs-\(number)"
            case 3: answer = "hearts-\(number)"
            case 4: answer = "diamonds-\(number)"
            default: break
            }
            if (!cardsPlayed.contains(answer)){
                answerFound = true
            }
        } while !answerFound
        return (answer)
    }
}













struct bot1: View {
    @Binding var cardsPlayed: [String]
    @Binding var thePot: [Int:Int]
    var body: some View {
        Rectangle()
            .stroke()
            .overlay{
                HStack(spacing: -50){
                    Spacer()
                        .frame(width: 100)
                    frontCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    frontCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    Spacer()
                }
                
            }
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePot = raise(oldPot: thePot, chipAmount: chipAmount, chipValue: chipValue)
    }
}












struct bot2: View {
    @Binding var cardsPlayed: [String]
    @Binding var thePot: [Int:Int]
    var body: some View {
        Rectangle()
            .stroke()
            .overlay{
                
                HStack(spacing: -50){
                    Spacer()
                        .frame(width: 100)
                    frontCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    frontCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    Spacer()
                }
                
            }
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePot = raise(oldPot: thePot, chipAmount: chipAmount, chipValue: chipValue)
    }
}













struct bot3: View {
    @Binding var cardsPlayed: [String]
    @Binding var thePot: [Int:Int]
    var body: some View {
        Rectangle()
            .stroke()
            .overlay{
                HStack(spacing: -50){
                    Spacer()
                        .frame(width: 100)
                    frontCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    frontCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    Spacer()
                }
                
            }
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePot = raise(oldPot: thePot, chipAmount: chipAmount, chipValue: chipValue)
    }
}













struct cards: View {
    var body: some View {
        VStack{
            
        }
    }
}








struct thePot: View {
    var thePot: [Int:Int]
    var body: some View {
        VStack(spacing: 75){
            HStack(spacing: 0){
                if let count2 = thePot[2] {
                    let stacks2: Int = (count2 / 10)
                    ForEach(0..<stacks2, id: \.self) { index in
                        VStack(spacing: -55){
                            if(count2 > 10 && index != 0){
                                ForEach(0..<10, id: \.self) { index in
                                    Image("chip 2")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50,height: 50)
                                }
                                
                            } else {

                                    ForEach(0..<(count2 % 10), id: \.self) { index in
                                        Image("chip 2")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50,height: 50)
                                    }

                            }
                            
                        }
                        .frame(height: 40)
                        
                    }
                    
                    
                }
            }
            HStack(spacing: 0){
                if let count10 = thePot[10] {
                    let stacks10: Int = (count10 / 10)
                    ForEach(0..<stacks10, id: \.self) { index in
                        VStack(spacing: -55){
                            
                            if(count10 > 10 && index != 0){
                                ForEach(0..<10, id: \.self) { index in
                                    Image("chip 10")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50,height: 50)
                                }
                                
                            } else {
                                ForEach(0..<(count10 % 10), id: \.self) { index in
                                    Image("chip 10")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50,height: 50)
                                }
                            }
                            
                        }
                        .frame(height: 40)
                        
                    }
                    
                    
                }
            }
            HStack(spacing: 0){
                if let count20 = thePot[20] {
                    let stacks20: Int = (count20 / 10)
                    ForEach(0..<stacks20, id: \.self) { index in
                        VStack(spacing: -55){
                            if(count20 > 10 && index != 0){
                                ForEach(0..<10, id: \.self) { index in
                                    Image("chip 20")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50,height: 50)
                                }
                                
                            } else {
                                ForEach(0..<(count20 % 10), id: \.self) { index in
                                    Image("chip 20")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50,height: 50)
                                }
                            }
                            
                        }
                        .frame(height: 40)
                        
                    }
                    
                    
                }
            }
        }
    }
}












public func raise(oldPot: [Int:Int],chipAmount : Int,chipValue : Int)->[Int:Int]{
    var newPot:[Int:Int] = [:]
    if (chipValue == 2){
        newPot[2] = oldPot[2]! + chipAmount
    } else {
        newPot[2] = oldPot[2]!
    }
    if (chipValue == 10){
        newPot[10] = oldPot[10]! + chipAmount
    } else {
        newPot[10] = oldPot[10]!
    }
    if (chipValue == 20){
        newPot[20] = oldPot[20]! + chipAmount
    } else {
        newPot[20] = oldPot[20]!
    }
    return newPot
}










#Preview {
    PlayView(startingMoney: 500)
}
