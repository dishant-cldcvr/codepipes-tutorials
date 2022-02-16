resource "aws_db_subnet_group" "database" {
  depends_on =[aws_subnet.dbsubnet]
  name       = "aws_db_subnet_group-demo-${random_string.role.id}"
  subnet_ids = aws_subnet.dbsubnet[*].id
  tags = {
    Name = "DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  identifier        = "db-demo-${random_string.cluster.id}"
  depends_on        = [aws_security_group.dbsg]
  storage_type      = "gp2"
  #DB Network
  vpc_security_group_ids = [aws_security_group.dbsg.id]
  db_subnet_group_name  =  aws_db_subnet_group.database.name
  publicly_accessible = false
  # Storage Allocation
  max_allocated_storage = 20
  allocated_storage    = 10
  #Type, version of DB and Instance Class to use
  engine               = "postgres"
  engine_version       = "11.11"
  instance_class       = "db.t3.micro"
  #Credentials
  name                 = "postgres"
  username             = "postgres"
  password             = "postgres"
  iam_database_authentication_enabled = true
  #Setting this true so that there will be no problem while destroying the Infrastructure as it won't create snapshot
  skip_final_snapshot  = true
  #Backup and protection
  backup_retention_period = 1
  storage_encrypted       = true
  deletion_protection     = var.enable_db_deletion_protection
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

resource "aws_security_group" "dbsg" {
  depends_on =[aws_subnet.dbsubnet]
  name        = "db-${random_string.role.id}"
  description = "security group for db"
  vpc_id      = aws_vpc.demo.id


  # Allowing traffic only for Postgres and that too from same VPC only.
  ingress {
    description = "POSTGRES"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.cluster_ipv4_cidr]
  }


  # Allowing all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}
