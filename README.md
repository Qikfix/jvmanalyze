# jvmanalyze
Script to analyze application server JVM's, with heap size information

Using this script, will be possible collect some information from your JVM's to analyze in another tool, like libre office, so will be easy create some graphs, use auto filters, etc.

To use this script, will be necessary

- Install the package java-1.7.0-openjdk-devel
- Enable the repo rhel-x86_64-server-6-debuginfo and execute the command below: 
  * # debuginfo-install java-1.7.0-openjdk
- Create a new contrab entry (hour) to execute this script.

Sample of fields that script will capture

```
Heap Configuration:
   MinHeapFreeRatio = 40
   MaxHeapFreeRatio = 70
   MaxHeapSize      = 1073741824 (1024.0MB)
   NewSize          = 1310720 (1.25MB)
   MaxNewSize       = 17592186044415 MB
   OldSize          = 5439488 (5.1875MB)
   NewRatio         = 2
   SurvivorRatio    = 8
   PermSize         = 21757952 (20.75MB)
   MaxPermSize      = 174063616 (166.0MB)
   G1HeapRegionSize = 0 (0.0MB)

Heap Usage:
New Generation (Eden + 1 Survivor Space):
   capacity = 80871424 (77.125MB)
   used     = 32660784 (31.147750854492188MB)
   free     = 48210640 (45.97724914550781MB)
   40.38606269626216% used
Eden Space:
   capacity = 71892992 (68.5625MB)
   used     = 25608168 (24.421852111816406MB)
   free     = 46284824 (44.140647888183594MB)
   35.61983899626823% used
From Space:
   capacity = 8978432 (8.5625MB)
   used     = 7052616 (6.725898742675781MB)
   free     = 1925816 (1.8366012573242188MB)
   78.55064225022811% used
To Space:
   capacity = 8978432 (8.5625MB)
   used     = 0 (0.0MB)
   free     = 8978432 (8.5625MB)
   0.0% used
tenured generation:
   capacity = 178978816 (170.6875MB)
   used     = 41404936 (39.48682403564453MB)
   free     = 137573880 (131.20067596435547MB)
   23.133986985364793% used
Perm Generation:
   capacity = 33226752 (31.6875MB)
   used     = 33149480 (31.613807678222656MB)
   free     = 77272 (0.07369232177734375MB)
   99.76744040464743% used
```

Hope help you.

Waldirio
