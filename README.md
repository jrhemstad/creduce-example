# C-Reduce

Compiler bugs are tricky to isolate and diagnose. 
Oftentimes these bugs originally show up in large pieces of code that would be impractical to include in a compiler bug report. 
Creating a minimal reproducer is essential to a compiler bug report as well as for identifying potential workarounds. 
However, manually constructing a minimal reproducer from the original source code can be an incredibly laborious and time consuming process. 
[C-Reduce](https://embed.cs.utah.edu/creduce/) is a tool that helps automate the process of shrinking the original reproducing code into a much smaller file that still reproduces the issue of interest. 


