//
//  UCloudFilterManager.m
//  UCloudMediaRecorderDemo
//
//  Created by yisanmao on 16/1/27.
//  Copyright © 2016年 https://ucloud.cn/. All rights reserved.
//

#import "FilterManager.h"
#import "CameraServer.h"
#import "UCloudGPUImage.h"

#define SysVersion [[[UIDevice currentDevice] systemVersion] floatValue]

@interface FilterManager()

@property (strong, nonatomic) UCloudGPUImageBeautyFilter *beautyFilter;
@property (strong, nonatomic) UCloudGPUImageBilateralFilter *bilateralFilter;
@property (nonatomic, strong) UCloudGPUImageBeautyFilter2 *beautyFilter2;

@end


@implementation FilterManager
- (NSArray *)filters
{
    if ([[CameraServer server] lowThan5]) {
        return nil;
    }
    else {
        //第一套滤镜方案
//        self.bilateralFilter = [[UCloudGPUImageBilateralFilter alloc] init];
//        self.beautyFilter = [[UCloudGPUImageBeautyFilter alloc] init];
//        return @[self.beautyFilter, self.bilateralFilter];
        
        //第二套滤镜方案
        if (!self.beautyFilter2) {
            self.beautyFilter2 = [[UCloudGPUImageBeautyFilter2 alloc]init];
        }
        return @[_beautyFilter2];
    }
}

- (void)setCurrentValue:(NSArray *)filterValues
{
    for (NSDictionary *filter in filterValues) {
        float current = [[filter objectForKey:@"current"] floatValue];
        NSString *type = [filter objectForKey:@"type"];
        [self valueChange:type value:current];
    }
}

- (void)valueChange:(NSString *)name value:(float)value
{
    if ([name isEqualToString:@"smooth"]) {
        [self.beautyFilter2 setSmooth:value];
    }
    else if ([name isEqualToString:@"brightness"]) {
        [self.beautyFilter2 setBrightness:value];
    }
    else if ([name isEqualToString:@"saturation"]) {
        [self.beautyFilter2 setSaturation:value];
    }
    else if ([name isEqualToString:@"beautyFilter"]) {
        [self.beautyFilter setBeautyLevel:value];
    }
    else if ([name isEqualToString:@"bilateralFilter"]) {
        [self.bilateralFilter setDistanceNormalizationFactor:value];
    }
}

- (NSMutableArray *)buildData
{
    NSArray *infos;
    if ([[CameraServer server] lowThan5]) {
        return nil;
    }
    else {
        if (SysVersion >= 8.f) {
            //第一套滤镜方案
//            infos = @[
//                      @{@"name":@"美颜", @"type":@"bilateralFilter", @"min":@(0.0), @"max":@(20.0), @"current":@(16.5)},
//                      ];
            
            //第二套滤镜方案
            infos = @[
                      @{@"name":@"磨皮", @"type":@"smooth", @"min":@(0.0), @"max":@(100.0), @"current":@(62.5)},
                      @{@"name":@"亮度", @"type":@"brightness", @"min":@(0.0), @"max":@(100.0), @"current":@(25)},
                      @{@"name":@"饱和度", @"type":@"saturation", @"min":@(0.0), @"max":@(100.0), @"current":@(25)}
                      ];
        }
    }
    return [NSMutableArray arrayWithArray:infos];
}
@end
