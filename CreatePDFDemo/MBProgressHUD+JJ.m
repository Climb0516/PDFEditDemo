//
//  MBProgressHUD+JJ.m
//  GuoHaoProperty
//
//  Created by zih on 2018/11/12.
//  Copyright © 2018年 zih. All rights reserved.
//

#import "MBProgressHUD+JJ.h"
//#import "JHNetworkHelper.h"
@implementation MBProgressHUD (JJ)

#pragma mark 显示一条信息
+ (void)showMessage:(NSString *)message toView:(UIView *)view{
    [self show:message icon:nil view:view];
}

#pragma mark 显示带图片或者不带图片的信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view{
//    在iOS11上，多了一个_UIInteractiveHighlightEffectWindow类型窗口，hidden = YES。MBProgressHUD使用[[UIApplication shareApplication] lastObject]获取最上层窗口并添加，此时拿到的窗口为_UIInteractiveHighlightEffectWindow，并不可见。解决办法： 将MBProgressHUD中获取最上层窗口的方法（[[UIApplication shareApplication] lastObject]）替换成[UIApplication shareApplication].keyWindow即可。
//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (view == nil) view = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = text;
    // 判断是否显示图片
    if (icon == nil) {
        hud.mode = MBProgressHUDModeText;
    }else{
        // 设置图片
        UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]];
        img = img == nil ? [UIImage imageNamed:icon] : img;
        hud.customView = [[UIImageView alloc] initWithImage:img];
        // 再设置模式
        hud.mode = MBProgressHUDModeCustomView;
    }
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 指定时间之后再消失
    [hud hideAnimated:YES afterDelay:kHudShowTime];
}

#pragma mark 显示成功信息
+ (void)showSuccess:(NSString *)success toView:(UIView *)view{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

#pragma mark 显示警告信息
+ (void)showWarning:(NSString *)Warning toView:(UIView *)view{
    [self show:Warning icon:@"warn" view:view];
}

#pragma mark 显示自定义图片信息
+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message toView:(UIView *)view{
    [self show:message icon:imageName view:view];
}

#pragma mark 加载中
+ (MBProgressHUD *)showActivityMessage:(NSString*)message view:(UIView *)view{
//    在iOS11上，多了一个_UIInteractiveHighlightEffectWindow类型窗口，hidden = YES。MBProgressHUD使用[[UIApplication shareApplication] lastObject]获取最上层窗口并添加，此时拿到的窗口为_UIInteractiveHighlightEffectWindow，并不可见。解决办法： 将MBProgressHUD中获取最上层窗口的方法（[[UIApplication shareApplication] lastObject]）替换成[UIApplication shareApplication].keyWindow即可。
    //    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (view == nil) view = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 细节文字
    //    hud.detailsLabelText = @"请耐心等待";
    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.backgroundView.color = [UIColor colorWithWhite:0 alpha:0.3];


    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    return hud;
}

+ (MBProgressHUD *)showProgressBarToView:(UIView *)view{
//    在iOS11上，多了一个_UIInteractiveHighlightEffectWindow类型窗口，hidden = YES。MBProgressHUD使用[[UIApplication shareApplication] lastObject]获取最上层窗口并添加，此时拿到的窗口为_UIInteractiveHighlightEffectWindow，并不可见。解决办法： 将MBProgressHUD中获取最上层窗口的方法（[[UIApplication shareApplication] lastObject]）替换成[UIApplication shareApplication].keyWindow即可。
//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text = @"加载中...";
    return hud;
}



+ (void)showMessage:(NSString *)message{
    [self showMessage:message toView:nil];
}

+ (void)showSuccess:(NSString *)success{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error{
    [self showError:error toView:nil];
}

+ (void)showWarning:(NSString *)Warning{
    [self showWarning:Warning toView:nil];
}

+ (void)showMessageWithImageName:(NSString *)imageName message:(NSString *)message{
    [self showMessageWithImageName:imageName message:message toView:nil];
}

+ (MBProgressHUD *)showActivityMessage:(NSString*)message{
    return [self showActivityMessage:message view:nil];
}




+ (void)hideHUDForView:(UIView *)view{
//    在iOS11上，多了一个_UIInteractiveHighlightEffectWindow类型窗口，hidden = YES。MBProgressHUD使用[[UIApplication shareApplication] lastObject]获取最上层窗口并添加，此时拿到的窗口为_UIInteractiveHighlightEffectWindow，并不可见。解决办法： 将MBProgressHUD中获取最上层窗口的方法（[[UIApplication shareApplication] lastObject]）替换成[UIApplication shareApplication].keyWindow即可。
//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD{
    [self hideHUDForView:nil];
}

//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    //有网络请求正在进行
//    if ([JHNetworkHelper isLoading]) {
//       [MBProgressHUD hideHUD];
//        //只要不加入轮徇的接口应该是没多大问题的，先这样吧
//        //取消接口的请求
//        if ([JHNetworkHelper allSessionTasks].count > 0) {
//            @synchronized (self) {
//                NSURLSessionTask* task = [JHNetworkHelper allSessionTasks].lastObject;
//                [task cancel];
//                [[JHNetworkHelper allSessionTasks] removeLastObject];
//            }
//            
//        }
//        
//        //取消最新的也就是task数组最后一个元素的网络请求，先不㝍代码，我不确定这样行不行，因为你能确定最后一个是你想取消的那个网络请求吗？所以我没敢直接确定这种方式。等明天再说吧
//    }
//
//    // 先只隐藏，上面的我还没想好要不要这样做，所以等我再想一想明天再说吧
////    [MBProgressHUD hideHUD];
//    
//}

@end

