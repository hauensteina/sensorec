//
//  Utils.h
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-19.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

// Some generally useful block types
typedef void(^LKVoidBlock)();
typedef void(^LKBoolBlock)(BOOL p_bool);
typedef void(^LKIntegerBlock)(NSInteger value);
typedef void(^LKStringBlock)(NSString *p_str);
typedef void(^LKStrStrBlock)(NSString *p_str1,NSString *p_str2);
typedef void(^LKStrArrBlock)(NSString *p_str,NSArray *p_arr);
typedef void(^LKArrayBlock)(NSArray *p_array);
typedef void(^LKDictBlock)(NSDictionary *p_dict);
typedef void(^LKObjectBlock)(NSObject* p_obj);
typedef void(^LKDataBlock)(NSData *p_data);
typedef void(^LKResponseBlock)(NSHTTPURLResponse *p_response);
typedef void(^LKDateBlock)(NSDate *p_date);
typedef void(^LKLogBlock)(NSString *mstr);
static LKLogBlock s_logblock = nil;

//-------------------------------------
//--- C functions against verbosity ---
//-------------------------------------

//-------------------------------------
NSString *str (id p_id);
//-------------------------------------
// Turn anything into a string

//-------------------------------------
NSString *nsprintf (NSString *format, ...);
//-------------------------------------
// Short for [NSString stringWithFormat ...

//-------------------------------------
NSString *errmsg (NSString *format, ...);
//-------------------------------------
// Same as nsprintf, but prepend method name

//-------------------------------------
NSString *str2ns (const char *cstr);
//-------------------------------------
// C string to NSString

//-------------------------------------
BOOL nstrstr (NSString *haystack, NSString *needle);
//-------------------------------------
// Case insensitive check whether a string contains another

//--------------------------------------------
BOOL strmatch (NSString *str, NSString *pat);
//--------------------------------------------
// Check whether string matches regex

//-------------------------------------
NSString *nscat (id a, id b);
//-------------------------------------
// Concatenate two strings

//-------------------------------------
NSString *nscat3 (id a, id b, id c);
//-------------------------------------

//-------------------------------------
NSString *nscat4 (id a, id b, id c, id d);
//-------------------------------------

//-------------------------------------
NSString *chop  (NSString *s);
//-------------------------------------
// Remove last char from string

//-------------------------------------
NSString *chomp (NSString *s);
//-------------------------------------
// Remove last char from string if newline

//===============================
@interface Utils : NSObject
//===============================

//--------------------
//--- Class Methods --
//--------------------
#if TARGET_OS_IPHONE
//-------------------------------------------------------
+ (CGFloat)screenHeight;
//-------------------------------------------------------

//-------------------------------------------------------
+ (CGFloat)screenWidth;
//-------------------------------------------------------

//-------------------------------------------------------
+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize;
//-------------------------------------------------------
// Scale any UIImage
#endif

//-------------------------------------------------------
+ (NSArray *) getFirstandLastName:(NSString *)namestr;
//-------------------------------------------------------
// Try to split a string into first and last name


//-------------------------------------------------------
+ (NSString *) replaceRegex:(NSString *)theRegex
                   inString:(NSString *)source
                 withString:(NSString *)newStr;
//-------------------------------------------------------

//------------------------------------------------------------
+ (NSString *) repeatString: (NSString *)str times: (long) n;
//------------------------------------------------------------

//-------------------------------------------------------
+ (NSString*) generateJSON:(id)theObject;
//-------------------------------------------------------
// Object to JSON.

//-------------------------------------------------------
+ (id) parseJSON:(NSString*)theJSON;
//-------------------------------------------------------
// JSON to Object

//----------------------------------------------------
+ (NSString *) fullFilePath:(NSString*)p_fname;
//----------------------------------------------------
// Prepend document directory to fname

//-------------------------------------------------------
+ (bool) makeEmptyFile:(NSString*)fname;
//-------------------------------------------------------
// Empty a file. Create if not exists.

//-----------------------------------------
+ (void) rmFile:(NSString*)p_fname;
//-----------------------------------------
// Remove a file

//-----------------------------------------
+ (bool) fileIsReadable:(NSString*)fname;
//-----------------------------------------

//-------------------------------------------------------
+ (void) appendObjToFileAsJSON:(NSDictionary*)actDict
                         fname:(NSString*)fname;
//-------------------------------------------------------
// Append JSON representation of object to file

//-------------------------------------------------
+ (void) appendObjToFileAsCSV:(NSDictionary*)dict
                        fname:(NSString*)fname;
//-------------------------------------------------
// Sort dictionary values by the keys, make a comma sep string, write to file

//-------------------------------------------------------
+ (NSArray *) readObjectsFromJsonFile:(NSString*)fname;
//-------------------------------------------------------
// Read a bunch of objects from a file with their JSON

//-------------------------------------------------------
+ (BOOL) isString:(NSString*)str
           inFile:(NSString*)fname;
//-------------------------------------------------------
// Look for a string in a file

//-------------------------------------------------------
+ (time_t) t;
//-------------------------------------------------------
// GMT UNIX timstamp

//-------------------------------------------------------
+ (time_t) tlocal;
//-------------------------------------------------------
// Local time UNIX timestamp

//-------------------------------------------------------
+ (int) tlocalHour;
//-------------------------------------------------------
// Local time full hour (0-23)

//-------------------------------------------------------
+ (NSString *) yyyymmdd_local;
//-------------------------------------------------------
// Local date as string

/**
 Gets the current date in yyyyMMddHH format
 */
//----------------------------
+ (NSString *) yyyymmddhh_local;
//----------------------------


//-------------------------------------------------------
+ (NSDictionary *) dateAsDict;
//-------------------------------------------------------
// Current local date. Keys are year,month,day,hour,minute

//-------------------------------------------------------
+ (NSString *) systemVersion;
//-------------------------------------------------------
// iOS or OSX version

//-------------------------------------------------------
+ (NSString *) i2s:(NSInteger)i;
//-------------------------------------------------------
// Integer to string

//-------------------------------------------------------
+ (NSInteger) intFromRowArray:(NSArray *)rows;
//-------------------------------------------------------
// Catch [rows[0][0] intValue] edge cases

//-------------------------------------------------------
+ (void) setLogBlock:(LKLogBlock) b;
//-------------------------------------------------------
// log: passes the string to be logged to this callback

//-------------------------------------------------------
+ (void) log:(NSString *)format, ...;
//-------------------------------------------------------
// log message calling custom callback for storage/display

//-------------------------------------------------------
+ (void) err:(NSString *)format, ...;
//-------------------------------------------------------
// log error message calling custom callback for storage/display


//----------------------------
+ (unsigned long long) msTime;
//----------------------------
// Current time in milliseconds

//------------------------------------------------------------
+ (void) runBlockIfBackendUp: (LKVoidBlock) block;
//------------------------------------------------------------

//----------------------------------------------------
+ (void)callWriteEndpoint:(NSString*)ep
                 withArgs:(NSDictionary*)args
          completionBlock:(LKStringBlock)completionBlock;
//----------------------------------------------------
// Call any akepa write endpoint. Result string is passed to completion.
// If nothing comes back, the string will start with 'err_network'.


//-----------------------------------------------------
void putNum (NSNumber *val, NSString *key);
//-----------------------------------------------------
// Store a number in UserDefaults

//-----------------------------------------------------
NSNumber *getNum (NSString *key);
//-----------------------------------------------------
// Get number from UserDefaults

//-----------------------------------------------------
int getInt (NSString *key);
//-----------------------------------------------------
// Get number from UserDefaults, return as int

//-----------------------------------------------------
void putStr (NSString *val, NSString *key);
//-----------------------------------------------------
// Store a string in UserDefaults

//-----------------------------------------------------
NSString *getStr (NSString *key);
//-----------------------------------------------------
// Get object from UserDefaults, return as string


@end // LKUtil

