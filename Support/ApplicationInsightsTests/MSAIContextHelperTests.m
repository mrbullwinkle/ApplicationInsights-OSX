#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

#import "MSAIHelper.h"
#import "MSAISession.h"
#import "MSAIUser.h"
#import "MSAIContextHelper.h"
#import "MSAIContextHelperPrivate.h"
#import "MSAIPersistence.h"
#import "MSAIPersistencePrivate.h"
#import "MSAITestsDependencyInjection.h"
#import <AppKit/AppKit.h>

@interface MSAIContextHelperTests : MSAITestsDependencyInjection

@property (strong) MSAIContextHelper *sut;

@end

@implementation MSAIContextHelperTests

- (void)setUp {
  [super setUp];
  
  self.sut = [MSAIContextHelper new];
}

- (void)teardown {
  [super tearDown];
}

#pragma mark - User Tests

- (void)testNewUser {
  MSAIUser *newUser = [self.sut newUser];
  XCTAssertNotNil(newUser);
  XCTAssertEqual(newUser.userId.length, 36U);
}

- (void)testSetUserWithConfigurationBlock {
  self.sut = OCMPartialMock(self.sut);
  
  NSString *testUserId = @"testUserId";
  NSString *testAccountId = @"testAccountId";
  
  [self.sut setUserWithConfigurationBlock:^(MSAIUser *user) {
    user.userId = testUserId;
    user.accountId = testAccountId;
  }];

  OCMVerify([self.sut setCurrentUser:[OCMArg checkWithBlock:^BOOL(MSAIUser *user) {
    if (([user.userId isEqualToString:testUserId]) && ([user.accountId isEqualToString:testAccountId])) {
      return YES;
    }
    return NO;
  }]]);
 
  // Test changing only one attribute
  NSString *testAccountId2 = @"testAccountId2";
  
  [self.sut setUserWithConfigurationBlock:^(MSAIUser *user) {
    user.accountId = testAccountId2;
  }];
  
  OCMVerify([self.sut setCurrentUser:[OCMArg checkWithBlock:^BOOL(MSAIUser *user) {
    if (([user.userId isEqualToString:testUserId]) && ([user.accountId isEqualToString:testAccountId2])) {
      return YES;
    }
    return NO;
  }]]);
}

#pragma mark - Session Tests

#pragma mark Test Automtic Session Management

- (void)testRegisterObserversOnInit {
  self.mockNotificationCenter = mock(NSNotificationCenter.class);
  
  self.sut = [MSAIContextHelper new];
  
  [verify((id)self.mockNotificationCenter) addObserverForName:NSApplicationDidResignActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
  [verify((id)self.mockNotificationCenter) addObserverForName:NSApplicationWillBecomeActiveNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
  [verify((id)self.mockNotificationCenter) addObserverForName:NSApplicationWillTerminateNotification object:nil queue:NSOperationQueue.mainQueue usingBlock:(id)anything()];
}

#pragma mark Test Manual Session Management

- (void)testRenewSessionWithId {
  self.sut = OCMPartialMock(self.sut);
  
  NSString *testId = @"1337";
  [self.sut renewSessionWithId:testId];
  
  OCMVerify([self.sut sendSessionStartedNotificationWithUserInfo:[OCMArg checkWithBlock:^BOOL(NSDictionary *userInfo) {
    MSAISession *session = userInfo[kMSAISessionInfo];
    if ([session.sessionId isEqualToString:testId])  {
      return YES;
    }
    return NO;
  }]]);
}

#pragma mark -

- (void)testUnixTimestampFromDate {
  NSString *timestamp = [self.sut unixTimestampFromDate:[NSDate dateWithTimeIntervalSince1970:42]];
  XCTAssertEqualObjects(timestamp, @"42");
}

- (void)testSessionHelperNotifications {
  self.sut = OCMPartialMock([MSAIContextHelper new]);

  OCMExpect([self.sut updateDidEnterBackgroundTime]);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NSApplicationDidResignActiveNotification object:nil]];
  
  OCMExpect([self.sut startNewSessionIfNeeded]);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NSApplicationWillBecomeActiveNotification object:nil]];
  
  OCMExpect([self.sut endSession]);
  [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:NSApplicationWillTerminateNotification object:nil]];
  
  OCMVerifyAllWithDelay((id)self.sut, 0.1);
}

#pragma mark Helper

- (MSAISession *)sessionWithId:(NSString *)sessionId {
  MSAISession *session = [MSAISession new];
  session.sessionId = sessionId;
  session.isNew = @"false";
  session.isFirst = @"false";
  
  return session;
}

- (MSAIUser *)newUserWithId:(NSString *)userId {
  return ({ MSAIUser *user = [MSAIUser new];
    user.userId = userId ?: msai_appAnonID();
    user;
  });
}

@end
