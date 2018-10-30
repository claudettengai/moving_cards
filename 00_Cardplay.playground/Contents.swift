//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport


//label and button styles
let label = UILabel()
label.frame = CGRect(x: 130, y: 150, width: 200, height: 20)
label.text = "Hello World!"
label.textColor = .black
label.font = UIFont(name: "Avenir-Heavy", size: 22)


let startButton = UIButton()
startButton.frame = CGRect(x: 120, y: 200, width: 150, height: 50)
startButton.setTitle("Start", for: .normal)
startButton.setTitle("Stop", for: .selected)
startButton.layer.borderColor = UIColor.purple.cgColor
startButton.layer.borderWidth = 2
startButton.setTitleColor(.purple, for: .normal)


///********** Set Up ************//

let cardColorArray : [UIColor] = [.blue, .green, .purple, .red, .orange]

let cardWidthHeight: CGFloat = 50
let cardSize : CGSize = CGSize(width: cardWidthHeight, height: cardWidthHeight)

//var awesomeCardArray : [AwesomeCard] = []

func randomizeNumber(_ lowerValue:Int, _ upperValue:Int) -> (Int) {
    let result = Int(arc4random_uniform(UInt32(upperValue - lowerValue + 1))) +   lowerValue
    return result
}


///********** View Controller ************//
class MyViewController : UIViewController {

    //setup
    var awesomeCardArray : [AwesomeCard] = []

    //loadview
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        view.addSubview(label)
        view.addSubview(startButton)
        
        startButton.isSelected = false
        startButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        //make cards
        for cardColor in cardColorArray {
            let card : AwesomeCard = AwesomeCard(cardBackgroundColor : cardColor)
            awesomeCardArray.append(card)
            view.addSubview(card)
        }
        
        self.view = view
    } //end of loadview
    
    
    //button click
    @objc func buttonAction(sender: UIButton!) {
        if startButton.isSelected == false {
            for card in awesomeCardArray{
                card.moveAwesomeCard()
            }
            startButton.isSelected = true
        } else {
            startButton.isSelected = false
            for awesomeCard in awesomeCardArray{
                let timeElapsed = (awesomeCard.startingPoint?.timeIntervalSinceNow)! * -1
                let pausePosition = awesomeCard.layer.presentation()?.frame.origin
                let pauseRotation = CGFloat(timeElapsed * awesomeCard.angleDiffPerTime!)
                awesomeCard.layer.removeAllAnimations()
                awesomeCard.frame.origin = pausePosition!
                awesomeCard.transform = CGAffineTransform(rotationAngle: pauseRotation)
            }
        }
    }
 

}



///**********************//

class AwesomeCard : UIView {
    
    var keyframeTargetAngle:CGFloat = 0
    var startingPoint:Date?
    var angleDiffPerTime: Double?


    
    init(cardBackgroundColor : UIColor) {

        let cardPoint = AwesomeCard.pointRandomizer()
        let cardFrame = CGRect(origin: cardPoint, size: cardSize)
    
        super.init(frame: cardFrame)
        self.backgroundColor = cardBackgroundColor
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    

    class func pointRandomizer() -> (CGPoint){
        let viewWidth:Int = Int(UIScreen.main.bounds.width/2 - cardWidthHeight)
        let viewHeight:Int = Int(UIScreen.main.bounds.height/2 - cardWidthHeight)
        let positionX:CGFloat = CGFloat(randomizeNumber(0, viewWidth))
        let positionY:CGFloat = CGFloat(randomizeNumber(0, viewHeight))

        let cardPoint = CGPoint(x: positionX, y: positionY)
        return cardPoint
    }
    
    func randomizeRotationAngle() -> (CGFloat) {
        let rotationValue = Double(randomizeNumber(-360, 360)) / 180 * Double.pi //make radians
        let rotationAngle = CGFloat(rotationValue)
        self.keyframeTargetAngle = rotationAngle
//        print(self.keyframeTargetAngle)
        return rotationAngle
    }
    
    func moveAwesomeCard() {
        let initialPosition : CGPoint = self.frame.origin
        let initialBounds = self.bounds
        
        UIView.animateKeyframes(withDuration: 4.0, delay: 0, options: [.repeat, .calculationModeLinear], animations: {
            //first 3 keyframes
            for i in 0...2{
                UIView.addKeyframe(withRelativeStartTime: Double(i)*0.25, relativeDuration: 0.25, animations: {
                    let startAngle = self.keyframeTargetAngle
                    let endAngle = self.randomizeRotationAngle()
                    self.frame.origin = AwesomeCard.pointRandomizer()
                    
                    self.startingPoint = Date()
                    self.transform = CGAffineTransform(rotationAngle: endAngle)
                    
                    self.bounds = initialBounds
                    self.keyframeTargetAngle = endAngle
                    
                    let angleDiffPerTime = Double(endAngle - startAngle)/0.25
                    self.angleDiffPerTime = angleDiffPerTime
                    
                })
            }
            // last keyframe
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                let startAngle = self.keyframeTargetAngle
                let endAngle:CGFloat = 0

                self.startingPoint = Date()
                self.transform = CGAffineTransform(rotationAngle: endAngle)
                self.bounds = initialBounds
                self.frame.origin = initialPosition
                
                self.keyframeTargetAngle = endAngle
                let angleDiffPerTime = Double(endAngle - startAngle)/0.25
                self.angleDiffPerTime = angleDiffPerTime

            })

        }, completion: nil)
    }
    
    
}








// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()


