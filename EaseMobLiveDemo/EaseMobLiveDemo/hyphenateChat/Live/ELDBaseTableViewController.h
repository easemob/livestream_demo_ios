//
//  AgoraBaseTableViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/21.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELDBaseTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
@protected
    UITableView              *_table;
    UIView                   *_headerView;
    UIView                   *_footerView;
    UIRefreshControl         *_refreshView;
    UIView                   *_loadFooterView;
    UIView                   *_emptyView;
}

/*
 * table for controller. default is a grouped table.
 * for sub class  overwrite getter to custom a new one.
 */
@property (nonatomic, strong) UITableView* table;

/*
 * headerView for controller or table. default is nil.
 * for sub class  overwrite getter to custom a new one.
 */
@property (nonatomic, strong) UIView* headerView;

/*
 * footerView for controller or table. default is nil.
 * for sub class  overwrite getter to custom a new one.
 */
@property (nonatomic, strong) UIView* footerView;


/*
 * emptyView for controller or table. default is nil.
 * for sub class  overwrite getter to custom a new one.
 */
@property (nonatomic, strong) UIView* emptyView;

/**
 *  初始化各个视图，子类实现
 */
- (void)prepare;


/**
 *  摆放位置，子类实现
 */
- (void)placeSubViews;


/*
 *for sub class  overwrite
 *will be toggled when pull up
 */
- (void)didStartLoadMore;

/*
 *for sub class  overwrite
 *will be toggled when pull down
 */
- (void)didStartRefresh;

/*
 *use load more footer
 */
- (void)useLoadMore;

/*
 *use pull refresh
 */
- (void)useRefresh;

/*
 *end load more
 */
- (void)endLoadMore;

/*
 *load more completed
 */
- (void)loadMoreCompleted;

/*
 *end refresh
 */
- (void)endRefresh;

/*
 *reresh completed
 */
- (void)refreshCompleted;

@end

NS_ASSUME_NONNULL_END
