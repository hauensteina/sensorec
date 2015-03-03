//
//  Utils.m
//  sensorec
//
//  Created by Andreas Hauenstein on 2015-02-19.
//  Copyright (c) 2015 AHN. All rights reserved.
//

#import "Utils.h"
#import <sys/time.h>
#include <pthread.h>
#include <execinfo.h>

//=======================
@implementation Utils
//=======================

//----------------------
+ (CGFloat)screenHeight
//----------------------
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    return screenSize.height;
}

//----------------------
+ (CGFloat)screenWidth
//----------------------
{
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    return screenSize.width;
}


//-----------------------------------------------
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
//-----------------------------------------------
// Resize an image
// Example:
// UIImage *myIcon = [Utils imageWithImage:myUIImageInstance scaledToSize:CGSizeMake(20, 20)];
{
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//---------------------------------------------------
+ (NSArray *) getFirstandLastName:(NSString *)namestr
//---------------------------------------------------
// "John von Neumann" -> ["John","von Neumann"]
{
    namestr = [namestr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSArray *components = [namestr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSMutableArray *words =
    [[components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]] mutableCopy];
    NSString *first = @"";
    NSString *last = @"";
    if (words.count) {
        first = words[0];
        [words removeObjectAtIndex:0];
        last = [words componentsJoinedByString:@" "];
    }
    NSArray *res = @[first,last];
    return res;
} // getFirstandLastName()


//-----------------------------------------
+ (NSString *) replaceRegex:(NSString *)theRegex inString:(NSString *)source withString:(NSString *)newStr
//-----------------------------------------
{
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:theRegex
                                  options:0
                                  error:nil];
    NSString *res = [regex stringByReplacingMatchesInString:source
                                                    options:0
                                                      range:NSMakeRange(0, [source length])
                                               withTemplate:newStr];
    return res;
}

//--------------------------------------------------------------
+ (NSString *) repeatString: (NSString *)str times: (long) n
//--------------------------------------------------------------
{
    NSString *res =
    [@"" stringByPaddingToLength:[str length]*n
                      withString: str
                 startingAtIndex:0];
    return res;
} // repeatString

//-----------------------------------------
+ (NSString*) generateJSON:(id)theObject
//-----------------------------------------
// Convert any NSObject to a JSON representation
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theObject options:0 error:&error];
    if (!jsonData) {
        [Utils err:@"failed to convert object %@",theObject];
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
} // generateJSON

//-----------------------------------------
+ (id) parseJSON:(NSString*)theJSON
//-----------------------------------------
// Parse Json into an NSObject
{
    NSData *theData = [theJSON dataUsingEncoding:NSUTF8StringEncoding];
    NSError *theError = nil;
    id objFromJson = [NSJSONSerialization JSONObjectWithData:theData
                                                     options:0
                                                       error:&theError];
    if (!objFromJson)
    {
        [Utils err:@"Error parsing JSON: %@", theJSON];
    }
    return objFromJson;
} // parseJSON

//-----------------------------------------
+ (void) appendObjToFileAsJSON:(NSDictionary*)actDict
                         fname:(NSString*)p_fname
//-----------------------------------------
{
    NSString *fname = [Utils fullFilePath:p_fname];
    NSString *json = [self generateJSON:actDict];
    [self appendString:json toFile:fname];
} // appendObjToFileAsJSON()

//----------------------------------------------------
+ (NSString *) fullFilePath:(NSString*)p_fname
//----------------------------------------------------
// Prepend document directory to fname, if not already there
{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *fname = [path stringByAppendingPathComponent:p_fname];
    return fname;
} // fullFilePath()

//----------------------------------------------------
+ (void) appendObjToFileAsCSV:(NSDictionary*)dict
                        fname:(NSString*)p_fname
//----------------------------------------------------
// Sort dictionary values by the keys, make a comma sep string, write to file
{
    NSString *fname = [Utils fullFilePath:p_fname];
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)];
    
    if (![Utils fileIsReadable:fname]) { // Make a header line
        NSMutableString *line = [NSMutableString new];
        for (NSString *col in sortedKeys) {
            [line appendString:col];
            [line appendString:@","];
        }
        NSString *csv = chop (line);
        [self appendString:csv toFile:fname];
    }
    
    NSArray *objects = [dict objectsForKeys: sortedKeys notFoundMarker: [NSNull null]];
    NSMutableString *line = [NSMutableString new];
    for (id obj in objects) {
        NSString *tstr = str(obj);
        [line appendString:tstr];
        [line appendString:@","];
    }
    NSString *csv = chop (line);
    [self appendString:csv toFile:fname];
} // appendObjToFileAsCSV()

//-----------------------------------------
+ (NSArray *) readObjectsFromJsonFile:(NSString*)p_fname
//-----------------------------------------
// Assume the file has one JSON obj per line.
// Read them all into an array.
{
    NSString *fname = [Utils fullFilePath:p_fname];
    FILE *fp = fopen([fname cStringUsingEncoding:NSUTF8StringEncoding],"r");
    if (!fp) {
        [Utils makeEmptyFile:p_fname];
        // Attempt a second open
        fp = fopen([fname cStringUsingEncoding:NSUTF8StringEncoding],"r");
        if(!fp) {
            [Utils err:@"Could not open file %@", fname];
            return nil;
        }
    }
    
    char *line = NULL;
    size_t buflen = 0;
    long bytes_read;
    NSMutableArray *res = [NSMutableArray new];
    while ((bytes_read = getline (&line, &buflen, fp)) > 0) {
        id obj = [self parseJSON:@(line)];
        [res addObject:obj];
    } // while
    fclose (fp);
    free (line);
    return res;
} // readObjectsFromJsonFile()

//-----------------------------------------
+ (bool) makeEmptyFile:(NSString*)p_fname
//-----------------------------------------
// Empty a file. Create if not exists.
{
    NSString *fname = [Utils fullFilePath:p_fname];
    FILE *fp = fopen([fname cStringUsingEncoding:NSUTF8StringEncoding],"w");
    if (!fp) {
        [Utils err:@"Could not write file %@",fname];
        return NO;
    }
    fclose(fp);
    return YES;
} // makeEmptyFile()

//-----------------------------------------
+ (void) rmFile:(NSString*)p_fname
//-----------------------------------------
// Remove a file
{
    NSString *fname = [Utils fullFilePath:p_fname];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fname error:NULL];
} // makeEmptyFile()

//-----------------------------------------
+ (bool) fileIsReadable:(NSString*)p_fname
//-----------------------------------------
// Empty a file. Create if not exists.
{
    NSString *fname = [Utils fullFilePath:p_fname];
    FILE *fp = fopen([fname cStringUsingEncoding:NSUTF8StringEncoding],"r");
    if (!fp) {
        return NO;
    }
    fclose(fp);
    return YES;
} // fileIsReadable()


//-----------------------------------------
+ (void) appendString:(NSString*)str toFile:(NSString*)p_fname
//-----------------------------------------
// Open or create file, append string, add a newline, close
{
    if (!str || !p_fname)
        return;
    const char *path = p_fname.UTF8String;
    FILE *fp = fopen (path, "a");
    if (!fp) {
        perror ("fopen");
        [Utils err:@"Could not write file %@",p_fname];
        return;
    }
    fprintf (fp, "%s\n", str.UTF8String);
    fclose(fp);
} // appendString:toFile()

//-------------------------------------------------------
+ (BOOL) isString:(NSString*)str inFile:(NSString*)fname
//-------------------------------------------------------
{
    // Get the URL for the Password.txt file on the desktop.
    NSURL *fileURL = [NSURL fileURLWithPath:fname];
    
    // Read the contents of the file into a string.
    NSError *error = nil;
    NSString *fileContentsString = [NSString stringWithContentsOfURL:fileURL
                                                            encoding:NSUTF8StringEncoding
                                                               error:&error];
    
    // Make sure that the file has been read, log an error if it hasn't.
    if (!fileContentsString) {
        [Utils log:@"Error reading file"];
        return NO;
    }
    
    // Search the file contents for the given string, put the results into an NSRange structure
    NSRange result = [fileContentsString rangeOfString:str];
    
    // -rangeOfString returns the location of the string NSRange.location or NSNotFound.
    if (result.location == NSNotFound) {
        // Password not found. Bail.
        [Utils log:@"string not found in file"];
        return NO;
    }
    // Continue processing
    return YES;
} // istring: infile:


//----------------------
+ (time_t) t
//----------------------
// Return GMT timestamp
{
    return time (NULL);
}

//----------------------
+ (time_t) tlocal
//----------------------
// Return timestamp for local time
{
    time_t now;
    now = time (NULL);
    time_t tlocal = timegm (localtime(&now));
    return tlocal;
}

//----------------------
+ (int) tlocalHour
//----------------------
// Hour for tlocal (0-23)
{
    return (((long)[self tlocal]) % (24 * 3600)) / 3600;
}

//----------------------------
+ (NSString *) yyyymmdd_local
//----------------------------
// Get current local date as yyyymmdd
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *nowStr = [formatter stringFromDate:now];
    return nowStr;
}

//----------------------------
+ (NSString *) yyyymmddhh_local
//----------------------------
// Get current local date as yyyymmddhh
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyyMMddHH"];
    NSString *nowStr = [formatter stringFromDate:now];
    return nowStr;
}

//----------------------------
+ (NSDictionary *) dateAsDict
//----------------------------
{
    time_t rawtime;
    struct tm *info;
    rawtime = time(NULL);
    info = localtime( &rawtime );
    return @{@"year":@(info->tm_year + 1900)
             ,@"month":@(info->tm_mon + 1)
             ,@"day":@(info->tm_mday)
             ,@"hour":@(info->tm_hour)
             ,@"minute":@(info->tm_min)
             ,@"second":@(info->tm_sec)
             };
}

//--------------------------
+ (NSString *)systemVersion
//--------------------------
{
    NSString *res;
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    res = nsprintf (@"IOS %@",[UIDevice currentDevice].systemVersion);
#else
    NSDictionary *systemVersionDictionary =
    [NSDictionary dictionaryWithContentsOfFile:
     @"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *systemVersion =
    [systemVersionDictionary objectForKey:@"ProductVersion"];
    res = SPR(@"OSX %@",systemVersion);
#endif
    return res;
}

//--------------------------------
+ (NSString *) i2s:(NSInteger)i
//--------------------------------
{
    return [NSString stringWithFormat:@"%ld",(long)i];
}

//---------------------------------------------
+ (NSInteger) intFromRowArray:(NSArray *)rows
//---------------------------------------------
// After a DB query, the array of rows may be empty or
// contain a NULL value. Catch those cases and convert to zero.
// Useful for queries like 'select max(tlocal) from ....'
{
    NSInteger res = 0;
    @try {
        res = [rows[0][0] intValue];
    }
    @catch (NSException *exception) {
        res = 0;
    }
    return res;
} // intFromRowArray


//----------------------------------
+ (void) setLogBlock:(LKLogBlock) b
//----------------------------------
{
    s_logblock = b;
}

//----------------------------
+ (void) log:(NSString *)format, ...
//----------------------------
{
    va_list args;
    va_start(args, format);
    NSString *msg =[[NSString alloc] initWithFormat:format
                                          arguments:args];
    //NSLog(@"%@",msg);
    if (s_logblock) {
        s_logblock (msg);
    }
}

//----------------------------
+ (void) err:(NSString *)format, ...
//----------------------------
{
    va_list args;
    va_start(args, format);
    NSString *msg =[[NSString alloc] initWithFormat:nscat (@"Error: ",format)
                                          arguments:args];
    //NSLog(@"%@",msg);
    if (s_logblock) {
        s_logblock (msg);
    }
}

//----------------------------
+ (unsigned long long) msTime
//----------------------------
// Current time in milliseconds
{
    struct timeval tv;
    gettimeofday (&tv,NULL);
    unsigned long long tmp = tv.tv_usec;
    unsigned long long tmp2 = tv.tv_sec;
    tmp /= 1000;
    tmp2 *= 1000;
    return tmp + tmp2;
} // msTime


//------------------------------------------------------------------------------
+ (void) runBlockIfBackendUp: (LKVoidBlock) block
//------------------------------------------------------------------------------
{
    NSURLSession *defaultSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask =
    [defaultSession
     dataTaskWithURL:[NSURL URLWithString:@"https://akepa.herokuapp.com/uptest"]
     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (error) {
             [Utils log:@"akepa unreachable:%@",error];
             return;
         }
         block();
     }];
    [dataTask resume]; // try to hit the URL
} // runBlockIfBackendUp

//--------------------------------------------------------
+ (void)callWriteEndpoint:(NSString*)ep
                 withArgs:(NSDictionary*)args
          completionBlock:(LKStringBlock)completionBlock
//--------------------------------------------------------
// Call a cloud endpoint with the specified arguments.
// The returned string is passed to completionBlock.
{
    NSMutableString *body = [NSMutableString new];
    for (NSString *key in args) {
        NSString *val = args[key];
        [body appendString:nsprintf(@"%@=%@&",key,val)];
    }
    //[body appendString:nsprintf (@"tt=%d",rand())]; // ignored by endpoint
    NSString *escapedBody = [body stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // Create the http request
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:
                                                    nsprintf(@"https://akepa.herokuapp.com/%@",ep)]];
    [request setHTTPMethod: @"POST"];
    [request setValue: [@(escapedBody.length) stringValue] forHTTPHeaderField: @"Content-Length"];
    [request setHTTPBody: [escapedBody dataUsingEncoding: NSUTF8StringEncoding]];
    
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (data) {
                                   NSString *responseString = [[NSString alloc] initWithData: data
                                                                                    encoding: NSASCIIStringEncoding];
                                   if(completionBlock){
                                       completionBlock (responseString);
                                   }
                               }
                               else {
                                   if(completionBlock){
                                       completionBlock (nsprintf (@"err_network:%@",[error description]));
                                   }
                               }
                           }];
} // callEndpoint

//====================
// C Functions below
//====================

//----------------------------
NSString *nsprintf (NSString *format, ...)
//----------------------------
{
    va_list args;
    va_start(args, format);
    NSString *msg =[[NSString alloc] initWithFormat:format
                                          arguments:args];
    return msg;
} // nsprintf()


//----------------------------
NSString *errmsg (NSString *format, ...)
//----------------------------
{
    va_list args;
    va_start(args, format);
    NSString *msg =[[NSString alloc] initWithFormat:format
                                          arguments:args];
    va_end (args);
    msg = nsprintf (@"%@",getCaller(),msg);
    return msg;
} // errmsg()

//------------------------------
NSString *str2ns (const char *cstr)
//------------------------------
// C string to NSString
{
    return [NSString stringWithUTF8String:cstr];
} // str2ns

//----------------------
NSString *str (id p_id)
//----------------------
// Turn any object into a string
{
    return [NSString stringWithFormat:@"%@",p_id];
} // str()

//-----------------------------
BOOL nstrstr (NSString *haystack, NSString *needle)
//-----------------------------
// Case insensitive check whether a string contains another
{
    int loc = (int)[haystack rangeOfString:needle options:NSCaseInsensitiveSearch].location;
    if (loc == (int)NSNotFound) { return NO; }
    else { return YES; }
} // nstrstr()


//---------------------------------------------
BOOL strmatch (NSString *str, NSString *pat)
//---------------------------------------------
// Check whether string matches regex
{
    NSRegularExpression *re =
    [NSRegularExpression regularExpressionWithPattern:pat options:0 error:NULL];
    NSTextCheckingResult *match =
    [re firstMatchInString:str options:0 range:NSMakeRange(0, [str length])];
    return [match numberOfRanges]?YES:NO;
}


//-----------------------------
NSString *nscat (id a, id b)
//-----------------------------
{
    return [NSString stringWithFormat:@"%@%@",a,b];
}
//-----------------------------
NSString *nscat3 (id a, id b, id c)
//-----------------------------
{
    return [NSString stringWithFormat:@"%@%@%@",a,b,c];
}
//-----------------------------
NSString *nscat4 (id a, id b, id c, id d)
//-----------------------------
{
    return [NSString stringWithFormat:@"%@%@%@%@",a,b,c,d];
}

//-----------------------------
NSString *chop (NSString *s)
//-----------------------------
// Cut last char off string
{
    return [s substringToIndex:[s length] -1];
}

//-----------------------------
NSString *chomp (NSString *s)
//-----------------------------
// Cut trailing newline off string
{
    return [s characterAtIndex:[s length] -1] == '\n' ? chop(s) : s;
}


//---------------------
NSString* getCaller()
//---------------------
{
    void *addr[4];
    int nframes = backtrace(addr, sizeof(addr)/sizeof(*addr));
    if (nframes > 2) {
        char **syms = backtrace_symbols(addr, nframes);
        char *tmp = strdup (2+syms[2]);
        char *tmp2= strchr (tmp, '[');
        char *tmp3 = NULL;
        if (tmp2) {
            tmp2++;
            tmp3 = strchr (tmp2, ']');
            if (tmp3)
                *tmp3 = 0;
        }
        //        NSLog(@"%s: caller: %s", __func__, syms[1]);
        NSString *name = [NSString stringWithFormat:@"%s", tmp2];
        free (tmp);
        free(syms);
        return name;
    } else {
        NSLog(@"%s: *** Failed to generate backtrace.", __func__);
        return @"(unknown)";
    }
} // getCaller()

#pragma Userdefaults


//==============================
#pragma mark Userdefaults
//==============================

#define DEF [NSUserDefaults standardUserDefaults]

//-----------------------------------------------------
void putNum (NSNumber *val, NSString *key)
//-----------------------------------------------------
// Store a number in UserDefaults
{
    [DEF setObject:val forKey:key];
}

//-----------------------------------------------------
NSNumber *getNum (NSString *key)
//-----------------------------------------------------
// Get number from UserDefaults
{
    return [DEF objectForKey:key];
}

//-----------------------------------------------------
int getInt (NSString *key)
//-----------------------------------------------------
// Get number from UserDefaults, return as int
{
    return [[DEF objectForKey:key] intValue];
}

//-----------------------------------------------------
void putStr (NSString *val, NSString *key)
//-----------------------------------------------------
// Store a string in UserDefaults
{
    [DEF setObject:val forKey:key];
}

//-----------------------------------------------------
NSString *getStr (NSString *key)
//-----------------------------------------------------
// Get object from UserDefaults, return as string.
// Map empty strings to nil.
{
    id obj = [DEF objectForKey:key];
    NSString *res = obj ? nsprintf (@"%@", obj) : nil;
    if ([res isEqualToString:@""]) {
        res = nil;
    }
    return res;
}


@end
