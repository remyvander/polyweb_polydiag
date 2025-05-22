## 3 Polyweb

PolyWeb is a web-based platform designed for the centralized visualization and interpretation of genomic variants derived from high-throughput sequencing (WES, WGS, RNA-seq, etc.). Built to support rare disease diagnostics and cohort-based research, PolyWeb integrates variant-level annotations, expression data, and cohort comparisons within a unified interface. It features tight integration with public databases (gnomAD, ClinVar, OMIM) and internal tools such as PolyQuery (for cohort-wide queries), DejaVu (for variant recurrence analysis), and modules for splice prediction, expression outliers, and gene prioritization. 

PolyWeb enables collaborative, iterative exploration of variant data and supports use cases ranging from routine diagnostics to exploratory research.

The platform is primarily written in Perl, and due to its broad functionality and multiple modules, it constitutes a relatively large and complex codebase.

If you are interested in deploying PolyWeb in your own environment, you are welcome to contact us for installation support at bioinformatique@users-imagine.fr.

### 3.1 Creating PolyWeb from Scratch

#### 3.1.1 Prerequisites

1. **Pull from DockerHub**:
    - Download the image using the command:
      ```sh
      docker pull imaginebioinfo/polyweb:V3
      ```

Before continuing, create a Docker group, `polyweb` and `mysql`, as well as two users `polyweb` and `mysql`:
```sh
sudo groupadd docker
sudo groupadd polyweb -g 9999
sudo useradd polyweb -u 9999 -g polyweb -G docker -m -p "mypassword" -s "/bin/bash"
sudo groupadd mysql -g 27
sudo useradd mysql -u 27 -g mysql -M
```

Now create the source directory for polyweb, which will serve as the source for the entire installation:
```sh
sudo mkdir /poly-disk
sudo chown polyweb:polyweb /poly-disk
```

### 3.1.2 Configuration of polyweb-core.cfg

The configuration file `polyweb-core.cfg` is located in `polyweb-install/conf/polyweb-core.cfg`.

Modify the `SOURCE` parameter to point to the base path of `poly-disk`: `SOURCE/poly-disk`.

Once this configuration is complete, run the installation script:
```sh
/polyweb-install/install/install-polyweb.sh
```

This script will create the directory structure and symbolic links.

### 3.1.3 Database Configuration

#### 3.1.3.1 Installing MariaDB

Install MariaDB on your system. On a Debian or Ubuntu-based system, use the following commands:
```sh
sudo apt-get update
sudo apt-get install mariadb-server
```

Ensure that the MariaDB service is running:
```sh
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

#### 3.1.3.2 Creating the User

Connect to MariaDB:
```sh
sudo mysql -u root
```

Run the following commands in the MariaDB shell:
```sql
CREATE USER 'polyweb'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'polyweb'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

#### 3.1.3.3 Loading Database Schemas

Download or place the `sql-dumps.tar` archive on your system, then extract its contents:
```sh
tar -xvf sql-dumps.tar
```

To load each dump into MariaDB, use the following command (adjust based on your SQL file names):
```sh
mysql -u polyweb -p < file_name.sql
```

For example:
```sh
mysql -u polyweb -p < PolyprojectNGS_schema.sql
```

Repeat this process for each file in the archive to load all necessary schemas.

### 3.1.3.4 Loading a SQL Procedure for the `polyprojectNGS` Table

Load the procedure into MariaDB with the following command:
```sh
mysql -u polyweb -p < new_project.sql
```

You can also verify that the procedure was created by connecting to MariaDB:
```sh
sudo mysql -u polyweb -p
```

And listing the available procedures:
```sql
SHOW PROCEDURE STATUS WHERE Db = 'polyprojectNGS';
```

### 3.1.4 Starting the Polyweb Server

To start the Polyweb server, follow the steps below:

Run the `start_services.sh` script:
```sh
./start_services.sh
```

If the container fails, you need to access the container:

Access the container:
```sh
docker exec -it <container_name> /bin/bash
```

Delete the `http.pid` file if it exists:
```sh
rm -f /var/run/http.pid
```

Restart the HTTP server in foreground mode:
```sh
/usr/bin/httpd -DFOREGROUND
```

You should now be able to access the Polyweb interface on port 8989 of your machine.

(Note: you will need to create a user in the database to log in to Polyweb)
