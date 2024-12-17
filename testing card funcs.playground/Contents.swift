
import SwiftUI





struct PlayView: View {
    let startingMoney: Int
    @State var blinds: Int = 0
    @State var winner: String = ""
    @State var cardsPlayed: [String] = []
    // index and importance [index 0-2 flop] [index 3-4 player] [index 5-6 bot 3] [index 7-8 bot 2] [index 9-10 bot 1] [index 11 river] [index 12 turn]
    @State var whoWon: [String:Bool] = ["player":false,"bot 1":false,"bot 2":false,"bot 3":false]
    @State var scores: [String:Int] = ["player":0,"bot 1":0,"bot 2":0,"bot 3":0]
    @State var animation: Bool = false
    
    @State var playerRaised: Bool = false
    @State var currentOut: [Bool] = [false,false,false,false]
    @State var roles: [String:String] = ["dealer":"player","small":"bot 2","big":"bot 3"]
    @State var flop: Bool = false
    @State var noAnimationRiver: Bool = false
    @State var river: Bool = false
    @State var noAnimationTurn: Bool = false
    @State var turn: Bool = false
    //    for the sake of not redoing my code turn is 5 river is 4
    @State var tempRaise2: Int = 0
    @State var tempRaise10: Int = 0
    @State var tempRaise20: Int = 0
    @State var whosTurn: Int = 1
    
    @State var goneYet: [String:Bool] = ["player":false,"bot 1":false,"bot 2":false,"bot 3":false]
    @State var bidsForWholeRound: Array<Any> = []
    @State var currentBids: [String:Int] = ["player":0,"bot 1":0,"bot 2":0,"bot 3": 0]
    @State var thePotChips: [Int:Int] = [2:010,10:010,20:010]
    @State var thePotTotal: Int = 0
    @State var call: [Bool] = [false,false,false,false]
    @State var folded: [Bool] = [false,false,false,false]
    @State var bettingStage = 1
    @State var foldedPlayer: [Bool] = [false,false,false,false]
    @State var dataRaised: [Bool] = [false, false, false, false]
    @State var didPlayerBluff: [Int] = []
    // 0 = no bluff 1 = cant tell 2 = bluff
    
    
    
    
    var body: some View {
        ZStack{
            //            Image("background")
            //                .resizable()
            //                .frame(maxWidth: .infinity,maxHeight: .infinity)
            //                .aspectRatio(contentMode: .fill)
            
            VStack{
                HStack(spacing: 0){
                    bot1(folded: $folded, goneYet: $goneYet, currentOut: $currentOut, bets:$currentBids, cardsPlayed: $cardsPlayed, thePot : $thePotChips,scores: $scores,turn: $whosTurn,bettingStage: $bettingStage,blinds: $blinds,bluffs: didPlayerBluff)
                        .frame(height: 250)
                    bot2(currentOut: $currentOut, bets:$currentBids, cardsPlayed: $cardsPlayed, thePot : $thePotChips,scores: $scores,turn: $whosTurn,bettingStage: $bettingStage,blinds: $blinds)
                        .frame(height: 250)
                    bot3(currentOut: $currentOut, bets:$currentBids, cardsPlayed: $cardsPlayed, thePot : $thePotChips,scores: $scores,turn: $whosTurn,bettingStage: $bettingStage,blinds: $blinds)
                        .frame(height: 250)
                    
                }
                .onAppear(){
                    blinds = startingMoney/125
                    scores["player"] = startingMoney
                    scores["bot 1"] = startingMoney
                    scores["bot 2"] = startingMoney
                    scores["bot 3"] = startingMoney
                    print(scores)
                }
                .opacity(playerRaised ? 0.4 : 1)
                Spacer()
                HStack{
                    Spacer()
                        .frame(width: 25)
                    VStack(spacing: 0){
                        Button{
                            if (playerRaised) {
                                tempRaise2 += 1
                                currentBids["player"]! = currentBids["player"]! + 2
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
                            if (playerRaised) {
                                tempRaise10 += 1
                                currentBids["player"]! = currentBids["player"]! + 10
                                raisePot(chipAmount: 1, chipValue: 10)
                            }
                        } label: {
                            Image("chip 10")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(animation ? 1.2 : 1.3)
                        }
                        Button {
                            if (playerRaised) {
                                tempRaise20 += 1
                                currentBids["player"]! = currentBids["player"]! + 20
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
                                if (playerRaised) {
                                    raisePot(chipAmount: -tempRaise2, chipValue: 2)
                                    raisePot(chipAmount: -tempRaise10, chipValue: 10)
                                    raisePot(chipAmount: -tempRaise20, chipValue: 20)
                                    currentBids["player"]! = currentBids["player"]! - (tempRaise2 * 2)
                                    currentBids["player"]! = currentBids["player"]! - (tempRaise20 * 20)
                                    currentBids["player"]! = currentBids["player"]! - (tempRaise10 * 10)
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
                                if(whosTurn == 1 && playerRaised == false && !folded[0]){
                                    playerRaised = true
                                    dataRaised[0] = true
                                } else if(whosTurn == 1 && playerRaised == true && !folded[0]){
                                    dataRaised[bettingStage - 1] = true
                                    playerRaised = false
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
                                if(whosTurn == 1 && !folded[0] && !playerRaised){
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
                            .opacity(playerRaised ? 0.4 : 1)
                            .frame(width: 150)
                            .buttonStyle(.bordered)
                            Spacer()
                                .frame(width: 50)
                            Button{
                                if(whosTurn == 1 && !folded[0] && !playerRaised){
                                    folded[0] = true
                                    //                                        endRound()
                                    endTurn()
                                    
                                }
                            }label: {
                                Text("Fold")
                                    .font(.system(size: 40))
                                    .bold()
                                    .foregroundStyle(.black)
                            }
                            .opacity(playerRaised ? 0.4 : 1)
                            .frame(width: 125)
                            .buttonStyle(.bordered)
                            Spacer()
                                .frame(width: 50)
                        }
                        
                        HStack{
                            Button{
                                endRound()
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
                    .opacity(playerRaised ? 0.4 : 1)
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
        if(currentOut[0] == true && currentOut[1] == true && currentOut[2] == true && currentOut[3] == true){
            endRound()
        } else {
            switch whosTurn{
            case 1:
                goneYet["player"]! = true
                whosTurn += 1
                if(folded[1]){
                    whosTurn += 1
                    if(folded[2]){
                        whosTurn += 1
                        if(folded[3]){
                            whosTurn = 1
                            winner = "player"
                        }
                    }
                }
            case 2:
                goneYet["bot 1"]! = true
                whosTurn += 1
                if(folded[2]){
                    whosTurn += 1
                    if(folded[3]){
                        whosTurn = 1
                        if(folded[0]){
                            whosTurn += 1
                            winner = "bot 1"
                        }
                    }
                }
            case 3:
                goneYet["bot 2"]! = true
                whosTurn += 1
                if(folded[3]){
                    whosTurn = 1
                    if(folded[0]){
                        whosTurn += 1
                        if(folded[1]){
                            whosTurn += 1
                            winner = "bot 2"
                        }
                    }
                }
            case 4:
                goneYet["bot 3"]! = true
                whosTurn = 1
                if(folded[0]){
                    whosTurn += 1
                    if(folded[1]){
                        whosTurn += 1
                        if(folded[2]){
                            whosTurn += 1
                            winner = "bot 3"
                        }
                    }
                }
            default:
                break
            }
        }
    }
    public func endRound(){
        bidsForWholeRound.append(currentBids)
        currentBids["player"]! = 0
        currentBids["bot 1"]! = 0
        currentBids["bot 2"]! = 0
        currentBids["bot 3"]! = 0
        currentOut[0] = false
        currentOut[1] = false
        currentOut[2] = false
        currentOut[3] = false
        bettingStage += 1
        switch roles["dealer"]{
        case "player":
            whosTurn = 1
        case "bot 1":
            whosTurn = 2
        case "bot 2":
            whosTurn = 3
        case "bot 3":
            whosTurn = 4
        default:
            break
        }
        
        if(turn){
            
            endHand()
        }
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
    public func endHand(){
        compareWinners()
        derterminePlayerBluff()
    }
    public func derterminePlayerBluff(){
        let player = evaluate(card1: cardsPlayed[3],
                              card2: cardsPlayed[4],
                              card3: cardsPlayed[0],
                              card4: cardsPlayed[1],
                              card5: cardsPlayed[2],
                              card6: cardsPlayed[11],
                              card7: cardsPlayed[12])
        let middle = evaluate(card1: cardsPlayed[0],
                              card2: cardsPlayed[1],
                              card3: cardsPlayed[2],
                              card4: cardsPlayed[11],
                              card5: cardsPlayed[12],
                              card6: "filler",
                              card7: "filler")
        if(folded[1] && folded[2] && folded[3]){
            maybeBluff()
        } else if(folded[0]){
            noBluff()
        } else if(player > 3 && middle != player){
            noBluff()
        } else if (player < 1.1 && dataRaised[3]){
            Bluff()
        } else if (player < 2.1){
            if(2 < evaluate(card1: cardsPlayed[3], card2: cardsPlayed[4], card3: cardsPlayed[0], card4: cardsPlayed[1], card5: cardsPlayed[2], card6: cardsPlayed[11], card7: "filler") || potentialStraight(card1: cardsPlayed[3], card2: cardsPlayed[4], card3: cardsPlayed[0], card4: cardsPlayed[1], card5: cardsPlayed[2],card6: cardsPlayed[11]) || potentialFlush(card1: cardsPlayed[3], card2: cardsPlayed[4], card3: cardsPlayed[0], card4: cardsPlayed[1], card5: cardsPlayed[2],card6: cardsPlayed[11])){
                noBluff()
            } else {
                if(dataRaised[1] || dataRaised[2]){
                    if(dataRaised[3]){
                        Bluff()
                    } else {
                        noBluff()
                    }
                } else {
                    noBluff()
                }
            }
        } else {
            maybeBluff()
        }
        func Bluff(){
            didPlayerBluff.append(2)
        }
        func noBluff(){
            didPlayerBluff.append(0)
        }
        func maybeBluff(){
            didPlayerBluff.append(1)
        }
    }
    public func compareWinners(){
        
        let player = evaluate(card1: cardsPlayed[3],
                              card2: cardsPlayed[4],
                              card3: cardsPlayed[0],
                              card4: cardsPlayed[1],
                              card5: cardsPlayed[2],
                              card6: cardsPlayed[11],
                              card7: cardsPlayed[12])
        let botOne = evaluate(card1: cardsPlayed[10],
                              card2: cardsPlayed[9],
                              card3: cardsPlayed[0],
                              card4: cardsPlayed[1],
                              card5: cardsPlayed[2],
                              card6: cardsPlayed[11],
                              card7: cardsPlayed[12])
        let botTwo = evaluate(card1: cardsPlayed[8],
                              card2: cardsPlayed[7],
                              card3: cardsPlayed[0],
                              card4: cardsPlayed[1],
                              card5: cardsPlayed[2],
                              card6: cardsPlayed[11],
                              card7: cardsPlayed[12])
        let botThree = evaluate(card1: cardsPlayed[6],
                                card2: cardsPlayed[5],
                                card3: cardsPlayed[0],
                                card4: cardsPlayed[1],
                                card5: cardsPlayed[2],
                                card6: cardsPlayed[11],
                                card7: cardsPlayed[12])
        
        print("player")
        print(player)
        
        print("bot 1")
        print(botOne)
        
        print("bot 2")
        print(botTwo)
        
        print("bot 3")
        print(botThree)
        
        if(player >= botOne && player >= botTwo && player >= botThree){
            whoWon["player"]! = true
        }
        if(botOne >= player && botOne >= botTwo && botOne >= botThree){
            whoWon["bot 1"]! = true
        }
        if(botTwo >= botOne && botTwo >= player && botTwo >= botThree){
            whoWon["bot 2"]! = true
        }
        if(botThree >= botOne && botThree >= botTwo && botThree >= player){
            whoWon["bot 3"]! = true
        }
        print(whoWon)
    }
    
}





public func evaluate(card1: String, card2: String, card3: String, card4: String, card5: String, card6: String, card7: String)->Double{
    
    let cardsCompare: [String] = [card1,card2,card3,card4,card5,card6,card7]
    //            let cardsCompare: [String] = ["hearts-6","hearts-13","hearts-4","diamonds-1","hearts-2","clubs-5","spades-3"]
    
    var total: Double = 0
    var type: Double = 0
    var editForFive: Bool = false
    var suits: [String] = []
    var numbers: [Int] = []
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
            suits.append("")
            break
        }
        switch cardsCompare[num].suffix(2){
        case "-1":
            //                    print(" 1 ")
            numbers.append(14)
        case "-2":
            //                    print(" 2 ")
            numbers.append(2)
        case "-3":
            //                    print(" 3 ")
            numbers.append(3)
        case "-4":
            //                    print(" 4 ")
            numbers.append(4)
        case "-5":
            //                    print(" 5 ")
            numbers.append(5)
        case "-6":
            //                    print(" 6 ")
            numbers.append(6)
        case "-7":
            //                    print(" 7 ")
            numbers.append(7)
        case "-8":
            //                    print(" 8 ")
            numbers.append(8)
        case "-9":
            //                    print(" 9 ")
            numbers.append(9)
        case "10":
            //                    print(" 10 ")
            numbers.append(10)
        case "11":
            //                    print(" 11 ")
            numbers.append(11)
        case "12":
            //                    print(" 12 ")
            numbers.append(12)
        case "13":
            //                    print(" 13 ")
            numbers.append(13)
        default:
            if(editForFive){
                numbers.append(-1)
            } else {
                numbers.append(0)
                editForFive.toggle()
            }
        }
    }
    
    
    
    //    print("before pair")
    if(pair(numbers: numbers)){
        type = 1
        print("pair")
    }
    //    print("before 2 pair")
    if(twoPair(numbers: numbers)){
        type = 2
        print("two pair")
    }
    //    print("before tres")
    if(tresUnKind(numbers: numbers)){
        type = 3
        print("tres")
    }
    //    print("before gay")
    if(straight(numbers: numbers)){
        type = 4
        print("gay")
    }
    //    print("before flush")
    if(flush(suits: suits)){
        type = 5
        print("flush")
    }
    //    print("before full")
    if(fullHouse(numbers: numbers)){
        type = 6
        print("full house")
    }
    //    print("before 4")
    if(fourOfAKind(numbers: numbers)){
        type = 7
        print("four 2s vs 3 aces 2 kings")
    }
    //    print("before dang")
    if(max(numbers: numbers,suits: suits)){
        type = 8
        print("take my money")
    }
    
    
    //remove the ones not needed
    switch type {
    case 1:
        numbers.sort(by: >)
        numbers = lowkeyWPairFunc(numbers: numbers)
    case 2:
        numbers.sort(by: >)
        numbers = lowkeyWPairFunc(numbers: numbers)
        numbers = lowkeyWPairFunc(numbers: numbers)
        numbers = lowkeyWPairFunc(numbers: numbers)
        if(numbers[6] > numbers[4]){
            numbers.insert(numbers[6], at: 0)
            numbers.remove(at: 7)
        }
    case 3:
        numbers.sort(by: >)
        numbers = threeOfKind(numbers: numbers)
    case 4:
        numbers.sort(by: >)
        numbers = straightThing(numbers: numbers)
    case 5:
        numbers = flushCards(numbers: numbers, suits: suits)
        numbers.sort(by: >)
    case 6:
        numbers.sort(by: >)
        numbers = threeTwo(numbers: numbers)
    case 7:
        numbers.sort(by: >)
        numbers = fourCards(numbers: numbers)
    case 8:
        numbers = flushCards(numbers: numbers, suits: suits)
        numbers.sort(by: >)
        numbers = straightThing(numbers: numbers)
    default:
        break
    }
    
    //remove the ones not allowed
    for num in 0..<5{
        //                print(total)
        total += Double(numbers[num])
        //                print(total)
    }
    total = total/1000
    return type + total
}





public func threeTwo(numbers: [Int])->[Int]{
    var editNums: [Int] = []
    var two = 0
    var three = 0
    var amount: [Int:Int] = [0:0, -1:0 ,2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        if(numbers[num] < 1){
            amount[numbers[num]]! = amount[numbers[num]]! + 1
        }
    }
    for threes in 2..<15{
        if(amount[threes]! >= 3){
            three = threes
        }
    }
    amount[three] = 0
    for twos in 2..<15{
        if(amount[twos]! >= 2){
            two = twos
        }
    }
    editNums.append(three)
    editNums.append(three)
    editNums.append(three)
    editNums.append(two)
    editNums.append(two)
    editNums.append(1)
    editNums.append(1)
    return editNums
}





public func flushCards(numbers: [Int],suits: [String])->[Int]{
    var editNums: [Int] = numbers
    var suit = ""
    var suitsCount: [String:Int] = ["s":0,"c":0,"d":0,"h":0]
    for suiter in suits{
        switch suiter{
        case "s":
            suitsCount["s"]! = suitsCount["s"]! + 1
        case "c":
            suitsCount["c"]! = suitsCount["c"]! + 1
        case "h":
            suitsCount["h"]! = suitsCount["h"]! + 1
        case "d":
            suitsCount["d"]! = suitsCount["d"]! + 1
        default:
            break
        }
    }
    if(suitsCount["s"]! >= 5){
        suit = "s"
    }
    if(suitsCount["c"]! >= 5){
        suit = "c"
    }
    if(suitsCount["d"]! >= 5){
        suit = "d"
    }
    if(suitsCount["h"]! >= 5){
        suit = "h"
    }
    for num in 0...6{
        let number = 6 - num
        if(suits[number] != suit){
            editNums.remove(at: number)
        }
    }
    return editNums
}





public func fourCards(numbers: [Int])->[Int]{
    var editNums: [Int] = []
    var four = 0
    var amount: [Int:Int] = [0:0, -1:0 ,2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        if(numbers[num] < 1){
            amount[numbers[num]]! = amount[numbers[num]]! + 1
        }
    }
    for number in 2..<15{
        if(amount[number]! >= 4){
            four = number
        }
    }
    editNums.append(four)
    editNums.append(four)
    editNums.append(four)
    editNums.append(four)
    if(numbers[0] == four){
        editNums.append(numbers[4])
    } else {
        editNums.append(numbers[0])
    }
    editNums.append(numbers[5])
    editNums.append(numbers[6])
    return editNums
}





public func lowkeyWPairFunc(numbers: [Int])->[Int]{
    var returnNums: [Int] = numbers
    if(numbers[4] == numbers[5]){
        returnNums.remove(at: 4)
        returnNums.remove(at: 4)
        returnNums.insert(numbers[4], at: 0)
        returnNums.insert(numbers[4], at: 0)
    }else if(numbers[5] == numbers[6]){
        returnNums.remove(at: 5)
        returnNums.remove(at: 5)
        returnNums.insert(numbers[5], at: 0)
        returnNums.insert(numbers[5], at: 0)
    }
    
    return returnNums
}





public func threeOfKind(numbers: [Int])->[Int]{
    var returnNums: [Int] = numbers
    if(numbers[4] == numbers[5] && numbers[3] == numbers[4]){
        returnNums.remove(at: 3)
        returnNums.remove(at: 3)
        returnNums.remove(at: 3)
        returnNums.insert(numbers[3], at: 0)
        returnNums.insert(numbers[3], at: 0)
        returnNums.insert(numbers[3], at: 0)
    }else if(numbers[5] == numbers[6] && numbers[4] == numbers[5]){
        returnNums.remove(at: 4)
        returnNums.remove(at: 4)
        returnNums.remove(at: 4)
        returnNums.insert(numbers[4], at: 0)
        returnNums.insert(numbers[4], at: 0)
        returnNums.insert(numbers[4], at: 0)
    }
    return returnNums
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
    var amount: [Int:Int] = [0:0, -1:0 ,2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        if(numbers[num] < 1){
            amount[numbers[num]]! = amount[numbers[num]]! + 1
        }
    }
    for num in 2..<15{
        if amount[num]! >= 3{
            tres = true
        }
    }
    return tres
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
    var amount: [Int:Int] = [0:0, -1:0 ,2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        if(numbers[num] < 1){
            amount[numbers[num]]! = amount[numbers[num]]! + 1
        }
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
    var amount: [Int:Int] = [0:0, -1:0 ,2:0,3:0,4:0,5:0,6:0,7:0,8:0,9:0,10:0,11:0,12:0,13:0,14:0]
    for num in 0..<7{
        if(numbers[num] < 1){
            amount[numbers[num]]! = amount[numbers[num]]! + 1
        }
    }
    for num in 2..<15{
        if amount[num]! >= 4{
            four = true
        }
    }
    return four
}




public func straight(numbers: [Int])->Bool{
    var isItLikeLogan = true
    var numsNoRepeat: [Int] = []
    for number in numbers{
        if (!numsNoRepeat.contains(number)){
            numsNoRepeat.append(number)
        }
        //        print(numsNoRepeat)
    }
    numsNoRepeat.sort()
    //    print(numsNoRepeat)
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





public func straightThing(numbers: [Int])->[Int]{
    var numbersEdit = numbers
    var numsNoRepeat: [Int] = []
    var numsThatRepeat: [Int] = []
    for number in numbers{
        if (!numsNoRepeat.contains(number)){
            numsNoRepeat.append(number)
        } else {
            numsThatRepeat.append(number)
        }
        print(numsNoRepeat)
    }
    numsNoRepeat.sort(by: >)
    if(numsNoRepeat.count == 5){
        numbersEdit = numsNoRepeat
        numbersEdit.append(0)
        numbersEdit.append(0)
    }else if(numsNoRepeat.count == 6){
        if(numsNoRepeat[0] == numsNoRepeat[1] + 1){
            numbersEdit = numsNoRepeat
            numbersEdit.append(0)
        } else {
            numbersEdit = numsNoRepeat
            numbersEdit.remove(at: 0)
            numbersEdit.append(0)
            numbersEdit.append(0)
        }
    } else {
        if(numsNoRepeat[0] == numsNoRepeat[1] + 1 && numsNoRepeat[1] == numsNoRepeat[2] + 1){
            numbersEdit = numsNoRepeat
        } else if(numsNoRepeat[1] == numsNoRepeat[2] + 1){
            numbersEdit = numsNoRepeat
            numbersEdit.remove(at: 0)
            numbersEdit.append(0)
        } else {
            numbersEdit = numsNoRepeat
            numbersEdit.remove(at: 0)
            numbersEdit.remove(at: 0)
            numbersEdit.append(0)
            numbersEdit.append(0)
        }
    }
    
    return numbersEdit
}





public func max(numbers: [Int],suits: [String])->Bool{
    var max = false
    var editNums = numbers
    var suitsCount: [String:Int] = ["s":0,"d":0,"c":0,"h":0]
    if(straight(numbers: numbers)){
        editNums = straightThing(numbers: editNums)
        for number in 0..<7{
            if (editNums.contains(numbers[number])){
                switch suits[number]{
                case "s":
                    suitsCount["s"]! = suitsCount["s"]! + 1
                case "c":
                    suitsCount["c"]! = suitsCount["c"]! + 1
                case "h":
                    suitsCount["h"]! = suitsCount["h"]! + 1
                case "d":
                    suitsCount["d"]! = suitsCount["d"]! + 1
                default:
                    break
                }
            }
        }
    }
    if(suitsCount["s"]! >= 5 || suitsCount["c"]! >= 5 || suitsCount["d"]! >= 5 || suitsCount["h"]! >= 5){
        max = true
    }
    
    return max
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





public func raiseAtStart(card1: String,card2:String)->Bool{
    var should = false
    let random = Int.random(in: 0...7)
    if(card1.suffix(2) == card2.suffix(2)){
        if(card1.suffix(2) == "-2" || card1.suffix(2) == "-3" || card1.suffix(2) == "-4" || card1.suffix(2) == "-5"){
            should = false
        } else {
            should = true
        }
    }
    if(random == 3){
        return !should
    } else {
        return !should
    }
}





public func whatFlop(card1:String,card2:String,card3:String)->Int{
    if(card1.suffix(2) == card2.suffix(2) && card2.suffix(2) == card3.suffix(2)){
        return 3
    }
    if(card1.suffix(2) == card2.suffix(2) || card2.suffix(2) == card3.suffix(2)){
        return 1
    }
    return 0
}





public func potentialFlush(card1: String,card2: String,card3: String,card4: String,card5: String,card6: String? = nil)->Bool{
    var suits: [String:Int] = ["h":0,"s":0,"c":0,"d":0]
    suits[String(card1.prefix(1))]! = suits[String(card1.prefix(1))]! + 1
    suits[String(card2.prefix(1))]! = suits[String(card2.prefix(1))]! + 1
    suits[String(card3.prefix(1))]! = suits[String(card3.prefix(1))]! + 1
    suits[String(card4.prefix(1))]! = suits[String(card4.prefix(1))]! + 1
    suits[String(card5.prefix(1))]! = suits[String(card5.prefix(1))]! + 1
    if let card6{
        suits[String(card6.prefix(1))]! = suits[String(card6.prefix(1))]! + 1
    }
    if(suits["h"]! >= 4 || suits["d"]! >= 4 || suits["s"]! >= 4 || suits["c"]! >= 4){
        return true
    } else {
        return false
    }
}





public func potentialStraight(card1: String,card2: String,card3: String,card4: String,card5: String? = nil,card6: String? = nil)->Bool{
    var numbers: [Int] = []
    var diff: Int = 0
    addNum(card: card1)
    addNum(card: card2)
    addNum(card: card3)
    addNum(card: card4)
    if let card5{
        addNum(card: card5)
    }
    if let card6{
        addNum(card: card6)
    }
    numbers = Array(Set(numbers))
    numbers.sort(by: >)
    
    if(numbers.count >= 4){
        diff = numbers[0] - numbers[3]
        if(diff <= 4 && diff > 2){
            return true
        }
    }
    if(numbers.count >= 5){
        diff = numbers[1] - numbers[4]
        if(diff <= 4 && diff > 2){
            return true
        }
    }
    if(numbers.count == 6){
        diff = numbers[2] - numbers[5]
        if(diff <= 4 && diff > 2){
            return true
        }
    }
    return false
    
    func addNum(card: String){
        switch card.suffix(2){
        case "-1":
            //                    print(" 1 ")
            numbers.append(14)
        case "-2":
            //                    print(" 2 ")
            numbers.append(2)
        case "-3":
            //                    print(" 3 ")
            numbers.append(3)
        case "-4":
            //                    print(" 4 ")
            numbers.append(4)
        case "-5":
            //                    print(" 5 ")
            numbers.append(5)
        case "-6":
            //                    print(" 6 ")
            numbers.append(6)
        case "-7":
            //                    print(" 7 ")
            numbers.append(7)
        case "-8":
            //                    print(" 8 ")
            numbers.append(8)
        case "-9":
            //                    print(" 9 ")
            numbers.append(9)
        case "10":
            //                    print(" 10 ")
            numbers.append(10)
        case "11":
            //                    print(" 11 ")
            numbers.append(11)
        case "12":
            //                    print(" 12 ")
            numbers.append(12)
        case "13":
            //                    print(" 13 ")
            numbers.append(13)
        default:
            break
        }
    }
}





struct bot1: View {
    @Binding var folded: [Bool]
    @Binding var goneYet: [String:Bool]
    @Binding var currentOut: [Bool]
    @Binding var bets: [String:Int]
    @Binding var cardsPlayed: [String]
    @Binding var thePot: [Int:Int]
    @Binding var scores: [String:Int]
    @Binding var turn: Int
    @Binding var bettingStage: Int
    @Binding var blinds: Int
    @State var handSame: Bool = false
    let bluffs: [Int]
    @State var bluffRate: Double = 0
    let agression: Double = 1.5
    let balls: Double = 1
    let belief: Int = 0
    let bluff: Int = 0
    let sighted: Int = 10
    
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
                    Text("\(scores["bot 1"]!)")
                        .bold()
                        .font(.system(size: 50))
                    Spacer()
                }
                
            }
            .onChange(of: bluffs) {
                var allTheWay: Bool = false
                var newRate: Double = 0
                var howManyMaybes: Int = 0
                if(bluffs.count >= sighted){
                    allTheWay = true
                }
                if(allTheWay){
                    for num in 1...sighted{
                        if(bluffs[bluffs.count - num] == 2){
                            newRate += 1
                        } else if(bluffs[bluffs.count - num] == 1){
                            howManyMaybes += 1
                        }
                    }
                    bluffRate = newRate / Double(10 - howManyMaybes)
                } else {
                    for num in 1...bluffs.count{
                        if(bluffs[bluffs.count - num] == 2){
                            newRate += 1
                        } else if(bluffs[bluffs.count - num] == 1){
                            howManyMaybes += 1
                        }
                    }
                    bluffRate = newRate / Double(bluffs.count - howManyMaybes)
                }
            }
            .onChange(of: turn) { oldValue, newValue in
                if (turn == 2){
                    if(folded[0]){
                        endBotTurn()
                    }
                    if(cardsPlayed[9].suffix(2) == cardsPlayed[10].suffix(2)){
                        handSame = true
                    }
                    print(handSame)
                    print("bot 1")
                    
                    switch bettingStage{
                    case 1:
                        caseOneLogic()
                    case 2:
                        caseTwoLogic()
                    case 3:
                        break
                    case 4:
                        break
                    default:
                        break
                    }
                    
                }
            }
    }
    public func caseThreeLogic(){
        
        let full: Double = evaluate(card1: cardsPlayed[9], card2: cardsPlayed[10], card3: cardsPlayed[0], card4: cardsPlayed[2], card5: cardsPlayed[1],card6: cardsPlayed[11],card7: "filler")
        let flop: Double = Double(evaluate(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[11], card5: "filler",card6: "filler",card7: "filler"))
        if(whichBid() == 1){
            betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
        } else if (whichBid() == 2){
            if(folded[0]){
                betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
            } else {
                shouldCall(full: full, flop: flop)
            }
        } else if (whichBid() == 3){
            if(folded[0] && folded[3]){
                betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
            } else {
                shouldCall(full: full, flop: flop)
            }
        } else if (whichBid() == 4){
            if(folded[0] && folded[3] && folded[2]){
                betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
            } else {
                shouldCall(full: full, flop: flop)
            }
        }
        endBotTurn()
    }
    
    
    public func suited()->Bool{
        if(cardsPlayed[9].prefix(1) == cardsPlayed[10].prefix(1)){
            return true
        } else {
            return false
        }
    }
    public func fold(){
        folded[1] = true
        print(folded)
    }
    public func shouldCall(full: Double,flop: Double){
        if(playerBluffWithRandom()){
            if(diffBid(who: 1) > 0 && diffBid(who: 1) < maxCall(fullStart: full + 2, flop: flop)){
                call()
            } else {
                fold()
            }
        } else {
            if(diffBid(who: 0) > 0 && diffBid(who: 0) < maxCall(fullStart: full, flop: flop)){
                call()
            } else {
                fold()
            }
        }
    }
    public func caseTwoLogic(){
        
        let full: Double = evaluate(card1: cardsPlayed[9], card2: cardsPlayed[10], card3: cardsPlayed[0], card4: cardsPlayed[2], card5: cardsPlayed[1],card6: "filler",card7: "filler")
        let flop: Double = Double(whatFlop(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2]))
        if(whichBid() == 1){
            betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
        } else if (whichBid() == 2){
            if(folded[0]){
                betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
            } else {
                shouldCall(full: full, flop: flop)
            }
        } else if (whichBid() == 3){
            if(folded[0] && folded[3]){
                betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
            } else {
                shouldCall(full: full, flop: flop)
            }
        } else if (whichBid() == 4){
            if(folded[0] && folded[3] && folded[2]){
                betAdd(amount: bidCaseTwo(fullStart: full, flop: flop))
            } else {
                shouldCall(full: full, flop: flop)
            }
        }
        endBotTurn()
    }
    public func endBotTurn(){
        goneYet["bot 1"]! = true
        turn += 1
    }
    public func diffBid(who:Int)->Int{
        var diff:Int = 0
        var bot1Bet:Int = 0
        if(who == 0){
            if(bets["player"]! > bot1Bet){
                bot1Bet = bets["player"]!
            }
            if(bets["bot 2"]! > bot1Bet){
                bot1Bet = bets["bot 2"]!
            }
            if(bets["bot 3"]! > bot1Bet){
                bot1Bet = bets["bot 3"]!
            }
            diff = bot1Bet - bets["bot 1"]!
        }
        if(who == 1){
            if(bets["player"]! > bets["bot 1"]!){
                diff = bets["player"]! - bets["bot 1"]!
            }
        }
        if(who == 3){
            if(bets["bot 2"]! > bets["bot 1"]!){
                diff = bets["bot 2"]! - bets["bot 1"]!
            }
        }
        if(who == 4){
            if(bets["bot 3"]! > bets["bot 1"]!){
                diff = bets["bot 3"]! - bets["bot 1"]!
            }
        }
        return diff
    }
    public func threeFlush(card1: String,card2: String,card3: String,card4: String? = nil,card5: String? = nil)->Bool{
        var cards: [String] = [card1,card2,card3]
        var suits: [String:Int] = ["s":0,"c":0,"h":0,"d":0]
        if let card4{
            cards.append(card4)
        }
        if let card5{
            cards.append(card5)
        }
        for card in cards{
            suits[String(card.prefix(1))]! = suits[String(card.prefix(1))]! + 1
        }
        if(suits["s"]! <= 3 || suits["d"]! <= 3 || suits["h"]! <= 3 || suits["c"]! <= 3){
            return true
        }
        return false
        
    }
    public func threeStraight(card1: String,card2: String,card3: String,card4: String? = nil,card5: String? = nil)->Bool{
        var cards: [String] = [card1,card2,card3]
        var nums: [Int] = []
        if(card2.suffix(2) == card3.suffix(2)){
            cards.remove(at: 2)
        }
        if(card1.suffix(2) == card2.suffix(2)){
            cards.remove(at: 1)
        }
        if let card4{
            cards.append(card4)
        }
        if let card5{
            cards.append(card5)
        }
        for card in cards{
            addnum(card: card)
        }
        nums.sort(by: >)
        if(nums.count == 3){
            let diff = nums[0] - nums[2]
            if(diff <= 4 && diff > 1){
                return true
            }
        } else if(nums.count == 4){
            var diff = nums[0] - nums[2]
            if(diff <= 4 && diff > 1){
                return true
            }
            diff = nums[1] - nums[3]
            if(diff <= 4 && diff > 1){
                return true
            }
        } else if(nums.count == 5){
            var diff = nums[0] - nums[2]
            if(diff <= 4 && diff > 1){
                return true
            }
            diff = nums[1] - nums[3]
            if(diff <= 4 && diff > 1){
                return true
            }
            diff = nums[2] - nums[4]
            if(diff <= 4 && diff > 1){
                return true
            }
        }
        return false
        func addnum(card: String){
            switch card.suffix(2){
            case"-1":
                nums.append(14)
            case"-2":
                nums.append(2)
            case"-3":
                nums.append(3)
            case"-4":
                nums.append(4)
            case"-5":
                nums.append(5)
            case"-6":
                nums.append(6)
            case"-7":
                nums.append(7)
            case"-8":
                nums.append(8)
            case"-9":
                nums.append(9)
            case"10":
                nums.append(10)
            case"11":
                nums.append(11)
            case"12":
                nums.append(12)
            case"13":
                nums.append(13)
            default:
                break
            }
        }
        
    }
    public func fourFlush(card1: String,card2: String,card3: String,card4: String? = nil,card5: String? = nil)->Bool{
        var cards: [String] = [card1,card2,card3]
        var suits: [String:Int] = ["s":0,"c":0,"h":0,"d":0]
        if let card4{
            cards.append(card4)
        }
        if let card5{
            cards.append(card5)
        }
        for card in cards{
            suits[String(card.prefix(1))]! = suits[String(card.prefix(1))]! + 1
        }
        if(suits["s"]! <= 4 || suits["d"]! <= 4 || suits["h"]! <= 4 || suits["c"]! <= 4){
            return true
        }
        return false
        
    }
    public func playerBluffWithRandom()->Bool{
        if(Int.random(in: 0...2) == 0){
            return !playerBluff()
        } else {
            return playerBluff()
        }
    }
    public func playerBluff()->Bool{
        
        let playerBid: Int = (bets["player"]! / blinds) * 4
        let playerScore: Int = (scores["player"]! / blinds) * 4
        //        let flop: Int =
        //you can always bluff a three of a kind and bellow
        //if you have pair you can bluff full house of 4 of a kind
        //if there is 3 in the middle of the same suit you can bluff flush
        //if 2 cards needed for straight or one card needed bluff straight
        //if staight flush call them cause they dont got that shit
        if(bettingStage == 1){
            return true
        } else if (bettingStage == 2){
            let straightChance = threeStraight(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2])
            let flushChance = threeFlush(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2])
            let botHand = evaluate(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[10], card5: cardsPlayed[9], card6: "filler", card7: "filler")
            let flop = whatFlop(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2])
            if(bluffRate >= 0.8){
                return true
            }
            if(bluffRate <= 0.2){
                return false
            }
            if(playerBid + 15 >= playerScore){
                return true
            }
            if (playerBid < 20){
                return false
            }
            if(playerBid > 300){
                return true
            }
            if(flushChance || straightChance || flop >= 1){
                if (bluffRate > 0.5){
                    return true
                }
                if(playerBid < 40){
                    return false
                }
            } else {
                return true
            }
            
        } else if (bettingStage == 3){
            let straightChance = threeStraight(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[11])
            let flushChance = threeFlush(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2])
            let betterStraightChance = potentialStraight(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[11])
            let betterFlushChance = fourFlush(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[11])
            let flop = evaluate(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[11], card5: "filler", card6: "filler", card7: "filler")
            if(bluffRate >= 0.8){
                return true
            }
            if(bluffRate <= 0.2){
                return false
            }
            if(playerBid + 15 >= playerScore){
                return true
            }
            if (playerBid < 20){
                return false
            }
            if (playerBid > 300){
                return true
            }
            if(flushChance || straightChance || flop >= 1){
                if (bluffRate > 0.7){
                    return true
                }
                if(playerBid < 30){
                    return false
                }
            } else if (betterFlushChance || betterStraightChance){
                if(bluffRate > 0.7){
                    return true
                }
                if(playerBid > 40){
                    return true
                }
                return false
            } else {
                return true
            }
        } else if (bettingStage == 4){
            if(bluffRate >= 0.8){
                return true
            }
            if(playerBid + 15 >= playerScore){
                return true
            }
            if (playerBid >= 50){
                return true
            }
            
        }
        return true
        
    }
    
    public func whichBid()->Int{
        var bidTurn = 0
        if(!goneYet["player"]!){
            bidTurn = 1
        } else if(!goneYet["bot 3"]!){
            bidTurn = 2
        } else if(!goneYet["bot 2"]!){
            bidTurn = 3
        } else if(!goneYet["bot 1"]!){
            bidTurn = 4
        }
        return bidTurn
    }
    public func maxCall(fullStart: Double,flop: Double)->Int{
        var call: Int = 0
        var full = fullStart
        if(flop + 0.1 > full){
            full = 0
        } else if(flop + 1.1 > full && full < 2.1 && full > 2) {
            full -= 1
        }
        if(full > 1 && full < 1.1){
            call = Int(12.5 * Double(blinds) * balls)
        } else if(full < 2.1){
            call = Int(25 * Double(blinds) * balls)
        } else if(full < 3.1){
            call = Int(50 * Double(blinds) * balls)
        } else if(full < 4.1){
            call = Int(100 * Double(blinds) * balls)
        } else if(full < 5.1){
            call = Int(100 * Double(blinds) * balls)
        } else if(full < 6.1){
            call = Int(10000 * Double(blinds) * balls)
        } else if(full < 7.1){
            call = Int(10000 * Double(blinds) * balls)
        } else if(full > 8){
            call = Int(10000 * Double(blinds) * balls)
        } else {
            call = Int(5 * Double(blinds) * balls)
        }
        if(cardsPlayed.count == 12){
            if(potentialFlush(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[10], card5: cardsPlayed[9], card6: cardsPlayed[11])){
                call += 10
            }
            if(potentialStraight(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[10], card5: cardsPlayed[9], card6: cardsPlayed[11])){
                call += 10
            }
        } else if (cardsPlayed.count == 11){
            if(potentialFlush(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[10], card5: cardsPlayed[9])){
                call += 25
            }
            if(potentialStraight(card1: cardsPlayed[0], card2: cardsPlayed[1], card3: cardsPlayed[2], card4: cardsPlayed[10], card5: cardsPlayed[9])){
                call += 25
            }
        }
        // do anything that determines value considering score for bot here if needed
        return call
    }
    public func bidCaseTwo(fullStart: Double,flop: Double)->Int{
        var bid: Int = 0
        var full = fullStart
        var randomElement: Int = 0
        randomElement = Int.random(in: 0...8)
        if(randomElement == 8){
            randomElement = 3
            
        } else if(randomElement == 7){
            randomElement = 2
        }
        print(randomElement)
        if(flop + 0.1 > full){
            full = 0
        } else if(flop + 1.1 > full && full < 2.1 && full > 2) {
            full -= 1
        }
        
        if(full > 1 && full < 1.1){
            print("pair")
            bid = randomElement
            print(bid)
        } else if(full > 2 && full < 2.1){
            print("two pair")
            bid = Int(2.5 * Double(blinds) + Double(randomElement) + Double(randomElement))
            print(bid)
        } else if(full > 3 && full < 3.1){
            if(handSame){
                bid = Int((4.5 * Double(blinds) + Double(randomElement)) / (Double(randomElement) / 3))
                bid = bid / 2
            } else {
                bid = Int((4 * Double(blinds) + Double(randomElement)) / (Double(randomElement) / 3))
                bid = bid / 2
            }
        } else if(full > 4 && full < 4.1){
            bid = Int((4 * Double(blinds)) * (Double(randomElement))  / 2)
            bid = bid / 2
        } else if(full > 5 && full < 5.1){
            bid = Int((4.25 * Double(blinds)) * (Double(randomElement))  / 2)
            bid = bid / 2
        } else if(full > 6 && full < 6.1){
            bid = Int((5 * Double(blinds)) * (Double(randomElement))  / 2)
            bid = bid / 2
        } else if(full > 7 && full < 7.1){
            bid = Int((5.5 * Double(blinds)) * (Double(randomElement))  / 2)
            bid = bid / 2
        } else if(full > 8){
            if(full == 8.06){
                bid = scores["bot 1"]!
            } else {
                bid = Int((10 * Double(blinds)) * (Double(randomElement)))
                bid = bid / 2
            }
        } else {
            print("nada")
            bid = 0
        }
        print(bid)
        bid = Int(Double(bid) * agression)
        if (bid % 2 == 1){
            bid += 1
        }
        
        return bid
    }
    public func caseOneLogic(){
        call()
        if(raiseAtStart(card1: cardsPlayed[9], card2: cardsPlayed[10]) && Double(bets["bot 1"]!) <= (Double(blinds) * 1.5)){
            betAdd(amount: blinds/2)
            print(scores["bot 1"]!)
        }
        endBotTurn()
    }
    public func isHighest()->Bool{
        if(bets["bot 1"]! >= bets["player"]! && bets["bot 1"]! >= bets["bot 2"]! && bets["bot 1"]! >= bets["bot 3"]!){
            return true
        } else {
            return false
        }
    }
    public func call(){
        if(bets["bot 1"]! < bets["player"]!){
            var diff: Int = 0
            diff = bets["player"]! - bets["bot 1"]!
            betAdd(amount: diff)
        }
        if(bets["bot 1"]! < bets["bot 2"]!){
            var diff: Int = 0
            diff = bets["bot 2"]! - bets["bot 1"]!
            betAdd(amount: diff)
        }
        if(bets["bot 1"]! < bets["bot 3"]!){
            var diff: Int = 0
            diff = bets["bot 3"]! - bets["bot 1"]!
            betAdd(amount: diff)
        }
    }
    public func betAdd(amount: Int){
        scores["bot 1"]! = scores["bot 1"]! - amount
        bets["bot 1"]! = bets["bot 1"]! + amount
        raiseAmount(amount: amount)
    }
    public func raiseAmount(amount: Int){
        raisePot(chipAmount: Int((amount % 10) / 2), chipValue: 2)
        raisePot(chipAmount: Int((amount % 20) / 10), chipValue: 10)
        raisePot(chipAmount: Int(amount / 20), chipValue: 20)
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePot = raise(oldPot: thePot, chipAmount: chipAmount, chipValue: chipValue)
    }
}





struct bot2: View {
    @Binding var currentOut: [Bool]
    @Binding var bets: [String:Int]
    @Binding var cardsPlayed: [String]
    @Binding var thePot: [Int:Int]
    @Binding var scores: [String:Int]
    @Binding var turn: Int
    @Binding var bettingStage: Int
    @Binding var blinds: Int
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
                    Text("\(scores["bot 2"]!)")
                        .bold()
                        .font(.system(size: 50))
                    Spacer()
                }
                
            }
            .onChange(of: turn) { oldValue, newValue in
                if (turn == 3){
                    print("bot 2")
                }
                
            }
        
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePot = raise(oldPot: thePot, chipAmount: chipAmount, chipValue: chipValue)
    }
}





struct bot3: View {
    @Binding var currentOut: [Bool]
    @Binding var bets: [String:Int]
    @Binding var cardsPlayed: [String]
    @Binding var thePot: [Int:Int]
    @Binding var scores: [String:Int]
    @Binding var turn: Int
    @Binding var bettingStage: Int
    @Binding var blinds: Int
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
                    Text("\(scores["bot 3"]!)")
                        .bold()
                        .font(.system(size: 50))
                    Spacer()
                }
                
            }
            .onChange(of: turn) { oldValue, newValue in
                if (turn == 4){
                    print("bot 3")
                }
                
            }
        
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePot = raise(oldPot: thePot, chipAmount: chipAmount, chipValue: chipValue)
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







print (evaluate(card1: "spades-2", card2: "spades-2", card3: "spades-2", card4: "spades-2", card5: "clubs-2",card6: "filler",card7: "filler"))
