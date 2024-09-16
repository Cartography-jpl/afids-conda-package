mkdir -p "$PREFIX"/afids/pommos
cp *.upf *.pdf *.sh "$PREFIX"/afids/pommos
# Not sure why, but doing a direct pip install doesn't work. Seems
# to be fine if we install from source though
tar -xf "$RECIPE_DIR"/ttkbootstrap-1.9.0.tar.gz
pip install ./ttkbootstrap-1.9.0
tar -xf "$RECIPE_DIR"/tkinterweb-3.15.5.tar.gz
pip install ./tkinterweb-3.15.5

mkdir -p "$PREFIX"/bin/
cp "$RECIPE_DIR"/pommos-post-link.sh "$PREFIX"/bin/.pommos-post-link.sh

