//
//  ViewController.h
//  AV Camera
//
//  Created by Will Chilcutt on 8/15/13.
//  Copyright (c) 2013 ERCLab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate>
{
    AVCaptureVideoPreviewLayer *previewLayer;
    int initialVolume;
    AVCaptureStillImageOutput *imageCaptureOutput;
    AVCaptureMovieFileOutput *movieFileOutput;
}

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *folderButton;
@property (weak, nonatomic) IBOutlet UIButton *takePictureButton;
@property (weak, nonatomic) IBOutlet UIButton *torchButton;
@property (weak, nonatomic) IBOutlet UIView *rotatingContainerView;
@property (weak, nonatomic) IBOutlet UIView *bottomBarView;

@end
