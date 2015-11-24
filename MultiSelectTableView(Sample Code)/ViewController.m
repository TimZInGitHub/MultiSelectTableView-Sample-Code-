//
//  ViewController.m
//  MultiSelectTableView(Sample Code)
//
//  Created by Tim.Z on 11/24/15.
//  Copyright © 2015 Tim.Z. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

#pragma mark - 

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //是否可以多选
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    
    self.dataArray = [NSMutableArray new];
    
    dispatch_apply(20, dispatch_queue_create("TZ", DISPATCH_QUEUE_SERIAL), ^(size_t index) {
        NSString *itemName = [NSString stringWithFormat:@"Item %zu", index];
        [self.dataArray addObject:itemName];
    });
    

    [self updateButtonsToMatchTableState];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDeleteButtonTitle];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateDeleteButtonTitle];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (IBAction)edit:(id)sender
{
    [self.tableView setEditing:YES animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)cancel:(id)sender
{
    [self.tableView setEditing:NO animated:YES];
    [self updateButtonsToMatchTableState];
}

- (IBAction)delete:(id)sender
{
    NSString *actionTitle;
    if (([[self.tableView indexPathsForSelectedRows] count] == 1)) {
        actionTitle = @"你确定要删除这一项吗?";
    } else {
        actionTitle = @"你确定要删除这些项目吗?";
    }
    NSString *cancelTitle = @"取消";
    NSString *okTitle = @"好的";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:actionTitle message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:okTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
        BOOL deleteSpecificRows = selectedRows.count > 0 ;
        if (deleteSpecificRows) {
            NSMutableIndexSet *indicesOfItemsToDelete = [NSMutableIndexSet new];
            for (NSIndexPath *selectionIndex in selectedRows) {
                [indicesOfItemsToDelete addIndex:selectionIndex.row];
            }
            
            [self.dataArray removeObjectsAtIndexes:indicesOfItemsToDelete];
            
            [self.tableView deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } else {
            [self.dataArray removeAllObjects];
                //根据模型 更新view
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            //退出编辑模式
        [self.tableView setEditing:NO animated:YES];
        [self updateButtonsToMatchTableState];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}



- (IBAction)add:(id)sender
{
        //告诉tableView 即将要添加或移除;
    [self.tableView beginUpdates];
    
    [self.dataArray addObject:@"New Item"];
    
        //告诉tableView 要添加的项目
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForRow:(self.dataArray.count -1) inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem] withRowAnimation:UITableViewRowAnimationAutomatic];
    
        //与beginUpdates对应,告诉tableView结束添加或移除
    [self.tableView endUpdates];
    
        //将tableView自动滚动到底部
    [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
        //更新按钮状态
    [self updateButtonsToMatchTableState];
}


#pragma mark - Updating button state

- (void)updateButtonsToMatchTableState
{
    if (self.tableView.editing) {
            //显示取消按钮
        self.navigationItem.rightBarButtonItem = self.cancelButton;
        
        [self updateDeleteButtonTitle];
        
            //显示删除按钮
        self.navigationItem.leftBarButtonItem = self.deleteButton;
    } else {
        
            //显示添加按钮
        self.navigationItem.leftBarButtonItem = self.addButton;
        
        
        if (self.dataArray.count > 0) {
            self.editButton.enabled = YES;
        } else {
            self.editButton.enabled = NO;
        }
            //显示编辑按钮
        self.navigationItem.rightBarButtonItem = self.editButton;
    
    }
}

- (void)updateDeleteButtonTitle
{
        // 根据选中情况 更新删除标题
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    
    BOOL allItemsAreSelected = selectedRows.count == self.dataArray.count;
    BOOL noItemsAreSelected = selectedRows.count == 0;
    
    if (allItemsAreSelected || noItemsAreSelected)
        {
        self.deleteButton.title = @"Delete All";
        }
    else
        {
        self.deleteButton.title = [NSString stringWithFormat:@"Delete (%d)", selectedRows.count];
        }
}

@end
