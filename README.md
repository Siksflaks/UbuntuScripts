These are some scripts i made to help with the maintenance of a server i have

main.sh is like a little menu with a few options

backup.sh is an automated backup script that you can run via crontab
it will create a backup of given target every hour, day, week, month and year.
it will keep:
24 Hour backups, so oldest get deleted
7 Day backups
52 week backups
24 month backups
year backup limit not set
