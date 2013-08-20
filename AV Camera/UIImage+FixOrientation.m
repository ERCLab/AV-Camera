//
//  UIImage+FixOrientation.m
//  AV Camera
//
//  Created by Will Chilcutt on 8/20/13.
//  Copyright (c) 2013 ERCLab. All rights reserved.
//

#import "UIImage+FixOrientation.h"

@implementation UIImage (FixOrientation)

- (UIImage *)imageRotated
{
    UIDevice *device = [UIDevice currentDevice];
    
    int imageOrientation = 0;
    switch (device.orientation)
    {
        case UIDeviceOrientationPortrait:
            imageOrientation = UIImageOrientationRight;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imageOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imageOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            imageOrientation = UIImageOrientationDown;
            break;
            
        default:
            break;
    }
    
    UIImage *rotatedImage = [[UIImage alloc] initWithCGImage:self.CGImage scale:1.0f orientation:imageOrientation];
    return rotatedImage;
}

@end
