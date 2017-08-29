/*******************************************************************************
 * 版权所有 (C)2014用友软件股份有限公司
 *
 * 文件名称： UIView+Extension
 * 内容摘要： UIImage类别，用于扩展UIImage方法
 * 当前版本： v1.0
 * 作   者： 朱磊
 * 完成日期： 2014年4月15日
 * 说   明：
 
 * 修改日期：
 * 版 本 号：
 * 修 改 人：
 * 修改内容：
 ******************************************************************************/

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color;


//按照宽度等比压缩图片
+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;


+ (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur;


+ (UIImage *)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

@end
