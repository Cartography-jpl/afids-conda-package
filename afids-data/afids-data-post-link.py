# In case we are on an older system with python 2 still. This will
# go away with time, but older systems might not have python 3 yet.
from __future__ import print_function
import os
import re

prefix = os.environ["PREFIX"]
fname = "%s/data/cspice/geocal.ker" % prefix
t = open(fname).read()

spice_path = prefix + "/data/cspice"
# Break prefix up into at most 80 characters
chunk = 70
t2 = ["   '" + spice_path[i:i+chunk] + "+'"
      for i in range(0, len(spice_path), chunk)]
t2[-1] = str.replace(t2[-1], "+'", "'")
t3 = "PATH_VALUES =(\n" + "\n".join(t2) + "\n)" 

# Replace the build directory path with the install directory

t4 = re.sub(r'^PATH_VALUES.*?^\)',t3, t, flags=re.MULTILINE | re.DOTALL)

# Want to recreate the file. Conda can create a hardlink from a cached value,
# which is a problem if we update was is in the cache
os.unlink(fname)
fh = open(fname, 'w')
print(t4, file=fh)


