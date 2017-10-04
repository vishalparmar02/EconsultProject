//
//  API_Defines.h
//  pro
//
//  Created by Shashank Patel on 16/09/16.
//  Copyright © 2016 iOS. All rights reserved.
//

#ifndef API_Defines_h
#define API_Defines_h

#import <AFNetworking/AFNetworking.h>
#import "NSUserDefaults-macros.h"
#import "NSArray+JSON.h"
#import "NSDictionary+JSON.h"
#import "NSString+JSON.h"

#ifndef DEBUG
#define DEBUG 0
#endif

#define TARGET_NAME [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"]
#define TEST_VERSION [TARGET_NAME isEqualToString:@"Consult"]


#define PUBLISH_KEY     TEST_VERSION ? CONSULT_PUBLISH_KEY : (DEBUG ? DEBUG_PUBLISH_KEY : RELEASE_PUBLISH_KEY)
#define SUB_KEY         TEST_VERSION ? CONSULT_SUB_KEY : (DEBUG ? DEBUG_SUB_KEY : RELEASE_SUB_KEY)


//#define PUBLISH_KEY                 @"pub-c-8a2b71e5-abba-4100-a82f-0b711a688164"
//#define SUB_KEY                     @"sub-c-c445e564-7c05-11e7-8bd1-0619f8945a4f"

#define CONSULT_PUBLISH_KEY                 @"pub-c-557f4390-6625-4bbf-af0b-704cbd9f9730"
#define CONSULT_SUB_KEY                     @"sub-c-d2ee5a6a-a80b-11e7-81e2-967c19df6324"

#define DEBUG_PUBLISH_KEY                   @"pub-c-457a7ff0-70b4-46ed-8d40-4d21fabeaf01"
#define DEBUG_SUB_KEY                       @"sub-c-0e556e0a-8e25-11e7-b947-aae040ae6b45"

#define RELEASE_PUBLISH_KEY                 @"pub-c-8a2b71e5-abba-4100-a82f-0b711a688164"
#define RELEASE_SUB_KEY                     @"sub-c-c445e564-7c05-11e7-8bd1-0619f8945a4f"


#define OUT_DATE_FORMAT             @"dd LLL yyyy HH:mm a"
#define IN_DATE_FORMAT              @"yyyy-LL-dd'T'HH:mm:ssZ"

#define CURRENT_USER_KEY            @"current_user"

#define API_BASE_URL                TEST_VERSION ? @"https://econsult.jshealthtech.com/api" : @"https://app.drateetsharma.com/api"

#define REGISTER_PHONE_END_POINT    @"login"
#define VERIFY_PHONE_END_POINT      @"verify"
#define GET_CLINICS                 @"getAllClinics"
#define ADD_CLINICS                 @"addClinic"
#define UPDATE_CLINICS              @"updateClinicById/%@"
#define DELETE_CLINIC               @"deleteClinic/%@/%@"


#define GET_SCHEDULES               @"schedules"
#define ADD_SCHEDULE                @"schedules/add"
#define UPDATE_SCHEDULE             @"schedules/%@"
#define DELETE_SCHEDULE             @"schedules/%@/%@"

#define GET_SLOTS                   @"slots"
#define ADD_APPOINTMENT             @"appointments/add"

#define GET_REPORTS                 @"patient/getReports"
#define ADD_REPORT                  @"patient/addReports/"
#define UPDATE_PROFILE_PIC          @"profilePic"

#define EDIT_DOCTOR_PROFILE         @"doctor/editProfile"
#define EDIT_PATIENT_PROFILE        @"patient/editProfile"

#define GET_PATIENTS                @"doctor/patientInfo"
#define GET_STAFF                   @"doctor/staffInfo/"
#define ADD_STAFF                   @"doctor/addStaff"
#define DELETE_STAFF                @"/staff/%@/"

#define GET_MY_PATIENTS             @"users/%@/patients"
#define SEARCH_PATIENTS             @"doctor/searchPatient"
#define ADD_PATIENT                 @"addPatient"

#define GET_APPOINTMENTS            @"appointments"
#define GET_CLASHING_APPOINTMENTS   @"conflictAppointment"
#define GET_BOOKED_APPOINTMENTS     @"appointments/log"

#define PATIENT_APPOINTMENTS        @"patientAppointments"
#define CANCEL_APPOINTMENT          @"cancelAppointment"
#define UPDATE_APPOINTMENT          @"changeAppointment"
#define MARK_DONE_APPOINTMENT       @"appointments/done"

#define DOCTOR_PROFILE_END_POINT    @"doctor/profile"
#define PATIENT_PROFILE_END_POINT   @"patient/profile"

#define UPDATE_TOKEN_END_POINT      @"mobile/private/v1/people/%@"
#define CATEGORIES_LIST_END_POINT   @"mobile/private/v1/categories"
#define COMPANIES_LIST_END_POINT    @"private/v1/companies/%@"
#define PRODUCTS_LIST_END_POINT     @"private/v1/products/%@"
#define ORDERS_LIST_END_POINT       @"private/v1/orders"
#define ORDER_ITEMS_END_POINT       @"private/v1/order-items/%@"

#define SPLASH_END_POINT            @"public/v1/info/home"

#define LOYALTIES_END_POINT         @"private/v1/loyalties"
#define REDEEM_LOYALTIES_END_POINT  @"private/v1/rewards/%@"
#define BEACON_LIST                 @"private/v1/list-types/BEACON_UUID"

#define BILLS_LIST_END_POINT        @"private/v1/bills"
#define BILL_ITEMS_END_POINT        @"private/v1/bill-items/%@"
#define BILL_REVIEW_END_POINT       @"private/v1/bills/ratings-reviews/%@"

#define APP_REVIEW_END_POINT        @"private/v1/app/ratings-reviews"

#define CITIES_END_POINT            @"private/v1/cities"

#define POINTS_END_POINT            @"private/v1/people/point"
#define POINTS_DETAILS_END_POINT    @"private/v1/person-points"

#define CREATE_POINT_END_POINT      @"private/v1/person-points/%@/%ld/%ld"

#define BEACON_COMPANY_END_POINT    @"private/v1/beacons/%@/%ld/%ld"
#define BEACON_OFFERS_END_POINT     @"private/v1/offers/beacons/%@/%ld/%ld"
#define SALE_END_POINT              @"private/v1/sales"
#define SALE_PRODUCTS_END_POINT     @"private/v1/offers/sales/%@"
#define BEACON_ENTER_END_POINT      @"private/v1/people/enter/%@/%ld/%ld"
#define PLACE_ORDER_END_POINT       @"private/v1/orders/%@?seat=%@"

#endif /* API_Defines_h */
