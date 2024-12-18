# How to self-sign the code

First create your certificate as described [here](https://stackoverflow.com/questions/58356844/what-are-the-ways-or-technologies-to-sign-an-executable-application-file-in-mac). Because Glance consists of two executables, both have to be (re)signed like this:

```bash
cd Glance.app
codesign --force --sign my-codesign-cert Contents/Macos/Glance
codesigh --force --sign my-codesign-cert Contents/PlugIns/QLPlugin.appex
```
