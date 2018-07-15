# FreeBSD ZFS-enabled packer
To use:

- Install packer
- Install AWS cli tools
- Set up user access keys on your AWS account

Note
  The product-code filter for FreeBSD in the aws-marketplace differs based
  on the major relase version. Add the following line as necessary to the
  "filters" in fbsdzfs-base.json, or leave out altogether (not recommended,
  but this is the default for friendly use). 

  - For FreeBSD 10 Releases: "product-code": "dxlde6kbuza4cb7ero2ny5lqj"
  - For FreeBSD 11 Releases: "product-code": "b5c1v52b2tam17wi8krmj4e77"

With all this done, just run:

    ./build_img 11.2-RELEASE

For using with alternate AWS profiles, pass in as an evironment variable,
e.g.:

    env AWS_PROFILE=dev_vpc ./build_img 11.0-RELEASE
