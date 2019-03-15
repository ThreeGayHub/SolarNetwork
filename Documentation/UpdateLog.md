## Release Log

#### 1.1.0

1. SLTatget: change baseURLString to optional.
2. SLRequest: add userInfo, requestLog; change originalRequest to public.
3. SLResponse: add statusCode, header, originData, dataString.

#### 1.2.0

1. SLReflection: change api:
   a. func toJSONObject() to var jsonObject
   b. func blackList() to var blackList
2. fix blackList not work issue