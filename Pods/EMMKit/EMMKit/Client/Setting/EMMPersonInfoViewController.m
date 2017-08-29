//
//  PersonInfoViewController.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/16.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "EMMPersonInfoViewController.h"
#import "EMMPersonInfo.h"
#import "EMMPersonInfoAvatarCell.h"
#import "EMMApplicationContext.h"
#import "EMMDataAccessor.h"
#import "RSKImageCropViewController.h"
#import "UIImage+Extension.h"
#import "UIAlertController+EMM.h"
#import "MBProgressHUD.h"
#import "EMMPersonInfoCell.h"


@interface EMMPersonInfoViewController ()<UIActionSheetDelegate,RSKImageCropViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//@property (nonatomic,strong) UIImage *personImage;

@end

@implementation EMMPersonInfoViewController

static NSString * const kAvatarReuseIdentifier = @"EMMPersonInfoAvatarCell";
static NSString * const kReuseIdentifier = @"EMMPersonInfoCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人信息";
    [self.tableView registerNib:[UINib nibWithNibName:kReuseIdentifier bundle:nil] forCellReuseIdentifier:kReuseIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:kAvatarReuseIdentifier bundle:nil] forCellReuseIdentifier:kAvatarReuseIdentifier];
    
    self.tableView.showsVerticalScrollIndicator = YES;
    
    // 添加label约束后设置，可动态显示高度
    self.tableView.estimatedRowHeight =44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return  15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 2;
    }
    else if (section == 1){
        return 2;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.section == 0 && indexPath.row == 0){
        //头像
        EMMPersonInfoAvatarCell *cell = [tableView dequeueReusableCellWithIdentifier:kAvatarReuseIdentifier];
        if (self.personInfo.avatar) {
            [cell setAvatarImage:[UIImage imageNamed:self.personInfo.avatar]];
        }
        else {
            [cell setAvatarImageWithURL:self.personInfo.imgurl];
        }
        return cell;
    }
    else {
        EMMPersonInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kReuseIdentifier];
        
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                cell.titleLabel.text = @"姓名";
                cell.detailLabel.text = self.personInfo.name.length?self.personInfo.name:@"  ";
            }
        }
        else if (indexPath.section == 1) {
            
            if (indexPath.row == 0) {
                
                cell.titleLabel.text = @"电话";
                cell.detailLabel.text = self.personInfo.code.length?self.personInfo.code:@"  ";
            }
            else if(indexPath.row == 1){
                cell.titleLabel.text = @"邮箱";
                cell.detailLabel.text = self.personInfo.email.length?self.personInfo.email:@" ";
            }
            
            
        }
        else if (indexPath.section == 2) {
            
            cell.titleLabel.text = @"用户类型";
            cell.detailLabel.text =  self.personInfo.department.length?self.personInfo.department:@"  ";
        }
        return cell;
    }
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section == 0 && indexPath.row == 0){
//        NSMutableArray *allTitles = [NSMutableArray arrayWithObjects:@"拍照",@"从相册选择", nil];
//        UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                      initWithTitle:nil
//                                      delegate:self
//                                      cancelButtonTitle:@"取消"
//                                      destructiveButtonTitle:nil
//                                      otherButtonTitles:allTitles[0],allTitles[1],nil];
//        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
//        [actionSheet showInView:self.view];
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark -- UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            [self presentPicker:UIImagePickerControllerSourceTypeCamera];
        }
            break;
        case 1:{
            [self presentPicker:UIImagePickerControllerSourceTypePhotoLibrary];
        }
            break;
            
        default:
            break;
    }
}

-(void)presentPicker:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeCircle];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:YES];
    }];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage{
    // 上传头像
    UIImage *image = [UIImage imageWithImageSimple:croppedImage scaledToSize:CGSizeMake(150, 150)];
    NSString *username = [[EMMApplicationContext defaultContext] objectForKey:@"username"];
    NSDictionary *params = @{@"usercode":username,@"image":image,@"imageName":@"avatar.png"};
    EMMDataAccessor *dataAccessor = [EMMDataAccessor dataAccessorWithModule:@"com.yyuap.emm.login" request:@"modifyAvatar"];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [dataAccessor sendRequestWithParams:params success:^(id result) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSDictionary *data = result[@"data"];
        if([data[@"code"] isEqualToString:@"1"]){
            //成功
            [self.navigationController popViewControllerAnimated:YES];
            self.personInfo.avatarImage = croppedImage;
            [self.tableView reloadData];
            [UIAlertController showAlertWithTitle:@"提示" message:@"上传成功"];
        }
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        [UIAlertController showAlertWithTitle:@"提示" message:error.localizedDescription];
    }];
    
}

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
