We have the packages as LFS files in the JPL github, but too large for public github.

Grab updates by:

    git checkout remove-large-file
	git merge master
	git rm -r afids-*-Linux-x86_64.sh afids-conda-channel
	(look for any other large files to remove)
	git commit -a -m "Remove large files before pushing to public github. We'll attach th construtor and channels as release artifacts because of the size."
	git checkout master-public
	git merge --squash --allow-unrelated-histories remove-large-file
	git commit
	git push origin master-public
	git push origin-public master-public:master
	git checkout master
	
