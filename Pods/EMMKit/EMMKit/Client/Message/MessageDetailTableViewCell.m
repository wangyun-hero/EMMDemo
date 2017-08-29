//
//  MessageDetailTableViewCell.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/21.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "MessageDetailTableViewCell.h"
#import "MessageModel.h"
#import "YYIMLabel.h"

@implementation MessageDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    CALayer *timeLayer = [self.timeLabel layer];
    [timeLayer setMasksToBounds:YES];
    [timeLayer setCornerRadius:3];
    
    [self.timeLabel setEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (CGFloat)heightForCellWithData:(MessageModel *)message isTimeShow:(BOOL) isTimeShow {
    
    NSString *descStr = message.messageInfo;
    if (descStr.length == 0) {
        descStr = @"";
    }
    //    NSString *descStr = @"TXRC1511170255通讯费报销单（股份） -日常业务已审批通过，请及时打印（支持邮件附件方式打印）并张贴原始单据投递到财务部指定的单据手机箱！";
    CGFloat height = [self attributedStringWithString:descStr fontFloat:16.0f];
    //    if (height < 54.5) {
    //        height = 54.5;
    //    }
//    NSLog(@"heiht = %f", height);
    if (isTimeShow) {
        // 文字高度 + 时间上间距 + 时间高度 + 时间下间距 +离cell间距 + 文字上下间距 + 距离cell高度
        height = height + 2 + 13 + 20 + 13 + 10 + 8 + 2;
        return height;
    }
    //    return height + 40 + 34 + 1.5  + 20 + 7;
    // 文字高度+2 是label高度 20文字上下间距 3是line间距和高度 34是底部 40是任务消息 1.5是时间
    return height + 2 + 20 + 3  + 34 + 8 + 1 + 20;
}

+ (CGFloat)attributedStringWithString:(NSString *)string fontFloat:(CGFloat)fontSize
{
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:string];
    // 设置行间距
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = 5;
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    // 字体大小
    NSDictionary *attrDict = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    [attributedStr addAttributes:attrDict range:NSMakeRange(0, attributedStr.length)];
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, string.length)];
    CGFloat width = [UIScreen mainScreen].bounds.size.width - 68 - 54;
    CGRect rect = [attributedStr boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)  options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size.height;
}

@end
