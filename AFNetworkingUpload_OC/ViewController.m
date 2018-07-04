//
//  ViewController.m
//  AFNetworkingUpload_OC
//
//  Created by yeeku on 16/2/17.
//  Copyright © 2016年 org.crazyit. All rights reserved.
//

#import "AFNetworking.h"
#import "ViewController.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController{
	UIImagePickerController* _imagePicker;
	AFHTTPSessionManager* _manager;
}
- (void)viewDidLoad {
	[super viewDidLoad];
	NSArray* titles = @[@"选择图片上传", @"拍照上传"];
	SEL actions[] = {@selector(uploadStillImage:), @selector(uploadCaptureImage:)};
	// 采用循环创建、并添加2个UIButton控件
	for (int i = 0; i < 2; i++) {
		UIButton* uploadBn = [UIButton buttonWithType:UIButtonTypeSystem];
		uploadBn.frame = CGRectMake(10, 25 + 32 * i,
			self.view.bounds.size.width - 20, 29);
		[uploadBn setTitle:titles[i] forState:UIControlStateNormal];
		[self.view addSubview:uploadBn];
		[uploadBn addTarget:self action:actions[i]
		   forControlEvents:UIControlEventTouchUpInside];
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.delegate = self;
	}
	// 创建AFHTTPSessionManager实例
	NSURL* baseURL = [NSURL URLWithString:
		@"http://192.168.1.104:8888/AFNetworkingServer/"];
	_manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
	// 为服务端的HTML响应设置解析器
	_manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
}
- (void)uploadStillImage:(id)sender{
	// 设置使用UIImagePickerController选择相机图片
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	_imagePicker.allowsEditing = NO;
	// 设置只能选择图片
	_imagePicker.mediaTypes = @[@"public.image"];
	// 设置即可选择照片，也可选择视频
//	_imagePicker.mediaTypes = @[@"public.image", @"public.movie"];
	[self presentViewController:_imagePicker animated:YES completion:nil];
}
- (void)uploadCaptureImage:(id)sender{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		// 设置使用UIImagePickerController选择相机图片
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		// 设置拍摄照片
		_imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
		// 设置闪光灯模式
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
		// 设置使用后置摄像头
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		_imagePicker.allowsEditing = NO;
		[self presentViewController:_imagePicker animated:YES completion:nil];
	}else{
		NSLog(@"模拟器上无法打开相机！");
	}
}

- (void)imagePickerController:(UIImagePickerController *)picker
	didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
	// 获取通过该视图控制器选择的媒体类型
	NSString* mediaType = info[UIImagePickerControllerMediaType];
	// 获取被选择或拍摄的照片
	UIImage* image = info[UIImagePickerControllerOriginalImage];
	[_imagePicker dismissViewControllerAnimated:YES completion:nil];
	// 如果用户选择的是照片，且照片来自相机照片库或相机拍照
	if ([mediaType isEqualToString:@"public.image"]
		&& (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary
		|| picker.sourceType == UIImagePickerControllerSourceTypeCamera)){
			NSDictionary *parameters = @{@"name": @"额外的请求参数"};
			// 使用AFHTTPRequestOperationManager发送POST请求
			[_manager POST:@"http://192.168.1.104:8888/AFNetworkingServer/" parameters:parameters
			// 使用代码块来封装要上传的文件数据
			constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
				NSData* imageData = UIImageJPEGRepresentation(image, 1);
				// 将照片数据添加到上传请求中
				[formData appendPartWithFileData:imageData name:@"file"
					fileName:@"sample.jpg"
				// 指定上传文件的MIME类型
				mimeType:@"image/jpeg"];
			}
			progress:nil
			// 获取服务器响应成功时激发的代码块
			success:^(NSURLSessionDataTask* task, id responseObject){
				// 当使用HTTP响应解析器时，服务器响应数据被封装在NSData中
				// 此处将NSData转换成NSString，并使用UIAlertController显示上传结果
				UIAlertController* alert = [UIAlertController
					alertControllerWithTitle:@"上传结果"
					message:[[NSString alloc] initWithData:responseObject
						encoding: NSUTF8StringEncoding]
						preferredStyle:UIAlertControllerStyleAlert];
						[alert addAction:[UIAlertAction actionWithTitle:@"确定"
							style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
						   [self dismissViewControllerAnimated:YES completion:nil];
					   }]];
				[self presentViewController:alert animated:YES completion:nil];
			}
			 // 获取服务器响应失败时激发的代码块
			failure:^(NSURLSessionDataTask* task, NSError *error){
				NSLog(@"获取服务器响应出错！%@", error);
			}];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
