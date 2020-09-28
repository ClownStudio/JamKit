# JamKit

整理的一份Xcode 11 Build Settings推荐配置，对于减小包大小和性能优化有一定帮助。

一，Build Options

Debug Information Format

Debug：DWARF
Release：DWARF with dSYM file
Enable Bitcode = Yes

二，Deployment

Deployment Postprocessing

Deployment Postprocessing是Deployment部分的开关，建议Release模式下设置为Yes，Debug设置为No。

Strip Debug Symbols During copy = Yes

Strip Linked Product = Yes

Strip Style = All Symbols

Strip Swift Symbols = Yes

三，Linking

Dead Code Stripping = Yes

四，Apple Clang - Code Generation

Debug Information Level = Compiler Default

Generate Debug Symbols = Yes

Link-Time Optimization

Debug：No
Release：Incremental
Optimization Level

Debug：None
Release：Fastest、Smallest[-Os]
Symbols Hidden by Default = Yes

五，Swift Compiler - Code Generation

Compilation Mode

Debug：Incremental-增量编译
Release：Whole Module-全模块编译
Optimization Level

Debug：No Optimization
Release：Optimize for Speed
