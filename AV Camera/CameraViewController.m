//
//  ViewController.m
//  AV Camera
//
//  Created by Will Chilcutt on 8/15/13.
//  Copyright (c) 2013 ERCLab. All rights reserved.
//

#import "CameraViewController.h"

@implementation CameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cameraCaptureSession = [[AVCaptureSession alloc]init];
    [cameraCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];

    //Add input
    {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [self setUpFlashForCaptureDevice:device];

        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        [cameraCaptureSession addInput:deviceInput];
    }
    
    //Add output
    {
        AVCaptureStillImageOutput *imageCaptureOutput = [[AVCaptureStillImageOutput alloc] init];
        [cameraCaptureSession addOutput:imageCaptureOutput];
    }
    
    //Set up preview layer
    {
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:cameraCaptureSession];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        CALayer *rootLayer = [[self view] layer];
        [rootLayer setMasksToBounds:YES];
        [previewLayer setFrame:CGRectMake(0, 0, rootLayer.bounds.size.height, rootLayer.bounds.size.height)];
        [rootLayer insertSublayer:previewLayer atIndex:0];
    }
    
    [cameraCaptureSession startRunning];
}

- (IBAction)switchCamera:(UIButton *)sender
{
    //If the device has a back camera, then the user can change cameras
    if ([self deviceHasBackCamera])
    {
        AVCaptureDevice *device = nil;
        AVCaptureDeviceInput *currentInput = [cameraCaptureSession.inputs objectAtIndex:0];
        
        //Set the new device we will be switching to
        {
            if (currentInput.device.position == AVCaptureDevicePositionBack)
            {
                device = [self getDeviceForPosition:AVCaptureDevicePositionFront];
            }
            else
            {
                device = [self getDeviceForPosition:AVCaptureDevicePositionBack];
            }
        }
        
        [self setUpFlashForCaptureDevice:device];
        
        AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        //Switch the inputs
        {
            [cameraCaptureSession beginConfiguration];
            
            [cameraCaptureSession removeInput:currentInput];
            [cameraCaptureSession addInput:deviceInput];
            
            [cameraCaptureSession commitConfiguration];
        }
    }
    //If the user only has a front camera, then tell the user sorry
    else
    {
        UIAlertView *oneCameraAlertView = [[UIAlertView alloc]initWithTitle:@"Camera error" message:@"Sorry, this device only has a front facing camera." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [oneCameraAlertView show];
    }
}

- (IBAction)changeFlash:(UIButton *)sender
{
    //First get the current capture device
    AVCaptureDevice *currentCaptureDevice = [[cameraCaptureSession.inputs objectAtIndex:0] device];

    //Next check if flash is available for the current capture device
    if ([currentCaptureDevice isFlashAvailable])
    {
        //Lock the current device until done configurating the flash mode
        [currentCaptureDevice lockForConfiguration:nil];
    
        //Check what the current flash mode is and change it to the next
        switch (currentCaptureDevice.flashMode)
        {
            case AVCaptureFlashModeAuto:
                [currentCaptureDevice setFlashMode:AVCaptureFlashModeOff];
                [sender setTitle:@"Off" forState:UIControlStateNormal];
                break;
            case AVCaptureFlashModeOff:
                [currentCaptureDevice setFlashMode:AVCaptureFlashModeOn];
                [sender setTitle:@"On" forState:UIControlStateNormal];
                break;
            case AVCaptureFlashModeOn:
                [currentCaptureDevice setFlashMode:AVCaptureFlashModeAuto];
                [sender setTitle:@"Auto" forState:UIControlStateNormal];
                break;
                
            default:
                break;
        }
        
        //Configurating the device is done, so unlock
        [currentCaptureDevice unlockForConfiguration];
    }
    //If flash is not available for the current device, then show an error alert view
    else
    {
        UIAlertView *cameraAlertView = [[UIAlertView alloc]initWithTitle:@"Camera error" message:@"Sorry, the camera you are currently using does not have a flash" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [cameraAlertView show];
    }
}

- (IBAction)takePhoto:(id)sender
{
    //First get the output to see if we're taking a picture or a video
    AVCaptureOutput *output = [cameraCaptureSession.outputs objectAtIndex:0];
    
    //If taking a picture
    if ([output isKindOfClass:[AVCaptureStillImageOutput class]])
    {
        //Convert the output to a AVCaptureStillImageOutput
        AVCaptureStillImageOutput *imageOutput = (AVCaptureStillImageOutput *)output;
        //Take the picture
        [imageOutput captureStillImageAsynchronouslyFromConnection:[imageOutput.connections objectAtIndex:0] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error)
        {
            //If any error, show it
            if (error)
            {
                UIAlertView *cameraAlertView = [[UIAlertView alloc]initWithTitle:@"Camera error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [cameraAlertView show];
            }
            //If no error, set the thumbnail image as the image taken
            else
            {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [self.thumbnailImageView setImage:image];
            }
        }];
    }
}
#pragma mark custom methods

-(BOOL)deviceHasBackCamera
{
    //First, get all of the possible camera devices that can record video on the users device
    NSArray *devicesArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //Next, loop through the devices
    for (AVCaptureDevice *device in devicesArray)
    {
        //The device's position is on the back, return yes
        if (device.position == AVCaptureDevicePositionBack)
        {
            return YES;
        }
    }
    
    //If no devices were the on the back, then return no
    return NO;
}

-(AVCaptureDevice *)getDeviceForPosition:(AVCaptureDevicePosition)position
{
    //First, get all of the possible camera devices that can record video on the users device
    NSArray *devicesArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //Next, loop through the devices
    for (AVCaptureDevice *device in devicesArray)
    {
        //If the device's position is in the position we want, return it
        if (device.position == position)
        {
            return device;
        }
    }
    
    return nil;
}

-(void)setUpFlashForCaptureDevice:(AVCaptureDevice *)captureDevice
{
    NSString *buttonTitleString = @"";
    //If the device has flash then set it up for the device
    if (captureDevice.hasFlash)
    {
        [captureDevice lockForConfiguration:nil];
        [captureDevice setFlashMode:AVCaptureFlashModeAuto];
        [captureDevice unlockForConfiguration];
        buttonTitleString = @"Auto";
    }
    //If no flash, then set the buttons title to reflect it
    else
    {
        buttonTitleString = @"None";
    }
    
    [self.flashButton setTitle:buttonTitleString forState:UIControlStateNormal];
}

@end
