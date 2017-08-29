//
//  EMMQRCodeViewController.h
//  EMMKitDemo
//
//  Created by Chenly on 16/7/5.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMMQRCodeViewController;

typedef NS_ENUM(NSUInteger, EMMQRCodeScannerType) {
    EMMQRCodeScannerTypeBoth = 0,
    EMMQRCodeScannerTypeQRCode,
    EMMQRCodeScannerTypeBarCode,
};

@protocol EMMQRCodeViewControllerDelegate <NSObject>

- (void)emm_QRCodeViewController:(EMMQRCodeViewController *)viewController didFinishScanningQRCode:(NSString *)code;

@end

@interface EMMQRCodeViewController : UIViewController

@property (nonatomic, weak) id<EMMQRCodeViewControllerDelegate> delegate;
@property (nonatomic, assign) EMMQRCodeScannerType scannerType;
    
- (void)startScanning;

@end
