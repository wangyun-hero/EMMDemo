//
//  AppCenterAssistiveTouchItem.m
//  EMMPortalDemo
//
//  Created by zm on 16/7/11.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "AppCenterAssistiveTouchItem.h"
#import "UIImageView+WebCache.h"

static const CGFloat backImageWidth = 35;

@interface AppCenterAssistiveTouchItem(){
    CGFloat itemWidth;
    CGFloat itemHeight;
}
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSString *appKey;
@end

@implementation AppCenterAssistiveTouchItem

- (instancetype) initWithFrame:(CGRect)frame  type:(EMMAssistiveTouchItemType)type{
    return [self initWithFrame:frame itemModel:nil type:type];
}

- (instancetype) initWithFrame:(CGRect)frame itemModel:(AssistiveTouchItemModel *)itemModel type:(EMMAssistiveTouchItemType)type{
    self = [super initWithFrame:frame];
    itemWidth = frame.size.width;
    itemHeight = frame.size.height;
    if(self){
        self.appKey = itemModel.key;
        switch (type) {
            case EMMItemViewTypeSystem:{
                [self initWithSystemType];
            }
                break;
            case EMMItemViewTypeCustomer:{
                [self initWithSystemCustomer:itemModel isOpening:NO];
            }
                break;
            case EMMItemViewTypeOpeningCustomer:{
                [self initWithSystemCustomer:itemModel isOpening:YES];
            }
                break;
            case EMMItemViewTypeBack:{
                [self initWithBackType];
            }
                break;
                
            default:
                break;
        }
        
    }
    return self;
    
}

- (void)initWithBackType{
    //    [self setBackgroundColor:[UIColor blueColor]];
//    CAShapeLayer *layer = [CAShapeLayer layer];
//    UIBezierPath *path = [UIBezierPath bezierPath];
//    [path moveToPoint:CGPointMake(0, 0)];
//    [path addLineToPoint:CGPointMake(22, 17)];
//    [path addLineToPoint:CGPointMake(22, 7)];
//    [path addLineToPoint:CGPointMake(44, 7)];
//    [path addLineToPoint:CGPointMake(44, -7)];
//    [path addLineToPoint:CGPointMake(22, -7)];
//    [path addLineToPoint:CGPointMake(22, -17)];
//    [path closePath];
//    layer.path = path.CGPath;
//    layer.lineWidth = 2;
//    layer.fillColor = [UIColor whiteColor].CGColor;
//    layer.strokeColor = [UIColor whiteColor].CGColor;
//    layer.position = CGPointMake(15, 40);
//    [self.layer addSublayer:layer];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AssistiveTouch_home.png"]];
    imageView.frame = CGRectMake((itemWidth - backImageWidth)/2, (itemHeight - backImageWidth)/2, backImageWidth, backImageWidth);
    imageView.userInteractionEnabled = YES;
    [imageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:imageView];
}


- (void)initWithSystemCustomer:(AssistiveTouchItemModel *)itemModel isOpening:(BOOL)isOpen{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemHeight)];
    UIImageView *imageView= [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, itemWidth)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(itemWidth/60*-20, itemHeight/95*65, itemWidth/60*100, itemHeight/95*20)];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:13]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    if([itemModel.imageName hasPrefix:@"http"]){
    [imageView sd_setImageWithURL:[NSURL URLWithString:itemModel.imageName] placeholderImage:[UIImage imageNamed:@"HGApp_placehoder.png"]];
    }
    else if ([itemModel.imageName hasPrefix:@"https"]){
         [imageView sd_setImageWithURL:[NSURL URLWithString:itemModel.imageName] placeholderImage:[UIImage imageNamed:@"HGApp_placehoder.png"] options:SDWebImageAllowInvalidSSLCertificates];
    }
    [label setText:itemModel.labelName];
    [view addSubview:imageView];
    [view addSubview:label];
    
    UIView *deleteView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth/60*-5, itemHeight/95*-5, itemWidth/60*20, itemHeight/95*20)];
    [deleteView.layer addSublayer:[self createDeleteLayer:deleteView]];
    UITapGestureRecognizer *deleteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteItem:)];
    [deleteView addGestureRecognizer:deleteTap];
    [view addSubview:deleteView];
    
    if(isOpen){
        // 是当前打开页面
        imageView.layer.borderWidth = 5;
        imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 18;
        deleteView.hidden = YES;
    }
    
    
    [self addSubview:view];
    
}

- (void)initWithSystemType {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AssistiveTouch.png"]];
    imageView.frame = CGRectMake(0, 0, itemWidth, itemHeight);
    imageView.userInteractionEnabled = YES;
    [imageView setBackgroundColor:[UIColor clearColor]];
    [self addSubview:imageView];
}

- (CAShapeLayer *)createDeleteLayer:(UIView*)deleteView{
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer addSublayer:[self createCircle:10 alpha:0.8 center:CGPointMake(deleteView.center.x+5, deleteView.center.y+5)]];
    // 画叉叉
    CAShapeLayer *leftLayer = [CAShapeLayer layer];
    UIBezierPath *leftPath = [UIBezierPath bezierPath];
    [leftPath moveToPoint:CGPointMake(0, 0)];
    [leftPath addLineToPoint:CGPointMake(5, 5)];
    [leftPath closePath];
    leftLayer.path = leftPath.CGPath;
    leftLayer.lineWidth = 1;
    leftLayer.strokeColor = [UIColor grayColor].CGColor;
    leftLayer.position = CGPointMake(deleteView.center.x+2.5, deleteView.center.y+2.5);
    [layer addSublayer:leftLayer];
    
    CAShapeLayer *rightLayer = [CAShapeLayer layer];
    UIBezierPath *rightPath = [UIBezierPath bezierPath];
    [rightPath moveToPoint:CGPointMake(0, 0)];
    [rightPath addLineToPoint:CGPointMake(5, -5)];
    [rightPath closePath];
    rightLayer.path = rightPath.CGPath;
    rightLayer.lineWidth = 1;
    rightLayer.strokeColor = [UIColor grayColor].CGColor;
    rightLayer.position = CGPointMake(deleteView.center.x+2.5, deleteView.center.y+7.5);
    [layer addSublayer:rightLayer];
    
    
    return layer;
}


- (CAShapeLayer *)createCircle:(CGFloat)radius alpha:(CGFloat)alpha center:(CGPoint)center{
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor colorWithWhite:1 alpha:alpha].CGColor;
    layer.lineWidth = 1;
    layer.strokeColor = [UIColor colorWithWhite:0 alpha:0.3 * alpha].CGColor;
    return layer;
}

- (void)deleteItem:(UITapGestureRecognizer *)tap{
    NSDictionary *dic = @{@"appKey":self.appKey,@"closeAnimated":@"reload"};
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"deleteItem" object:self userInfo:dic];
}


@end
