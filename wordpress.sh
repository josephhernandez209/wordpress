sudo apt update
sudo apt install -y apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip \
                 sendmail
                 
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

cat <<- EOF | sudo tee /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite wordpress

sudo a2enmod rewrite

sudo a2dissite 000-default

sudo service apache2 reload

sudo mysql -u root -e 'CREATE DATABASE wordpress;'

sudo mysql -u root -e 'CREATE USER wordpress@localhost IDENTIFIED BY "joe";'

sudo mysql -u root -e 'GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON wordpress.* TO wordpress@localhost;'

sudo mysql -u root -e 'FLUSH PRIVILEGES;'

sudo service mysql start

# write wp-config.php
cat <<-'EOF' | sudo tee /srv/www/wordpress/wp-config.php 
<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the installation.
 * You don't have to use the web site, you can copy this file to "wp-config.php"
 * and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * Database settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://wordpress.org/documentation/article/editing-wp-config-php/
 *
 * @package WordPress
 */

// ** Database settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'wordpress' );

/** Database username */
define( 'DB_USER', 'wordpress' );

/** Database password */
define( 'DB_PASSWORD', 'joe' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**#@+
 * Authentication unique keys and salts.
 *
 * Change these to different unique phrases! You can generate these using
 * the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}.
 *
 * You can change these at any point in time to invalidate all existing cookies.
 * This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
 define('AUTH_KEY',         'F;N4rmte4h)lC^-Y)EPYR5P~jSvXuC[2AbZ;yYc8nIdaI^MBZa4##)pW:aR8s3DL');
define('SECURE_AUTH_KEY',  'LA%YBFugUDClK1kGDuu%P<`+P_%>[-Q#z}Fi/pXHhh]+?2igD*SA2+Bkp3-GMuL|');
define('LOGGED_IN_KEY',    '33h27oq9iSA|HM:Q1_StXo~]N[b@Q*0Okzn4|_:;E(9d+w#t&?RoXSTBV=ECPg4j');
define('NONCE_KEY',        '[+}>:a msn&:&|~^*a#>{n+&>D9?67ukN]O#.gQ/[)n)k{h:Ir{bXhs0t.]XyXee');
define('AUTH_SALT',        'qiz8^-fbZf2=nau1:jR*`GXx[;3<Ti&500*`lw`)081q|8{|y-V$edI3]0Pa~NP ');
define('SECURE_AUTH_SALT', ';K;p`tC)}+Di*=|RV*M)&c}a.c`(98d8Lj*g!GTG:f]*&/*O:q:h-.S`Z-b).l@L');
define('LOGGED_IN_SALT',   'H_}+&VoWanQ|xU7s9+[s=~0p4ClKzzFLmV,nPSC+(C-0JN`}F/:?mnUr9=hL0MSb');
define('NONCE_SALT',       'i+uB/%uJO+ [2/~EyzQ9Lg=t~5|<]CO*z86NJ?M^w%{gzS>e&1-j|rV[h:aBSk0[');

/**#@-*/

/**
 * WordPress database table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 *
 * For information on other constants that can be used for debugging,
 * visit the documentation.
 *
 * @link https://wordpress.org/documentation/article/debugging-in-wordpress/
 */
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

EOF

echo "http://$(hostname -I | awk '{print $1}')/wp-login.php"

# install wordpress cli 
if (wp --info)
then 
  echo "wp-cli already installed"
else
  echo "installing wp-cli"
  curl -OJL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  sudo install -o root -g root -m 0755 wp-cli.phar /usr/local/bin/wp
fi

sleep 10

wp core install --url=$(hostname -I | awk '{print $1}') --title=Example --admin_user=joe --admin_password=joe --admin_email=info@example.com --path=/srv/www/wordpress

sudo wp plugin update --all --path=/srv/www/wordpress --allow-root
 
# install cloudflared for tunnel

if (stat cloudflared-linux-amd64.deb )
then 
  echo "cloudflared-linux-amd64.deb already downloaded"
else
  echo "downloading cloudflared-linux-amd64.deb"
  curl -OJL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb 
fi

if (cloudflared --version)
then 
  echo "cloudlfared already installed"
else
 echo "installing cloudflared"
 sudo dpkg -i cloudflared-linux-amd64.deb
fi

if (cloudflared tunnel token 209bits)
then  
  echo "cloudflare tunnel already authenticated"
else
  echo "authenticating cloudflare tunnel"
  cloudflared tunnel login 
fi

if (systemctl is-active cloudflared)
then 
  echo "cloudflared service already active"
else
  echo "activating cloudflared service"
  sudo cloudflared service install $(cloudflared tunnel token 209bits)
fi

if (wp plugin get woocommerce --path=/srv/www/wordpress)
then 
  echo "woo plugin already installed"
else
  echo "installing woo"
  sudo wp plugin install woocommerce --activate --path=/srv/www/wordpress --allow-root
fi  