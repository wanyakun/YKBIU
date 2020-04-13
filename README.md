### 项目简介

YKBIU 是一个使用 Ruby 编写的iOS远程依赖配置安装工具，用来获取服务端配置的CocoaPods依赖，并自动安装。 从而解决Podfile中频繁修改依赖组件，或者组件的版本。 特别适合项目发展到一定程度形成组件化，Podfile中依赖的组件越多，越适合使用YKBIU。

### 为什么有这个项目

公司App经过几年的迭代发展，目前已经完全进入组件化开发的方式，项目中已经有将近上百个组件，如果这些组件的依赖都写到Podfile中，里面将有将近上百条类似`Pod 'xxxx'`的内容存在，而且在多人同时修改的情况也容易形成冲突。为此我们开发了移动应用管理系统，用来线上管理应用、管理组件、管理应用版本对组件的依赖。线上系统中配置的依赖需要能够在执行`pod install`的时候自动被安装，此项目就是为了解决这个问题而产生的，它是整个移动应用管理系统中很重要的一部分。

### 安装

将下面这行代码添加到您应用目录下的Gemfile中

```ruby
gem 'YKBIU'
```

然后执行:

    $ bundle

或者用下面的命令进行安装:

    $ gem install YKBIU

### 使用

1. 在Podfile中引入依赖 `require 'YKBIU'`

2. 删除所有可以通过服务端配置的依赖代码如： pod 'xxxxx'

3. 添加`makeup_pods(url, params, method, ignores)`来获取依赖并进行依赖安装， 参数中含义解释如下：

    - url： 为获取json依赖内容的地址，通过url接口请求得到Podfile中的依赖，来安装依赖内容

    - params为url的请求参数

    - method为网络请求的方式，支持GET和POST

    - ignores为忽略依赖的数组，在执行依赖安装的过程中会判断依赖名称是否在忽略的数组中，忽略数组一般用来调试本地组件或者指定git地址使用，放弃从配置中安装依赖，再在Podfile中添加本地组件或者git地址。

4. 服务端配置返回的json内容格式如下：

```json
{
    "result": 0,
    "codeMsg": "",
    "resultMessage": "响应成功",
    "content": [
        {
            "dependencyName": "AFNetworking",
            "componentVersion": "~> 3.2.0"
        },
        {
            "dependencyName": "YYModel",
            "componentVersion": "1.0.4"
        },
        {
            "dependencyName": "YYText",
            "componentVersion": "1.0.5"
        },
        {
            "dependencyName": "Masonry",
            "gitUrl": "https://github.com/SnapKit/Masonry.git"
        },
        {
            "dependencyName": "MBProgressHUD",
            "gitUrl": "https://github.com/jdg/MBProgressHUD.git",
            "componentBranch": "master"
        },
        {
            "dependencyName": "UICKeyChainStore",
            "gitUrl": "https://github.com/kishikawakatsumi/UICKeyChainStore.git",
            "tag": "v2.1.1"
        }
    ]
}
```

5. 依赖安装过程优先安装指定`componentVersion`的版本，如果返回的有`componentVersion`字段，会安装此字段设置的版本进行安装，否则安装giturl、tag，componentBranch等信息进行依赖安装

实例：

```ruby
source 'http://github.com/CocoaPods/Specs.git'

platform :ios, "8.0"
inhibit_all_warnings!
workspace 'Demo.xcworkspace'

target 'Demo' do
  project 'Demo/Demo.xcodeproj'

  require 'YKBIU'

  # 包含忽略依赖数组，如['YYText']
  makeup_pods('https://raw.githubusercontent.com/wanyakun/resources/master/dependency.json', {'applicationVersionId' => '4', 'pageSize' => '99999'}, 'GET', ['YYText'])
  pod 'YYText', :git => 'https://github.com/ibireme/YYText.git'

  # 不包含忽略数字键
  # makeup_pods('https://raw.githubusercontent.com/wanyakun/resources/master/dependency.json', {'applicationVersionId' => '4', 'pageSize' => '99999'}, 'GET')
end
```

### 项目结构

整个项目结构如下：

```
YKBIU/
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── README.md
├── Rakefile
├── bin
│   ├── console
│   └── setup
├── lib
│   ├── YKBIU
│   │   └── version.rb
│   └── YKBIU.rb
├── YKBIU.gemspec
└── test
    ├── Demo
    │   ├── Demo
    │   │   ├── AppDelegate.h
    │   │   ├── AppDelegate.m
    │   │   ├── Assets.xcassets
    │   │   │   ├── AppIcon.appiconset
    │   │   │   │   └── Contents.json
    │   │   │   └── Contents.json
    │   │   ├── Base.lproj
    │   │   │   ├── LaunchScreen.storyboard
    │   │   │   └── Main.storyboard
    │   │   ├── Info.plist
    │   │   ├── ViewController.h
    │   │   ├── ViewController.m
    │   │   └── main.m
    │   ├── Demo.xcodeproj
    │   │   ├── project.pbxproj
    │   │   └── xcuserdata
    │   │       └── wanyakun.xcuserdatad
    │   │           └── xcschemes
    │   │               └── xcschememanagement.plist
    │   └── DemoTests
    │       ├── DemoTests.m
    │       └── Info.plist
    ├── Demo.xcworkspace
    │   ├── contents.xcworkspacedata
    │   ├── xcshareddata
    │   │   └── IDEWorkspaceChecks.plist
    │   └── xcuserdata
    │       └── wanyakun.xcuserdatad
    │           └── UserInterfaceState.xcuserstate
    ├── Gemfile
    ├── Gemfile.lock
    ├── Podfile
    ├── Podfile.lock
    └── dependency.json
```

项目编译使用到Ruby 2.5.1, 并使用Rake进行构建、打包和发布。

### 开发

克隆代码后进入项目目录，执行`bin/setup`来安装依赖。

想要在本机安装此gem，可以执行`bundle exec rake install`。如果想要发布一个新版本，先更新`version.rb`里的版本号，然后执行`bundle exec rake release`，这个操作将为这个版本创建一个git tag，并且推送git提交和tags，而且会推送`.gem`文件到[rubygems.org](https://rubygems.org)。

### 联系

我们的邮箱地址： wanyakun@ppdai.com, 欢迎来信联系。

### 开源许可协议

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
