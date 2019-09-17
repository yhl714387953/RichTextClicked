//
//  ViewController.m
//  RichTextClicked-OC
//
//  Created by 嘴爷 on 2019/9/12.
//  Copyright © 2019 嘴爷. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()

{
    NSDictionary* _currentInfo;
}

/** <#description#> */
@property (nonatomic, strong) UILabel* label;

/** <#description#> */
@property (nonatomic, strong) NSMutableAttributedString* attStr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.label];
    self.label.attributedText = self.attStr;
    [self addConstraitsForView:self.label];
    // Do any additional setup after loading the view.
}


-(void)addConstraitsForView:(UIView*)view{

    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-100];
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:20];
    
    //    此属性必须要设置为NO，否则约束不生效
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[rightConstraint, bottomConstraint, leftConstraint]];
}

-(NSMutableAttributedString *)attStr{
    
    if (!_attStr) {
        NSString* h1 = @"《三国直播用户使用协议》";
        NSString* h2 = @"《三国直播隐私政策》";
        NSString* str = [NSString stringWithFormat:@"登录即代表您已经同意%@和%@", h1, h2];
        _attStr = [[NSMutableAttributedString alloc] initWithString:str];
        
        NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2;
        NSDictionary* attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:12],
                                     NSParagraphStyleAttributeName: style };
        NSRange range = NSMakeRange(0, _attStr.length);
        [_attStr addAttributes:attributes range:range];
        
        NSDictionary* dic1 = @{ @"id": @"protocol", @"text": h1 };
        NSDictionary* dic2 = @{ @"id": @"strategy", @"text": h2 };
        NSDictionary* attributs1 = @{@"moreInfo": dic1, NSUnderlineStyleAttributeName: @(1), NSUnderlineColorAttributeName:[UIColor blueColor], NSForegroundColorAttributeName: [UIColor blueColor]};
        NSDictionary* attributs2 = @{@"moreInfo": dic2, NSUnderlineStyleAttributeName: @(1), NSUnderlineColorAttributeName:[UIColor blueColor], NSForegroundColorAttributeName: [UIColor blueColor]};
        [_attStr addAttributes:attributs1 range:[str rangeOfString:h1]];
        [_attStr addAttributes:attributs2 range:[str rangeOfString:h2]];

    }
    
    return _attStr;
}

-(UILabel *)label{
    
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.numberOfLines = 0;
    }
    
    return _label;
}

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
    
    if (!_currentInfo) {
        
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
    
    if (!_currentInfo) {
        
        return;
    }
    
    if ([info[@"id"] isEqualToString:_currentInfo[@"id"]]) {
        
        [self showViewController];
        [self hasClickedAtt];
    }
    
    _currentInfo = nil;
//    [self removeAtt];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeAtt];
}

#pragma mark - private method
-(NSDictionary*)getClickInfoTouches:(NSSet<UITouch *> *)touches{

    UITouch* touch = touches.anyObject;
    CGPoint point = [touch locationInView:self.label];
    
    NSRange range = NSMakeRange(0, self.attStr.length);
    if (!CGRectContainsPoint(self.label.bounds, point)) {
        
        return nil;
    }
    
    CFIndex index = [self getIndexOfStringInLabel:self.label point:point];
    if (index == NSNotFound) {
        
        return nil;
    }
    
    if (index > self.attStr.length - 1) {
        
        return nil;
    }
    
    NSDictionary* info = [self.attStr attributesAtIndex:index effectiveRange:&range];
    
    if (![info[@"moreInfo"] isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSString* text = info[@"moreInfo"][@"text"];
    NSRange textRange = [self.attStr.string rangeOfString:text];
    
    if (index > textRange.location && index < textRange.location + textRange.length) {
        
        return info[@"moreInfo"];
    }
    return nil;
}

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

-(void)hasClickedAtt{
    
    NSString* text = _currentInfo[@"text"];
    NSRange textRange = [self.attStr.string rangeOfString:text];
    [self.attStr removeAttribute:NSForegroundColorAttributeName range:textRange];
    [self.attStr removeAttribute:NSUnderlineColorAttributeName range:textRange];
    [self.attStr removeAttribute:NSBackgroundColorAttributeName range:textRange];
    [self.attStr addAttribute:NSForegroundColorAttributeName value:[UIColor purpleColor] range:textRange];
    [self.attStr addAttribute:NSUnderlineColorAttributeName value:[UIColor purpleColor] range:textRange];
    
    self.label.attributedText = self.attStr;
}

-(void)showViewController{
    
    NSString* text = _currentInfo[@"text"];
    UIViewController* vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    vc.title = text;
    [self.navigationController pushViewController:vc animated:YES];
}

-(CFIndex)getIndexOfStringInLabel:(UILabel *)label point:(CGPoint)point {
    
    CGRect rect = label.bounds;
    CGPoint aPoint = CGPointMake(point.x, rect.size.height - point.y);
    
    NSUInteger index = NSNotFound;
    
    NSAttributedString *attStr = label.attributedText;
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, attStr.length), path, NULL);
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    for (CFIndex lineIndex = 0; lineIndex < sizeof(lineOrigins) / sizeof(lineOrigins[0]); lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        if (aPoint.y > yMax) {
            
            break;
        }
        
        if (aPoint.y >= yMin) {
            if (aPoint.x >= lineOrigin.x && aPoint.x <= lineOrigin.x + width) {
                CGPoint relativePoint = CGPointMake(aPoint.x - lineOrigin.x, aPoint.y - lineOrigin.y);
                index = CTLineGetStringIndexForPosition(line, relativePoint);
                break;
            }
        }
    }
    
    return index;
}

@end

