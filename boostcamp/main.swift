//
//  main.swift
//  BoostCamp
//
//  Created by byung-soo kwon on 2017. 5. 26..
//  Copyright © 2017년 BlackStoneTeam. All rights reserved.
//

import Foundation

//결과 출력 위치, 입력 위치
var homeDirectory = NSHomeDirectory()
let newLocation = homeDirectory + "/result.txt"
var dataPath = homeDirectory + "/students.json"


/**성적 분류 함수**/
func gradeCheck(score:Double) -> String{
    
    switch score {
    case 90...100:
        return "A"
    case 80..<90:
        return "B"
    case 70..<80:
        return "C"
    case 60..<70:
        return "D"
    case 0..<60:
        return "F"
    default:
        return "F"
    }
    
}

/**통과 했는지에 대한 판별 함수**/
func isPassed(grade:String) -> Bool{
    
    switch grade {
    case "A","B","C":
        return true
    default:
        return false
    }
}

/**소수점2자리를 만드는 함수**/
func roundPoint(number:Double) -> Double{
    
    
    let integerPart:Int = Int(number)
    let floatPoint:Double = number - Double(integerPart)
    let pointTwo:Double = (floatPoint*100).rounded() * 0.01
    let resultNumber:Double = Double(integerPart) + pointTwo
    return resultNumber
}




var finalResult = "성적결과표"

//학생 : 학점 으로 저장될 배열
var student:[String:String] = [:]

//모든 학생 성적 평균
var allAverage:Double = 0
//모든 학생의 점수
var allSumOfScore:Double = 0

do {
    
    let data = try Data(contentsOf: URL(fileURLWithPath: dataPath))
    let json = try JSONSerialization.jsonObject(with: data, options: [])
    
    if let array = json as? [[String:Any]]{
        
        //grade 안에 있는 성적을 꺼내서 계산하자
        for (index,value) in array.enumerated() {
            
            var name:String = value["name"] as! String
            
            //자리수를 맞추기 위해 4자리 이름에 공백을 하나 삽입..
            if name.characters.count < 5{
                name.append(" ")
            }
            let grade = array[index]["grade"] as? [String:Int]
            
            //과목 수
            let count = grade?.count
            var scoreSum:Double = 0
            var averageScore:Double = 0
            
            //학생 1명당 모든 성적의 합
            for score in (grade?.values)!{
                
                scoreSum += Double(score)
                
            }
            
            
            //학생들 평균 성적
            averageScore = (scoreSum/Double(count!))
            
            //모든 학생들의 평균의 합
            allSumOfScore += averageScore
            
            
            //학생 이름: 성적 으로 새로운 딕셔너리 생성
            student[name] = gradeCheck(score: averageScore)
            
            
        }
        //학생 전체 평균값
        allAverage = roundPoint(number: allSumOfScore/Double(array.count))
        
    }
    
    
}catch{
    print("something error")
}


let sortedStudent = student.sorted{$0.0<$1.0}


finalResult = "성적결과표\n\n" + "전체 평균 : \(allAverage)\n\n" + "개인별 학점\n"

for item in sortedStudent{
    
        finalResult += ("\(item.key)      : \(item.value)\n")
}

finalResult += "\n수료생\n"

//앞에서 삽입된 4자리 이름의 공백 하나를 삭제해준다.
var newSorted = sortedStudent.filter {
         isPassed(grade: $0.1)}.map { (item: (key: String, value: String)) -> String in
            if item.key.contains(" "){
                return item.key.substring(to: item.key.index(before: item.key.endIndex))
            }else {
                return item.key
            }
}


var isFirst:Bool = true

for (index,value) in newSorted.enumerated(){

    if isFirst{
        finalResult += "\(newSorted[index])"
        isFirst = false
    }else {
        finalResult += ", \(newSorted[index])"
    }

}


try finalResult.write(toFile: newLocation, atomically: false, encoding: .utf8)

