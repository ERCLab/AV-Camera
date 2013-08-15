//
//  ViewController.h
//  AV Camera
//
//  Created by Will Chilcutt on 8/15/13.
//  Copyright (c) 2013 ERCLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController
{
    AVCaptureSession *session;
}

@end
