# Basic support for determining what packages we have, and doing some basic
# package functionality
import json
import subprocess
import pickle
import pandas as pd
import sys
import os
import requests

class PackageSet(dict):
    '''A package set, which is really just a dict with some extra
    functions. Not 100% sure this should be a class instead of just some
    functions, but for now we'll organize this this way.

    The dictionary has keys that are tuples of the package, version, and build
    (e.g., ('libgomp', '12.2.0', 'h65d4601_19')), and maps to other metadata
    '''
    def ingest_index(self, fname):
        '''Ingest a conda index file, and add it to this PackageSet'''
        t = json.load(open(fname,"rb"))
        for v in t["packages"].values():
            self[(v["name"],v["version"],v["build"])]=v
        for v in t["packages.conda"].values():
            self[(v["name"],v["version"],v["build"])]=v

    def save_pickle(self, fname):
        pickle.dump(self, open(fname, "wb"))

    def delta_set(self, base):
        '''Return a new PackageSet that just contains packages found in
        this one but not another base set. This can be used to calculate what
        new packages we need to download.'''
        pset = set(self.keys()) - set(base.keys())
        res = PackageSet()
        for k in pset:
            res[k] = self[k]
        return res

    def append(self, a):
        '''Extend this package set with packages found in a second
        PackageSet,'''
        pset = set(a.keys()) - set(self.keys())
        for k in pset:
            self[k] = a[k]

    @classmethod
    def load_pickle(cls, fname):
        return pickle.load(open(fname,"rb"))

    @classmethod
    def from_text_file(cls, fname):
        '''Get the package list from a text file.'''
        t = pd.read_csv(fname, sep=' ', comment="#",
                        names=["name", "version", "build", "subdir"])
        res = cls()
        for r in t.to_numpy():
            res[(r[0],r[1],r[2])] = {
                'name' : r[0],
                'version' : r[1],
                'build' : r[2],
                'subdir' : r[3]
            }
        return res

    @classmethod
    def from_conda_env(cls, conda_env):
        '''Create a PackageSet from the given conda environment'''
        if(conda_env is None):
            t = subprocess.run(["conda","list","--json"], capture_output=True)
        else:
            t = subprocess.run(["conda","list","--json","-n", conda_env],
                               capture_output=True)
        t = json.loads(t.stdout)
        res = cls()
        for v in t:
            res[(v['name'], v['version'],v["build_string"])] = {
                'name' : v['name'],
                'version' : v['version'],
                'build' : v['build_string'],
                'subdir' : v['platform'],
                'channel' : v['channel'],
                'dist_name' : v['dist_name']
                }
        return res

    def base_fname(self,k):
        '''Return the base filename for the given key, without the
        directory/front url or extension'''
        return f"{self[k]['subdir']}/{k[0]}-{k[1]}-{k[2]}"

    def report(self, file=sys.stdout):
        '''Print out a report of what is in a package set'''
        for channel in ("defaults", "conda-forge"):
            print(channel, file=file)
            print("--------", file=file)
            print(f"{'package':<25} {'version':>10} {'build':>20} {'subdir':<10} ",file=file)
            print(f"{'-------':<25} {'-------':>10} {'-----':>20} {'------':<10} ",file=file)
            for k in sorted(self.keys()):
                t = self[k]
                if(t["channel"] == channel):
                    print(f"{t['name']:<25} {t['version']:>10} {t['build']:>20} {t['subdir']:<10} ",file=file)
            print("",file=file)

    def download_url(self,k, channel=None, extension=None):
        '''The URL to download the given file.'''
        if(channel is None):
            channel = self[k]['channel']
        if(extension is None):
            extension = self[k]['extension']
        if channel == "defaults":
            url = "https://repo.anaconda.com/pkgs/main"
        elif channel == "conda-forge":
            url = "https://conda.anaconda.org/conda-forge"
        else:
            raise RuntimeError(f"Unknown channel {channel}")
        url = f"{url}/{self.base_fname(k)}.{extension}"
        return url

    def local_channel_fname(self, k, basedir):
        '''The file name in a local channel from the given basedir'''
        return f"{basedir}/{self.base_fname(k)}.{self[k]['extension']}"

    def local_channel_fname_and_extension(self, k, basedir):
        '''Like local_channel_fname, but determines which extension to use.'''
        if('extension' in self[k]):
            return self.local_channel_fname(k,basedir)
        for extension in ('conda', 'tar.bz2'):
            self[k]['extension'] = extension
            if(os.path.exists(self.local_channel_fname(k,basedir))):
                return self.local_channel_fname(k,basedir)
        del self[k]['extension']
        return None
    
    def download_all(self, basedir):
        '''Download all the files. We don't clobber existing files, this
        just downloads any files that aren't already there.'''
        self.fill_in_extra()
        subprocess.run(["mkdir","-p", f"{basedir}/linux-64"])
        subprocess.run(["mkdir","-p", f"{basedir}/noarch"])
        for k,v in self.items():
            subprocess.run(["wget", "-nc", "-O",
                            self.local_channel_fname(k,basedir),
                            self.download_url(k)])

    def fill_in_extra(self, remove_failure=False):
        '''Go through all the keys and fill in the channel and extension.
        remove_failure can be set to True when bootstrapping, it can
        filter out afids packages before we've built them.'''
        kdel = []
        for k in self.keys():
            try:
                self.determine_channel_and_extension(k)
            except RuntimeError:
                # Can manually set to True when bootstrapping, to
                # filter out afids packages
                if remove_failure:
                    kdel.append(k)
                else:
                    raise
        if remove_failure:
            for k in kdel:
                del self[k]

    def determine_channel_and_extension(self,k):
        '''Fill in a 'channel' and 'extension' field. The 'channel' will
        be 'defaults' or 'conda-forge', the 'extension' will be 'conda'
        or 'tar.bz2'. We just try each variation of this, and see what
        actually exists.

        If channel and extension are already filled in, this is a no-op
        and just returns.'''
        if('channel' in self[k] and 'extension' in self[k]):
            return
        for channel in ('defaults', 'conda-forge'):
            for extension in ('conda', 'tar.bz2'):
                r = subprocess.run(['wget','-q', "--spider",
                                    self.download_url(k, channel=channel,
                                                      extension=extension)])
                if(r.returncode == 0):
                    self[k]['channel'] = channel
                    self[k]['extension'] = extension
                    return
        raise RuntimeError(f"We didn't find the channel and extension for {k}")

    def upload_to_anaconda(self, basedir, channel_name):
        '''Upload all packages to the  given channel. Skip files already there.'''
        # Note, somewhat confusingly there is a anaconda completely unrelated to this
        # that redhat and feodora uses. This anaconda can be installed as
        # "conda install anaconda-client"
        palready = self.packages_in_channel(channel_name)
        for k,v in self.items():
            f = self.local_channel_fname_and_extension(k, basedir)
            if(os.path.basename(f) not in palready):
                subprocess.run(["anaconda", "upload", "--user", channel_name, f])

    def packages_in_channel(self, channel_name):
        '''Return a set of all the files already in an anaconda channel (e.g.
        cartography-jpl. This can be used when uploading new package to skip ones
        we already have.'''
        res = set()
        for subdir in ('linux-64', 'noarch'):
            t = requests.get(url=f"https://conda.anaconda.org/{channel_name}/{subdir}/repodata.json")
            f = t.json()
            res |= set(f["packages"].keys())
            res |= set(f["packages.conda"].keys())
        return res
                    
                
        
            
    
    
