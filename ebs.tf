provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "test" {
  ami               = "ami-01216e7612243e0ef"
  availability_zone = "ap-south-1a"
  instance_type     = "t2.micro"
  ebs_block_device {
    device_name = "/dev/sdb"
    volume_size = "2"
  }
  user_data = <<EOF
#!/bin/bash
pvcreate /dev/sdb
vgcreate test_vg /dev/sdb
lvcreate -n test_lv -L 1.5G test_vg
mkfs -t xfs /dev/test_vg/test_lv
mkdir /test
mount /dev/test_vg/test_lv  /test
EOF

  tags = {
    Name = "HelloWorld"
  }
}


resource "aws_ebs_volume" "test" {
  availability_zone = "ap-south-1a"
  size              = 10

  tags = {
    Name = "/dev/sdc"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.test.id
  instance_id = aws_instance.test.id
  force_detach = true
}





