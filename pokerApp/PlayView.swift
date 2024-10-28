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
    // index and importance bot 1 0,1 bot 2 2,3 bot 3 4,5 player 6,7
    @State var animation: Bool = false
    @State var folded: Bool = false
    @State var raised: Bool = false
    @State var check: Bool = false
    @State var call: Bool = false
    @State var tempRaise2: Int = 0
    @State var tempRaise10: Int = 0
    @State var tempRaise20: Int = 0
    @State var whosTurn: Int = 1
    @State var currentBids: [String:Int] = ["player":0,"bot 1":0,"bot 2":0,"bot 3": 0]
    @State var flopTurnRiver: [String] = []
    @State var thePotChips: [Int:Int] = [2:0,10:0,20:0]
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
                .opacity(raised ? 0.4 : 1)
                Spacer()
                HStack{
                    Spacer()
                        .frame(width: 25)
                    VStack(spacing: 0){
                        Button{
                            if (raised) {
                                tempRaise2 += 1
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
                            if (raised) {
                                tempRaise10 += 1
                            }
                        } label: {
                            Image("chip 10")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(animation ? 1.2 : 1.3)
                        }
                        Button {
                            if (raised) {
                                tempRaise20 += 1
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
                                if (raised) {
                                    tempRaise2 = 0
                                    tempRaise10 = 0
                                    tempRaise20 = 0
                                }
                            }label: {
                                thePot(thePot: thePotChips)
                                
                            }
                            .offset(x:-50)
                        }
                        if (!folded){
                            HStack{
                                Button{
                                    if(whosTurn == 1 && raised == false){
                                        raised = true
                                    } else if(whosTurn == 1 && raised == true){
                                        raised = false
                                        raisePot(chipAmount: tempRaise2, chipValue: 2)
                                        raisePot(chipAmount: tempRaise10, chipValue: 10)
                                        raisePot(chipAmount: tempRaise20, chipValue: 20)
                                        tempRaise2 = 0
                                        tempRaise10 = 0
                                        tempRaise20 = 0
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
                                    if(whosTurn == 1){
                                        
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
                                .opacity(raised ? 0.4 : 1)
                                .frame(width: 150)
                                .buttonStyle(.bordered)
                                Spacer()
                                    .frame(width: 50)
                                Button{
                                    if(whosTurn == 1){
                                        folded = true
                                        
                                    }
                                }label: {
                                    Text("Fold")
                                        .font(.system(size: 40))
                                        .bold()
                                        .foregroundStyle(.black)
                                }
                                .opacity(raised ? 0.4 : 1)
                                .frame(width: 125)
                                .buttonStyle(.bordered)
                                Spacer()
                                    .frame(width: 50)
                            }
                            
                            HStack{
                                Text("\((tempRaise2 * 2)+(tempRaise10 * 10)+(tempRaise20 * 20))")
                                    .font(.title)
                                    .bold()
                            }
                        }
                        
                    }
                    Spacer()
                    
                    HStack(spacing: -100){
                        if(!folded){
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
                    .opacity(raised ? 0.4 : 1)
                    .offset(y: 200)
                    Spacer()
                        .frame(width: 25)
                }
            }
        }
    }
    public func raisePot(chipAmount : Int , chipValue : Int){
        thePotChips = raise(oldPot: thePotChips, chipAmount: chipAmount, chipValue: chipValue)
    }
    public func endTurn(){
        folded = false
        raised = false
        check = false
        call = false
        whosTurn += 1
    }
    
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
                    backCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    backCard(cardsPlayed: $cardsPlayed)
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
                    backCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    backCard(cardsPlayed: $cardsPlayed)
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
                    backCard(cardsPlayed: $cardsPlayed)
                        .frame(width: 100)
                    backCard(cardsPlayed: $cardsPlayed)
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
                    let stacks2: Int = (count2 / 10) + 1
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
                    let stacks10: Int = (count10 / 10) + 1
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
                    let stacks20: Int = (count20 / 10) + 1
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
