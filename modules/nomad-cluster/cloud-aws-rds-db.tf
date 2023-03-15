resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "13.7"
  instance_class       = "db.t3.micro"
  db_name              = "rdsdb"
  username             = "MyUser1"
  password             = "MyPassword1"
  skip_final_snapshot  = true
  publicly_accessible  = true
  allow_major_version_upgrade = false
  db_subnet_group_name = aws_db_subnet_group.rds.name
}

resource "aws_db_subnet_group" "rds" {
  name       = "main"
  #subnet_ids = ["${aws_subnet.public[0].id}","${aws_subnet.public[1].id}"]
  subnet_ids = toset(aws_subnet.public[*].id)
  tags = {
    Name = "My DB subnet group"
  }
}