//
//  GDReminderStateIcon.swift
//  middleagercityparty
//
//  Created by Philipp Faßheber on 18/12/2016.
//  Copyright © 2016 Philipp Faßheber. All rights reserved.
//

import UIKit
 /*
     rotated horizontal line described by function: f(x) = x
     checkmark line described by function: f(x) = -1,276142374916323x + 2
   both lines have an intersection at the point: P:= (0,87867965644, 5,12132034356)
 */

@IBDesignable
class GDReminderStateIcon : UIView{
    
    //Parameters for animation
    
    /**
     Defines thickness of the line of the plus and checkmark.
    */
    private let lineLength = CGFloat(1.5)
    
    /**
     Duration of syncing horizontal and vertical line.
    */
    private let durationSyncLines = 0.2
    
    /**
     Duration of rotating synced horizontal and vertical line to its final position.
    */
    private let durationRotateLines = 0.3
    
    /**
     Delay before sync of vertical line starts.
    */
    private let beginVerticalSync = 0.0
    
    /**
     Delay before sync of horizontal line starts.
     */
    private let beginHorizontalSync = 0.0
    
    /**
     Duration of growing the checkmark line to the rotated horizontal and vertical line.
     */
    private let durationGrowCheckmark = 0.3
    
    /**
     Duration of shrinking checkmark line when transforming to plus.
    */
    private let durationShrinkCheckmark = 0.3
    
    /**
     Color of the plus lines.
    */
    @IBInspectable var color = UIColor(colorLiteralRed: 0.1921568627, green: 0.4431372549, blue: 0.3725490196, alpha: 1.0)
    
    /**
     Color of the checkmark lines.
    */
    @IBInspectable var colorCheckmark = UIColor.white
    
    /**
     Flag that indicates weather the icon is currently transforming or not. Used to prevent icon from transforming multiple times during a running animation.
    */
    lazy var isTransforming = false
    
    /**
     Layer to draw the horizontal line of the plus.
    */
    private lazy var horizontalLayer = CAShapeLayer()
    
    /**
     Layer to draw the vertical line of the plus.
    */
    private lazy var verticalLayer = CAShapeLayer()
    
    /**
     Layer to draw round corners to the horizontal plus line. Sure there is a better way :)
    */
    private lazy var horRoundCornerLayer = CAShapeLayer()
    
    /**
     Layer to draw round corners to the vertical plus line. Sure there is a better way :)
     */
    private lazy var verRoundCornerLayer = CAShapeLayer()
    
    /**
     Layer to draw the checkmark line.
    */
    private lazy var checkLayer = CAShapeLayer()

    /**
     Layer to draw round corners to the checkmark line. Sure there is a better way :)
     */
    lazy var checkmarkCornerLayer = CAShapeLayer()
    
    /**
     A factory to create transform animations.
    */
    private lazy var factory = TransformAnimationFactory()
    
    var isSelected = true
    
    var initializedWithCheckmark = false
    
    /**
     Path that describes the horizontal line of the plus.
    */
    private var horizontalPath : UIBezierPath {
        let path = UIBezierPath()
        let points = horizonzalPoints()
        path.move(to: points.start)
        path.addLine(to: points.end)
        
        return path
    }
    
    private var horizontalPathRotated : UIBezierPath {
        let path = UIBezierPath()
        let points = pointsRotated()
        path.move(to: points.start)
        path.addLine(to: points.end)
        
        return path
        
    }
    
    /**
     Path that describes the round corners from the horizontal line of the plus.
    */
    private var horRoundCornerPath : UIBezierPath {
        let path = UIBezierPath()
        let points = horizonzalPoints()
    
        path.addArc(withCenter: points.start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: points.end, radius: lineLength / 2.0 , startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        
        return path
    }
    
    private var horRoundCornerPathRotated : UIBezierPath {
        let path = UIBezierPath()
        let points = pointsRotated()
        
        path.addArc(withCenter: points.start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: points.end, radius: lineLength / 2.0 , startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        
        return path
    }
    
    /**
     Path that describes the vertical line of the plus.
     */
    private var verticalPath : UIBezierPath {
        let path = UIBezierPath()
        
        let points = verticalPoints()
        
        path.move(to: points.start)
        path.addLine(to: points.end)
        return path
    }
    
    private var vertialPathRotated: UIBezierPath {
        let path = UIBezierPath()
        let points = pointsRotated()
        path.move(to: points.start)
        path.addLine(to: points.end)
        
        return path
    }
    
    /**
     Path that describes the round corners from the vertical line of the plus.
     */
    private var verRoundCornerPath : UIBezierPath {
        let path = UIBezierPath()
        let points = verticalPoints()
        
        path.addArc(withCenter: points.start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: points.end, radius: lineLength / 2.0 , startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        
        return path
    }
    
    private var verRoundCornerPathRotated : UIBezierPath {
        let path = UIBezierPath()
        let points = pointsRotated()
        
        path.addArc(withCenter: points.start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: points.end, radius: lineLength / 2.0 , startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        
        return path
    }

    /**
     Path that describes that checkmark line before it growed. It's just a dot.
    */
    private var checkPathStart : UIBezierPath {
        let path = UIBezierPath()
        let start = checkMarkStartPoint()
        path.move(to: start)
        path.addLine(to: start)
        return path
    }
    
    /**
     Path that describes the round corners of the checkmark line before it growed.
    */
    private var checkmarkCornerStart : UIBezierPath {
        let path = UIBezierPath()
        let start = checkMarkStartPoint()
        
        path.addArc(withCenter: start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        return path
    }
    
    /**
     Path that describes the growed checkmark line.
    */
    private var checkPathGrow : UIBezierPath {
        let path = UIBezierPath()
        let points = checkmarkPoints()
        
        path.move(to: points.start)
        path.addLine(to: points.end)
        
        return path
    }
    
    private var checkPathGrowRotated : UIBezierPath {
        let path = UIBezierPath()
        let points = checkmarkPointsRotated()
        
        path.move(to: points.start)
        path.addLine(to: points.end)
        
        return path
    }
    
    /**
     Path that describes the round corners of the growed checkmark line.
     */
    private var checkmarkCornerGrow : UIBezierPath {
        let path = UIBezierPath()
        let points = checkmarkPoints()
        
        path.addArc(withCenter: points.start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: points.end, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        
        return path
    }
    
    private var checkmarkCornerGrowRotated : UIBezierPath {
        let path = UIBezierPath()
        let points = checkmarkPointsRotated()
        
        path.addArc(withCenter: points.start, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        path.addArc(withCenter: points.end, radius: lineLength / 2.0, startAngle: 0, endAngle: CGFloat(2.0) * CGFloat(Double.pi), clockwise: true)
        
        return path
    }
    
    /**
     Calculates start and end point of the horizontal line of the plus.
     
     - Returns start: the left point in the coordinate system
     - Returns end: the right point in the coordinate system
    */
    private func horizonzalPoints() -> (start: CGPoint, end: CGPoint) {
        let y = bounds.size.height / 2.0
        
        let startX = 0.0 + lineLength / 2.0
        let start = CGPoint(x: startX , y: y)
        
        let toX = bounds.size.width - lineLength / 2.0
        let to = CGPoint(x: toX, y: y)
        
        return (start, to)
    }
    
    private func pointsRotated() -> (start: CGPoint, end: CGPoint) {
        let startX = 0.0 + lineLength / 2.0
        let toX = bounds.size.width - lineLength / 2.0
        
        
        let length = toX - startX
        let coordinate1 = length / 2.0 + lineLength / 2.0 + (length / 2.0) * cos(0.785398)
        let coordinate2 = length / 2.0 + lineLength / 2.0 - (length / 2.0) * cos(-0.785398)
        
        let start = CGPoint(x: coordinate1, y: coordinate2)
        let to = CGPoint(x: coordinate2, y: coordinate1)
        
        return (start, to)
    }
    
    /**
     Calculates start and end point of the vertical line of the plus.
     
     - Returns start: the upper point in the coordinate system
     - Returns end: the lower point in the coordinate system
     */
    private func verticalPoints() -> (start: CGPoint, end: CGPoint) {
        let x = bounds.size.width / 2.0
        
        let startY = 0.0 + lineLength / 2.0
        let start = CGPoint(x: x, y: startY)
        
        let toY = bounds.size.height - lineLength / 2.0
        let to = CGPoint(x: x, y: toY)
        
        return (start, to)
    }
    
    /**
     Calculates start and end point of the grown checkmark line.
     
     - Returns: Start and end point.
    */
    private func checkmarkPoints() -> (start: CGPoint, end: CGPoint) {
        let x : CGFloat = 0.87867965644 + lineLength / 2.0
        let y = checkmark(x)
        let start = CGPoint(x: x, y: y)
        let toX : CGFloat = -1.5 + lineLength / 2.0
        let toY = checkmark(toX)
        let to = CGPoint(x: toX, y: toY)
        
        return (start, to)
    }
    
    private func checkmarkPointsRotated() -> (start: CGPoint, end: CGPoint) {
        let x : CGFloat = 0.87867965644 + lineLength / 2.0
        let y = checkmark(x)
        let start = CGPoint(x: x, y: y)
        let toX : CGFloat = -1.5 + lineLength / 2.0
        let toY = checkmark(toX)
//        let to = CGPoint(x: toX, y: toY)
        
        let length = pow((toX - x), 2) + pow((toY - y), 2)
        
        let toXRotated = toX * cos(CGFloat(1 * Double.pi) / 4.0)
//        let toYRotated = 0  - length * cos(-CGFloat(Double.pi) / 9.0)
        let toYRotated = toY * sin(CGFloat(1 * Double.pi) / 4.0)
        
        let to = CGPoint(x: toXRotated, y: toYRotated)
    
        return (start, to)
    }
    
    /**
     Calculates start and end point of the checkmark line before it growed.
     
     - Returns: Start and end point.
     */
    private func checkMarkStartPoint() -> CGPoint {
        let x = 3.8 + lineLength / 2.0
        let y = checkmark(x) - lineLength / 2.0
        return CGPoint(x: x, y: y)
    }
    
    /**
     Functions that describes the checkmark line.
    */
    private func checkmark(_ x: CGFloat) -> CGFloat {
        let heightCoefficient : CGFloat = bounds.size.height
        let m : CGFloat = -0.4
        let n : CGFloat = 2
        var y = m * x + n
        if y < 0 {
            y = y + heightCoefficient
        } else {
            y = (y - heightCoefficient) * -1
        }
        return y
    }
    
    func clearLayers() {
        layer.sublayers = nil
        clearLayer(horizontalLayer)
        clearLayer(verticalLayer)
        clearLayer(horRoundCornerLayer)
        clearLayer(verRoundCornerLayer)
        clearLayer(checkLayer)
        clearLayer(checkmarkCornerLayer)
    }
    
    func clearLayer(_ layer: CAShapeLayer) {
        layer.sublayers = nil
        layer.path = nil
        layer.removeAllAnimations()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.masksToBounds = false
        drawIcon(rect)
    }
    
    private func drawIcon(_ rect: CGRect) {
        if isSelected {
            drawCheckmark(rect)
        } else {
            drawPlus(rect)
        }
    }
    
    private func drawCheckmark(_ rect: CGRect) {
        initializedWithCheckmark = true
        clearLayers()
        
        initialize(layer: horizontalLayer, path: horizontalPathRotated.cgPath, color: colorCheckmark.cgColor)
        initialize(layer: verticalLayer, path: vertialPathRotated.cgPath, color: colorCheckmark.cgColor)
        initialize(layer: horRoundCornerLayer, path: horRoundCornerPathRotated.cgPath, color: colorCheckmark.cgColor)
        initialize(layer: verRoundCornerLayer, path: verRoundCornerPathRotated.cgPath, color: colorCheckmark.cgColor)
        initialize(layer: checkLayer, path: checkPathGrowRotated.cgPath, color: colorCheckmark.cgColor)
        initialize(layer: checkmarkCornerLayer, path: checkmarkCornerGrowRotated.cgPath, color: colorCheckmark.cgColor)
        
        horRoundCornerLayer.lineWidth = 0.05
        horRoundCornerLayer.strokeColor = colorCheckmark.cgColor
        horRoundCornerLayer.fillColor = colorCheckmark.cgColor
        verRoundCornerLayer.lineWidth = 0.05
        verRoundCornerLayer.strokeColor = colorCheckmark.cgColor
        verRoundCornerLayer.fillColor = colorCheckmark.cgColor
        checkmarkCornerLayer.strokeColor = colorCheckmark.cgColor
        checkmarkCornerLayer.fillColor = colorCheckmark.cgColor
        checkmarkCornerLayer.lineWidth = 0.05
        
        layer.addSublayer(horizontalLayer)
        layer.addSublayer(verticalLayer)
        layer.addSublayer(horRoundCornerLayer)
        layer.addSublayer(verRoundCornerLayer)
        layer.addSublayer(checkLayer)
        layer.addSublayer(checkmarkCornerLayer)
    }
    
    private func drawPlus(_ rect: CGRect) {
        initializedWithCheckmark = false
        clearLayers()
        
        //prepare layer
        initialize(layer: horizontalLayer, path: horizontalPath.cgPath, color: color.cgColor)
        initialize(layer: verticalLayer, path: verticalPath.cgPath, color: color.cgColor)
        initialize(layer: horRoundCornerLayer, path: horRoundCornerPath.cgPath, color: color.cgColor)
        initialize(layer: verRoundCornerLayer, path: verRoundCornerPath.cgPath, color: color.cgColor)
        initialize(layer: checkLayer, path: checkPathStart.cgPath, color: color.cgColor)
        initialize(layer: checkmarkCornerLayer, path: checkmarkCornerStart.cgPath, color: color.cgColor)
        
        //we need to adjust the anchor to make rotation work correct
        let anchorX : CGFloat = 0.0 + lineLength / 2.0
        let anchorY = checkmark(anchorX) - lineLength / 2.0
        changeAnchor(layer: checkLayer, x: anchorX, y: anchorY)
        changeAnchor(layer: checkmarkCornerLayer, x: anchorX, y: anchorY)

        horRoundCornerLayer.lineWidth = 0.05
        horRoundCornerLayer.strokeColor = color.cgColor
        horRoundCornerLayer.fillColor = color.cgColor
        verRoundCornerLayer.lineWidth = 0.05
        verRoundCornerLayer.strokeColor = color.cgColor
        verRoundCornerLayer.fillColor = color.cgColor
        checkmarkCornerLayer.lineWidth = 0.05

        hideCheckmarkCornerLayer()
        
        layer.addSublayer(horizontalLayer)
        layer.addSublayer(verticalLayer)
        layer.addSublayer(horRoundCornerLayer)
        layer.addSublayer(verRoundCornerLayer)
        layer.addSublayer(checkLayer)
        layer.addSublayer(checkmarkCornerLayer)
    }
    
    /**
     Initializes layer.
     - with path
     - with size (not automatically done)
     - with frame (needs to be rearranged after setting size)
     - with line thickness
     - with stroke color
    */
    private func initialize(layer: CAShapeLayer, path: CGPath, color: CGColor) {
        layer.path = path
        layer.strokeColor = color
        layer.lineWidth = lineLength
        layer.bounds.size = self.bounds.size
        layer.frame.origin.x = 0.0
        layer.frame.origin.y = 0.0
    }
    
    /**
     Starts transforming the plus to a checkmark.
    */
    func transformToCheckmark() {
        if isTransforming {
            return
        }
        
        changeColor(color: colorCheckmark)
        let first = factory.createTransformCheckmarkAnimation(reminderStateIcon: self)
        first.animate()
    }
    
    /**
     Starts transforming the checkmark to a plus.
    */
    func transformToPlus() {
        if isTransforming {
            return
        }
        
        changeColor(color: color)
        let first = factory.createTransformPlusAnimation(reminderStateIcon: self)
        first.animate()
        
    }
    
    /**
     Changes stroke and (from some layers) fill color of all layers that draw a line of the plus or checkmark.
     
     - Parameter color: The new color of the layers.
    */
    private func changeColor(color: UIColor) {
        horizontalLayer.strokeColor = color.cgColor
        verticalLayer.strokeColor = color.cgColor
        horRoundCornerLayer.strokeColor = color.cgColor
        horRoundCornerLayer.fillColor = color.cgColor
        verRoundCornerLayer.strokeColor = color.cgColor
        verRoundCornerLayer.fillColor = color.cgColor
        checkLayer.strokeColor = color.cgColor
        checkLayer.fillColor = color.cgColor
        checkmarkCornerLayer.strokeColor = color.cgColor
        checkmarkCornerLayer.fillColor = color.cgColor
    }
    
    /**
     Animates synchronization of horizontal and vertical plus line. The lines are synched to the bottom right corner of the view.
     
     - Parameter animationDelegate: Delegate that is informed when animation starts and stops.
    */
    func animSync(animationDelegate: CAAnimationDelegate) {
        //rotate horizontal and vertical line to same position
        let syncHorizontal = CABasicAnimation(keyPath: "transform.rotation.z")
        syncHorizontal.toValue = CGFloat(Double.pi / 4.0)
        syncHorizontal.duration = durationSyncLines
        syncHorizontal.beginTime = beginHorizontalSync
        syncHorizontal.isRemovedOnCompletion = false
        syncHorizontal.fillMode = kCAFillModeForwards
        
        let horCornerSync = syncHorizontal.copy() as! CABasicAnimation
        
        let syncVertical = CABasicAnimation(keyPath: "transform.rotation.z")
        syncVertical.toValue = CGFloat(3 * Double.pi / 4.0)
        syncVertical.duration = durationSyncLines
        syncVertical.beginTime = beginVerticalSync
        syncVertical.isRemovedOnCompletion = false
        syncVertical.fillMode = kCAFillModeForwards
        
        let verCornerSync = syncVertical.copy() as! CABasicAnimation
        
        verCornerSync.delegate = animationDelegate
        
        horizontalLayer.add(syncHorizontal, forKey: nil)
        horRoundCornerLayer.add(horCornerSync, forKey: nil)
        
        verticalLayer.add(syncVertical, forKey: nil)
        verRoundCornerLayer.add(verCornerSync, forKey: nil)
    }
    
    func animSyncFromRotatedLines(animationDelegate: CAAnimationDelegate) {
        //rotate horizontal and vertical line to same position
        let syncHorizontal = CABasicAnimation(keyPath: "transform.rotation.z")
        syncHorizontal.toValue = -CGFloat(1 * Double.pi / 2.0)
        syncHorizontal.duration = durationSyncLines
        syncHorizontal.beginTime = beginHorizontalSync
        syncHorizontal.isRemovedOnCompletion = false
        syncHorizontal.fillMode = kCAFillModeForwards
        
        let horCornerSync = syncHorizontal.copy() as! CABasicAnimation
        
        let syncVertical = CABasicAnimation(keyPath: "transform.rotation.z")
        syncVertical.toValue = -CGFloat(1 * Double.pi / 2.0)
        syncVertical.duration = durationSyncLines
        syncVertical.beginTime = beginVerticalSync
        syncVertical.isRemovedOnCompletion = false
        syncVertical.fillMode = kCAFillModeForwards
        
        let verCornerSync = syncVertical.copy() as! CABasicAnimation
        
        verCornerSync.delegate = animationDelegate
        
        horizontalLayer.add(syncHorizontal, forKey: nil)
        horRoundCornerLayer.add(horCornerSync, forKey: nil)
        
        verticalLayer.add(syncVertical, forKey: nil)
        verRoundCornerLayer.add(verCornerSync, forKey: nil)

    }
    
    /**
     Animates alignment of horizontal and vertical plus line. The lines are aligned to the bottom left corner of the view.
     
     - Parameter animationDelegate: Delegate that is informed when animation starts and stops.
     */
    func animAlign(animationDelegate: CAAnimationDelegate) {
        let alignHorizontal = CABasicAnimation(keyPath: "transform.rotation.z")
        alignHorizontal.toValue = CGFloat(3 * Double.pi / 4.0)
        alignHorizontal.beginTime = 0.0
        alignHorizontal.duration = durationRotateLines
        alignHorizontal.isRemovedOnCompletion = false
        alignHorizontal.fillMode = kCAFillModeForwards
        
        let horAlignCorner = alignHorizontal.copy() as! CABasicAnimation
        
        let alignVertical = CABasicAnimation(keyPath: "transform.rotation.z")
        alignVertical.toValue = CGFloat(5 * Double.pi / 4.0)
        alignVertical.beginTime = 0.0
        alignVertical.duration = durationRotateLines
        alignVertical.isRemovedOnCompletion = false
        alignVertical.fillMode = kCAFillModeForwards
        
        let verAlignCorner = alignVertical.copy() as! CABasicAnimation
        
        verAlignCorner.delegate = animationDelegate
        
        horizontalLayer.add(alignHorizontal, forKey: nil)
        horRoundCornerLayer.add(horAlignCorner, forKey: nil)
        
        verticalLayer.add(alignVertical, forKey: nil)
        verRoundCornerLayer.add(verAlignCorner, forKey: nil)
    }
    
    func animAlignFromRotatedLines(animationDelegate: CAAnimationDelegate) {
        let alignHorizontal = CABasicAnimation(keyPath: "transform.rotation.z")
        alignHorizontal.toValue = 0.0
        alignHorizontal.beginTime = 0.0
        alignHorizontal.duration = durationRotateLines
        alignHorizontal.isRemovedOnCompletion = false
        alignHorizontal.fillMode = kCAFillModeForwards
        
        let horAlignCorner = alignHorizontal.copy() as! CABasicAnimation
        
        let alignVertical = CABasicAnimation(keyPath: "transform.rotation.z")
        alignVertical.toValue = 0.0
        alignVertical.beginTime = 0.0
        alignVertical.duration = durationRotateLines
        alignVertical.isRemovedOnCompletion = false
        alignVertical.fillMode = kCAFillModeForwards
        
        let verAlignCorner = alignVertical.copy() as! CABasicAnimation
        
        verAlignCorner.delegate = animationDelegate
        
        horizontalLayer.add(alignHorizontal, forKey: nil)
        horRoundCornerLayer.add(horAlignCorner, forKey: nil)
        
        verticalLayer.add(alignVertical, forKey: nil)
        verRoundCornerLayer.add(verAlignCorner, forKey: nil)
    }
    
    /**
     Animates realignment of horizontal and vertical plus line to its original positions.
     
     - Parameter animationDelegate: Delegate that is informed when animation starts and stops.
     */
    func animReAlign(animationDelegate: CAAnimationDelegate) {

        let alignHorizontal = CABasicAnimation(keyPath: "transform.rotation.z")
        alignHorizontal.toValue = 0.0
        alignHorizontal.beginTime = 0.0
        alignHorizontal.duration = durationRotateLines
        alignHorizontal.isRemovedOnCompletion = false
        alignHorizontal.fillMode = kCAFillModeForwards
    
        let horAlignCorner = alignHorizontal.copy() as! CABasicAnimation
        
        let alignVertical = CABasicAnimation(keyPath: "transform.rotation.z")
        alignVertical.toValue = 0.0
        alignVertical.beginTime = 0.0
        alignVertical.duration = durationRotateLines
        alignVertical.isRemovedOnCompletion = false
        alignVertical.fillMode = kCAFillModeForwards
        
        let verAlignCorner = alignVertical.copy() as! CABasicAnimation
        
        verAlignCorner.delegate = animationDelegate
        
        horizontalLayer.add(alignHorizontal, forKey: nil)
        horRoundCornerLayer.add(horAlignCorner, forKey: nil)
        
        verticalLayer.add(alignVertical, forKey: nil)
        verRoundCornerLayer.add(verAlignCorner, forKey: nil)
    }
    
    func animReAlignFromRotatedLines(animationDelegate: CAAnimationDelegate) {
        
        let alignHorizontal = CABasicAnimation(keyPath: "transform.rotation.z")
        alignHorizontal.toValue = -CGFloat(3 * Double.pi) / 4
        alignHorizontal.beginTime = 0.0
        alignHorizontal.duration = durationRotateLines
        alignHorizontal.isRemovedOnCompletion = false
        alignHorizontal.fillMode = kCAFillModeForwards
        
        let horAlignCorner = alignHorizontal.copy() as! CABasicAnimation
        
        let alignVertical = CABasicAnimation(keyPath: "transform.rotation.z")
        alignVertical.toValue = -CGFloat(1 * Double.pi) / 4
        alignVertical.beginTime = 0.0
        alignVertical.duration = durationRotateLines
        alignVertical.isRemovedOnCompletion = false
        alignVertical.fillMode = kCAFillModeForwards
        
        let verAlignCorner = alignVertical.copy() as! CABasicAnimation
        
        verAlignCorner.delegate = animationDelegate
        
        horizontalLayer.add(alignHorizontal, forKey: nil)
        horRoundCornerLayer.add(horAlignCorner, forKey: nil)
        
        verticalLayer.add(alignVertical, forKey: nil)
        verRoundCornerLayer.add(verAlignCorner, forKey: nil)
    }
    
    /**
     Animates growing of the checkmark line.
     
     - Parameter animationDelegate: Delegate that is informed when animation starts and stops.
     */
    func animGrow(animationDelegate: CAAnimationDelegate) {
        
        //animation to make checkmark growing
        let grow = CABasicAnimation(keyPath: "path")
        grow.toValue = checkPathGrow.cgPath
        grow.duration = durationGrowCheckmark
        grow.beginTime = 0.0
        grow.isRemovedOnCompletion = false
        grow.fillMode = kCAFillModeForwards
       
        //also "grow" corners
        let growCorners = CABasicAnimation(keyPath: "path")
        growCorners.toValue = checkmarkCornerGrow.cgPath
        growCorners.duration = durationGrowCheckmark
        growCorners.beginTime = 0.0
        grow.isRemovedOnCompletion = false
        grow.fillMode = kCAFillModeForwards
        
        //animation to slightly rotate the checkmark while growing
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.toValue = CGFloat(Double.pi / 9.0)
        rotate.beginTime = 0.0
        rotate.duration = durationGrowCheckmark
        rotate.isRemovedOnCompletion = false
        rotate.fillMode = kCAFillModeForwards
        
        //also slightly rotate corners
        let rotateCorners = rotate.copy() as! CABasicAnimation
        
        //start both animations at the same time
        let move = CAAnimationGroup()
        move.animations = [grow, rotate]
        move.duration = durationGrowCheckmark
        move.isRemovedOnCompletion = false
        move.fillMode = kCAFillModeForwards
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        move.delegate = animationDelegate
        
        let moveCorners = CAAnimationGroup()
        moveCorners.animations = [growCorners, rotateCorners]
        moveCorners.duration = durationGrowCheckmark
        moveCorners.isRemovedOnCompletion = false
        moveCorners.fillMode = kCAFillModeForwards
        moveCorners.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        checkmarkCornerLayer.add(moveCorners, forKey: nil)
        checkLayer.add(move, forKey: nil)
    }
    
    /**
     Animates shrinking of the checkmark line.
     
     - Parameter animationDelegate: Delegate that is informed when animation starts and stops.
     */
    func animShrink(animationDelegate: CAAnimationDelegate) {
        //animation to make checkmark growing
        let grow = CABasicAnimation(keyPath: "path")
        grow.toValue = checkPathStart.cgPath
        grow.duration = durationGrowCheckmark
        grow.beginTime = 0.0
        grow.isRemovedOnCompletion = false
        grow.fillMode = kCAFillModeForwards
        
        //also "grow" corners
        let growCorners = CABasicAnimation(keyPath: "path")
        growCorners.toValue = checkmarkCornerStart.cgPath
        growCorners.duration = durationGrowCheckmark
        growCorners.beginTime = 0.0
        grow.isRemovedOnCompletion = false
        grow.fillMode = kCAFillModeForwards
        
        //animation to slightly rotate the checkmark while growing
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.toValue = 0.0
        rotate.beginTime = 0.0
        rotate.duration = durationGrowCheckmark
        rotate.isRemovedOnCompletion = false
        rotate.fillMode = kCAFillModeForwards
        
        //also slightly rotate corners
        let rotateCorners = rotate.copy() as! CABasicAnimation
        
        //start both animations at the same time
        let move = CAAnimationGroup()
        move.animations = [grow, rotate]
        move.duration = durationGrowCheckmark
        move.isRemovedOnCompletion = false
        move.fillMode = kCAFillModeForwards
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        move.delegate = animationDelegate
        
        let moveCorners = CAAnimationGroup()
        moveCorners.animations = [growCorners, rotateCorners]
        moveCorners.duration = durationGrowCheckmark
        moveCorners.isRemovedOnCompletion = false
        moveCorners.fillMode = kCAFillModeForwards
        moveCorners.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        checkmarkCornerLayer.add(moveCorners, forKey: nil)
        checkLayer.add(move, forKey: nil)
    }
    
    /**
     Changes the anchor of the given view without realigning its frame.
     
     - Parameter layer: The layer that should get a new anchor.
     - Parameter x: The real x coordinate of the anchor. Will be transformed to a relative.
     - Parameter y: The real y coordinate of the anchor. Will be transformed to a relative.
    */
    private func changeAnchor(layer: CAShapeLayer, x: CGFloat, y: CGFloat) {
        let relativeAnchorX = x / bounds.size.width
        let relativeAnchorY = y / bounds.size.height
        let anchor = CGPoint(x: relativeAnchorX, y: relativeAnchorY)
        layer.anchorPoint = anchor
        layer.frame.origin.x = 0.0
        layer.frame.origin.y = 0.0
    }
    
    /**
     Hides round corners of checkmark. Needed for initialize button as plus.
    */
    func hideCheckmarkCornerLayer() {
        checkmarkCornerLayer.strokeColor = UIColor.clear.cgColor
        checkmarkCornerLayer.fillColor = UIColor.clear.cgColor
    }
}
