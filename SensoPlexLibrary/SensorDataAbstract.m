//
//  SensorDataAbstract.m
//  Sensoplex
//
//  Created by Maciej Czupryna on 11.12.2013.
//  Copyright (c) 2013 Maciej Czupryna. All rights reserved.
//

#import "SensorDataAbstract.h"

@implementation SensorDataAbstract
- (NSDictionary*)asDictionary
{
    return [NSDictionary dictionary];
}

- (void)logClass
{
//    NSMutableString *string = [NSMutableString stringWithString:@""];
//    unsigned int propertyCount;
//    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
//    
//    for (unsigned int i = 0; i < propertyCount; i++)
//    {
//        NSString *selector = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding] ;
//        
//        SEL sel = sel_registerName([selector UTF8String]);
//        
//        const char *attr = property_getAttributes(properties[i]);
//        switch (attr[1]) {
//            case '@':
//                [string appendString:[NSString stringWithFormat:@"%s : %@\n", property_getName(properties[i]), objc_msgSend(self, sel)]];
//                break;
//            case 'i':
//                [string appendString:[NSString stringWithFormat:@"%s : %i\n", property_getName(properties[i]), objc_msgSend(self, sel)]];
//                break;
//            case 'f':
//                [string appendString:[NSString stringWithFormat:@"%s : %f\n", property_getName(properties[i]), objc_msgSend(self, sel)]];
//                break;
//            default:
//                break;
//        }
//    }
//    
//    NSLog(@"%@", string);
//    
//    free(properties);
}
@end
