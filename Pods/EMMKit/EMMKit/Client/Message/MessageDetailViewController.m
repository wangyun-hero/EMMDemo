//
//  MessageDetailViewController.m
//  EMMPortalDemo
//
//  Created by zm on 16/6/21.
//  Copyright © 2016年 zm. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "MessageDetailTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIColor+HexString.h"
#import "UINavigationController+Extension.h"
#import "MessageDateHandle.h"

#define MessageDetail_Cell @"MessageDetailTableViewCell"

@interface MessageDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UINib *nib = [UINib nibWithNibName:MessageDetail_Cell bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:MessageDetail_Cell];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    MessageModel *model = [self.messages lastObject];
    self.title = model.messageName;
    
    [self.tableView setBackgroundColor:[UIColor emm_colorWithHexString:@"#efeff4"]];
    [self.navigationController initNavBarBackBtnWithSystemStyle];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0]  atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [MessageDetailTableViewCell heightForCellWithData:self.messages[indexPath.row] isTimeShow:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MessageDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MessageDetail_Cell];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    MessageModel *model = self.messages[indexPath.row];
    if ([model.messageImage hasPrefix:@"http"]) {
        [cell.headImageView sd_setImageWithURL:[NSURL URLWithString:model.messageImage]];
    }else{
        [cell.headImageView setImage:[UIImage imageNamed:model.messageImage]];
    }
    cell.Infolabel.text = model.messageInfo;
    cell.timeLabel.text = [MessageDateHandle detailShowTime:model.messageDate];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}



@end
