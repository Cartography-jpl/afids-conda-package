import tempfile
import subprocess
import os

class PackageModify:
    '''Modify files in a existing package.'''
    def __init__(self, tname):
        '''Open the given tar file for modifying'''
        self.tdir = tempfile.TemporaryDirectory()
        self.tname = tname
        # We use the new cph command instead, because this handles both tar.bz2
        # file and the newer .conda format. If you don't have this, you
        # can install it from https://github.com/conda/conda-package-handling/
        #subprocess.run(["tar","-xf", self.tname, "--directory", self.tdir.name], check=True)
        subprocess.run(["cph","x", self.tname, "--prefix", self.tdir.name, "--dest", "."], check=True)

    def close(self):
        '''Write out updated tar file'''
        #subprocess.run(["tar","-cjf", self.tname, "--directory", self.tdir.name, "."], check=True)
        subprocess.run(["cph","c", "--out-folder", os.path.dirname(self.tname), self.tdir.name, os.path.basename(self.tname)], check=True)
        self.tdir.cleanup()

    def sed(self, filename="info/index.json", sed_command='s/libiconv >=1.16,<1.17.0a0/libiconv >=1.16,<2.0.0a0/'):
        '''Run sed on the given relative file (e.g., info/index.json).'''
        subprocess.run(["sed", "-i", sed_command, f"{self.tdir.name}/{filename}"])
        
        
