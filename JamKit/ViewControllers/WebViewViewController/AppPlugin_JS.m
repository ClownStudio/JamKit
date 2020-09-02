//
//  CLAppPlugin_JS.m
//  Js2NativeDemo
//
//  PS: 每个语句的结尾必须有；分号
//
//  Created by chenliang on 2018/7/23.
//  Copyright © 2018年 chenl. All rights reserved.
//

#import "AppPlugin_JS.h"

NSString * CLWebViewJavascriptBridge_js() {
    #define __wvjb_js_func__(x) #x
    static NSString * preprocessorJSCode = @__wvjb_js_func__(
         var app_plugin_uuid_count = 1;
         
         function app_plugin_uuid() {
             var result = 'cid_' + (app_plugin_uuid_count++) + '_' + new Date().getTime();
             return result;
         }
         
         var app_plugin_callback_map = new Map();
         
         function app_plugin_execute_callback(key, data) {
             var func = app_plugin_callback_map.get(key);
             if (func) {
                 if (data) {
                     func(data);
                 } else {
                     func();
                 }
             }
         }
                                                             
        //定义插件
        function app_plugin_page_name(){
            var strUrl = location.href;
            if(strUrl){
                var arrUrl=strUrl.split("/");
                var strPage=arrUrl[arrUrl.length-1];
                return strPage;
            }
            return "";
        }
        function app_plugin_create_frame(url){
            var iframe = document.createElement('iframe');
            iframe.style.display = 'none';
            iframe.src = url;
            document.body.appendChild(iframe);
            
            setTimeout(function () {
                iframe.parentNode.removeChild(iframe);
                iframe = null;
            }, 0);
        }
                                                             

        if(!window.plugins){
            window.plugins = {};
        }

        if(!window.js2native){
            window.js2native = {
                exec : function(successCallback,failureCallback,className,methodName,params){
                    
                    
                    var arr = params;
                    var arrStr = "";
                    if(arr && arr.length > 0 && Array.isArray(arr)){
                        for(var tt in arr){
                            arrStr += '$';
                            arrStr += arr[tt];
                        }
                        arrStr = arrStr.substring(1);
                    }else if(typeof(params) == 'string'){
                        arrStr = params;
                    }
                    
                    var callbackId = app_plugin_uuid();
                    var successKey = callbackId + "SuccessEvent";
                    var failKey = callbackId + "FailEvent";
                    if(successCallback){
                        app_plugin_callback_map.set(successKey, successCallback);
                    }
                    if (failureCallback) {
                        app_plugin_callback_map.set(failKey, failureCallback);
                    }
                    var url = "https://callfunction//callbackId=" + callbackId + "&className=" + className + "&method=" + methodName + "&params=" + encodeURIComponent(arrStr);
                    url += ("&currentPage=" + app_plugin_page_name());
                    url += ("&tt=" + new Date().getTime());
                    app_plugin_create_frame(url);
                }
            };
        }
    );
    
    #undef __wvjb_js_func__
    return preprocessorJSCode;
};
