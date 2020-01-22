#########################################################################
# File Name: image.sh
# Author: zpengg
# mail: zpengg@yeah.net
# Created Time: 六  1/18 23:22:45 2020
#########################################################################
#!/bin/bash -eu
dir="/Users/yezhanpeng/Documents/blog/image"
remote_dir="http://zpengg.oss-cn-shenzhen.aliyuncs.com"
tmp_file=$(mktemp)
pngpaste $tmp_file

hash=$(md5 < $tmp_file)
img="$hash.png"
mv $tmp_file "$dir/$img"
remote_img="$remote_dir/$img"
echo "![]($remote_img)" | tee >(pbcopy)
