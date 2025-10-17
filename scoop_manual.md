#### 1. 安装Scoop

1. 确定`PowerShell`允许脚本运行，否则运行

   ```bash
   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. 以用户身份打开终端，运行

   ```bash
    irm get.scoop.sh -outfile 'install.ps1'
    .\install.ps1 -ScoopDir 'D:\software\Scoop' -ScoopGlobalDir 'D:\software\GlobalScoopApps'
   ```

3. 验证安装是否成功，运行

   ```bash
    scoop help
   ```

#### 2. 换源

设置`Gitee`源

```bash
scoop config SCOOP_REPO https://gitee.com/scoop-installer/scoop
scoop update
```

设置南京大学开源镜像站的仓库源

```bash
scoop bucket add extras https://mirrors.nju.edu.cn/git/scoop-extras.git/
scoop bucket add java https://mirrors.nju.edu.cn/git/scoop-java.git/
scoop bucket add versions https://mirrors.nju.edu.cn/git/scoop-versions.git/
```

如果有稳定的`Github`连接环境，也可使用原有的`Github`源。

#### 3. 配置安装软件

```bash
scoop update
scoop install sudo -g
scoop install aria2
scoop checkup
```

根据 `warning`补全环境，通常需要安装`git`、`7zip`、`innounp`、`wixtoolset`，可以考虑全局安装。

安装常用软件

```bash
###火狐浏览器
scoop install  firefox 
###Listary,everything
scoop install listary everything
###GNU工具，可以考虑全局安装
scoop install gcc make cmake python  openssh miktex  pandoc sass
###微软官方环境，可以考虑全局安装
scoop install vcredist windowsdesktop-runtime-lts
###实用工具
scoop install office-tool-plus typora vscode sourcegit zeal zotero dism++ sumatrapdf snipaste pdftk honeyview ImageMagick GraphicsMagick ghostscript powertoys foxmail syncthing
###娱乐工具
scoop install wechat qbittorrent-enhanced  aliyun aimp potplayer translucenttb
```

#### 4. Scoop常用命令

```bash
scoop help #查看帮助
scoop help <command> #查看某个命令的帮助

scoop update #更新scoop自身和软件列表
scoop update * #更新scoop和所有软件
scoop hold <app> #禁用某应用更新
scoop unhold <app> #允许某应用更新

scoop install <app>
scoop uninstall <app>
scoop update <app>

scoop list #列出通过scoop安装的所有软件
scoop bucket list #列出已添加的软件仓库
scoop bucket known #列出当前源可添加的软件仓库
scoop bucket add <bucketname> <url> #从某个远程git仓库添加
scoop search <app> #在软件源中搜索软件包
scoop status #检查哪些软件有更新
scoop cleanup <app> #清除软件旧版本
```

#### 5. 创建并维护自己的软件仓库

1. 从`scoop`官方提供的模版仓库创建仓库

   ```bash
   ###安装github cli并登录github账户
   scoop install gh
   gh auth login
   ###从模板创建仓库并克隆到本地
   gh repo create my-bucket --template ScoopInstaller/BucketTemplate --public --description "A third party scoop bucket" --clone <path>
   ```

2. 根据`README.md`修改仓库设置和模板文件

3. 编写`manifest`

   `scoop`通过读取软件对应的json文件来获取并安装软件，因此维护自定义`bucket`的关键就在于编写`manifest`

   | 属性           | 描述                                                         | 是否必需 |
   | -------------- | ------------------------------------------------------------ | -------- |
   | `version`      | 软件版本，通常匹配`^[\\w\\.\\-+_]+$`                         | 是       |
   | `description`  | 软件描述，最好避开软件名称                                   | 是       |
   | `homepage`     | 软件发布主页                                                 | 是       |
   | `license`      | 许可证标识符                                                 | 是       |
   | `notes`        | 安装完成时会显示的注释或提示，通常提示安装注册表             | 否       |
   | `architecture` | 多架构应用配置，允许32位、64位和ARM64系统进行不同配置        | 否       |
   | `url`          | 软件下载地址，如果是压缩包无需修改，如果是`.exe`需要加上后缀`#dl.7z` | 是       |
   | `hash`         | 对下载的文件进行哈希校验所需的`hash`值，支持`MD5`、`SHA1`、`SHA256`和`SHA512` | 是       |
   | `depends`      | 应用安装所需的依赖项，在安装时会自动安装                     | 否       |
   | `bin`          | 软件的可执行文件路径，`scoop`会将其添加到`shims`文件夹       | 是       |
   | `shortcuts`    | 添加到开始菜单中的快捷方式，包含一个必要的可执行文件/标签对  | 否       |
   | `pre_install`  | 安装前的准备，通常用于嵌套压缩文件夹或`innounp`解包          | 否       |
   | `installer`    | 安装器或安装脚本                                             | 否       |
   | `post_install` | 安装后要做的，通常用于创建注册表文件                         | 否       |
   | `uninstaller`  | 卸载器或卸载脚本                                             | 否       |
   | `env_add_path` | 将安装目录下的某个目录添加到用户路径或系统路径               | 否       |
   | `env_set`      | 为用户或系统设置环境变量                                     | 否       |
   | `persist`      | 卸载或更新应用后需要保留的数据，通常是安装目录下的数据文件夹 | 否       |
   | `checkver`     | 版本检查，通过正则表达式检查版本更新                         | 否       |
   | `autoupdate`   | 配置自动更新，如果有不同的`architecture`属性需要配置相应的架构版本 | 否       |

   

   > [!NOTE]
   >
   > 一些第三方`bucket`的哈希校验经常出错，在自己编写`manifest`时，如果信任下载来源，可将`hash`属性设置为`skip`来跳过哈希校验。

   > [!NOTE]
   >
   > 特别的，可以通过`scoop create <url>`快速创建一个只含`url`和`version`的`manifest`

   示例：`7zip`的官方`manifest`

   ```json
   {
       "version": "25.01",
       "description": "A multi-format file archiver with high compression ratios",
       "homepage": "https://www.7-zip.org/",
       "license": "LGPL-2.1-or-later",
       "notes": "Add 7-Zip as a context menu option by running: \"$dir\\install-context.reg\"",
       "architecture": {
           "64bit": {
               "url": "https://www.7-zip.org/a/7z2501-x64.msi",
               "hash": "e7eb0b7ed5efa4e087b7b17f191797f7af5b7f442d1290c66f3a21777005ef57",
               "extract_dir": "Files\\7-Zip"
           },
           "32bit": {
               "url": "https://www.7-zip.org/a/7z2501.msi",
               "hash": "dce9e456ace76b969fe0fe4d228bf096662c11d2376d99a9210f6364428a94c4",
               "extract_dir": "Files\\7-Zip"
           },
           "arm64": {
               "url": "https://www.7-zip.org/a/7z2501-arm64.exe",
               "hash": "6365c7c44e217b9c1009e065daf9f9aa37454e64315b4aaa263f7f8f060755dc",
               "pre_install": [
                   "$7zr = Join-Path $env:TMP '7zr.exe'",
                   "Invoke-WebRequest https://www.7-zip.org/a/7zr.exe -OutFile $7zr",
                   "Invoke-ExternalCommand $7zr @('x', \"$dir\\$fname\", \"-o$dir\", '-y') | Out-Null",
                   "Remove-Item \"$dir\\Uninstall.exe\", \"$dir\\*-arm64.exe\", $7zr"
               ]
           }
       },
       "post_install": [
           "$7zip_root = \"$dir\".Replace('\\', '\\\\')",
           "'install-context.reg', 'uninstall-context.reg' | ForEach-Object {",
           "    $content = Get-Content \"$bucketsdir\\main\\scripts\\7-zip\\$_\"",
           "    $content = $content.Replace('$7zip_root', $7zip_root)",
           "    if ($global) {",
           "       $content = $content.Replace('HKEY_CURRENT_USER', 'HKEY_LOCAL_MACHINE')",
           "    }",
           "    Set-Content \"$dir\\$_\" $content -Encoding Ascii",
           "}"
       ],
       "bin": [
           "7z.exe",
           "7zFM.exe",
           "7zG.exe"
       ],
       "shortcuts": [
           [
               "7zFM.exe",
               "7-Zip"
           ]
       ],
       "persist": [
           "Codecs",
           "Formats"
       ],
       "checkver": {
           "url": "https://www.7-zip.org/download.html",
           "regex": "Download 7-Zip ([\\d.]+) \\(\\d{4}-\\d{2}-\\d{2}\\)"
       },
       "autoupdate": {
           "architecture": {
               "64bit": {
                   "url": "https://www.7-zip.org/a/7z$cleanVersion-x64.msi"
               },
               "32bit": {
                   "url": "https://www.7-zip.org/a/7z$cleanVersion.msi"
               },
               "arm64": {
                   "url": "https://www.7-zip.org/a/7z$cleanVersion-arm64.exe"
               }
           }
       }
   }
   
   ```

   `github`上的`musicfree`项目

   ```json
   {
       "version": "0.0.7",
       "description": "A free, cross-platform music player",
       "homepage": "https://musicfree.catcat.work/",
       "license": "GPL-3.0",
       "architecture": {
           "64bit": {
               "url": "https://github.com/maotoumao/MusicFreeDesktop/releases/download/v0.0.7/MusicFree-0.0.7-win32-x64-portable.zip",
               "hash": "SHA256:14d6520628f544339c773d7c915a2a8c809ceaf54a31fa5d4682ece78d9a3137"
           }
       },
       "installer": {
           "script": [
               "Expand-Archive -Path \"$dir\\$fname\" -DestinationPath \"$dir\" -Force",
               "$inner = Get-ChildItem -Path \"$dir\" -Filter \"*.zip\" | Where-Object { $_.FullName -ne \"$dir\\$fname\" } | Select-Object -First 1",
               "if ($inner) { Expand-Archive -Path $inner.FullName -DestinationPath \"$dir\" -Force }",
               "Remove-Item $inner.FullName -Force"
           ]
       },
       "bin": [
           "MusicFree.exe"
       ],
       "shortcuts": [
           [
               "MusicFree.exe",
               "MusicFree"
           ]
       ],
       "checkver": {
           "github": "https://github.com/maotoumao/MusicFreeDesktop"
       },
       "autoupdate": {
           "architecture": {
               "64bit": {
                   "url": "https://github.com/maotoumao/MusicFreeDesktop/releases/latest/download/MusicFree-$version-win32-x64-portable.zip"
               }
           }
       }
   }
   ```

   官方网站上的`xdiary`

   ```json
   {
       "version": "3",
       "description": "A simple and elegant calender desk.",
       "homepage": "https://www.xdiarys.com/",
       "license": "freeware",
       "architecture": {
           "64bit": {
               "url": "https://download.xdiarys.com/windows/xdiarys-green.7z",
               "hash": "sha256:8ebe0676571e22a745d046b261bb3c3353f9f9d760ae93549fe2f804310cb064"
           }
       },
       "bin": "desktopcal.exe",
       "shortcuts": [
           [
               "desktopcal.exe",
               "xDiary"
           ]
       ],
       "persist": [
           "data"
       ],
       "checkver": {
           "url": "https://www.xdiarys.com/download.html",
           "regex": "xdiarys-setup-v([\\d]).exe"
       },
       "autoupdate": {
           "architecture": {
               "64bit": {
                   "url": "https://download.xdiarys.com/windows/xdiarys-green.7z",
                   "hash": {
                       "url": "https://download.xdiarys.com/windows/xdiarys-green.7z.sha256",
                       "regex": "$sha256:([a-f0-9]{64})"
                   }
               }
           }
       }
   }
   
   ```

   > 1.  https://www.thisfaner.com/p/scoop/
   > 2.  https://deepwiki.com/ScoopInstaller/Scoop/4.1-manifest-structure
   > 3.  https://blog.csdn.net/it_rs/article/details/120479996
   > 4.  https://blog.csdn.net/gitblog_00897/article/details/152704300
   > 5.  https://spdx.org/licenses/
   > 6.  https://chat.deepseek.com/
