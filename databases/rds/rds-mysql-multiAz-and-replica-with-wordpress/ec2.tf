
resource "aws_instance" "web_wordprees_instance" {
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.regra_http_ssh.id]
  subnet_id = module.criar_vpcA_regiao1.subnet_a_id
  ami = data.aws_ami.amazonLinux_regiao1.id

  key_name = aws_key_pair.keyPairSSH_1.key_name

  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  associate_public_ip_address =  true

  provider = aws.primary

  /*user_data = base64encode(<<EOF
        #!/bin/bash
        yum update -y
        # Instalação do SSM Agent
        yum install -y https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm

        yum install httpd php php-mysql unzip -y
        cd /var/www/html
        echo "Servidor Funcionando" > funcionando.html
        wget https://wordpress.org/wordpress-5.1.1.tar.gz
        tar -xzf wordpress-5.1.1.tar.gz
        cp -r wordpress*//* /var/www/html/
        rm -rf wordpress
        rm -rf wordpress-5.1.1.tar.gz
        chmod -R 755 wp-content
        chown -R apache:apache wp-content
        wget https://s3.amazonaws.com/bucketforwordpresslab-donotdelete/htaccess.txt
        mv htaccess.txt .htaccess
        service httpd start
        chkconfig httpd on


        # Navegar até o diretório de plugins do WordPress Plugin HyperDB
        cd /var/www/html/wp-content/plugins
        EOF*/

        user_data = base64encode(<<-EOF
#!/bin/bash

# Atualiza os pacotes do sistema
yum update -y

amazon-linux-extras enable php8.2
yum clean metadata
# Instala Apache, PHP 7 e outras dependências necessárias
yum install -y httpd php php-mysqlnd php-fpm php-json unzip

# Inicia o serviço Apache e configura para iniciar no boot
systemctl start httpd
systemctl enable httpd

# Baixa a última versão do WordPress
wget https://wordpress.org/latest.tar.gz -O /var/www/html/latest.tar.gz
tar -xzf /var/www/html/latest.tar.gz -C /var/www/html
mv /var/www/html/wordpress/* /var/www/html/

# Baixe o WP-CLI phar (PHP Archive) para /usr/local/bin
sudo curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Torne o arquivo wp-cli executável
sudo chmod +x /usr/local/bin/wp

WP_KEYS=$(curl https://api.wordpress.org/secret-key/1.1/salt/)

# Cria o arquivo wp-config.php com as configurações do banco de dados
cat <<EOL > /var/www/html/wp-config.php
<?php
define('DB_NAME', '${local.DB_NAME}');
define('DB_USER', '${local.DB_USER}');
define('DB_PASSWORD', '${local.DB_PASSWORD}');
define('DB_HOST', '${module.db.db_instance_endpoint}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

// Insere as chaves únicas
$WP_KEYS

\$table_prefix  = 'wp_';

define('WP_DEBUG', false);

/* That's all, stop editing! Happy publishing. */

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOL

# Baixa e configura o HyperDB
# wget https://downloads.wordpress.org/plugin/hyperdb.zip -O /var/www/html/wp-content/plugins/hyperdb.zip
# unzip /var/www/html/wp-content/plugins/hyperdb.zip -d /var/www/html/wp-content/plugins/
# cp /var/www/html/wp-content/plugins/hyperdb/db.php /var/www/html/wp-content/

# Cria o arquivo de configuração do HyperDB
cat <<EOL > /var/www/html/db-config.php
<?php
\$wpdb->save_queries = false;
\$wpdb->persistent = false;
\$wpdb->max_connections = 10;
\$wpdb->check_tcp_responsiveness = true;

// Servidor Master (para escrita)
\$wpdb->add_database(array(
    'host'     => '${module.db.db_instance_address}',     // Host do servidor Master
    'user'     => '${local.DB_USER}',           // Nome de usuário do banco de dados
    'password' => '${local.DB_PASSWORD}',           // Senha do banco de dados
    'name'     => '${local.DB_NAME}',      // Nome do banco de dados
    'write'    => 1,                    // Ativar para escrita
    'read'     => 1,                    // Ativar para leitura
    'dataset'  => 'global',
    'timeout'  => 0.2,
));

// Servidor Replica (para leitura)
\$wpdb->add_database(array(
    'host'     => '${module.replica.db_instance_address}',    // Host do servidor Replica
    'user'     => '${local.DB_USER}',           // Nome de usuário do banco de dados
    'password' => '${local.DB_PASSWORD}',           // Senha do banco de dados
    'name'     => '${local.DB_NAME}',      // Nome do banco de dados
    'write'    => 0,                    // Desativar para escrita
    'read'     => 1,                    // Ativar para leitura
    'dataset'  => 'global',
    'timeout'  => 0.2,
));
EOL

# Adiciona a inclusão do db-config.php no wp-config.php
# sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i require_once(ABSPATH . 'db-config.php');" /var/www/html/wp-config.php

# Ajusta permissões
chown apache:apache -R /var/www/html/
find /var/www/html/ -type d -exec chmod 750 {} \;
find /var/www/html/ -type f -exec chmod 640 {} \;

# Reinicia o Apache para aplicar as mudanças
systemctl restart httpd
        EOF
  )

  tags = {
    Name = "web_wordprees_instance"
  }
}

