# ![SLNetwork](SLNetwork.png)

![Build Status](https://travis-ci.org/Alamofire/Alamofire.svg?branch=master)

![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)

![Platform](https://img.shields.io/cocoapods/p/Alamofire.svg?style=flat)

Elegant network abstraction layer in Swift.



- [Design](#Design)
- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#installation)
  - **Base -** [Target](##Target)  [Request](##Request)  [Download](##Download)  [Upload](##Upload)  [Decodable](##Decodable)
  - **Target** - [Target Config](##Target Config)
  - **Request** - [Data Request](##Data Request)
  - **Download** - [Download Request](##Download Request)  [Resume Download Request](##Resume Download Request)
  - **Upload** - [Upload Data](##Upload Data)  [Upload File](##Upload File)  [Upload InputStream](##Upload InputStream)  [Upload FormData](##Upload FormData)
  - **Progress** - [Progress](#Progress)
  - **Plugin** - [WillSend](##WillSend)  [DidReceive](##DidReceive)
  - **Response** - [Data Decodable](##Data Decodable)  [Data Keypath](##Data Keypath)

---

# Design

**Alamofire** and **Moya** are elegant Swift network frames. They each have their own advantages. When I use them, I always want to combine the advantages of both, make them easy to use and retain their original features. So I design the **SolarNetwork** framework.

Network(Target).WillSend.Request.Progress.DidReceive.Response



