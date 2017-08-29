//
//  SummerDeviceService.m
//  SummerExample
//
//  Created by Chenly on 16/6/20.
//  Copyright © 2016年 Little Meaning. All rights reserved.
//

#import "SummerDeviceService.h"
#import "SummerInvocation.h"
#import "EMMQRCodeViewController.h"
#import "UIAlertController+EMM.h"
#import "SUMWindowViewController.h"
#import "SUMFrameViewController.h"
//#import "SUMWindowViewController+Responder.h"

#import "EMMLocationManager.h"
#import "WGS84TOGCJ02.h"
#import "EMMDeviceInfo.h"
#import "UIImage+FixOrientation.h"

#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import <QuickLook/QuickLook.h>


@interface SummerDeviceService () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, EMMQRCodeViewControllerDelegate, MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate, QLPreviewControllerDataSource,SUMWindowViewControllerResponderDelegate>

@property (nonatomic, strong) SummerInvocation *invocation;
@property (nonatomic, assign) BOOL observedLocationUpdating;
@property (nonatomic,copy) NSString *phoneNumer;
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation SummerDeviceService

+ (void)load {
    
    if (self == [SummerDeviceService self]) {
        [SummerServices registerService:@"device" class:@"SummerDeviceService"];
        [SummerServices registerService:@"SummerDevice" class:@"SummerDeviceService"];
        [SummerServices registerService:@"UMDevice" class:@"SummerDeviceService"];  // 兼容旧 Summer
    }
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SummerDeviceService *sSharedInstance;
    dispatch_once(&onceToken, ^{
        sSharedInstance = [[SummerDeviceService alloc] init];
    });
    return sSharedInstance;
}

+ (id)instanceForServices {
    return [self sharedInstance];
}

#pragma mark -

- (SUMWindowViewController *)windowForInvocation:(SummerInvocation *)invocation {
    
    SUMWindowViewController *window;
    if ([invocation.sender isKindOfClass:[SUMFrameViewController class]]) {
        window = ((SUMFrameViewController *)invocation.sender).window;
    }
    else {
        window = (SUMWindowViewController *)invocation.sender;
    }
    return window;
}

#pragma mark - 获取设备信息

- (id)getDeviceInfo:(SummerInvocation *)invocation {
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    CGFloat scale = [[UIScreen mainScreen] scale];
    
    NSDictionary *screen = @{
                             @"width": @(width),
                             @"height": @(height),
                             @"density": @(scale)
                             };
    
    NSDictionary *info = @{
                           @"screen": screen,
                           @"os": @"ios",
                           @"scale": @(scale),
                           @"model": [UIDevice currentDevice].model,
                           @"deviceid": [EMMDeviceInfo currentDeviceInfo].UUID,
                           };
    return info;
}

- (id)currentOrientation:(SummerInvocation *)invocation {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return @"portrait";
    }
    return @"landscape";
}

#pragma mark - 获取时区

- (id)getTimeZone:(SummerInvocation *)invocation {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设定时间格式
    [formatter setDateFormat:@"Z"];
    //时间格式正规化并做时区校正
    NSString *correctDate = [formatter stringFromDate:[NSDate date]];
    NSString *timeZoneID = [correctDate stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSString *timeZoneName = [[NSTimeZone localTimeZone] name];
    
    NSDictionary *result = @{
                             @"id": timeZoneID,
                             @"name": timeZoneName
                             };
    return result;
}

- (id)getTimeZoneID:(SummerInvocation *)invocation {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设定时间格式
    [formatter setDateFormat:@"Z"];
    //时间格式正规化并做时区校正
    NSString *correctDate = [formatter stringFromDate:[NSDate date]];
    NSString *timeZoneID = [correctDate stringByReplacingOccurrencesOfString:@"+" withString:@""];
    return timeZoneID;
}

- (id)getTimeZoneDisplayName:(SummerInvocation *)invocation {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //设定时间格式
    [formatter setDateFormat:@"Z"];
    //时间格式正规化并做时区校正
    NSString *timeZoneName = [[NSTimeZone localTimeZone] name];
    return timeZoneName;
}

#pragma mark - 闪光灯

// 打开闪关灯
- (void)openFlash:(SummerInvocation *)invocation {
    
    AVCaptureDevice *avDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![avDevice hasTorch]) {
        //判断是否有闪关灯
        
        [UIAlertController showAlertWithTitle:@"提示" message:@"当前设备没有闪光灯"];
    }
    else {
        [avDevice lockForConfiguration:nil];
        avDevice.torchMode = AVCaptureTorchModeOn;
        [avDevice unlockForConfiguration];
    }
}

// 关闭闪光灯
- (void)closeFlash:(SummerInvocation *)invocation {
    
    AVCaptureDevice *avDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([avDevice hasTorch]) {
        [avDevice lockForConfiguration:nil];
        avDevice.torchMode = AVCaptureTorchModeOff;
        [avDevice unlockForConfiguration];
    }
}

#pragma mark - 地图

- (void)gotoMapView:(SummerInvocation *)invocation {
    /*
     if (!invocation.params[@"latitude"] || !invocation.params[@"longitude"]) {
     
     [UIAlertController showAlertWithTitle:@"提示" message:@"未设置经纬度"];
     return;
     }
     
     float latitude = [invocation.params[@"latitude"] floatValue];
     float longitude = [invocation.params[@"longitude"] floatValue];
     
     CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
     // TODO: 打开地图
     */
}

#pragma mark - 定位

- (void)getLocation:(SummerInvocation *)invocation {
    
    EMMLocationManager *locationManager = [EMMLocationManager sharedManager];
    if (locationManager.isUpdating) {
        // 已经开启定位：直接获取最后一次定位信息
        [invocation callbackWithObject:[self resultByParsingLocation:locationManager.lastLocation]];
    }
    else {
        self.invocation = invocation;
        [locationManager addObserver:self forKeyPath:@"lastLocation" options:NSKeyValueObservingOptionNew context:NULL];
        [locationManager startUpdatingLocation];
        self.observedLocationUpdating = YES;
    }
}

- (NSDictionary *)resultByParsingLocation:(CLLocation *)loc {
    
    CLLocation *location;
    if (!outOfChina(loc.coordinate.latitude, loc.coordinate.longitude)) {
        // 国内
        Location chinaLocation = transformFromWGSToGCJ(LocationMake(loc.coordinate.latitude, loc.coordinate.longitude));
        location = [[CLLocation alloc] initWithLatitude:chinaLocation.lat longitude:chinaLocation.lng];
    }
    // 获取地址
    __block NSString *address = @"";
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error.localizedDescription);
            return;
        }
        for (CLPlacemark *placemark in placemarks) {
            address = placemark.name;
            if (!address) {
                return;
            }
        }
    }];
    return @{
             @"latitude": @(location.coordinate.latitude),
             @"longitude": @(location.coordinate.longitude),
             @"address": address
             };
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([object isKindOfClass:[EMMLocationManager class]]) {
        
        if (!self.observedLocationUpdating) {
            return;
        }
        self.observedLocationUpdating = NO;
        [object removeObserver:self forKeyPath:keyPath];
        [((EMMLocationManager *)object) stopUpdatingLocation];
        [self.invocation callbackWithObject:[self resultByParsingLocation:((EMMLocationManager *)object).lastLocation]];
        self.invocation = nil;
    }
}

#pragma mark - 相机

- (void)openCamera:(SummerInvocation *)invocation {
    
    self.invocation = invocation;
    [self openCameraWithCameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto inViewController:invocation.sender];
}

- (void)openVideo:(SummerInvocation *)invocation {
    
    self.invocation = invocation;
    [self openCameraWithCameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo inViewController:invocation.sender];
}

- (void)openCameraWithCameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)mode inViewController:(UIViewController *)viewController {
    
    if (viewController == nil) {
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) {
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if(granted){ // Access has been granted ..do something
                
            } else { // Access denied ..do something
                
            }
        }];
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = mode == UIImagePickerControllerCameraCaptureModePhoto ? @[(NSString *)kUTTypeImage] : @[(NSString *)kUTTypeMovie];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;
    
    [viewController presentViewController:cameraUI animated:YES completion:nil];
}

- (id)getAppAlbumPath:(SummerInvocation *)invocation {
    return [self private_photosDir];
}

static NSString * const kAppAlbumPath = @"Summer/Photos";

- (NSString *)private_photosDir {
    
    NSString *documentDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *photosDir = [documentDir stringByAppendingPathComponent:kAppAlbumPath];
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    
    BOOL isDirectory;
    BOOL fileExisted = [fileManager fileExistsAtPath:photosDir isDirectory:&isDirectory];
    if (fileExisted && !isDirectory) {
        [fileManager removeItemAtPath:photosDir error:nil];
        fileExisted = NO;
    }
    if (!fileExisted) {
        [fileManager createDirectoryAtPath:photosDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    }
    return photosDir;
}

#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    BOOL isImage = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeImage) != 0;
    BOOL isMovie = UTTypeConformsTo((__bridge CFStringRef)mediaType, kUTTypeMovie) != 0;
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (isImage) {
        UIImage *image = [info[UIImagePickerControllerOriginalImage] fixOrientation];
        NSString *imagesDir;
        if ([self.invocation.method isEqual:@"openCamera"]) {
            imagesDir = [self private_photosDir];
        }
        else {
            imagesDir = NSTemporaryDirectory();
        }
        NSString *(^writeImage)(CGFloat) = ^(CGFloat compressionQuality) {
            // block 将对应压缩率的图片写入到临时文件夹下
            NSData *data = UIImageJPEGRepresentation(image, compressionQuality);
            NSString *tmpFileName = [self fileNameFromDate];
            NSString *filePath = [imagesDir stringByAppendingPathComponent:tmpFileName];
            if ([data writeToFile:filePath atomically:YES]) {
                return filePath;
            }
            return @"";
        };
        
        NSString *imgPath = writeImage(1);
        result[@"imgPath"] = imgPath;
        
        NSString *compressionRatioString = self.invocation.params[@"compressionRatio"];
        if (compressionRatioString) {
            // 参数里面有 'compressionRatio'
            result[@"compressionRatio"] = compressionRatioString;
            CGFloat compressionRatio = [compressionRatioString floatValue];
            if (compressionRatio <= 0 || compressionRatio > 1) {
                compressionRatio = 1;
                result[@"compressionRatio"] = @(1);
            }
            if (compressionRatio == 1) {
                result[@"compressImgPath"] = imgPath;
            }
            else {
                NSString *compressImgPath = writeImage(compressionRatio);
                result[@"compressImgPath"] = compressImgPath;
            }
        }
    }
    else if (isMovie) {
        // NSString *mediaPath = [(NSURL *)info[UIImagePickerControllerMediaURL] path];
    }
    
    [picker dismissViewControllerAnimated:YES completion:^{
        // 返回 media 文件路径
        [self.invocation callbackWithObject:result resultType:SummerInvocationResultTypeOriginal];
        self.invocation = nil;
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 二维码

- (void)captureTwodcode:(SummerInvocation *)invocation {
    
    EMMQRCodeScannerType scannerType = EMMQRCodeScannerTypeBoth;
    NSString *formatcode = invocation.params[@"formatcode"];
    if ([formatcode isEqual:@"ONE_D_FORMATS"]) {
        scannerType = EMMQRCodeScannerTypeBarCode;
    }
    else if ([formatcode isEqual:@"QR_CODE_FORMATS"]) {
        scannerType = EMMQRCodeScannerTypeQRCode;
    }
    
    EMMQRCodeViewController *qrcodeVC = [[EMMQRCodeViewController alloc] init];
    qrcodeVC.delegate = self;
    qrcodeVC.scannerType = scannerType;
    [invocation.sender presentViewController:qrcodeVC animated:YES completion:nil];
    
    self.invocation = invocation;
}

- (id)createTwocodeImage:(SummerInvocation *)invocation {
    
    CGFloat sizeWidth = [invocation.params[@"size"] floatValue];
    sizeWidth = sizeWidth <= 0 ? 180.f : sizeWidth;
    NSString *text = invocation.params[@"content"];
    
    NSData *stringData = [text dataUsingEncoding: NSUTF8StringEncoding];
    
    // 生成
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    UIColor *onColor = [UIColor blackColor];
    UIColor *offColor = [UIColor whiteColor];
    
    // 上色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage", qrFilter.outputImage,
                             @"inputColor0", [CIColor colorWithCGColor:onColor.CGColor],
                             @"inputColor1", [CIColor colorWithCGColor:offColor.CGColor],
                             nil];
    
    CIImage *qrImage = colorFilter.outputImage;
    
    // 绘制
    CGSize size = CGSizeMake(sizeWidth, sizeWidth);
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(cgImage);
    
    NSData *data = UIImagePNGRepresentation(codeImage);
    NSString *tmpFileName = [self fileNameFromDate];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
    if ([data writeToFile:filePath atomically:YES]) {
        return filePath;
    }
    return nil;
}

- (void)emm_QRCodeViewController:(EMMQRCodeViewController *)viewController didFinishScanningQRCode:(NSString *)code {
    [viewController dismissViewControllerAnimated:YES completion:nil];
    
    [self.invocation callbackWithObject:code];
    self.invocation = nil;
}

#pragma mark - 截屏

- (id)screenshot:(SummerInvocation *)invocation {
    
    dispatch_semaphore_t lock = dispatch_semaphore_create(0);
    
    __block NSString *filePath;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIView *view = [UIApplication sharedApplication].keyWindow;
        //绘制
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0);
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSData *data = UIImagePNGRepresentation(image);
        NSString *tmpFileName = [self fileNameFromDate];
        filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:tmpFileName];
        
        if (![data writeToFile:filePath atomically:YES]) {
            filePath = nil;
        }
        dispatch_semaphore_signal(lock);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    return filePath;
}

#pragma mark - 获取存储信息

- (id)getMemoryInfo:(SummerInvocation *)invocation {
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    double total = [attributes[NSFileSystemSize] doubleValue]/1024.0/1024.0/1024.0;
    double free = [attributes[NSFileSystemFreeSize] doubleValue]/1024.0/1024.0/1024.0;
    
    NSDictionary *info = @{
                           @"MemToal": [NSString stringWithFormat:@"%.3f", total],
                           @"MenFree": [NSString stringWithFormat:@"%.3f", free],
                           };
    return info;
}

- (id)getInternalMemoryInfo:(SummerInvocation *)invocation {
    
    return [self getMemoryInfo:invocation];
}

#pragma mark - 通讯录

- (id)saveContact:(SummerInvocation *)invocation{
    
    ABAddressBookRef tmpAddressBook = nil;
    tmpAddressBook =ABAddressBookCreate();
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);        ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool granted, CFErrorRef error)                                                 {                                                     dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
            //如果没有权限
        case kABAuthorizationStatusDenied:{
            NSDictionary *errorInfo = @{@"errorInfo":@"没有访问通讯录权限"};
            return errorInfo;
        }
            break;
        case kABAuthorizationStatusRestricted:{
            NSDictionary *errorInfo = @{@"errorInfo":@"没有访问通讯录权限"};
            return errorInfo;
        }
            break;
            
        default:
            break;
    }
    
    NSDictionary *params = invocation.params;
    NSString * name = params[@"employeename"] != nil ? params[@"employeename"]:@"";//名字
    NSString * tel = params[@"tel"] != nil ? params[@"tel"] : @"";//电话
    NSString * jobname = params[@"jobname"] != nil ? params[@"jobname"] : @"";
    NSString * address = params[@"address"] != nil ? params[@"address"] : @"";
    
    NSString * email = params[@"email"] != nil ? params[@"email"] : @"";//邮箱
    NSString * officetel = params[@"officetel"] != nil ? params[@"officetel"] : @"";//办公电话
    NSString * orgname = params[@"orgname"] != nil ? params[@"orgname"] : @"";//部门
    
    if ([name isEqualToString:@""] && [tel isEqualToString:@""] && [jobname isEqualToString:@""] && [address isEqualToString:@""] && [email isEqualToString:@""] && [officetel isEqualToString:@""] && [orgname isEqualToString:@""]) {
        
        NSDictionary *errorInfo = @{@"errorInfo":@"没有联系人信息"};
        return errorInfo;
    }
    
    CFErrorRef error =NULL;
    
    ABRecordRef newPerson = ABPersonCreate();
    
    if(![name isEqualToString:@""])
    {
        ABRecordSetValue(newPerson, kABPersonFirstNameProperty,(__bridge CFTypeRef)(name), &error);
    }
    if(![jobname isEqualToString:@""])
    {
        ABRecordSetValue(newPerson, kABPersonJobTitleProperty,(__bridge CFTypeRef)(jobname), &error);
    }
    if(![address isEqualToString:@""])
    {
        [self addAddress:newPerson street:address];
    }
    if(![orgname isEqualToString:@""])
    {
        ABRecordSetValue(newPerson, kABPersonDepartmentProperty,(__bridge CFTypeRef)(orgname), &error);
    }
    if (email) {
        
        ABMutableMultiValueRef emails = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emails, (__bridge CFTypeRef)(email), kABWorkLabel, NULL);
        ABRecordSetValue(newPerson, kABPersonEmailProperty, emails, &error);
        CFRelease(emails);
    }
    
    if(![tel isEqualToString:@""]){
        
        ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(multiPhone,(__bridge CFTypeRef)(tel), kABPersonPhoneMainLabel, NULL);
        
        if (![officetel isEqualToString:@""]){
            
            ABMultiValueAddValueAndLabel(multiPhone,(__bridge CFTypeRef)(officetel), kABWorkLabel,NULL);
        }
        
        ABRecordSetValue(newPerson, kABPersonPhoneProperty, multiPhone, &error);
        CFRelease(multiPhone);
    }
    
    BOOL success;
    
    if (tmpAddressBook != nil) {
        success = ABAddressBookAddRecord(tmpAddressBook, newPerson, &error);
        success = ABAddressBookSave(tmpAddressBook, &error);
    }
    if(tmpAddressBook)
    {
        CFRelease(tmpAddressBook);
    }
    CFRelease(newPerson);
    
    if(success){
        NSDictionary *info = @{@"successInfo":@"保存成功"};
        return info;
    }
    
    NSDictionary *errorInfo = @{@"errorInfo":@"保存失败"};
    return errorInfo;
}

#pragma mark 添加通讯录地址方法
- (BOOL)addAddress:(ABRecordRef)person street:(NSString*)street
{
    ABMutableMultiValueRef address = ABMultiValueCreateMutable(kABDictionaryPropertyType);
    
    static int  homeLableValueCount = 5;
    
    // Set up keys and values for the dictionary.
    CFStringRef keys[homeLableValueCount];
    CFStringRef values[homeLableValueCount];
    
    keys[0]      = kABPersonAddressStreetKey;
    keys[1]      = kABPersonAddressCityKey;
    keys[2]      = kABPersonAddressStateKey;
    keys[3]      = kABPersonAddressZIPKey;
    keys[4]      = kABPersonAddressCountryKey;
    values[0]    = (__bridge CFStringRef)street;
    values[1]    = CFSTR("");
    values[2]    = CFSTR("");
    values[3]    = CFSTR("");
    values[4]    = CFSTR("");
    
    CFDictionaryRef aDict = CFDictionaryCreate(
                                               kCFAllocatorDefault,
                                               (void *)keys,
                                               (void *)values,
                                               homeLableValueCount,
                                               &kCFCopyStringDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks
                                               );
    
    // Add the street address to the person record.
    ABMultiValueIdentifier identifier;
    
    BOOL result = ABMultiValueAddValueAndLabel(address, aDict, kABHomeLabel, &identifier);
    
    CFErrorRef error = NULL;
    result = ABRecordSetValue(person, kABPersonAddressProperty, address, &error);
    
    CFRelease(aDict);
    CFRelease(address);
    
    return result;
}

#pragma mark - 打开本地通讯录
- (void)openAddressBook:(SummerInvocation *)invocation{
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    
    picker.peoplePickerDelegate = invocation.sender;
    // Display only a person's phone, email, and birthdate
    NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
                               [NSNumber numberWithInt:kABPersonEmailProperty],
                               [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
    
    
    picker.displayedProperties = displayedItems;
    // Show the picker
    [invocation.sender presentViewController:picker animated:YES completion:nil];
    
}

#pragma mark - 获取本地通讯录

- (id)getContactPerson:(SummerInvocation *)invocation {
    
    //新建一个通讯录类
    ABAddressBookRef addressBooks = nil;
    addressBooks = ABAddressBookCreateWithOptions(NULL, NULL);
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);        ABAddressBookRequestAccessWithCompletion(addressBooks, ^(bool granted, CFErrorRef error)                                                 {                                                     dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    switch (ABAddressBookGetAuthorizationStatus())
    {
            //如果没有权限
        case kABAuthorizationStatusDenied:{
            NSDictionary *errorInfo = @{@"errorInfo":@"没有访问通讯录权限"};
            return errorInfo;
        }
            break;
        case kABAuthorizationStatusRestricted:{
            NSDictionary *errorInfo = @{@"errorInfo":@"没有访问通讯录权限"};
            return errorInfo;
        }
            break;
            
        default:
            break;
    }
    
    NSMutableArray *addressBooksTemp = [NSMutableArray new];
    //获取通讯录中的所有人
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBooks);
    //通讯录中人数
    CFIndex count = ABAddressBookGetPersonCount(addressBooks);
    //循环，获取每个人的个人信息
    for (NSInteger i = 0; i < count; i++)
    {
        NSMutableDictionary *addressBookDicTemp = [NSMutableDictionary new];
        //获取个人
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        //获取个人名字
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        CFStringRef abFullName = ABRecordCopyCompositeName(person);
        NSString *nameString = (__bridge NSString *)abName;
        NSString *lastNameString = (__bridge NSString *)abLastName;
        
        if ((__bridge id)abName == nil) {
            nameString = @"";
        }
        if ((__bridge id)abLastName == nil){
            lastNameString = @"";
        }
        nameString = [NSString stringWithFormat:@"%@%@",lastNameString,nameString];
        [addressBookDicTemp setObject:nameString forKey:@"name"];
        [addressBookDicTemp setObject:[NSString stringWithFormat:@"%ld",(long)ABRecordGetRecordID(person) ] forKey:@"recordID"];
        
        //读取地址多值
        ABMultiValueRef address = ABRecordCopyValue(person, kABPersonAddressProperty);
        NSInteger count = ABMultiValueGetCount(address);
        NSMutableString *addrString = [[NSMutableString alloc] initWithString:@"["];
        for (NSInteger m = 0; m<count; m++) {
            //获取地址Label
            NSString* addressLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(address, m);
            addressLabel = [addressLabel stringByReplacingOccurrencesOfString:@"_$!<" withString:@""];
            addressLabel = [addressLabel stringByReplacingOccurrencesOfString:@">!$_" withString:@""];
            //获取地址5属性
            NSDictionary* personaddress =(__bridge_transfer NSDictionary*) ABMultiValueCopyValueAtIndex(address, m);
            NSString* country = [personaddress valueForKey:(NSString *)kABPersonAddressCountryKey];
            NSString* city = [personaddress valueForKey:(NSString *)kABPersonAddressCityKey];
            NSString* state = [personaddress valueForKey:(NSString *)kABPersonAddressStateKey];//省
            NSString* street = [personaddress valueForKey:(NSString *)kABPersonAddressStreetKey];
            NSString* addr = [NSString stringWithFormat:@"%@%@%@%@",country,state,city,street];
            NSString * string  = [NSString stringWithFormat:
                                  @"{\"type\":\"%@\",\"address\":\"%@\"},",addressLabel,addr];
            string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];;
            [addrString appendString:string];
        }
        NSUInteger addrlocation = [addrString length]-1;
        NSRange addrrange       = NSMakeRange(addrlocation, 1);
        [addrString replaceCharactersInRange:addrrange withString:@"]"];
        [addressBookDicTemp setObject:addrString forKey:@"addresses"];
        if (count==0) {
            [addressBookDicTemp setObject:@"[]" forKey:@"addresses"];
        }
        CFRelease(address);
        //获取email多值
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);
        NSInteger emailcount = ABMultiValueGetCount(email);
        NSMutableString *emailString = [[NSMutableString alloc] initWithString:@"["];
        for (int n = 0; n < emailcount; n++)
        {
            //获取email Label
            NSString* emailLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(email, n));
            //获取email值
            NSString* emailContent = (__bridge NSString*)ABMultiValueCopyValueAtIndex(email, n);
            NSString * string  = [NSString stringWithFormat:
                                  @"{\"type\":\"%@\",\"email\":\"%@\"},",emailLabel,emailContent];
            string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [emailString appendString:string];
        }
        NSUInteger emaillocation = [emailString length]-1;
        NSRange emailrange       = NSMakeRange(emaillocation, 1);
        [emailString replaceCharactersInRange:emailrange withString:@"]"];
        [addressBookDicTemp setObject:emailString forKey:@"emails"];
        if (emailcount==0) {
            [addressBookDicTemp setObject:@"[]" forKey:@"emails"];
        }
        CFRelease(email);
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSMutableString *phoneString = [[NSMutableString alloc] initWithString:@"["];
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            
            CFStringRef telStrRef = ABMultiValueCopyLabelAtIndex(phone, k);
            NSString * personPhoneLabel = (__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(telStrRef);
            
            //获取該Label下的电话值
            //NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            NSString * personPhone = (__bridge_transfer NSString*)ABMultiValueCopyValueAtIndex(phone, k);
            personPhone = [personPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
            NSString * string  = [NSString stringWithFormat:
                                  @"{\"type\":\"%@\",\"number\":\"%@\",\"phone\":\"%@\"},",personPhoneLabel,personPhone,personPhone];
            string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [phoneString appendString:string];
        }
        NSUInteger phonelocation = [phoneString length]-1;
        NSRange phonerange       = NSMakeRange(phonelocation, 1);
        [phoneString replaceCharactersInRange:phonerange withString:@"]"];
        [addressBookDicTemp setObject:phoneString forKey:@"phones"];
        if (ABMultiValueGetCount(phone)==0) {
            [addressBookDicTemp setObject:@"[]" forKey:@"phones"];
        }
        
        CFRelease(phone);
        //读取照片
        NSData *image = (__bridge NSData*)ABPersonCopyImageData(person);
        if(image != nil){
            NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString * imagePath = [NSString stringWithFormat:@"%@/%ld.png",documentPath,[[addressBookDicTemp objectForKey:@"recordID"] integerValue]];
            [image writeToFile:imagePath atomically:YES];
            [addressBookDicTemp setObject:imagePath forKey:@"contactPhoto"];
        }else{
            [addressBookDicTemp setObject:@"" forKey:@"contactPhoto"];
        }
        //读取备注
        NSString *note = (__bridge NSString*)ABRecordCopyValue(person, kABPersonNoteProperty);
        if(note != nil){
            [addressBookDicTemp setObject:note forKey:@"notes"];
        }else{
            [addressBookDicTemp setObject:@"" forKey:@"notes"];
        }
        
        [addressBooksTemp addObject:addressBookDicTemp];
        if (abName) CFRelease(abName);
        if (abLastName) CFRelease(abLastName);
        if (abFullName) CFRelease(abFullName);
    }
    return addressBooksTemp;
}

#pragma mark - 震动服务
/*
 *  @brief	震动服务
 *
 */
-(void)vibrator:(SummerInvocation *)invocation{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}


#pragma mark - 摇一摇
/*
 *  @brief	摇一摇
 *
 */
- (void)listenGravitySensor:(SummerInvocation *)invocation{
    [[UIApplication  sharedApplication] setApplicationSupportsShakeToEdit:YES];
    SUMWindowViewController *window = [self windowForInvocation:invocation];
    window.responderDelegate = [SummerDeviceService sharedInstance];
    self.invocation = invocation;
    [window resignFirstResponder];
    
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    NSString *isOpenVibrator = self.invocation.params[@"vibrarte"];
    if([isOpenVibrator isEqualToString:@"true"] ){
        [self vibrator:self.invocation];
    }
    
    // 播放音频
    NSString *string = [[NSBundle mainBundle] pathForResource:@"shake" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:string];
    [self playAudio:url];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [self.invocation callbackWithObject:self.invocation.params];
}


/**
 关闭摇一摇
 */
- (void)closeGravitySensor:(SummerInvocation *)invocation{
    SUMWindowViewController *window = [self windowForInvocation:self.invocation];
    window.responderDelegate = nil;
}

- (void)playAudio:(NSURL *)url{
   _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_audioPlayer play];
}


#pragma mark - 获取系统版本
/*
 *  @brief	获取系统版本
 *
 */
-(id)getSysVersion:(SummerInvocation *)invocation
{
    NSString * version = [NSString stringWithFormat:@"%.2f",[[UIDevice currentDevice].systemVersion floatValue]];
    return version;
}


#pragma mark - 拨打电话
/*
 *  @brief	打电话
 *
 *	@param 	 tel      号码
 *
 */
-(void)callPhone:(SummerInvocation *)invocation{
    
    NSString * tel = invocation.params[@"tel"] ?: @"";
    if (tel != nil )
    {
        
        NSString * msg = [NSString stringWithFormat:@"呼叫: %@",tel];
        tel = [NSString stringWithFormat:@"tel://%@",tel];
        
        [SummerDeviceService sharedInstance].phoneNumer = tel;
        
        [UIAlertController showAlertWithTitle:nil message:msg cancelButtonTitle:@"取消" otherButtonTitle:@"确定" handler:^(UIAlertAction *action, NSUInteger buttonIndex) {
            if (buttonIndex == 1) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[SummerDeviceService sharedInstance].phoneNumer]];
            }
        }];
    }
}

#pragma mark - 发短信服务

/*
 *  @brief	发送短信
 *
 *	@param 	 recevie tel      收信人号码，用逗号分格，或绑定到Ctx的路径，或绑定到Ctx的数组
 *           message body     内容，可以绑CTx"
 *
 */
-(void)sendMsg:(SummerInvocation *)invocation {
    
    [invocation check:@"tel"];
    [invocation check:@"body"];
    
    NSString * receive = invocation.params[@"tel"] ?: @"";
    NSString * message = invocation.params[@"body"] ?: @"";
    
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    
    if (messageClass != nil) {
        if ([messageClass canSendText]) {
            
            
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            
            picker.messageComposeDelegate = [SummerDeviceService sharedInstance];
            
            picker.navigationBar.tintColor = [UIColor blackColor];
            
            picker.body = message;
            
            if (![receive isEqualToString:@""]) {
                if ([receive rangeOfString:@","].location != NSNotFound) {//判断是否为多个电话号码
                    NSArray * telArray = [receive componentsSeparatedByString:@","];
                    picker.recipients = telArray;
                }else{
                    picker.recipients = [NSArray arrayWithObject:receive];
                }
            }
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
            
            // [picker release];
            
            
        } else {
            [UIAlertController showAlertWithTitle:@"提示" message:@"设备没有短信功能"];
            
        }
    } else {
        
        
        [UIAlertController showAlertWithTitle:@"提示" message:@"iOS版本过低，iOS4.0以上才支持程序内发送短信"];
        
    }
    
}

/*
 *  @brief	群发送短信
 */
-(void)SendMutilMessage:(SummerInvocation *)invocation{
    
    NSString * phones = invocation.params[@"phones"] ?: @"";
    NSString * content = invocation.params[@"content"] ?: @"";
    SummerInvocation * suin = [[SummerInvocation alloc] init];
    suin.params = @{@"tel":phones,@"body":content};
    [self sendMsg:suin];
}

/*
 *  @brief	发送邮件
 *
 *	@param 	 recevie      收信人邮箱，用逗号分格，或绑定到Ctx的路径，或绑定到Ctx的数组
 *           message      内容，可以绑CTx"
 *
 */
-(void)sendMail:(SummerInvocation *)invocation{
    
    NSString * receive = invocation.params[@"receive"]?:@"";
    NSString * content = invocation.params[@"content"]?:@"";
    NSString * title = invocation.params[@"title"]?:@"";
    NSString * cc = invocation.params[@"cc"]?:@"";
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if ([mailClass canSendMail]) {
            
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate = [SummerDeviceService sharedInstance];
            
            
            // Fill out the email body text
            [picker setMessageBody:content isHTML:NO];
            [picker setSubject:title];
            if ([receive rangeOfString:@","].location != NSNotFound) {//判断是否为多个邮箱地址
                NSArray * mailArray = [receive componentsSeparatedByString:@","];
                [picker setToRecipients:mailArray];
            }else{
                [picker setToRecipients:[NSArray arrayWithObject:receive]];
            }
            
            if ([cc rangeOfString:@","].location != NSNotFound) {//判断是否为多个抄送地址
                NSArray * ccArray = [cc componentsSeparatedByString:@","];
                [picker setCcRecipients:ccArray];
            }else{
                [picker setCcRecipients:[NSArray arrayWithObject:cc]];
            }
            
            if (invocation.params[@"imagedata"]!= nil ) {
                
                [picker addAttachmentData:invocation.params[@"imagedata"] mimeType:@"png" fileName:@"CutUIView.png"];
            }
            
            
            
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
        }
        else{
            
            [UIAlertController showAlertWithTitle:@"提示" message:@"请先设置您的邮箱"];
        }
    }
}

- (void)openPhotoAlbum:(SummerInvocation *)invocation {
    [self capturePhoto:invocation];
}

- (void)captureVideo:(SummerInvocation *)invocation {
    [self presentImagePickerController:invocation mediaTypes:@[(NSString *)kUTTypeMovie]];
}

- (void)capturePhoto:(SummerInvocation *)invocation {
    [self presentImagePickerController:invocation mediaTypes:nil];
}

- (void)presentImagePickerController:(SummerInvocation *)invocation
                          mediaTypes:(NSArray<NSString *> *)mediaTypes {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        if (mediaTypes) {
            picker.mediaTypes = mediaTypes;
        }
        self.invocation = invocation;
        SUMWindowViewController *window = [self windowForInvocation:invocation];
        [window presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark MFMailComposeViewController

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"删除成功"];
            break;
        case MFMailComposeResultSaved:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"保存成功"];
            break;
        case MFMailComposeResultSent:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"发送成功"];
            
            break;
        case MFMailComposeResultFailed:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"发送失败"];
            break;
        default:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"没有发送"];
            break;
    }
    
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MessageComposeResultSent:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"发送成功"];
            break;
        case MessageComposeResultCancelled:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"发送取消"];
            break;
        case MessageComposeResultFailed:
            //	[UIAlertController showAlertWithTitle:@"提示" message:@"发送失败"];
            break;
        default:
            break;
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 获取设备信息

- (id)getSysInfo:(SummerInvocation *)invocation {
    
    SUMWindowViewController *window = [self windowForInvocation:invocation];
    
    NSString *winId = window.sumId;
    NSString *winWidth = @(CGRectGetWidth(window.view.frame)).stringValue;
    NSString *winHeight = @(CGRectGetHeight(window.view.frame)).stringValue;
    
    id pageParams;
    NSString *frameId = @"";
    NSString *frameWidth = @"";
    NSString *frameHeight = @"";
    if ([invocation.sender isKindOfClass:[SUMFrameViewController class]]) {
        SUMFrameViewController *frame = invocation.sender;
        frameId = frame.sumId;
        frameWidth = @(CGRectGetWidth(frame.view.frame)).stringValue;
        frameHeight = @(CGRectGetHeight(frame.view.frame)).stringValue;
        pageParams = frame.pageParams;
    }
    else {
        pageParams = window.pageParams;
    }
    if (pageParams) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:pageParams options:0 error:nil];
        pageParams = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSString *statusBarStyle;
    if (window.navigationController.navigationBar.barStyle == UIBarStyleDefault) {
        statusBarStyle = @"dark";
    }
    else {
        statusBarStyle = @"light";
    }
    
    CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat height = CGRectGetHeight([UIScreen mainScreen].bounds);
    CGFloat statusBarHeight = window.sum_statusBarHidden ? 0 : 20;
    
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    NSString *appVersionName = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    
    NSDictionary *dictionary = @{
                                 @"systemType" : @"ios",
                                 @"systemVersion" : [UIDevice currentDevice].systemVersion,
                                 @"statusBarAppearance" : @(!window.sum_statusBarHidden),
                                 @"statusBarHeight" : @(statusBarHeight),
                                 @"statusBarStyle" : statusBarStyle,
                                 @"fullScreen" : @(window.sum_isFullScreenLayout),
                                 @"pageParam" : pageParams ?: @"",
                                 @"screenWidth" : @(width),
                                 @"screenHeight" : @(height),
                                 @"appVersion": appVersion,
                                 @"appVersionName": appVersionName,
                                 @"winId": winId,
                                 @"winWidth": winWidth,
                                 @"winHeight": winHeight,
                                 @"frameId": frameId,
                                 @"frameWidth": frameWidth,
                                 @"frameHeight": frameHeight,
                                 };
    
    NSMutableDictionary *result = [invocation.params mutableCopy];
    for (NSString *key in result.allKeys) {
        id value = dictionary[key];
        if (value) {
            result[key] = value;
        }
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

#pragma mark - 打开文件

- (void)openFile:(SummerInvocation *)invocation {
    
    NSString *path = invocation.params[@"filepath"];
    NSString *fileName = invocation.params[@"filename"];
    NSString *filePath = [self fullPathWithPath:[path stringByAppendingPathComponent:fileName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        self.filePath = filePath;
        
        QLPreviewController *qlViewController = [[QLPreviewController alloc] init];
        qlViewController.dataSource = self;
        [invocation.sender presentViewController:qlViewController animated:YES completion:nil];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"未找到文件：%@", path];
        [UIAlertController showAlertWithTitle:@"提示" message:message];
    }
}

#pragma mark - 文件操作

- (NSURL *)documentsDirectoryURL {
    
    return [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                  inDomain:NSUserDomainMask
                                         appropriateForURL:nil
                                                    create:NO
                                                     error:nil];
}

- (NSString *)fullPathWithPath:(NSString *)path {
    
    NSURL *filePath = nil;
    if ([path hasPrefix:[self documentsDirectoryURL].path]) {
        
        filePath = [NSURL fileURLWithPath:path];
    }
    else {
        filePath = [[self documentsDirectoryURL] URLByAppendingPathComponent:path];
    }
    return filePath.path;
}

#pragma mark <QLPreviewControllerDataSource>

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    return [NSURL fileURLWithPath:self.filePath];
}

#pragma mark - 

- (void)openWebView:(SummerInvocation *)invocation {
    
    NSString *urlString = invocation.params[@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openApp:(SummerInvocation *)invocation {
    
    NSString *scheme = invocation.params[@"ios_appid"];
    NSString *query = invocation.params[@"query"];
    NSDictionary *params = invocation.params[@"param"];
    
    NSString *urlString = [NSString stringWithFormat:@"%@://%@", scheme, query];
    if (params) {
        NSMutableString *parameterString = [[NSMutableString alloc] init];
        [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            
            if (parameterString.length == 0) {
                [parameterString appendString:@"?"];
            }
            else {
                [parameterString appendString:@"&"];
            }
            [parameterString appendFormat:@"%@=%@", key, [self jsStringWithObject:obj]];
        }];
        urlString = [urlString stringByAppendingString:parameterString];
    }
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    else {
        [invocation callbackWithObject:invocation.params];
    }
}

#pragma mark - private

- (NSString *)fileNameFromDate {
    return [NSString stringWithFormat:@"%ld.png", (NSInteger)[[NSDate date] timeIntervalSinceReferenceDate]];
}

- (NSString *)jsStringWithObject:(id)object {
    
    if (!object) {
        return nil;
    }
    
    id obj = object;
    if ([obj isKindOfClass:[NSValue class]] && ![obj isKindOfClass:[NSNumber class]]) {
        obj = [obj nonretainedObjectValue];
    }
    
    if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return [obj stringValue];
    }
    else if ([obj isKindOfClass:[NSDate class]]) {
        return [NSString stringWithFormat:@"(new Date(%f))", [obj timeIntervalSince1970] * 1000];
    }
    else if ([obj isKindOfClass:[NSArray class]] ||
             [obj isKindOfClass:[NSDictionary class]]) {
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:obj options:0 error:nil];
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return [obj description];
}

@end
