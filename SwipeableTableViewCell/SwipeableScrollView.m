//
//  SwipeableScrollView.m
//  SwipeableTableViewCell
//
//  Created by Reinier Melian on 5/30/16.
//  Copyright © 2016 47 Center, Inc. All rights reserved.
//

#import "SwipeableScrollView.h"

@implementation SwipeableScrollView


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.customDelegate touchesBegan:touches withEvent:event];
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.customDelegate touchesMoved:touches withEvent:event];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.customDelegate touchesEnded:touches withEvent:event];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
