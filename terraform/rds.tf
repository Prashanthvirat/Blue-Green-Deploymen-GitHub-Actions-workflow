resource "aws_db_subnet_group" "rds_subnet" {
  name       = "strapi-rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]
}

resource "aws_db_instance" "strapi" {
  identifier         = "strapi-prod-db"
  engine             = "postgres"
  engine_version     = "15"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  username           = "postgres"
  password           = "StrapiPassword123!"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot = true
}