#########################################
# CONFIGURATION OF MYSQL CONTAINER
#########################################

# Password of MySql root account
# Warning: This option must not be modified after the first installation
# Type: alphanumeric
MYSQL_ROOT_PASSWORD=3cUkjiKgVJgKLqx1lR1QyqSmbGkoRghZ0pas6rRXcxsSnKkktDYmqY2oiuxscHoG

# User account used for db access
# Warning: This option must not be modified after the first installation
# Type: alphanumeric
MYSQL_USER=samourai

# Password of of user account
# Warning: This option must not be modified after the first installation
# Type: alphanumeric
MYSQL_PASSWORD=u7ARjl8VbKg4ta7SoKmQWXF1vvgwFLneqmgoF77w0KejXWZKUv2T3v5VNS92vNY1

# MySQL configuration profile
#   default = default configuration parameters
#   low_mem = configuration minimizing the RAM consumed by the database
# Values: default | low_mem
MYSQL_CONF_PROFILE=default