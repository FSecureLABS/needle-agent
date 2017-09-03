//
//  OpcodeDUMP_KEYCHAIN.m
//  needleAgent
//

#import "OpcodeProtocol.h"

@interface OpcodeDUMP_KEYCHAIN : NSObject <OPCODE>
@end


@implementation OpcodeDUMP_KEYCHAIN


+(NSString *)run:(NSArray *)args
{
    NSString *responseString = [NSString stringWithFormat:@"%@%@", [self dumpKeychainItems], COMMAND_OUTPUT_END];
    
    return responseString;
}


NSDictionary * parseSecAccessControlObject(id sacObject){
    
    // iOS 8 always returns a SecAccessControlRef to an empty dictionary!!
    // TODO: Test on iOS 9/10 and probably return NSString
    
    // Undocumented function
    // https://opensource.apple.com/source/Security/Security-57031.1.35/Security/sec/Security/SecAccessControl.c
    /*
     CFDictionaryRef SecAccessControlGetConstraints(SecAccessControlRef access_control) {
     return CFDictionaryGetValue(access_control->dict, kAKSKeyAcl);
     }
     */
    
    CFDictionaryRef SecAccessControlGetConstraints(SecAccessControlRef access_control);
    // Declare the undocumented function so it can be used
    
    CFDictionaryRef sacDict = SecAccessControlGetConstraints((__bridge SecAccessControlRef)(sacObject));
    // Create dictionary to store SecAccessControl object
    
    if (sacDict != NULL){
        
        return (__bridge NSDictionary *)(sacDict);
        
    } else {
        
        return @"No SecAccessControl Constraints";
    }
}


NSString* convertNSDataToNSString(id value) {
    
    // Service and Account values sometimes of type NSData
    // NSJSONSerialization cannot serialise NSData
    // Converts only NSData input otherwise returns original value
    
    if ([value isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:value encoding:NSUTF8StringEncoding];
    }
    
    return value;
}


NSString* encodeDataValue(NSData* dataValue) {
    
    // Some Keychain items have no value (null) in the Data field
    // setObjectForKey: object cannot be nil
    // If data attempt to encode as UTF8 else encode as BASE64
    
    if ([dataValue length] != 0 && dataValue != NULL) {
        // If some data in data field
        
        NSString *formattedUTF8Data = [[NSString alloc] initWithData:dataValue encoding:NSUTF8StringEncoding];
        // Attempt to encode with UTF8
        
        if (formattedUTF8Data == NULL | [formattedUTF8Data length] == 0){
            // UTF8 Encoding didn't work
            
            return [dataValue base64EncodedStringWithOptions:0];
            // Return the data as a base64 encoded string
            
        } else {
            // UTF8 Encoding did work
            
            return formattedUTF8Data;
            // Return the data as a UTF8 encoded string
        }
        
    } else {
        
        //return [[@"null" dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        // Returns " "
        
        return @"null";
        // Returns "null"
    }
    
}


NSString *mapkSecAttrAccessibleValues(NSString *pdmn) {
    
    // https://opensource.apple.com/source/Security/Security-55471/sec/Security/SecItemConstants.c.auto.html
    
    if ([pdmn isEqualToString:@"ck"])
        return @"kSecAttrAccessibleAfterFirstUnlock";
    
    else if ([pdmn isEqualToString:@"cku"])
        return @"kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly";
    
    else if ([pdmn isEqualToString:@"dk"])
        return @"kSecAttrAccessibleAlways";
    
    else if ([pdmn isEqualToString:@"akpu"])
        return @"kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly";
    
    else if ([pdmn isEqualToString:@"dku"])
        return @"kSecAttrAccessibleAlwaysThisDeviceOnly";
    
    else if ([pdmn isEqualToString:@"ak"])
        return @"kSecAttrAccessibleWhenUnlocked";
    
    else if ([pdmn isEqualToString:@"aku"])
        return @"kSecAttrAccessibleWhenUnlockedThisDeviceOnly";
    
    else
        return @"Unknown kSecAttrAccessible Value";
    
}


NSData* convertToJSON(NSArray *keychainDictionariesArray) {
    
    // Convert array of dictionaries to dictionary of dictionaries
    // Each dictionary in keychainDictionariesArray is a keychain item
    // Build keychainItem from dictionaries in keychainDictionariesArray
    // Do some processing: mapkSecAttrAccessibleValues, convertNSDataToNSString and encodeDataValue
    // Add each keychainItem to processedKeychainItems then serialise to JSON
    
    // JSON Format:
    /*
     {
     "index" : {
     "Protection" : ""
     "Account" : ""
     "Access Control : "
     "Creation Time" : ""
     "Entitlement Group" : ""
     "Service" : ""
     "Modified Time" : ""
     "Data" : ""
     },
     }
     */
    
    NSMutableDictionary *processedKeychainItems = [[NSMutableDictionary alloc] init];
    NSDictionary *keychainItemDictionary = [[NSDictionary alloc] init];
    NSInteger keychainItemIndex = 0;
    
    for (keychainItemDictionary in keychainDictionariesArray) {
        // Build dictionary keychainItem from each dictionary in keychainDictionariesArray
        
        NSMutableDictionary *keychainItem = [[NSMutableDictionary alloc] init];
        // Temp dictionary to hold individual keychain items before being added to processedKeychainItems
        
        [keychainItem setObject:mapkSecAttrAccessibleValues([keychainItemDictionary
                                                             objectForKey:(id)kSecAttrAccessible])
                         forKey:@"Protection"];
        
        [keychainItem setObject:convertNSDataToNSString([keychainItemDictionary
                                                         objectForKey:(id)kSecAttrAccount])
                         forKey:@"Account"];
        
        [keychainItem setObject:parseSecAccessControlObject([keychainItemDictionary
                                                             objectForKey:(id) kSecAttrAccessControl])
                         forKey:@"Access Control"];
        
        [keychainItem setObject:[NSString stringWithFormat:@"%@", [keychainItemDictionary
                                                                   objectForKey:(id)kSecAttrCreationDate]]
                         forKey:@"Creation Time"];
        
        [keychainItem setObject:[NSString stringWithFormat:@"%@", [keychainItemDictionary
                                                                   objectForKey:(id)kSecAttrAccessGroup]]
                         forKey:@"Entitlement Group"];
        
        [keychainItem setObject:convertNSDataToNSString([keychainItemDictionary
                                                         objectForKey:(id)kSecAttrService])
                         forKey:@"Service"];
        
        [keychainItem setObject:[NSString stringWithFormat:@"%@", [keychainItemDictionary
                                                                   objectForKey:(id)kSecAttrModificationDate]]
                         forKey:@"Modified Time"];
        
        [keychainItem setObject:encodeDataValue([keychainItemDictionary
                                                 objectForKey:(id)kSecValueData])
                         forKey:@"Data"];
        
        
        [processedKeychainItems setObject:keychainItem
                                   forKey:[NSString stringWithFormat:@"%li", (long)keychainItemIndex++]];
        // Add keychainItem dictionary to processedKeychainItems Dictionary
        
    }
    
    NSError* error = nil;
    NSData* json = nil;
    
    json = [NSJSONSerialization dataWithJSONObject:processedKeychainItems options:NSJSONWritingPrettyPrinted error:&error];
    // Convert processedKeychainItems dictionary to JSON
    
    if (json != nil && error == nil) {
        // If NSJSONSerialization returns no error and some data
        return json;
    }
    else {
        // If NSJSONSerialization an error or no data
        return nil;
    }
}


+ (NSString *)dumpKeychainItems
{
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    // Dictionary that describes SecItemCopyMatching search
    
    NSMutableArray *queryResult = [[NSMutableArray alloc] init];
    // Array for returned Keychain item dictionaries
    // Each item is returned as a dictionary
    
    NSString *eachConstant = [[NSString alloc] init];
    // Init string to hold accessibility attribute
    
    OSStatus status = -1;
    // Setup OSStatus return code
    
    NSArray *kSecAttrAccessibleValues = @[
                                          (NSString *)kSecAttrAccessibleAfterFirstUnlock,
                                          (NSString *)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
                                          (NSString *)kSecAttrAccessibleAlways,
                                          (NSString *)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                          (NSString *)kSecAttrAccessibleAlwaysThisDeviceOnly,
                                          (NSString *)kSecAttrAccessibleWhenUnlocked,
                                          (NSString *)kSecAttrAccessibleWhenUnlockedThisDeviceOnly];
    // Array holding possible kSecAttrAccessible values
    
    for (eachConstant in kSecAttrAccessibleValues) {
        // For each kSecAttrAccessible type create a query requesting
        // all accessible Keychain items of type kSecClassGenericPassword
        // Return the attributes and data of each item
        
        [query setObject:   (id)kSecClassGenericPassword
                  forKey:   (id)kSecClass];
        // Query for  generic password items
        
        [query setObject:   eachConstant
                  forKey:   (id<NSCopying>)(kSecAttrAccessible)];
        // Accessibility attribute of item
        
        [query setObject:   (id)kSecMatchLimitAll
                  forKey:   (id)kSecMatchLimit];
        // Maximum number of results to return
        
        [query setObject:   (id)kCFBooleanTrue
                  forKey:   (id)kSecReturnAttributes];
        // Return unencrypted dictionary (type CFDictionaryRef) of item attributes
        
        [query setObject:   (id)kCFBooleanTrue
                  forKey:   (id)kSecReturnData];
        // Return a CFDataRef object of item data
        
        
        CFTypeRef results = nil;
        // Setup object for SecItemCopyMatching to store results
        
        status = SecItemCopyMatching((CFDictionaryRef)query, &results);
        // Search for items matching query
        
        if (status == errSecSuccess) {
            // status = 0 on success
            
            [queryResult addObjectsFromArray: (__bridge NSArray *)results];
            // Add returned data into Dictionary returnedKeyChainItems from results
            
        }
    }
    
    
    if ([queryResult count] != 0) {
        // If at least one Keychain item found
        
        NSData *json = convertToJSON(queryResult);
        // Convert array of Keychain items to JSON
        
        if (json == nil) {
            // convertToJSON returns nill if NSJSONSerialization
            // returns an error or produces no data
            return (@"NSJSONSerialization Error!");
        }
        
        NSString *keychainItemsAsJSONString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        // Convert json to NSString object
        
        return keychainItemsAsJSONString;
        //  Dictionary return finalKeychainItems array
        
    } else {
        
        NSString *statusString = [NSString stringWithFormat:@"OSStatus: %i", (int)status];
        return statusString;
        // If no data in returnedKeyChainItems return OSStatus code
    }
}


@end
