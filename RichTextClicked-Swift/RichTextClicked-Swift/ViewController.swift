//
//  ViewController.swift
//  RichTextClicked-Swift
//
//  Created by 嘴爷 on 2019/9/12.
//  Copyright © 2019 嘴爷. All rights reserved.
//

import UIKit
import CoreText

class ViewController: UIViewController {
    
    private var _currentInfo : Dictionary<String, Any>?
    
    lazy var attLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var attStr: NSMutableAttributedString = {
        
        let h1 = "《三国直播用户使用协议》";
        let h2 = "《三国直播隐私政策》";
        let str = "登录即代表您已经同意" + h1 + "和" + h2
        let myAttStr = NSMutableAttributedString(string: str)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                          NSAttributedString.Key.paragraphStyle: style ]
        let range = NSMakeRange(0, myAttStr.length)
        myAttStr.addAttributes(attributes, range: range)
        
        let dic1 = ["id": "protocol", "text": h1]
        let dic2 = ["id": "strategy", "text": h2]
        
        
        myAttStr.addAttribute(.link, value: dic1, range: NSString(string: str).range(of: h1))
        myAttStr.addAttribute(.link, value: dic2, range: NSString(string: str).range(of: h2))
        
        return myAttStr
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(attLabel)
        attLabel.attributedText = attStr
        addConstraitsForView()
        
        // Do any additional setup after loading the view.
    }
    
    func addConstraitsForView() {
        
        let rightConstraint = NSLayoutConstraint(item: attLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: -20)
        let bottomConstraint = NSLayoutConstraint(item: attLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -100)
        let leftConstraint = NSLayoutConstraint(item: attLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 20)
        
        //        此属性必须要设置为false，否则约束不生效
        attLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([rightConstraint, bottomConstraint, leftConstraint])
    }
    
    //    MARK: touch action
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       _currentInfo = getClickInfoTouches(touches: touches)
        if _currentInfo != nil{
            highlightedBack()
        }

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let info = getClickInfoTouches(touches: touches)
        
        if info == nil{
            
            removeAtt()
            return
        }
        
        if _currentInfo == nil {
            return
        }

        let cur_id = _currentInfo!["id"] as! String
        let id = info!["id"] as! String
        if _currentInfo != nil && id == cur_id{
            highlightedBack()
        }else{
            removeAtt()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let info = getClickInfoTouches(touches: touches)
        
        if info == nil{

            return
        }
        
        if _currentInfo == nil {
            return
        }
        
        let cur_id = _currentInfo!["id"] as! String
        let id = info!["id"] as! String
        if _currentInfo != nil && id == cur_id{
            showViewController()
        }
        
        _currentInfo = nil
        removeAtt()

    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAtt()
    }
    
    //    MARK: private method
    
    func highlightedBack(){
        
        if let info = _currentInfo {
            let text = info["text"] as! String
            let textRange = NSString(string: attStr.string).range(of: text);
            let color = UIColor.lightGray.withAlphaComponent(0.5)
            attStr.addAttribute(.backgroundColor, value: color, range: textRange)
            attLabel.attributedText = attStr
        }
    }
    
    func removeAtt() {
        let range = NSMakeRange(0, attStr.length)
        attStr.removeAttribute(.backgroundColor, range: range)
        attLabel.attributedText = attStr
    }
    
    func showViewController() {
        let text = _currentInfo!["text"] as! String
        let vc = UIViewController()
        vc.view.backgroundColor = UIColor.white
        vc.title = text
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getClickInfoTouches(touches: Set<UITouch>) -> [String:Any]? {
        
        let touch = touches.first!
        let point = touch.location(in: attLabel)
        var range = NSMakeRange(0, attStr.length)
        if !attLabel.bounds.contains(point){
            return nil
        }
        
        let index = getIndexOfStringInLabel(label: attLabel, point: point)
        if index == NSNotFound {
            return nil
        }
        
        if index > attStr.length - 1 {
            return nil
        }
        
        let info = attStr.attributes(at: index, effectiveRange: &range)
        
        if  info.count == 0 {
            return nil
        }
      
        let linkInfo = info[.link]
        if !(linkInfo is Dictionary<String, Any>) {
            return nil
        }
        
        if linkInfo is Dictionary<String, Any> {
            let l_info = linkInfo as! Dictionary<String, Any>
            let text = l_info["text"] as! String
 
            let textRange = NSString(string: attStr.string).range(of: text)
            if index > textRange.location && index < textRange.location + textRange.length {
                return l_info
            }
        }

        return nil
    }
    

    func getIndexOfStringInLabel(label: UILabel, point: CGPoint) -> CFIndex {
        
        let rect = label.bounds
        let aPoint = CGPoint(x: point.x, y:rect.size.height - point.y)
        
        var index = NSNotFound
        
        let attributedStr = label.attributedText!
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedStr)
        let path = CGMutablePath()
        path.addRect(rect)
        
        let frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attributedStr.length), path, nil);
        let lines = CTFrameGetLines(frame);
        let numberOfLines = CFArrayGetCount(lines);
        
//        let lineHeight = label.frame.height / CGFloat(numberOfLines)
//        let lineIndex = Int(aPoint.y / lineHeight)
//        let clickLine = CFArrayGetValueAtIndex(lines, lineIndex)
        
//        注意数组的初始化方式
        var lineOrigins = [CGPoint](repeating: .zero, count: numberOfLines)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &lineOrigins)
        
        for lineIndex in 0 ..< lineOrigins.count {
            let lineOrigin = lineOrigins[lineIndex]
            
//            注意取值方式
            let line = Unmanaged<CTLine>.fromOpaque(CFArrayGetValueAtIndex(lines, lineIndex)).takeUnretainedValue()
            var ascent = CGFloat()
            var descent = CGFloat()
            var leading = CGFloat()
            let width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            
            let yMin = floor(lineOrigin.y - descent);
            let yMax = ceil(lineOrigin.y + ascent);
            if aPoint.y > yMax {
                
                break
            }
            
            if aPoint.y >= yMin {
                if (aPoint.x >= lineOrigin.x && aPoint.x <= lineOrigin.x + CGFloat(width)){
                    let relativePoint = CGPoint(x:aPoint.x - lineOrigin.x, y:aPoint.y - lineOrigin.y)
                    index = CTLineGetStringIndexForPosition(line, relativePoint)
                    break
                }
            }
        }
        
        return index;
    }
    
}
    
    /*
    #pragma mark - touch action
    -(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    _currentInfo = [self getClickInfoTouches:touches];
    if (_currentInfo) {
    
    [self highlightedBack];
    }
    }
    
    -(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSDictionary* info = [self getClickInfoTouches:touches];
    if (!info) {
    [self removeAtt];
    
    return;
    }
    
    if (_currentInfo && [info[@"id"] isEqualToString:_currentInfo[@"id"]]) {
    [self highlightedBack];
    }else{
    [self removeAtt];
    }
    }
    
    -(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSDictionary* info = [self getClickInfoTouches:touches];
    if (!info) {
    return;
    }
    
    if ([info[@"id"] isEqualToString:_currentInfo[@"id"]]) {
    
    [self showViewController];
    }
    
    _currentInfo = nil;
    [self removeAtt];
    }
    
    -(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeAtt];
    }
    */
    



/*
    -(void)highlightedBack{
    NSString* text = _currentInfo[@"text"];
    NSRange textRange = [self.attStr.string rangeOfString:text];
    UIColor* color = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self.attStr addAttribute:NSBackgroundColorAttributeName value:color range:textRange];
    self.label.attributedText = self.attStr;
    }
    
    -(void)removeAtt{
    
    NSRange range = NSMakeRange(0, self.attStr.length);
    [self.attStr removeAttribute:NSBackgroundColorAttributeName range:range];
    self.label.attributedText = self.attStr;
    }
*/

/*
    -(void)showViewController{
    
    NSString* text = _currentInfo[@"text"];
    UIViewController* vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.title = text;
    [self.navigationController pushViewController:vc animated:YES];
    }
*/

/*
    -(CFIndex)getIndexOfStringInLabel:(UILabel *)label point:(CGPoint)point {
    
    CGRect rect = label.bounds;
    point = CGPointMake(point.x, rect.size.height - point.y);
    
    NSUInteger index = NSNotFound;
    
    NSAttributedString *attStr = label.attributedText;
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
    
    CGPoint lineOrigin = lineOrigins[lineIndex];
    CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
    CGFloat ascent, descent, leading, width;
    width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat yMin = floor(lineOrigin.y - descent);
    CGFloat yMax = ceil(lineOrigin.y + ascent);
    if (point.y > yMax) {
    
    break;
    }
    
    if (point.y >= yMin) {
    if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
    CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
    index = CTLineGetStringIndexForPosition(line, relativePoint);
    break;
    }
    }
    }
    
    return index;
    }
*/


