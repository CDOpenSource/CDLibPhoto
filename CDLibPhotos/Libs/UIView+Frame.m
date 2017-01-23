//
//  UIView+Frame.m
//  CDNotepad
//
//  Created by Cindy on 2017/1/7.
//  Copyright © 2017年 Comtop. All rights reserved.
//

#import "UIView+Frame.h"

@implementation UIView (Frame)


#pragma mark - 自定义设置或获取view的frame属性
- (CGSize)cd_size
{
    return self.bounds.size;
}

- (CGFloat)cd_height
{
    return self.bounds.size.height;
}

- (CGFloat)cd_width
{
    return self.bounds.size.width;
}

- (CGPoint)cd_origin
{
    return self.frame.origin;
}

- (CGFloat)cd_x
{
    return self.frame.origin.x;
}

- (CGFloat)cd_y
{
    return self.frame.origin.y;
}

- (void)setCd_size:(CGSize)cd_size
{
    CGRect oldFrame = self.frame;
    self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, cd_size.width, cd_size.height);
}

- (void)setCd_height:(CGFloat)cd_height
{
    CGRect oldFrame = self.frame;
    self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, cd_height);
}

- (void)setCd_width:(CGFloat)cd_width
{
    CGRect oldFrame = self.frame;
    self.frame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, cd_width, oldFrame.size.height);
}

- (void)setCd_origin:(CGPoint)cd_origin
{
    CGRect oldFrame = self.frame;
    self.frame = CGRectMake(cd_origin.x, cd_origin.y, oldFrame.size.width, oldFrame.size.height);
}

- (void)setCd_x:(CGFloat)cd_x
{
    CGRect oldFrame = self.frame;
    self.frame = CGRectMake(cd_x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
}

- (void)setCd_y:(CGFloat)cd_y
{
    CGRect oldFrame = self.frame;
    self.frame = CGRectMake(oldFrame.origin.x, cd_y, oldFrame.size.width, oldFrame.size.height);
}

@end
