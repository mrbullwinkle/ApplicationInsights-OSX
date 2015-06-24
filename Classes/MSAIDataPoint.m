#import "MSAIDataPoint.h"
#import "MSAIOrderedDictionary.h"

/// Data contract class for type DataPoint.
@implementation MSAIDataPoint

/// Initializes a new instance of the class.
- (instancetype)init {
  if(self = [super init]) {
    self.kind = MSAIDataPointType_measurement;
  }
  return self;
}

///
/// Adds all members of this class to a dictionary
/// @param dictionary to which the members of this class will be added.
///
- (MSAIOrderedDictionary *)serializeToDictionary {
  MSAIOrderedDictionary *dict = [super serializeToDictionary];
  if(self.name != nil) {
    [dict setObject:self.name forKey:@"name"];
  }
  dict[@"kind"] = @((int) self.kind);
  if(self.value != nil) {
    dict[@"value"] = self.value;
  }
  if(self.count != nil) {
    dict[@"count"] = self.count;
  }
  if(self.min != nil) {
    dict[@"min"] = self.min;
  }
  if(self.max != nil) {
    dict[@"max"] = self.max;
  }
  if(self.stdDev != nil) {
    dict[@"stdDev"] = self.stdDev;
  }
  return dict;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [self init];
  if(self) {
    self.name = [coder decodeObjectForKey:@"self.name"];
    self.kind = (MSAIDataPointType) [coder decodeIntForKey:@"self.kind"];
    self.value = [coder decodeObjectForKey:@"self.value"];
    self.count = [coder decodeObjectForKey:@"self.count"];
    self.min = [coder decodeObjectForKey:@"self.min"];
    self.max = [coder decodeObjectForKey:@"self.max"];
    self.stdDev = [coder decodeObjectForKey:@"self.stdDev"];
  }

  return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
  [coder encodeObject:self.name forKey:@"self.name"];
  [coder encodeInt:self.kind forKey:@"self.kind"];
  [coder encodeObject:self.value forKey:@"self.value"];
  [coder encodeObject:self.count forKey:@"self.count"];
  [coder encodeObject:self.min forKey:@"self.min"];
  [coder encodeObject:self.max forKey:@"self.max"];
  [coder encodeObject:self.stdDev forKey:@"self.stdDev"];
}


@end
