<?php
/**
 * GLPI stores some data in the files directory, the database access configuration is stored in the config directory, etc.
 * To ease the GLPI maintenance, the location of GLPI storage directories can be customized.
 * 
 * There are a few configuration directives you may use to achieve that:
 *
 * GLPI_CONFIG_DIR: set path to the configuration directory;
 * GLPI_VAR_DIR : set path to the files directory;
 * GLPI_LOG_DIR : set path to logs files.
 *
**/

// config
define('GLPI_CONFIG_DIR', '/et/glpi');    // Path for configuration files - make sure is writable by web server user

if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
   require_once GLPI_CONFIG_DIR . '/local_define.php';
}

// config
// defined('GLPI_CONFIG_DIR') or define('GLPI_CONFIG_DIR',     (getenv('GLPI_CONFIG_DIR') ?: '/var/www/html/glpi/etc/glpi'));
// if (file_exists(GLPI_CONFIG_DIR . '/local_define.php')) {
//    require_once GLPI_CONFIG_DIR . '/local_define.php';
// }
// marketplace plugins
// defined('GLPI_MARKETPLACE_ALLOW_OVERRIDE') or define('GLPI_MARKETPLACE_ALLOW_OVERRIDE', false);


// GLPI_VAR_DIR permits to change the storage path of all the GLPI files, but you can adapt the storage path for each kind of files

// runtime data
define('GLPI_VAR_DIR',        '/var/www/html/glpi/files');

define('GLPI_DOC_DIR',        GLPI_VAR_DIR);                  // Path for documents storage
define('GLPI_CACHE_DIR',      GLPI_VAR_DIR . '/_cache');      // Path for cache storage
define('GLPI_CRON_DIR',       GLPI_VAR_DIR . '/_cron');       // Path for cron storage
define('GLPI_GRAPH_DIR',      GLPI_VAR_DIR . '/_graphs');     // Path for graph storage
define('GLPI_LOCAL_I18N_DIR', GLPI_VAR_DIR . '/_locales');    // Path for local i18n files
define('GLPI_LOCK_DIR',       GLPI_VAR_DIR . '/_lock');       // Path for lock files storage (used by cron)
define('GLPI_LOG_DIR',        GLPI_VAR_DIR . '/_log');        // Path for log storage
define('GLPI_PICTURE_DIR',    GLPI_VAR_DIR . '/_pictures');   // Path for picture storage
define('GLPI_PLUGIN_DOC_DIR', GLPI_VAR_DIR . '/_plugins');    // Path for plugins documents storage
define('GLPI_RSS_DIR',        GLPI_VAR_DIR . '/_rss');        // Path for RSS feeds storage
define('GLPI_SESSION_DIR',    GLPI_VAR_DIR . '/_sessions');   // Path for sessions files storage
define('GLPI_TMP_DIR',        GLPI_VAR_DIR . '/_tmp');        // Path for temporary files storage
define('GLPI_UPLOAD_DIR',     GLPI_VAR_DIR . '/_uploads');    // Path for upload storage
define('GLPI_INVENTORY_DIR',  GLPI_VAR_DIR . '/_inventories');// Path for inventory files storage
define('GLPI_THEMES_DIR',     GLPI_VAR_DIR . '/_themes');     // Path for custom themes storage

// log
defined('GLPI_LOG_DIR')         or define('GLPI_LOG_DIR',         '/var/log/glpi');

// use system cron
//define('GLPI_SYSTEM_CRON', true);

// end of downstream.php