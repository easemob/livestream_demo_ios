//
//  MISTabBar.h
//  AFNetworking
//
//  Created by liujinliang on 2020/7/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ELD_TabItem : UIView
@property (nonatomic, assign, readwrite, getter=isSelected) BOOL selected;
@property (nonatomic, copy)void(^selectedBlock)(NSInteger tag);
- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                selectedImage:(UIImage *)selectedImage;

- (void)updateTabbarItemWithImage:(UIImage *)image
                    selectedImage:(UIImage *)selectedImage;

@end


@interface ELDTabBar : UIView
@property (nonatomic, assign, readwrite) NSInteger selectedIndex;
@property (nonatomic, copy) void(^selectedBlock)(NSInteger index);
@property (nonatomic, copy) NSArray<ELD_TabItem *>* tabItems;

- (void)updateTabbarItemIndex:(NSInteger )itemIndex
                    withImage:(UIImage *)image
                selectedImage:(UIImage *)selectedImage;

- (void)updateTabbarItemIndex:(NSInteger )itemIndex
                withUrlString:(NSString *)urlString;

@end

NS_ASSUME_NONNULL_END
