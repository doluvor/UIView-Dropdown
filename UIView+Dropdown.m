//
//  UIView+Dropdown.m
//
//  Created by Doluvor on 15/5/14.
//  Copyright (c) 2015年 Doluvor All rights reserved.
//

#import "UIView+Dropdown.h"
#import <objc/runtime.h>

@implementation UIView (Dropdown)

- (void)setPanGesture:(UIPanGestureRecognizer *)panGesture {
    objc_setAssociatedObject(self, @"PanGesture", panGesture, OBJC_ASSOCIATION_RETAIN);
}

- (UIPanGestureRecognizer *)panGesture {
    return objc_getAssociatedObject(self, @"PanGesture");
}

- (void)setTopOffset:(CGFloat)topOffset {
    objc_setAssociatedObject(self, @"TopOffset", @(topOffset), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)topOffset {
    return [objc_getAssociatedObject(self, @"TopOffset") doubleValue];
}

- (void)setUnfoldThreshold:(CGFloat)unfoldThreshold {
    objc_setAssociatedObject(self, @"UnfoldThreshold", @(unfoldThreshold), OBJC_ASSOCIATION_RETAIN);
}

- (CGFloat)unfoldThreshold {
    return [objc_getAssociatedObject(self, @"UnfoldThreshold") doubleValue];
}

- (void)setUnfoldedBlock:(void (^)())unfoldedBlock
{
    objc_setAssociatedObject(self, @"UnfoldedBlock", unfoldedBlock, OBJC_ASSOCIATION_COPY);
}

- (void (^)())unfoldedBlock
{
    return objc_getAssociatedObject(self, @"UnfoldedBlock");
}

- (void)enableDropdownWithFolded:(BOOL)folded {
    
    if (folded) {
        self.topOffset = CGRectGetMaxY(self.frame);
    } else {
        self.topOffset = CGRectGetMinY(self.frame);
    }
    
    self.unfoldThreshold = self.topOffset + CGRectGetHeight(self.frame) / 4 * 3 - CGRectGetHeight(self.frame);
    
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    [self.panGesture setMaximumNumberOfTouches:1];
    [self.panGesture setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:self.panGesture];
}

- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = self;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)sender {
    
    CGPoint translation = [sender translationInView:self.superview];
    
    [self adjustAnchorPointForGestureRecognizer:sender];
    
    //CGFloat newOriginX = CGRectGetMinX(self.frame) + translation.x;
    CGFloat newOriginY = CGRectGetMinY(self.frame) + translation.y;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
    
        if (newOriginY < self.unfoldThreshold) {
            __weak id weakSelf = self;
            [UIView animateWithDuration:0.2 animations:^{
                
                __strong UIView *strongSelf = weakSelf;
                
                strongSelf.frame = CGRectMake(0, self.topOffset - CGRectGetHeight(strongSelf.frame), CGRectGetWidth(strongSelf.frame), CGRectGetHeight(strongSelf.frame));
            }];
            
            self.unfoldedBlock();
            
        } else {
            __weak id weakSelf = self;
            [UIView animateWithDuration:0.2 animations:^{
                
                __strong UIView *strongSelf = weakSelf;
                
                strongSelf.frame = CGRectMake(0, self.topOffset, CGRectGetWidth(strongSelf.frame), CGRectGetHeight(strongSelf.frame));
            }];
        }
    } else {
    
        if (newOriginY > self.topOffset) {
            
            newOriginY = self.topOffset;
            
            self.frame = CGRectMake(CGRectGetMinX(self.frame), newOriginY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));

        } else if (newOriginY < self.topOffset - CGRectGetHeight(self.frame)) {

            newOriginY = self.topOffset - CGRectGetHeight(self.frame);
            
            self.frame = CGRectMake(CGRectGetMinX(self.frame), newOriginY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));

        } else {
            
            self.frame = CGRectMake(CGRectGetMinX(self.frame), newOriginY, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
        }
    }
    
    [sender setTranslation:(CGPoint){0, 0} inView:[self superview]];
}

@end
