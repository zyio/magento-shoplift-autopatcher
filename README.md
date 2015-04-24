Magento Shoplift Autopatcher
============================

A bash script to find sites vulnerable to the magento bug dubbed `shoplift` and apply the magento-provided patch `SUPEE-5344`.

Should run on any system that runs yum or apt, or feasibly any system that already has `patch` or `sed` already installed.

Run `main.sh` like so:

  `bash main.sh`

Although it's hardly advisable, you can download and run it all in one go like this:

  `curl -s https://raw.githubusercontent.com/zyio/magento-shoplift-autopatcher/master/main.sh|bash`

