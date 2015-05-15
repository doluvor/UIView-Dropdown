//
//  UIView+Dropdown.h
//
//  Created by doluvor on 15/5/14.
//  Copyright (c) 2015 Doluvor All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Dropdown)

@property (nonatomic, copy) void (^unfoldedBlock)();

- (void)enableDropdownWithFolded:(BOOL)folded;

@end
