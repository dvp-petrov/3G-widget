//
//  Constants.h
//  3G Data
//
//  Created by Dimitar Valentinov Petrov on 4/16/15.
//  Copyright (c) 2015 Dimitar Valentinov Petrov. All rights reserved.
//

#ifndef _G_Data_Constants_h
#define _G_Data_Constants_h

//constant for url
#define kRequestUrl @"http://m.mtel.bg/surf?client=1"

#define kServerResult @"<!DOCTYPE html>\n<html>\n<head>\n<title>Мобилен интернет :: Мтел</title>\n<base href=\"http://m.mtel.bg/\" />\n<meta charset=\"utf-8\" />\n<meta http-equiv=\"Content-Language\" content=\"bg\" />\n<meta name=\"viewport\" content=\"width=device-width,\n\n\n\n<section>\n\n<h1>Мобилен интернет</h1>\n\n<p>Здравейте!<br/> Благодарим ви, че използвате услугите на мрежата с най-добро покритие и най-висока скорост! Тук (на m.mtel.bg/surf) можете да управлявате потреблението на високоскоростен мобилен интернет. </p>\n\n<p>Имате активиран мобилен интернет с включени 512 МВ на максимална скорост за периода до 15.06.2015. Използвани са 35 МВ (7%).</p>\n\n<p><b><i></i></b></p>\n<p></p>\n<div class=\"progress_bar\">\n<span class=\"progress\n\n\"\nstyle=\"width: 7%\">\n\n</span>\n</div>\n\n<p></p>\n\n\n\n\n\n</section><section>\n\n<div>\n\n<p></p>\n\n<p>Желаете ли отново да бъдете информирани за достигнатия от вас лимит?</p>\n\n<form action=\"/surf\" method=\"POST\">\n\n\n\n<input type=\"hidden\" name=\"action\" value=\"changeSubscriberNotification\" />\n\n<p class=\"no_margin\">\n\n<input type=\"submit\" name=\"proceed\" value=\"Не\" class=\"button secondary\"/>\n\n<!--<input type=\"submit\" name=\"proceed\" value=\"No\" class=\"button secondary\"/> -->\n\n<//html>"


//userDefaults keys
#define kUserDefaultKeyInternetMax          @"InternetMax"
#define kUserDefaultKeyInternetCurrent      @"InternetCurrent"
#define kUserDefaultKeyDueDate              @"DueDate"

#define kUserDefaultKeyLastRequest          @"LastRequest"

#define kNotificationNameDataParsed         @"DataParsed"
#define kNotificationNameConnectionError    @"ConnectionError"

#endif